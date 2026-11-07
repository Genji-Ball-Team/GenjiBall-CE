# How the code works

This is a map of the game logic for contributors. It assumes you know roughly what Workshop rules, conditions and actions are. [development.md](development.md) covers the tooling.

## Source layout

`src/main.opy` is the entry point. It `#!include`s everything else **in order**, and include order is rule order. The Workshop runs rules top to bottom, so order matters when several rules react to the same thing. [Rule order](#rule-order) lists exactly which parts of the order matter. The files are grouped into folders by topic, but `main.opy` still includes them in the v1.3.2 rule order, so folders are interleaved there.

| Folder | What goes here |
|---|---|
| `config/` | Custom game settings, variables, Workshop settings and presets, initial values |
| `core/` | Controls timing, lobby and round flow, collision, ball physics. Needs a maintainer's review ([CODEOWNERS](../.github/CODEOWNERS)); most of it is [feel-locked](development.md#feel-lock) |
| `maps/` | Arena setup and map restrictions (boundaries, Workshop Island water and edges) |
| `features/` | Tournament mode, tourneys, the ranked log and rank tags |
| `ui/` | HUD text and visual effects |

| File | Contents |
|---|---|
| `config/constants.opy` | Named values (OverPy `enum`s and `#!define`s) for presets, ball feel, the fixed arena and anti-orbit values, add-ons, the ranked state and `simpleHUD`. They compile to the same numbers |
| `config/lobby.opy` | Lobby, game mode, hero and extension settings (the part of the export that isn't rules) |
| `config/variables.opy` | Every global/player variable and subroutine, with its **fixed index**, plus active extensions |
| `config/workshop-settings.opy` | Reads the Workshop settings and sets the fixed ruleset |
| `features/tourney.opy` | `v1.3.3R` only: tourney matches, with the generated rule `TOURNEY - generated` ([tourney-rule.md](tourney-rule.md)), its settings, holding the ball after the last round, and the final standings. Early because its first two rules change settings in the first tick |
| `maps/arenas.opy` | The arena's center and size (Workshop Island Night only), and the unsupported map message |
| `config/initialization.opy` | Initial variable values, map sphere, mobility, match length |
| `ui/hud.opy` | All HUD text and debug overlays |
| `ui/effects.opy` | Ball/target visuals, spawn countdown text |
| `core/lobby.opy` | Waiting for 2+ players, starting the first round, handling joins |
| `core/controls.opy` | Dash/deflect input, cooldowns, perspective, simple HUD, anti-rubberbanding, double sens |
| `core/round-flow.opy` | Round start, ball spawn, final duel, round win, tiebreakers, end of match, choosing a target |
| `core/collision.opy` | Ball-reaches-player detection, deflect/dash handling, retargeting, deaths |
| `core/ball-physics.opy` | Modern ball motion, the network resync, wall/floor/water bounces (including the Workshop Island bounces, which are feel-locked and order-sensitive, so they stay in `core/`) |
| `maps/restrictions.opy` | Center exclusion zone, arena boundary, Workshop Island water and edges |
| `features/tournament.opy` | Round counting, breaks, tournament-only restrictions, basic anti-orbit |
| `features/ranked-log.opy` | `v1.3.3R` only: the ranked log ([format](ranked-log.md)) |
| `features/rank-tags.opy` | `v1.3.3R` only: rank tags and the top 10 list, with the generated rule `RANKS - generated` ([rank-tags.md](rank-tags.md)) |

The file table is in include order. When you add a file, include it in `main.opy` at the place its rules need to run, and add it here.

## The core loop

```
       ┌──────────────── Wait for more players ─────────────────────┐
       │  2+ players                                                │
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

The numbers are fixed: `ballFeel` (hit radius, speed per deflect) and `roundTimings` (ball respawn delay) are set in `config/workshop-settings.opy`.

### Key state (globals)

| Variable | Meaning |
|---|---|
| `target` | The player the ball is chasing |
| `prevTarget` | Who hit it last (gets kill credit, can't be picked by `randomTarget()`) |
| `ballIsOut` | True while a ball is in play |
| `ballPosition`, `ballDirection`, `ballSpeed` | The ball. There's no entity. The ball is just these variables plus effects drawn at `ballPosition` |
| `ballSpawnCountdown` | Counts down to the next spawn (chased to 0) |
| `RoundInProgress`, `IsEnoughPlayersToStart`, `IsInFinalDuel`, `TieBreakerActive` | Round state flags |
| `circleCenter`, `SphereSize` | Arena center and radius, set in `maps/arenas.opy` |
| `presetMode`, `addOnSettings`, `rankedState`, `ballFeel`, … | Settings and fixed values from `config/workshop-settings.opy`. Compare enum values against `config/constants.opy` (`presetMode == Preset.TOURNAMENT`), not raw numbers |

Per-player: `canDash`, `canDeflect`, `dashOnCooldown` (input gating), `hasMoved` (has spawned into the arena, used to exclude people who haven't really joined yet), `antiRubberbanding`, `simpleHUD` (`SimpleHud.OFF`, `ON`, `ZEN`), `sensHigh` (double sens).

See `src/config/variables.opy` for the full list.

## Collision detection

The ball is a point, and it moves fast. The Workshop only evaluates conditions about once per tick (~60 Hz), so a fast ball can skip past a player between checks ("phasing"). Two rules handle this:

- **`Collision - ball reaches player`** fires when `ballPosition` is within "hit radius" (1.9 m by default, `ballFeel`) of the target's eyes.
- **`Collision - collision check`** runs every tick while `ballSpeed` is above the fast ball speed (150, `ballFeel`). It also checks **interpolated points** between the previous and current positions (the halfway and quarter points in `phasePosition`, see `PhasePoint`, and the three-quarter point), so a fast ball can't jump over the target.

Both call `collisionTarget()`. That checks whether the target is deflecting (`isUsingAbility2`) or dashing (`isUsingAbility1`). It then either redirects the ball or calls `deflectFail()`.

**Retargeting:** the new target is the living player with the **smallest angle** between the hitter's facing direction and the direction to that player.

## Ball physics

`startBall()` starts `startModernBall`: Workshop `chaseAtRate` on position, speed and direction. The direction chases "towards target" at `ballDirectionRate` (1.75). Right after a deflect, `ballCurve` raises the rate to 6 for 0.05 s for a sharper curve. These numbers, the hit radius, the +5% per deflect and the deflect window and lockout are in `ballFeel` (fields in `BallFeel`), fixed to `BALL_FEEL_DEFAULTS`, the v1.3.2 values. `main`'s other motion modes and physics engines (rapid, Legacy+, experimental, astro, retro) and anti-ghost aren't on `v1.3.3R`.

**Bounces:**
- `Ball Physics - general collision`: raycasts one step ahead. On a hit it reflects `ballDirection` with the simplified island side-collision helper.
- `Ball Physics - island collision`: Workshop Island platform floor and sides, using the nearest-surface helpers `simpleIslandCollision` / `simpleIslandSideCollision`.
- `Ball Physics - water`: flattens the ball's vertical direction when it dips below `waterLevel` outside the island.

**Network resync** (`v1.3.3R` only, `Ball Physics - network resync`): while the ball is out, it restarts the `ballDirection` chase 20 times a second, so every client's copy of the ball stays in step with the server (ported from vTec). It is always on and has no setting.

> **Chase warning:** OverPy reports warnings like *"rule condition will possibly not trigger properly … because the global variable 'ballPosition' is chased"*. This is a known Workshop quirk: conditions on chased variables don't always re-evaluate. Existing rules have worked with it for years. Newer code (e.g. the ranked log) avoids it by checking chased variables in the rule body instead of in conditions. Please do the same in new rules.

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
| `Settings - Workshop settings` → everything else | It must be the first rule. It reads the Workshop settings and sets the fixed values, and the startup rules below read the results. |
| `Settings - Workshop settings` → `Initialization - global variables` | Init copies `ballSpawnSpeed` into `ballSpeed`, `setballspawncountdownoriginal` ("ball spawn countdown") into `setballspawncountdown` and `ballSpawnCountdown`, `roundsUntilBreak` into `roundsUntilBreakInit`, and `ballDirectionRateInit` from `ballFeel`. Swapped, the ball would start with 0s. |
| `Settings - Workshop settings` → `TOURNEY - generated` → `Tourney - settings` | `v1.3.3R`. The settings rule builds `rankedState`, the generated rule then sets its `TOURNEY` field, and `Tourney - settings` reads it to force `tournamentMode`, `totalRounds` and ranked logging (`rankedState[LOGGING]`) in a tourney. |
| `Tourney - settings` → `Initialization - Match length`, `Initialization - Disable inspector`, `HUD - tournament text`, `Ranked log - MATCH_START` | They read `tournamentMode`, ranked logging, the tourney settings or `totalRounds` once, at start. Swapped, a tourney would get a match timer, a disabled inspector, the "ROUNDS LEFT" HUD or the preset's round limit in `TOURNEY`. |
| `Settings - Workshop settings` → `HUD - controls text` | The HUD rule reads the double sens setting (`addOnSettings`) once, when it starts. |
| `Settings - Workshop settings` → `Appearance - target effects` | It reads the "red-green colorblind filter" setting (`addOnSettings`) once when it creates its effects. Swapped, the filter would be ignored. |
| `Initialization - Set map` → `Initialization - map sphere` | The map sphere reads `circleCenter` and `SphereSize` once. |

**Lobby and round flow**

| Keep before | Why |
|---|---|
| `Check for <2 players` → `Active game - check for last player surviving` | When a player leaves a two-player round, both fire in the same tick. The check runs first and clears `IsEnoughPlayersToStart`, which stops the other rule from awarding a round win to the player left behind. |
| `Active game - spawn ball` → `core/collision` and `core/ball-physics` rules | In the tick the ball spawns, `ballPosition`/`ballDirection` are set before the collision and bounce rules look at them. |

**Collision and physics** (these are the rules the feel-lock protects)

| Keep before | Why |
|---|---|
| `Collision - ball reaches player` → `Collision - collision check` | Both can detect the same hit. The single-shot rule handles it first; the check loop then sees the new target and doesn't double-trigger. |
| `Collision - collision check` → `Ball Physics - general collision` | The check reads `ballHitPosition` from the previous tick, then general collision writes this tick's hit. Swapped, the phasing interpolation would use a different point. |
| `core/collision` rules → `core/ball-physics` bounce rules | When a deflect and a wall hit land in the same tick, the deflect sets the new direction first and the bounce reflects that. Swapped, the bounce would be applied to the old direction and then thrown away by the deflect. |
| `Ball Physics - island collision` → `Ball Physics - water` | On Workshop Island their areas overlap in a thin band at the platform edge (|x| or |z| between 20 and 20.2). Island collision flips a downward ball up, and water then no longer triggers. Swapped, water flattens the ball first and island collision picks a side wall instead. |

**Controls** (dash/deflect timing)

| Keep before | Why |
|---|---|
| `Controls - primary fire triggers dash`, `Controls - secondary fire triggers deflect` → `Controls - Shorten deflect length` → `Controls - Ability 1 dash queue`, `Controls - Ability 2 deflect queue` | `Shorten deflect length` re-enables `canDash`/`canDeflect`. The queue rules below it see that in the same tick, the mouse-button rules above it one tick later. That tick is part of how buffered inputs feel. |
| `Controls - Dash cooldown` → `Control - Dash reset` | If a dash starts in the same tick its user earns an elimination, the cooldown sets `dashOnCooldown` first and the reset clears it. Swapped, the reset would be lost. |
| `core/controls` → `maps/restrictions` water rules | `Controls - Dash slow (gravity shift)` and `Map restrictions - water leave` / `island enter` all set gravity. The water rules come later and win in a shared tick. |

**Ranked log** (`v1.3.3R`)

The `Ranked log` rules (`features/ranked-log.opy`) only read the round flow's variables, never change them, and come after it in rule order. So in a shared tick they see what the round flow has just done.

| Keep before | Why |
|---|---|
| `core/collision` → `Ranked log - DEFLECT` | The deflect rule watches `prevTarget`, which `Collision - collision sub` sets in the deflect. Coming later, it logs in the same tick, when `ballSpeed` and `target` are already the new ones. |
| `Check for <2 players` → `Ranked log - ROUND_END WIN` | When a player leaves a two-player round, the check clears `IsEnoughPlayersToStart` in the same tick as the `LEAVE` leaves one player in `rankedRound`. The round is logged as `ABORT`, like the round flow, which gives no win. Swapped, it would be logged as a `WIN`. |
| `Ranked log - ROUND_END WIN`, `NONE`, `ABORT`, `MATCH_END` → `Ranked log - MATCH_END ROUNDS` | In a tourney, the last round's `ROUND_END` closes the round (`IN_ROUND`) in the same tick `MATCH_END ROUNDS` checks it. It waits 1 s before logging anyway, so the order only changes that start by a tick. |

`Tourney - hold the next round` comes before the round flow and the ranked log, so it sees the last round close one tick late. The round flow starts the next round at least 0.35 s later (round win pause, `randomTarget()`), and `startRound()` reads `setballspawncountdown` only then. `Active game - all players dead` copies it into `ballSpawnCountdown` straight away, before the round is closed, and with two players the final duel counts that copy down, so the hold sets `ballSpawnCountdown` as well.

**HUD**

| Keep before | Why |
|---|---|
| `HUD - controls text` → `HUD - anti rubberbanding hud text` | Both draw on the left at sort order 0, so their rule order is their line order on screen. |

### Free to move

With the constraints above kept, these have no order dependency: `features/tournament`, the rest of `ui/hud` and `ui/effects`, the rest of `maps/restrictions`, and every `def` that's only called with `Call Subroutine`.

## Settings and presets

`Settings - Workshop settings` is the first rule. On `v1.3.3R` it only reads what a ranked or tourney lobby uses: the preset (Default or Tournament), double sens, the colorblind filter, the debug HUD and `70 - Ranked`. Everything else is fixed in the same rule to v1.3.3's `Default` values, so a host can't change the ball, arena, players or match. The Tournament preset only sets `tournamentMode`. `main` has the full settings, the other presets and the preset table.

When you add a setting:
1. Add a `createWorkshopSetting*` call in the right category, with a sort-order number. The Workshop only allows each setting to be referenced **once**, and setting names must be unique, ignoring case and spacing. Categories and names may not be blank or contain `{`, `}` or `:`. So read the setting once, in `Settings - Workshop settings`, into a variable, and use the variable everywhere else. Never read it through a macro used in several places, because each use compiles to another reference. To save global variables, put the setting into an existing array with an enum for its index, like `addOnSettings` (`AddOnSetting`) or `rankedState` (`RankedField`).
2. A setting that changes the ruleset should make the match unranked when it isn't at its default (`UnrankedReason` in `features/ranked-log.opy`).
3. Run `npm run docs:settings`, which adds it to the settings table in [hosting.md](hosting.md), and write its description there. See [Settings docs](development.md#settings-docs).

## Maps

The ranked code only plays on Workshop Island Night. `Initialization - Set map` (`maps/arenas.opy`) sets the arena's center and radius (`ISLAND_CENTER`, `ISLAND_RADIUS`). On any other map (`MAP_UNSUPPORTED` in the same file) `Initialization - unsupported map` shows everyone a message, `Wait for more players` (`core/lobby.opy`) never starts a round, and the arena rules (`Map restrictions - put out center` and `player dashes too far out of bounds`) don't run. The ball bounces and the water and ledge rules are written for Workshop Island.

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

- **Player rank** (rank-outline placeholders) isn't on `main`. The code is kept on the `feature/player-rank` branch. Its player variable slots (19–22) are free.
- **Tombstone** (name-based removal of specific players) isn't on `main`. The code is kept on the `feature/tombstone` branch.
- **Teams** (Team Deathmatch support) isn't on `main`. It lives on the `v1.3.3T` variant branch. Global variable slots 71–74 and 108 and subroutine slot 18 belong to `v1.3.3T` and are unused on `main`. Keep them that way, or merging `main` into `v1.3.3T` gives two variables the same slot.
- **Ranked** (event logging and rank tags) isn't on `main`. It lives on the `v1.3.3R` variant branch. Global variable slots 124–127 and player variable slots 124–127 are reserved for `v1.3.3R` and unused on `main`, for the same reason. Ranked state should be packed into as few of them as possible (one array if it fits). On `v1.3.3R`, global 124 is `rankedState`, 125 `rankedPlayers` and 126 `rankedRound` (the ranked log), 127 `rankTags` (rank tags), player 124 is `rankTier`, player 125 `tourneyStats` (a tourney's final standings), and subroutine slots from 124 up are its own. Player slots 126 and 127 held the rank glow, which was removed. `v1.3.3R` also leaves out the settings, presets and features a ranked or tourney lobby doesn't use, but never renumbers: the slots they used on `main` stay empty.
