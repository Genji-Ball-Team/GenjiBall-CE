# Changelog

Notable changes to Genji Ball CE. Add a line under **Unreleased** in your PR. It gets a version number when a release is cut.

## Unreleased

- `main` is now the development branch, and PRs go there. Version branches (`v1.3.2`, …) are release snapshots and variants.
- The release workflow updates an existing release instead of failing when a tag is re-pushed.
- Added the feel-lock: `npm run check` fails when a core ball rule (collision, physics, round flow, dash/deflect timing) changes or moves. `npm run feel-lock:update` records a deliberate change, which needs the `ball feel` label.
- Documented which parts of the rule order matter (`docs/architecture.md`, "Rule order") and marked the order-sensitive includes in `src/main.opy`.

## v1.3.2 (Community Edition import)

- Imported the v1.3.2 Workshop code into this repository.
- Decompiled it to OverPy and split it into feature files under `src/rules/`. The compiled output decompiles back to identical OverPy, so gameplay is unchanged.
- Added documentation, build tooling and CI.
