---
name: ui-verify
description: Verify user-visible behavior for __PROJECT_NAME__. Use when a change affects UI, screenshots, layout, browser flows, or runtime-visible regressions.
---

# UI Verify

For `__PROJECT_NAME__`:

1. Read the relevant task plan and `docs/harness-status.md`.
2. Identify the user-visible surfaces changed by the task.
3. Verify:
   - main path behavior
   - visible regressions
   - responsive or layout issues
   - browser console or network failures when available
4. Record concise evidence in `docs/review-report/` or the active handoff doc.
5. If verification is incomplete, state the missing runtime surface explicitly.
