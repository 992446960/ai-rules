# Harness Status Board

## Current Goal

Bootstrap harness engineering for `__PROJECT_NAME__`.

## Active Workstreams

| ID | Workstream | Owner | Status | Evidence | Next |
|----|------------|-------|--------|----------|------|
| W1 | Entry docs | shared | pending | `AGENTS.md`, `CLAUDE.md` | refine with project specifics |
| W2 | Status + handoff | shared | pending | `docs/harness-status.md`, `docs/handoffs/` | start using for real tasks |
| W3 | Guardrails + hooks | shared | pending | `.claude/settings.json`, `.claude/hooks/`, `scripts/` | add stack-specific checks |
| W4 | Child skills | shared | pending | `.claude/skills/` | validate on first real task |
| W5 | Evals + observability | shared | pending | `evals/`, `observability/` | connect to real runtime evidence |

## Verification

| Command | Purpose |
|---------|---------|
| `bash scripts/bootstrap-verify.sh` | verify bootstrap artifacts and references |

## Risks

- Generic bootstrap commands may not match the actual stack yet
- Release gates need project-specific refinement
- Observability is only a placeholder until wired into the runtime
