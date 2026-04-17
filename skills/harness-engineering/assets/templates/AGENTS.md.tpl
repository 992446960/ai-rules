# AGENTS.md — __PROJECT_NAME__

> Cross-window agreement for agents working in this repository.

## Read Order

1. `CLAUDE.md`
2. `AGENTS.md`
3. `docs/harness-status.md`
4. relevant `docs/execplans/*.md`
5. relevant `docs/review-report/*.md`
6. relevant `docs/handoffs/*.md`

## Shared Rules

- Treat repo files as the source of truth, not prior chat history.
- Keep task state explicit: `pending`, `in_progress`, `done`, `verified`, `blocked`.
- `done` means implementation finished; `verified` requires fresh evidence.
- Use `docs/harness-status.md` as the live state board.
- Use `docs/handoffs/` for cross-window continuity.

## Child Skills

- `task-intake` for task setup
- `review-fix` for addressing findings
- `release-check` for release readiness
- `ui-verify` for UI/runtime checks
- `handoff` for structured task handoff

## Verification

- Run `bash scripts/bootstrap-verify.sh`
- Add stack-specific verification commands to `CLAUDE.md`

## Project Profile

- Stack profile: `__STACK_PROFILE__`
