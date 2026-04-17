---
name: release-check
description: Run release readiness checks for __PROJECT_NAME__. Use right before release, deployment, or merge-to-main decisions.
disable-model-invocation: true
---

# Release Check

For `__PROJECT_NAME__`:

1. Read `CLAUDE.md`, `AGENTS.md`, and `docs/harness-status.md`.
2. Run the project's build, test, lint, and bootstrap verification commands.
3. Check for unresolved blockers in `docs/harness-status.md`.
4. Confirm that release notes, handoff state, and review evidence are current.
5. Return:
   - release-ready or not-ready
   - failing checks
   - residual risks
   - exact next action
