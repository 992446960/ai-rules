---
name: harness-engineering
description: Bootstrap harness engineering for a new project. Use only when explicitly asked to initialize repo-level agent scaffolding from PRD, technical docs, or a fresh project brief. Generates AGENTS.md, CLAUDE.md, a status board, handoff flow, guardrails, eval scaffolding, observability placeholders, and child skills under .claude/skills/.
disable-model-invocation: true
---

# Harness Engineering Bootstrap

Use this skill only for project bootstrap or explicit harness initialization.

## Inputs

- The user's PRD, technical documents, or architectural notes
- The current repository contents
- Optional explicit stack hint such as `frontend`, `backend`, or `fullstack`

## Execution Contract

1. Read the user's attached documents and inspect the repository root.
2. Determine the best profile:
   - `frontend`
   - `backend`
   - `fullstack`
3. Read [references/bootstrap-flow.md](references/bootstrap-flow.md).
4. Read the matching profile reference in [references/profiles/](references/profiles/).
5. Run:

```bash
bash .claude/skills/harness-engineering/scripts/scaffold.sh --root . --profile <profile>
```

6. After scaffolding, fill the generated repo files with project-specific details from the PRD and technical docs.
7. Run:

```bash
bash .claude/skills/harness-engineering/scripts/verify-bootstrap.sh --root .
```

8. Summarize:
   - what was created
   - which files still need stack-specific refinement
   - the next command or child skill to use

## Rules

- Treat this as `bootstrap-only`.
- If `.claude/harness-bootstrap.json` already exists, do not silently reinitialize.
- Prefer `repair` or `upgrade` behavior only when the user explicitly asks for it.
- Do not leave the formatting hook swallowing formatter failures.
- Generate these child skills:
  - `task-intake`
  - `review-fix`
  - `release-check`
  - `ui-verify`
  - `handoff`

## References

- [references/generated-skills.md](references/generated-skills.md)
- [references/profiles/frontend.md](references/profiles/frontend.md)
- [references/profiles/backend.md](references/profiles/backend.md)
- [references/profiles/fullstack.md](references/profiles/fullstack.md)
