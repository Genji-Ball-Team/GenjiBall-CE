# How the code works

This is a map of the game logic for contributors. It assumes you know roughly what Workshop rules, conditions and actions are. [development.md](development.md) covers the tooling.

## Source layout

`src/main.opy` is the entry point. It `#!include`s everything else **in order**, and include order is rule order. The Workshop runs rules top to bottom, so order matters when several rules react to the same thing. [Rule order](#rule-order) lists exactly which parts of the order matter. The files are grouped into folders by topic, but `main.opy` still includes them in the v1.3.2 rule order, so folders are interleaved there.

| Folder | What goes here |
|---|---|
| `config/` | Custom game settings, variables, Workshop settings and presets, initial values |
| `core/` | Controls timing, lobby and round flow, collision, ball physics. Needs a maintainer's review ([CODEOWNERS](../.github/CODEOWNERS)); most of it is [feel-locked](development.md#feel-lock) |
| `maps/` | Per-map arena setup and map restrictions (boundaries, Workshop Island water and edges) |
| `features/` | Optional modes and tools: duels, tournament, AntiOrbit, tracing, the bot, abilities, sandbox |
| `ui/` | HUD text and visual effects |

| File | Contents |
|---|---|
| `config/constants.opy` | Named values (OverPy `enum`s) for presets and the preset and map table columns, ball motion, physics engine, anti-ghost, water, mobility, `simpleHUD` and ability ids. They compile to the same numbers |
| `config/lobby.opy` | Lobby, game mode, hero and extension settings (the part of the export that isn't rules) |
| `config/variables.opy` | Every global/player variable and subroutine, with its **fixed index**, plus active extensions |
| `config/workshop-settings.opy` | Reads the Workshop settings and applies presets |
| `maps/arenas.opy` | Arena center and size per map (the map table), and `isIsland` |
| `config/initialization.opy` | Initial variable values, map sphere, bounce pads, mobility, match length |
| `ui/hud.opy` | All HUD text, debug overlays, kill tracker |
| `ui/effects.opy` | Ball/target visuals, spawn countdown text |
| `core/lobby.opy` | Waiting for 2+ players, starting the first round, handling joins |
| `core/controls.opy` | Dash/deflect input, cooldowns, perspective, simple HUD, anti-rubberbanding, double sens, bounce pads |
| `core/round-flow.opy` | Round start, ball spawn, final duel, round win, tiebreakers, end of match, choosing a target |
| `features/duels.opy` | Duel mode and its queue |
| `core/collision.opy` | Ball-reaches-player detection, deflect/dash handling, retargeting, deaths |
| `core/ball-physics.opy` | The four motion modes and three physics engines, anti-ghost, wall/floor/water bounces (including the Workshop Island and Chamber bounces, which are feel-locked and order-sensitive, so they stay in `core/`) |
| `maps/restrictions.opy` | Center exclusion zone, arena boundary, Workshop Island water and edges |
| `features/tournament.opy` | Round counting, breaks, tournament-only restrictions |
| `features/anti-orbit.opy` | AntiOrbit pressure/heat system |
| `features/tracing.opy` | Tracing mode |
| `features/bot-zbozo.opy` | The zBozo practice bot's AI |
| `features/abilities.opy` | Custom abilities (super jump, switch target, blink, crit slash) |
| `features/sandbox.opy` | Sandbox practice tools |
| `features/abilities-experimental.opy` | A disabled crit-slash rule (last only because it was last in v1.3.2; it has no order constraint) |

The file table is in include order. When you add a file, include it in `main.opy` at the place its rules need to run, and add it here.

## The core loop

```
       ┌──────────────── Wait for more players ─────────────────────┐
       │  2+ players (or Sandbox)                                   │
       ▼                                                            │
  startRound() ── randomTarget() ── countdown (ballSpawnCountdown)  │
       │                                                            │
       ▼  countdown hits 0                                          │
  "Active game - spawn ball" → startBall() → motion engine runs     │
       │                                                            │
       ▼  ball within 1.9 m of target's eyes                        │
  collisionTarget()                                                 │
       ├── target deflecting/dashing → redirect ball, +5% speed,    │
       │                               new target = closest to aim  │
       └── otherwise → deflectFail() → kill target, deleteBall(),   │
                                       randomTarget(), respawn in 2s │
       │                                                            │
       ▼  2 players left → setupFinal() (final duel)                │
       ▼  1 player left  → +1 score, maybe tiebreaker, resurrect ───┘
```

### Key state (globals)

| Variable | Meaning |
|---|---|
| `target` | The player the ball is chasing |
| `prevTarget` | Who hit it last (gets kill credit, can't be picked by `randomTarget()`) |
| `ballIsOut` | True while a ball is in play |
| `ballPosition`, `ballDirection`, `ballSpeed` | The ball. There's no entity. The ball is just these variables plus effects drawn at `ballPosition` |
| `ballSpawnCountdown` | Counts down to the next spawn (chased to 0) |
| `RoundInProgress`, `IsEnoughPlayersToStart`, `IsInFinalDuel`, `TieBreakerActive` | Round state flags |
| `circleCenter`, `SphereSize` | Arena center and radius, looked up per map from the map table in `maps/arenas.opy`. A non-zero "arena radius" setting replaces the radius |
| `isIsland` | True on Workshop Island (day or night). Set once in `maps/arenas.opy`. Use it instead of comparing `__getCurrentMap__()` |
| `presetMode`, `ballMotion`, `ballPhysicsMode`, … | Settings from `config/workshop-settings.opy`. Most are named after their Workshop setting. Compare enum settings against `config/constants.opy` (`ballMotion == BallMotion.ASTRO`), not raw numbers |

Per-player: `canDash`, `canDeflect`, `dashOnCooldown` (input gating), `hasMoved` (has spawned into the arena, used to exclude people who haven't really joined yet), `antiRubberbanding`, `simpleHUD` (`SimpleHud.OFF`, `ON`, `ZEN`), `orbit*` (AntiOrbit), `kills` (kill tracker).

See `src/config/variables.opy` for the full list.

## Collision detection

The ball is a point, and it moves fast. The Workshop only evaluates conditions about once per tick (~60 Hz), so a fast ball can skip past a player between checks ("phasing"). Two rules handle this:

- **`Collision - ball reaches player`** fires when `ballPosition` is within "hit radius" (1.9 m by default, `ballFeel`) of the target's eyes.
- **`Collision - collision check`** runs every tick while `ballSpeed` is above "fast ball speed" (150 by default). It also checks **interpolated points** between the previous and current positions (the halfway and quarter points in `phasePosition`, see `PhasePoint`, and the three-quarter point), so a fast ball can't jump over the target.

Both call `collisionTarget()`. That checks whether the target is deflecting (`isUsingAbility2`) or dashing (`isUsingAbility1`), and with tracing mode on, whether they're still tracing. It then either redirects the ball or calls `deflectFail()`.

**Retargeting:** the new target is the living player with the **smallest angle** between the hitter's facing direction and the direction to that player.

## Ball physics

`startBall()` chooses an engine from `ballPhysicsMode` and `ballMotion`:

| Engine / motion | Subroutine | How it moves |
|---|---|---|
| original + modern/rapid | `startModernBall` | Workshop `chaseAtRate` on position, speed and direction. The direction chases "towards target" at `ballDirectionRate` (1.75 modern, 5 rapid by default). Right after a deflect, `ballCurve` raises the rate to 6 for 0.05 s for a sharper curve. These numbers, the hit radius, the +5% per deflect and the deflect window and lockout are the *15 - Ball Feel* settings, in `ballFeel` (fields in `BallFeel`) |
| Legacy+ | `startLegacyPlusBall` | Manual integration every tick (`wait()` loop). No chase |
| experimental | `startExperimentalBall` | Like modern, but deflect direction = facing direction blended with the incoming direction (`REBOUND_INFLUENCE` in `experimentalState`, fields in `ExperimentalField`), and homing strength ramps from the "exp homing start %" setting back to 100%. The six "exp …" settings live in `experimentalTuning` (fields in `ExperimentalTuning`) |
| astro (any engine) | `startAstroBall` | `ballDirection` is a velocity vector with gravity-like pull toward the target, so it orbits |
| retro (any engine) | `startRetroBall` | Chases position directly to the target's eyes. No curve |

**Bounces:**
- `Ball Physics - general collision`: raycasts one step ahead. On a hit it reflects `ballDirection` around the surface normal (Workshop Island uses the simplified side-collision helper).
- `Ball Physics - island collision`: Workshop Island platform floor and sides, using the nearest-surface helpers `simpleIslandCollision` / `simpleIslandSideCollision`.
- `Ball Physics - chamber x/y/z collision`: axis-aligned walls for Workshop Chamber.
- `Ball Physics - water`: flattens the ball's vertical direction when it dips below `waterLevel` outside the island.

**Anti-ghost** only applies to modern motion. It temporarily raises `ballDirectionRate` to 4 when the ball is near the target but not converging.

> **Chase warning:** OverPy reports warnings like *"rule condition will possibly not trigger properly … because the global variable 'ballPosition' is chased"*. This is a known Workshop quirk: conditions on chased variables don't always re-evaluate. Existing rules have worked with it for years. Newer code (e.g. AntiOrbit) avoids it by checking chased variables in the rule body instead of in conditions. Please do the same in new rules.

## Rule order

The order in `src/main.opy` (and inside each file) is still the v1.3.2 order. This section lists the parts of that order that actually change behaviour. **Any rule not listed here can be moved freely.** If you add a rule that reacts to the same variables in the same tick as a rule listed here, add it to this list.

### How the Workshop orders rules

- Every server tick, rules are checked in list order. A variable change made by one rule is seen by rules **later** in the list during the same tick, and by rules **earlier** in the list only on the next tick.
- Rules with no conditions (and no event) all start in the first tick, in list order. So anything that reads a value once at startup must come after the rule that sets it.
- Rules whose condition simply waits for a variable are robust to order: moving them changes timing by at most one tick. They're only listed here when that one tick is visible, or when two rules can fire in the same tick and the first one changes what the second one does.
- Subroutines (`def`) run where they're called (`Call Subroutine`), so where a `def` sits in the file doesn't matter. The subroutines started with `async(...)` (`startBall`, the motion engines, `stopBall`, `ballCurve`) haven't been checked in-game for placement effects; leave them where they are unless you test it.
- Two rules with the same HUD position and sort order are drawn in the order they were created, which is rule order.

### Constraints

Each line reads "A must stay before B". Rules are named as they appear in-game.

**Startup (first tick)**

| Keep before | Why |
|---|---|
| `Settings - Workshop settings` → everything else | It must be the first rule. It reads the Workshop settings and applies presets, and the startup rules below read the results. |
| `Settings - Workshop settings` → `Initialization - global variables` | Init copies `ballSpawnSpeed` into `ballSpeed`, `setballspawncountdownoriginal` ("ball spawn countdown") into `setballspawncountdown` and `ballSpawnCountdown`, `roundsUntilBreak` into `roundsUntilBreakInit`, the "exp incoming min %" value into `experimentalState`, `arenaSettings` into `CenterOffLimitsSize` and `bouncePadConfig`, and picks `ballDirectionRateInit` from `ballMotion` and `ballFeel`. Swapped, the ball would use the pre-preset defaults (0). |
| `Settings - Workshop settings` → `Initialization - Set map` | Set map reads the "arena radius" setting (`arenaSettings`) once. Swapped, every map would keep its own radius. |
| `Settings - Workshop settings` → `HUD - controls text` | The HUD rule reads `addOnSettings` (Sandbox, double sens, custom abilities) once, when it starts. |
| `Settings - Workshop settings` → `HUD - Watermark` | The HUD rule checks the "watermark" setting (`addOnSettings`) once. Swapped, the watermark would never show. |
| `Settings - Workshop settings` → `Initialization - bounce pads`, `Appearance - target effects` | Both read the "red-green colorblind filter" setting (`addOnSettings`) once when they create their effects. Swapped, the filter would be ignored. |
| `Initialization - Set map` → `Initialization - map sphere`, `Initialization - bounce pads` | The bounce pad positions are computed once from `circleCenter`, and the map sphere reads `isIsland` once. |
| `Initialization - player variables` → `Initialization - global variables` | Existing quirk: players who are already in the lobby when the mode starts (usually the host) get `bouncePadCooldown` from `bouncePadConfig` (the `COOLDOWN` field) before that global is set, so they start with 0. Swapping would change that. Treat any fix as a deliberate change. |

**Lobby and round flow**

| Keep before | Why |
|---|---|
| `Check for <2 players` → `Wait for more players` | In Sandbox with one player both conditions are true in the same tick. The check has to reset `IsEnoughPlayersToStart` first, then the wait rule starts the round. |
| `Check for <2 players` → `Active game - check for last player surviving` | When a player leaves a two-player round, both fire in the same tick. The check runs first and clears `IsEnoughPlayersToStart`, which stops the other rule from awarding a round win to the player left behind. |
| `Active game - spawn ball` → `core/collision` and `core/ball-physics` rules | In the tick the ball spawns, `ballPosition`/`ballDirection` are set before the collision and bounce rules look at them. |

**Collision and physics** (these are the rules the feel-lock protects)

| Keep before | Why |
|---|---|
| `Collision - ball reaches player` → `Collision - collision check` | Both can detect the same hit. The single-shot rule handles it first; the check loop then sees the new target and doesn't double-trigger. |
| `Collision - collision check` → `Ball Physics - general collision` | The check reads `ballHitPosition` from the previous tick, then general collision writes this tick's hit. Swapped, the phasing interpolation would use a different point. |
| `core/collision` rules → `core/ball-physics` bounce rules | When a deflect and a wall hit land in the same tick, the deflect sets the new direction first and the bounce reflects that. Swapped, the bounce would be applied to the old direction and then thrown away by the deflect. |
| `Ball Physics - anti ghost correction` → `Ball Physics - general collision`, `Ball Physics - island collision` | Anti-ghost can raise `ballDirectionRate` to 4. With the experimental engine, a surface bounce computes the steering rate in `experimentalState` from `ballDirectionRate`, so in a shared tick the bounce uses the raised rate. |
| `Ball Physics - general collision` → `Ball Physics - chamber x/y/z collision` | On Workshop Chamber both can bounce the ball in the same tick, and a normal-based reflect followed by an axis flip is not the same as the reverse. |
| `Ball Physics - island collision` → `Ball Physics - water` | On Workshop Island their areas overlap in a thin band at the platform edge (|x| or |z| between 20 and 20.2). Island collision flips a downward ball up, and water then no longer triggers. Swapped, water flattens the ball first and island collision picks a side wall instead. |
| `core/collision` → `Tracing mode - gained` / `Tracing mode - lost` | `collisionTarget()` reads `tracingPoints`, so a hit uses the previous tick's tracing state. |
| `core/collision` → `Gb Abilities - 2. Target switch` | A target switch in the same tick as a deflect overrides the deflect's new target. Swapped, the deflect would win. |

The three chamber rules (`x`, `y`, `z`) each flip a different axis, so they can be reordered among themselves.

**Controls** (dash/deflect timing)

| Keep before | Why |
|---|---|
| `Controls - primary fire triggers dash`, `Controls - secondary fire triggers deflect` → `Controls - Shorten deflect length` → `Controls - Ability 1 dash queue`, `Controls - Ability 2 deflect queue` | `Shorten deflect length` re-enables `canDash`/`canDeflect`. The queue rules below it see that in the same tick, the mouse-button rules above it one tick later. That tick is part of how buffered inputs feel. |
| `Controls - Dash cooldown` → `Control - Dash reset` | If a dash starts in the same tick its user earns an elimination, the cooldown sets `dashOnCooldown` first and the reset clears it. Swapped, the reset would be lost. |
| `core/controls` → `maps/restrictions` water rules | `Controls - Dash slow (gravity shift)` and `Map restrictions - water leave` / `island enter` all set gravity. The water rules come later and win in a shared tick. |

**AntiOrbit**

| Keep before | Why |
|---|---|
| `AntiOrbit - no orbit abusing` → `AntiOrbit - track pressure` | When a player becomes the target, both start in the same tick. The sleep timer is computed from the penalty before this tick's pressure is added. |

**HUD**

| Keep before | Why |
|---|---|
| `HUD - controls text` → `HUD - anti rubberbanding hud text` | Both draw on the left at sort order 0, so their rule order is their line order on screen. |

### Free to move

With the constraints above kept, these have no order dependency: `features/duels`, `features/tournament`, `features/bot-zbozo`, `features/sandbox`, `features/abilities-experimental`, the rest of `ui/hud` and `ui/effects`, the rest of `maps/restrictions`, the rest of `features/abilities`, and every `def` that's only called with `Call Subroutine`.

## Settings and presets

`Settings - Workshop settings` is the first rule. It reads every `createWorkshopSetting*`, then, unless the preset is Custom, **overwrites** the core values with the preset's row of the preset table. The table has one row per preset (in `Preset` order) and one column per forced setting (`PresetColumn` in `config/constants.opy`). A `MANUAL` cell leaves the host's value, which is how anti-ghost and AntiOrbit stay manual in most presets. The anti-orbit tuning columns (`ORBIT_SPEED` to `BASIC_ORBIT_TIMER`) are forced as a group: a `MANUAL` in `ORBIT_SPEED` leaves all of `competitiveSettings` manual. Every preset forces "custom ball feel" off (`BALL_FEEL`); with it off, `ballFeel` is replaced by `BALL_FEEL_DEFAULTS`, the v1.3.2 values. It also turns enum settings into concrete numbers (mobility → move/gravity/jump percentages, water → a height, and so on). Mobility = custom keeps the "custom ... %" sliders, which are read straight into `moveSpeed`, `gravity` and `jumpVerticalSpeed`.

When you add a setting:
1. Add a `createWorkshopSetting*` call in the right category, with a sort-order number. The Workshop only allows each setting to be referenced **once**, and setting names must be unique, ignoring case and spacing. So read the setting once, in `Settings - Workshop settings`, into a variable, and use the variable everywhere else. Never read it through a macro used in several places, because each use compiles to another reference. To save global variables, put the setting into an existing array with an enum for its index, like `experimentalTuning` (`ExperimentalTuning`) or `addOnSettings` (`AddOnSetting`).
2. Decide whether presets should force it. If they should, add a `PresetColumn`, a cell to every row of the preset table (`MANUAL` where a preset leaves it alone) and the assignment below the table.
3. Run `npm run docs:settings`, which adds it to the settings table in [hosting.md](hosting.md), and write its description there. See [Settings docs](development.md#settings-docs).

## Maps

`Initialization - Set map` (`maps/arenas.opy`) looks the current map up in the map table once, at start: one row per supported map, with the arena center and radius (`MapColumn` in `config/constants.opy`). Day/night and winter variants have their own row. On any other map there's no arena: the lookup gives no row, so `mapRow`'s radius reads 0 (`MAP_UNSUPPORTED` in the same file). `Initialization - unsupported map` then shows everyone a message with the supported maps, `Wait for more players` (`core/lobby.opy`) never starts a round, `Duels - start game` never starts a duel, and the arena boundary rules (`Map restrictions - player dashes too far out of bounds` and `push to circle`) don't run. The same rule sets `isIsland`, which the Workshop Island water and ledge rules use as a condition.

To add a map, add it to the map list and a row at the same position in the row list, with a radius above 0, and add it to the supported maps in `Initialization - unsupported map`. Only Workshop maps can be enabled while the mode uses Workshop extensions, so Oasis University, King's Row and Blizzard World are commented out there (see [Maps](hosting.md#maps)). If the map has water or ledges like Workshop Island, it needs its own restriction rules.

## Limits to keep in mind

`npm run check` prints how much of each Workshop limit the mode uses, and fails when one gets too close:

| Resource | Workshop limit | `npm run check` fails at |
|---|---|---|
| Global variables | 128 | 5 or fewer left |
| Player variables | 128 | 5 or fewer left |
| Subroutines | 128 | 5 or fewer left |
| Elements | 32,768 | 1,000 or fewer left |
| Extension points | 24 (every extension enabled in `config/variables.opy` is used) | never (reported only; OverPy refuses to compile when they cost too many points) |

Run `npm run check` for the current numbers. The limits and margins live in `tools/budget.mjs`.

Global variable slots are the tightest limit. Reuse existing variables where it makes sense, and never renumber existing ones.

### Server load baseline (v1.3.2)

Measured with the debug HUD (`90 - Debug` → debug HUD) so later changes have something to compare against.

| Setup | Server Load | Server Load Average | Server Load Peak |
|---|---|---|---|
| Full lobby of bots, during a round | bounces 70 to 140–150 | 60–80 | not usable (see below) |

How to read these:

- The HUD values change too fast to record separate numbers for the lobby, final duel and fast ball (300+). The row above covers normal play with bots; treat it as the reference for all states.
- Server Load Peak resets too often to mean anything, so compare Server Load Average and the typical top of Server Load instead.
- Bots were used, not real players. Real players may load the server differently.
- When comparing a change against this baseline, use the same setup: a full bot lobby, mid-round, watching the average for a while.

## Odd bits worth knowing

- **Rule names can't contain "Blizzard"**, so the map rule is called "Blizz World".
- **Player rank** (rank-outline placeholders) isn't on `main`. The code is kept on the `feature/player-rank` branch. Its player variable slots (19–22) are free.
- **Tombstone** (name-based removal of specific players) isn't on `main`. The code is kept on the `feature/tombstone` branch.
- **Teams** (Team Deathmatch support) isn't on `main`. It lives on the `v1.3.2T` variant branch. Its global variable slots (71–74, 108) and subroutine slot 18 are unused on `main`. Keep them that way, or merging `main` into `v1.3.2T` gives two variables the same slot.
