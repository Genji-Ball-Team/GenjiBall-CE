# Changelog

Notable changes to Genji Ball CE. Add a line under **Unreleased** in your PR. It gets a version number when a release is cut.

## Unreleased

- `main` is now the development branch, and PRs go there. Version branches (`v1.3.2`, …) are release snapshots and variants.
- The release workflow updates an existing release instead of failing when a tag is re-pushed.
- Added the feel-lock: `npm run check` fails when a core ball rule (collision, physics, round flow, dash/deflect timing) changes or moves. `npm run feel-lock:update` records a deliberate change, which needs the `ball feel` label.
- `npm run check` prints the resource budget (global and player variables, subroutines, elements) and fails when one is within 5 of its Workshop limit (elements: within 1,000).
- Documented which parts of the rule order matter (`docs/architecture.md`, "Rule order") and marked the order-sensitive includes in `src/main.opy`.
- Wrote down the ball and player feel policy (`CONTRIBUTING.md`): feel changes go behind a default-off toggle, Default, Tournament and Tournament+ never turn them on and stay identical to v1.3.2, and the variant presets (Rapid, v1, v7, Experimental) may turn one on in its own labelled PR. Added a PR template checkbox and `.github/CODEOWNERS` for the core files.
- Moved Teams (Team Deathmatch) off `main`: removed `18-teams.opy`, the *70 - Teams* settings and the TDM branches in collision and target visuals. It lives on the `v1.3.2T` variant. Free-for-all is unchanged.
- Moved Player rank off `main`: removed `16-player-rank.opy` (placeholder rules that never fired) and freed its player variables. The code is kept on the `feature/player-rank` branch.
- Moved Tombstone off `main`: removed `15-tombstone.opy`, which removed players with specific names from the game. The code is kept on the `feature/tombstone` branch.
- Reorganised `src/` into `config/`, `core/`, `maps/`, `features/` and `ui/` folders. Files were moved and split only; the include order and the compiled Workshop code are unchanged. CODEOWNERS now covers all of `src/core/`.
- Replaced magic numbers with named constants in `src/config/constants.opy` (presets, ball motion, physics engine, anti-ghost, water, mobility, simple HUD, ability ids), e.g. `presetMode != Preset.CUSTOM`. The compiled Workshop code is unchanged.
- Merged the four bounce pad positions into one `bouncePads` array and the four `Controls - Bounce when near pad N` rules into one. Frees global slots 55–57; bounce pads work as before.
- Merged the six Sandbox variables (spawn position, direction, speed, axis, +/-, pos/dir/spd selection) into one `sandboxState` array (`SandboxField` in `src/config/constants.opy`). Frees global slots 91–95; Sandbox works as before.
- Merged the zBozo bot state (behaviour mode, aggression, orbit / ghost dash / edash flags) into one `botState` array (`BotField` in `src/config/constants.opy`) and removed four bot variables that were set but never read (`BozoTracing`, `bozoHasJumped`, `OrbitTolerance`, `IsOrbiting`) and `botJumping`. Frees global slots 79 and 81–89; the bot behaves as before.
- Removed zBozo code that never ran: `roundEndCall` was never set to true, so the behaviour-mode, aggression and orbit rules and the bot's "back off" movement never fired, in v1.3.2 or since. Frees global slot 6; the bot behaves as before. `docs/playing.md` no longer says the bot orbits.
- Merged the six Experimental engine tuning settings ("exp incoming min/max %", "exp homing start %/hold ms/ramp ms", "exp surface homing %") into one `experimentalTuning` array (`ExperimentalTuning` in `src/config/constants.opy`). Frees global slots 103–107; the Experimental engine behaves as before.
- Removed the global `Critalert` variable, which was set to false at start and never read. The player variable of the same name (the Crit slash alert) is unchanged. Frees global slot 96.
- The ball speed HUD is now one text that picks its colour and string by speed band, instead of 16 texts that each re-evaluated `ballSpeed` every tick. Every threshold, colour and joke string is the same. Saves 15 HUD texts and about 200 elements.
- `Map restrictions - water` now loops every tick with `wait()` instead of `wait(0.008)`. The Workshop already clamped 0.008 s up to one tick (0.016 s), so the water push runs exactly as often as before.
- Replaced the decompiler's `goto` jumps with `if`/`else` in the bounce pad effects, the Watermark HUD, the lobby rules (`Check for <2 players`, `Wait for more players`, `Player joins game`) and the abilities description and Target switch. Behaviour is unchanged. The ten gotos left are in feel-locked rules (dash slow, round flow, collision), where an `if` would change the compiled code.

## v1.3.2 (Community Edition import)

- Imported the v1.3.2 Workshop code into this repository.
- Decompiled it to OverPy and split it into feature files under `src/rules/`. The compiled output decompiles back to identical OverPy, so gameplay is unchanged.
- Added documentation, build tooling and CI.
