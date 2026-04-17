# Bootstrap Flow

This skill scaffolds a harness using six layers:

1. Repo structure stores shared context.
2. Status board and handoff files preserve continuity across windows.
3. Guardrails and hooks reduce drift.
4. Evals determine whether the harness works.
5. Observability makes runtime evidence legible.
6. Long-running protocols connect the pieces into a sustainable loop.

## Bootstrap Order

1. Create repo entrypoints: `AGENTS.md`, `CLAUDE.md`
2. Create shared process docs: `docs/harness-status.md`, `docs/handoffs/`
3. Create guardrails: `.claude/settings.json`, `.claude/hooks/`, `scripts/`
4. Create child skills in `.claude/skills/`
5. Create `evals/` and `observability/` placeholders
6. Write `.claude/harness-bootstrap.json`
7. Verify the generated scaffold

## Bootstrap Mode Rules

- Initialize once.
- Do not overwrite existing files unless `--force` is passed.
- Prefer minimal, editable scaffolding over large generated prose.
- Use project docs to refine the generated files in the same session.
