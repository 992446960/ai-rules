#!/usr/bin/env bash

set -euo pipefail

skill_dir="$(cd "$(dirname "$0")/.." && pwd)"
root="."
profile=""
project_name=""
force=0

usage() {
  cat <<'EOF'
Usage:
  scaffold.sh [--root <path>] [--profile <frontend|backend|fullstack>] [--project-name <name>] [--force]
EOF
}

escape_sed() {
  printf '%s' "$1" | sed -e 's/[\/&]/\\&/g'
}

render_template() {
  local src="$1"
  local dest="$2"

  if [[ ! -f "$src" ]]; then
    echo "Missing template: $src" >&2
    exit 1
  fi

  if [[ -e "$dest" && "$force" -ne 1 ]]; then
    echo "SKIP existing $dest"
    return
  fi

  mkdir -p "$(dirname "$dest")"

  sed \
    -e "s/__PROJECT_NAME__/$(escape_sed "$project_name")/g" \
    -e "s/__STACK_PROFILE__/$(escape_sed "$profile")/g" \
    "$src" >"$dest"

  echo "CREATE $dest"
}

write_file_if_missing() {
  local dest="$1"
  local mode="${2:-0644}"

  if [[ -e "$dest" && "$force" -ne 1 ]]; then
    echo "SKIP existing $dest"
    return
  fi

  mkdir -p "$(dirname "$dest")"
  cat >"$dest"
  chmod "$mode" "$dest"
  echo "CREATE $dest"
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --root)
      root="$2"
      shift 2
      ;;
    --profile)
      profile="$2"
      shift 2
      ;;
    --project-name)
      project_name="$2"
      shift 2
      ;;
    --force)
      force=1
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "Unknown argument: $1" >&2
      usage >&2
      exit 1
      ;;
  esac
done

if [[ -z "$profile" ]]; then
  profile="fullstack"
fi

case "$profile" in
  frontend|backend|fullstack)
    ;;
  *)
    echo "Unsupported profile: $profile" >&2
    exit 1
    ;;
esac

mkdir -p "$root"
root="$(cd "$root" && pwd)"

if [[ -z "$project_name" ]]; then
  project_name="$(basename "$root")"
fi

if [[ -f "$root/.claude/harness-bootstrap.json" && "$force" -ne 1 ]]; then
  echo "Refusing to reinitialize existing harness at $root/.claude/harness-bootstrap.json" >&2
  exit 1
fi

mkdir -p \
  "$root/.claude/skills" \
  "$root/.claude/hooks" \
  "$root/docs/execplans" \
  "$root/docs/review-report" \
  "$root/docs/handoffs" \
  "$root/scripts" \
  "$root/evals/harness" \
  "$root/evals/regression" \
  "$root/observability"

render_template "$skill_dir/assets/templates/AGENTS.md.tpl" "$root/AGENTS.md"
render_template "$skill_dir/assets/templates/CLAUDE.md.tpl" "$root/CLAUDE.md"
render_template "$skill_dir/assets/templates/harness-status.md.tpl" "$root/docs/harness-status.md"

bash "$skill_dir/scripts/generate-child-skill.sh" \
  --template-root "$skill_dir/assets/templates" \
  --dest-root "$root/.claude/skills" \
  --skill-name "task-intake" \
  --project-name "$project_name" \
  --profile "$profile" \
  $([[ "$force" -eq 1 ]] && printf '%s' '--force')

bash "$skill_dir/scripts/generate-child-skill.sh" \
  --template-root "$skill_dir/assets/templates" \
  --dest-root "$root/.claude/skills" \
  --skill-name "review-fix" \
  --project-name "$project_name" \
  --profile "$profile" \
  $([[ "$force" -eq 1 ]] && printf '%s' '--force')

bash "$skill_dir/scripts/generate-child-skill.sh" \
  --template-root "$skill_dir/assets/templates" \
  --dest-root "$root/.claude/skills" \
  --skill-name "release-check" \
  --project-name "$project_name" \
  --profile "$profile" \
  $([[ "$force" -eq 1 ]] && printf '%s' '--force')

