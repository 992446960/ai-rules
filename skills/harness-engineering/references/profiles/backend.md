# Backend Profile

Use this profile when the repository primarily delivers services, APIs, workers, or data pipelines.

## Biases

- Guardrails should emphasize contract checks, migrations, and service startup validation.
- Observability should prioritize logs, metrics, traces, and health endpoints.
- `ui-verify` still exists, but it is secondary unless the project exposes operator UI.

## Expected Repo Outputs

- `docs/architecture.md` should explain service boundaries and data flow.
- `CLAUDE.md` should list service startup, test, lint, and contract validation commands.
- `observability/README.md` should mention structured logs and tracing points.
