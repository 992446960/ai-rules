# __PROJECT_NAME__ — Harness Guide

## Quick Reference

| Item | Value |
|------|-------|
| Stack Profile | `__STACK_PROFILE__` |
| Status Board | `docs/harness-status.md` |
| Handoff Folder | `docs/handoffs/` |
| Child Skills | `.claude/skills/` |

## Commands

Replace these generic entries with exact project commands after inspecting the repo:

```bash
# bootstrap verification
bash scripts/bootstrap-verify.sh

# add project-specific commands here
# dev:
# build:
# test:
# lint:
```

## Read Order

1. `CLAUDE.md`
2. `AGENTS.md`
3. `docs/harness-status.md`
4. matching `docs/execplans/*.md`
5. matching `docs/review-report/*.md`

## Harness Workflow

- `task-intake` initializes new work and updates the status board.
- `review-fix` turns findings into fixes plus verification evidence.
- `release-check` runs release readiness verification.
- `ui-verify` checks user-visible behavior.
- `handoff` persists continuity for the next agent window.

## Required Refinement

- Fill in exact commands
- Add architecture constraints
- Add stack-specific verification rules
- Add release gates that match the real toolchain
