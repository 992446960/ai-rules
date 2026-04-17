#!/usr/bin/env bash

set -euo pipefail

root="."

usage() {
  cat <<'EOF'
Usage:
  verify-bootstrap.sh [--root <path>]
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --root)
      root="$2"
      shift 2
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

required_paths=(
  "AGENTS.md"
  "CLAUDE.md"
  "docs/harness-status.md"
  "docs/handoffs/_template.md"
  ".claude/settings.json"
  ".claude/hooks/posttooluse-format.sh"
  ".claude/skills/task-intake/SKILL.md"
  ".claude/skills/review-fix/SKILL.md"
  ".claude/skills/release-check/SKILL.md"
  ".claude/skills/ui-verify/SKILL.md"
  ".claude/skills/handoff/SKILL.md"
  "scripts/check-docs-freshness.sh"
  "scripts/bootstrap-verify.sh"
  "evals/harness/bootstrap-checklist.md"
  "observability/README.md"
  ".claude/harness-bootstrap.json"
)

failures=0

for rel in "${required_paths[@]}"; do
  if [[ ! -e "$root/$rel" ]]; then
    echo "MISSING: $rel"
    failures=$((failures + 1))
  fi
done

if [[ -f "$root/.claude/hooks/posttooluse-format.sh" ]] && grep -Fq '|| true' "$root/.claude/hooks/posttooluse-format.sh"; then
  echo "INVALID: .claude/hooks/posttooluse-format.sh must not swallow formatter failures"
  failures=$((failures + 1))
fi

if [[ -f "$root/AGENTS.md" ]] && ! grep -q 'docs/harness-status.md' "$root/AGENTS.md"; then
  echo "INVALID: AGENTS.md should reference docs/harness-status.md"
  failures=$((failures + 1))
fi

if [[ -f "$root/CLAUDE.md" ]] && ! grep -q 'docs/harness-status.md' "$root/CLAUDE.md"; then
  echo "INVALID: CLAUDE.md should reference docs/harness-status.md"
  failures=$((failures + 1))
fi

if [[ -x "$root/scripts/check-docs-freshness.sh" ]]; then
  if ! (cd "$root" && bash scripts/check-docs-freshness.sh); then
    echo "INVALID: scripts/check-docs-freshness.sh failed"
    failures=$((failures + 1))
  fi
fi

if [[ "$failures" -eq 0 ]]; then
  echo "Bootstrap verification passed."
else
  echo "Bootstrap verification failed with $failures issue(s)." >&2
  exit 1
fi
