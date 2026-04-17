#!/usr/bin/env bash

set -euo pipefail

template_root=""
dest_root=""
skill_name=""
project_name=""
profile=""
force=0

usage() {
  cat <<'EOF'
Usage:
  generate-child-skill.sh \
    --template-root <path> \
    --dest-root <path> \
    --skill-name <name> \
    --project-name <name> \
    --profile <frontend|backend|fullstack> \
    [--force]
EOF
}

escape_sed() {
  printf '%s' "$1" | sed -e 's/[\/&]/\\&/g'
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --template-root)
      template_root="$2"
      shift 2
      ;;
    --dest-root)
      dest_root="$2"
      shift 2
      ;;
    --skill-name)
      skill_name="$2"
      shift 2
      ;;
    --project-name)
      project_name="$2"
      shift 2
      ;;
    --profile)
      profile="$2"
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

if [[ -z "$template_root" || -z "$dest_root" || -z "$skill_name" || -z "$project_name" || -z "$profile" ]]; then
  usage >&2
  exit 1
fi

src="$template_root/$skill_name/SKILL.md.tpl"
dest_dir="$dest_root/$skill_name"
dest="$dest_dir/SKILL.md"

if [[ ! -f "$src" ]]; then
  echo "Missing child skill template: $src" >&2
  exit 1
fi

mkdir -p "$dest_dir"

if [[ -e "$dest" && "$force" -ne 1 ]]; then
  echo "SKIP existing $dest"
  exit 0
fi

project_name_esc=$(escape_sed "$project_name")
profile_esc=$(escape_sed "$profile")

sed \
  -e "s/__PROJECT_NAME__/$project_name_esc/g" \
  -e "s/__STACK_PROFILE__/$profile_esc/g" \
  "$src" >"$dest"

echo "CREATE $dest"