bash "$skill_dir/scripts/generate-child-skill.sh" \
  --template-root "$skill_dir/assets/templates" \
  --dest-root "$root/.claude/skills" \
  --skill-name "ui-verify" \
  --project-name "$project_name" \
  --profile "$profile" \
  $([[ "$force" -eq 1 ]] && printf '%s' '--force')

bash "$skill_dir/scripts/generate-child-skill.sh" \
  --template-root "$skill_dir/assets/templates" \
  --dest-root "$root/.claude/skills" \
  --skill-name "handoff" \
  --project-name "$project_name" \
  --profile "$profile" \
  $([[ "$force" -eq 1 ]] && printf '%s' '--force')

write_file_if_missing "$root/.claude/settings.json" 0644 <<'EOF'
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Edit|MultiEdit|Write",
        "hooks": [
          {
            "type": "command",
            "command": "bash \"$CLAUDE_PROJECT_DIR/.claude/hooks/posttooluse-format.sh\""
          }
        ]
      }
    ]
  }
}
EOF

write_file_if_missing "$root/.claude/hooks/posttooluse-format.sh" 0755 <<'EOF'
#!/usr/bin/env bash

set -euo pipefail

project_dir="${CLAUDE_PROJECT_DIR:-$(cd "$(dirname "$0")/../.." && pwd)}"
log_dir="$project_dir/.claude/hook-logs"
log_file="$log_dir/posttooluse-format.log"
payload_file="$(mktemp)"

mkdir -p "$log_dir"
trap 'rm -f "$payload_file"' EXIT

cat >"$payload_file"

target_file="${CLAUDE_FILE_PATH:-}"

if [[ -z "$target_file" && -s "$payload_file" ]]; then
  target_file="$(
    python3 - "$payload_file" <<'PY'
import json
import sys
from pathlib import Path

payload_path = Path(sys.argv[1])
try:
    data = json.loads(payload_path.read_text())
except Exception:
    print("")
    raise SystemExit(0)

tool_input = data.get("tool_input") or {}
tool_response = data.get("tool_response") or {}

candidates = [
    tool_input.get("file_path"),
    tool_input.get("path"),
    tool_response.get("file_path"),
    tool_response.get("filePath"),
]

for candidate in candidates:
    if isinstance(candidate, str) and candidate:
        print(candidate)
        raise SystemExit(0)

print("")
PY
  )"
fi

timestamp() {
  date -u +"%Y-%m-%dT%H:%M:%SZ"
}

if [[ -z "$target_file" ]]; then
  printf '%s SKIP missing-target\n' "$(timestamp)" >>"$log_file"
  exit 0
fi

if [[ ! -f "$target_file" ]]; then
  printf '%s SKIP missing-file %s\n' "$(timestamp)" "$target_file" >>"$log_file"
  exit 0
fi

formatter=""
case "$target_file" in
  *.ts|*.tsx|*.js|*.jsx|*.vue|*.css|*.scss|*.md|*.json|*.html|*.yaml|*.yml)
    formatter="prettier"
    ;;
  *.py)
    formatter="black"
    ;;
  *)
    printf '%s SKIP unsupported %s\n' "$(timestamp)" "$target_file" >>"$log_file"
    exit 0
    ;;
esac

printf '%s FORMAT %s via=%s\n' "$(timestamp)" "$target_file" "$formatter" >>"$log_file"
cd "$project_dir"

case "$formatter" in
  prettier)
    if npx prettier --write "$target_file" >/dev/null 2>&1; then
      printf '%s OK %s via=prettier\n' "$(timestamp)" "$target_file" >>"$log_file"
      exit 0
    fi
    status=$?
    printf '%s ERROR %s via=prettier exit=%s\n' "$(timestamp)" "$target_file" "$status" >>"$log_file"
    exit "$status"
    ;;
  black)
    if command -v black >/dev/null 2>&1 && black "$target_file" >/dev/null 2>&1; then
      printf '%s OK %s via=black\n' "$(timestamp)" "$target_file" >>"$log_file"
      exit 0
    fi
    status=$?
    printf '%s ERROR %s via=black exit=%s\n' "$(timestamp)" "$target_file" "$status" >>"$log_file"
    exit "$status"
    ;;
