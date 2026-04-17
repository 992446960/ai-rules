# Generated Child Skills

The bootstrap generates five project-local child skills:

- `task-intake`
  - Turns a new request into scope, risks, acceptance criteria, and status board updates.
- `review-fix`
  - Translates findings into fixes, verification work, and review-report evidence.
- `release-check`
  - Runs release readiness checks and summarizes blockers.
- `ui-verify`
  - Verifies screenshots, DOM flows, responsive behavior, and visible regressions.
- `handoff`
  - Writes a structured handoff document so the next window can continue without chat history.

These skills are intentionally lightweight. They rely on repo-level docs such as `AGENTS.md`,
`CLAUDE.md`, `docs/harness-status.md`, and `docs/handoffs/`.
