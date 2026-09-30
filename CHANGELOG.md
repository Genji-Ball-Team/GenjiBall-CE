# Changelog

Notable changes to Genji Ball CE. Add a line under **Unreleased** in your PR. It gets a version number when a release is cut.

## Unreleased

- `main` is now the development branch, and PRs go there. Version branches (`v1.3.2`, …) are release snapshots and variants.
- The release workflow updates an existing release instead of failing when a tag is re-pushed.
- Added the feel-lock: `npm run check` fails when a core ball rule (collision, physics, round flow, dash/deflect timing) changes or moves. `npm run feel-lock:update` records a deliberate change, which needs the `ball feel` label.
- `npm run check` prints the resource budget (global and player variables, subroutines, elements) and fails when one is within 5 of its Workshop limit (elements: within 1,000).
- Documented which parts of the rule order matter (`docs/architecture.md`, "Rule order") and marked the order-sensitive includes in `src/main.opy`.
- Wrote down the ball and player feel policy (`CONTRIBUTING.md`): feel changes go behind a default-off toggle, no preset turns them on, and Default and Tournament stay identical to v1.3.2. Added a PR template checkbox and `.github/CODEOWNERS` for the core files.
- Moved Teams (Team Deathmatch) off `main`: removed `18-teams.opy`, the *70 - Teams* settings and the TDM branches in collision and target visuals. It lives on the `v1.3.2T` variant. Free-for-all is unchanged.
- Moved Player rank off `main`: removed `16-player-rank.opy` (placeholder rules that never fired) and freed its player variables. The code is kept on the `feature/player-rank` branch.

## v1.3.2 (Community Edition import)

- Imported the v1.3.2 Workshop code into this repository.
- Decompiled it to OverPy and split it into feature files under `src/rules/`. The compiled output decompiles back to identical OverPy, so gameplay is unchanged.
- Added documentation, build tooling and CI.