esac
EOF

write_file_if_missing "$root/scripts/check-docs-freshness.sh" 0755 <<'EOF'
#!/usr/bin/env bash

set -euo pipefail

cd "$(dirname "$0")/.."

doc_files=()
for f in AGENTS.md CLAUDE.md; do
  [[ -f "$f" ]] && doc_files+=("$f")
done
while IFS= read -r file; do
  doc_files+=("$file")
done < <(find docs -name '*.md' -type f 2>/dev/null | sort)

if [[ "${#doc_files[@]}" -eq 0 ]]; then
  echo "Docs freshness check passed: no documentation files found."
  exit 0
fi

stale=0

while IFS= read -r ref; do
  clean="$(printf '%s' "$ref" | sed -E 's/^[<(]+//; s/[>)",;:]+$//; s/:[0-9]+$//')"
  [[ -z "$clean" ]] && continue
  if [[ ! -e "$clean" ]]; then
    echo "STALE: $clean (referenced in docs but not found)"
    stale=$((stale + 1))
  fi
done < <(
  grep -rohE '(\.claude|docs|scripts|evals|observability|src|app|packages|frontend|backend)/[A-Za-z0-9_./:-]+' "${doc_files[@]}" 2>/dev/null | sort -u
)

if [[ "$stale" -eq 0 ]]; then
  echo "Docs freshness check passed: all referenced paths exist."
else
  echo "Found $stale stale reference(s) in documentation." >&2
  exit 1
fi
EOF

write_file_if_missing "$root/scripts/bootstrap-verify.sh" 0755 <<'EOF'
#!/usr/bin/env bash

set -euo pipefail

cd "$(dirname "$0")/.."
bash .claude/skills/harness-engineering/scripts/verify-bootstrap.sh --root .
EOF

write_file_if_missing "$root/docs/handoffs/_template.md" 0644 <<'EOF'
# Handoff Template

## Task

## Current State

## Evidence

## Open Questions

## Next Step
EOF

write_file_if_missing "$root/evals/harness/bootstrap-checklist.md" 0644 <<'EOF'
# Harness Bootstrap Checklist

- Entry files exist and reference the status board
- Child skills exist in `.claude/skills/`
- Formatting hook does not swallow failures
- Docs freshness script passes
- Bootstrap verify passes
EOF

write_file_if_missing "$root/observability/README.md" 0644 <<EOF
# ${project_name} Observability Placeholder

This directory exists so agents can see where runtime evidence should live.

Recommended minimums:

- structured logs
- startup and healthcheck visibility
- one smoke path for user-visible behavior
- screenshots or DOM/runtime evidence for UI-heavy paths
- metrics and traces when the stack supports them
EOF

write_file_if_missing "$root/docs/harness-bootstrap-report.md" 0644 <<EOF
# ${project_name} Harness Bootstrap Report

- Stack profile: ${profile}
- Generated child skills: task-intake, review-fix, release-check, ui-verify, handoff
- Generated entry docs: AGENTS.md, CLAUDE.md, docs/harness-status.md
- Generated guardrails: .claude/settings.json, .claude/hooks/posttooluse-format.sh, scripts/check-docs-freshness.sh
- Generated verification scaffolding: scripts/bootstrap-verify.sh, evals/harness/bootstrap-checklist.md
- Generated observability placeholder: observability/README.md

Next step:

1. Refine AGENTS.md and CLAUDE.md with exact project commands.
2. Add stack-specific tests and release commands.
3. Run \`bash scripts/bootstrap-verify.sh\`.
EOF

write_file_if_missing "$root/.claude/harness-bootstrap.json" 0644 <<EOF
{
  "version": 1,
  "project_name": "$(printf '%s' "$project_name" | sed 's/"/\\"/g')",
  "profile": "$profile",
  "generated_skills": [
    "task-intake",
    "review-fix",
    "release-check",
    "ui-verify",
    "handoff"
  ]
}
EOF

bash "$skill_dir/scripts/verify-bootstrap.sh" --root "$root"
