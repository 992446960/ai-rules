---
name: review-fix
description: Address review findings for __PROJECT_NAME__. Use when code review, QA, or runtime findings need to be translated into fixes plus verification evidence.
---

# Review Fix

For `__PROJECT_NAME__`:

1. Read the findings and group them by severity and file.
2. Confirm the expected behavior before editing anything.
3. Apply the smallest coherent fix set.
4. Run the relevant verification commands.
5. Record evidence in `docs/review-report/`.
6. Update `docs/harness-status.md` so the next agent can see:
   - what was fixed
   - what was verified
   - what remains open

Do not mark work as `verified` without fresh evidence.
