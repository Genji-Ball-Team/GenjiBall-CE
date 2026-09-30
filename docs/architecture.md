# How the code works

This is a map of the game logic for contributors. It assumes you know roughly what Workshop rules, conditions and actions are. [development.md](development.md) covers the tooling.

## Source layout

`src/main.opy` is the entry point. It `#!include`s everything else **in order**, and include order is rule order. The Workshop runs rules top to bottom, so order matters when several rules react to the same thing. The files are grouped into folders by topic, but `main.opy` still includes them in the v1.3.2 rule order, so folders are interleaved there.

| Folder | What goes here |
|---|---|
| `config/` | Custom game settings, variables, Workshop settings and presets, initial values |
| `core/` | Controls timing, lobby and round flow, collision, ball physics |
| `maps/` | Per-map arena setup and map restrictions (boundaries, Workshop Island water and edges) |
| `features/` | Optional modes and tools: duels, tournament, AntiOrbit, tracing, the bot, tombstone, player rank, abilities, teams, sandbox |
| `ui/` | HUD text and visual effects |

| File | Contents |
|---|---|
| `config/lobby.opy` | Lobby, game mode, hero and extension settings (the part of the export that isn't rules) |
| `config/variables.opy` | Every global/player variable and subroutine, with its **fixed index**, plus active extensions |
| `config/workshop-settings.opy` | Reads the Workshop settings and applies presets |
| `maps/arenas.opy` | Arena center and size per map |
| `config/initialization.opy` | Initial variable values, map sphere, bounce pads, mobility, match length |
| `ui/hud.opy` | All HUD text, debug overlays, kill tracker |
| `ui/effects.opy` | Ball/target visuals, spawn countdown text |
| `core/lobby.opy` | Waiting for 2+ players, starting the first round, handling joins |
| `core/controls.opy` | Dash/deflect input, cooldowns, perspective, simple HUD, anti-rubberbanding, double sens, bounce pads |
| `core/round-flow.opy` | Round start, ball spawn, final duel, round win, tiebreakers, end of match, choosing a target |
| `features/duels.opy` | Duel mode and its queue |
| `core/collision.opy` | Ball-reaches-player detection, deflect/dash handling, retargeting, deaths |
| `core/ball-physics.opy` | The four motion modes and three physics engines, anti-ghost, wall/floor/water bounces |
| `maps/restrictions.opy` | Center exclusion zone, arena boundary, Workshop Island water and edges |
| `features/tournament.opy` | Round counting, breaks, tournament-only restrictions |
| `features/anti-orbit.opy` | AntiOrbit pressure/heat system |
| `features/tracing.opy` | Tracing mode |
| `features/bot-zbozo.opy` | The zBozo practice bot's AI |
| `features/tombstone.opy` | Name-based removal of specific players |
| `features/player-rank.opy` | Rank outline colors (placeholders, inactive) |
| `features/abilities.opy` | Custom abilities (super jump, switch target, blink, crit slash) |
| `features/teams.opy` | Team Deathmatch support (mostly disabled) |
| `features/sandbox.opy` | Sandbox practice tools |
| `features/abilities-experimental.opy` | A disabled crit-slash rule (kept last to preserve original rule order) |

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
| `circleCenter`, `SphereSize` | Arena center and radius, set per map in `maps/arenas.opy` |
| `presetMode`, `ballMotion`, `ballPhysicsMode`, … | Settings from `config/workshop-settings.opy`. Most are named after their Workshop setting |

Per-player: `canDash`, `canDeflect`, `dashOnCooldown` (input gating), `hasMoved` (has spawned into the arena, used to exclude people who haven't really joined yet), `antiRubberbanding`, `simpleHUD` (0 off, 1 simple, 2 zen), `orbit*` (AntiOrbit), `kills` (kill tracker).

See `src/config/variables.opy` for the full list.

## Collision detection

The ball is a point, and it moves fast. The Workshop only evaluates conditions about once per tick (~60 Hz), so a fast ball can skip past a player between checks ("phasing"). Two rules handle this:

- **`Collision - ball reaches player`** fires when `ballPosition` is within 1.9 m of the target's eyes.
- **`Collision - collision check`** runs every tick while `ballSpeed > 150`. It also checks **interpolated points** between the previous and current positions (`phasePosition`, `phasePosition1`, `phasePosition2`), so a fast ball can't jump over the target.

Both call `collisionTarget()`. That checks whether the target is deflecting (`isUsingAbility2`) or dashing (`isUsingAbility1`), and with tracing mode on, whether they're still tracing. It then either redirects the ball or calls `deflectFail()`.

**Retargeting:** the new target is the living player with the **smallest angle** between the hitter's facing direction and the direction to that player.

## Ball physics

`startBall()` chooses an engine from `ballPhysicsMode` and `ballMotion`:

| Engine / motion | Subroutine | How it moves |
|---|---|---|
| original + modern/rapid | `startModernBall` | Workshop `chaseAtRate` on position, speed and direction. The direction chases "towards target" at `ballDirectionRate` (1.75 modern, 5 rapid). Right after a deflect, `ballCurve` briefly raises the rate to 6 for a sharper curve |
| Legacy+ | `startLegacyPlusBall` | Manual integration every tick (`wait()` loop). No chase |
| experimental | `startExperimentalBall` | Like modern, but deflect direction = facing direction blended with the incoming direction (`reboundInfluence`), and homing strength ramps from `experimentalHomingStart` back to 100% |
| astro (any engine) | `startAstroBall` | `ballDirection` is a velocity vector with gravity-like pull toward the target, so it orbits |
| retro (any engine) | `startRetroBall` | Chases position directly to the target's eyes. No curve |

**Bounces:**
- `Ball Physics - general collision`: raycasts one step ahead. On a hit it reflects `ballDirection` around the surface normal (Workshop Island uses the simplified side-collision helper).
- `Ball Physics - island collision`: Workshop Island platform floor and sides, using the nearest-surface helpers `simpleIslandCollision` / `simpleIslandSideCollision`.
- `Ball Physics - chamber x/y/z collision`: axis-aligned walls for Workshop Chamber.
- `Ball Physics - water`: flattens the ball's vertical direction when it dips below `waterLevel` outside the island.

**Anti-ghost** only applies to modern motion. It temporarily raises `ballDirectionRate` to 4 when the ball is near the target but not converging.

> **Chase warning:** OverPy reports warnings like *"rule condition will possibly not trigger properly … because the global variable 'ballPosition' is chased"*. This is a known Workshop quirk: conditions on chased variables don't always re-evaluate. Existing rules have worked with it for years. Newer code (e.g. AntiOrbit) avoids it by checking chased variables in the rule body instead of in conditions. Please do the same in new rules.

## Settings and presets

`Settings - Workshop settings` is the first rule. It reads every `createWorkshopSetting*`, then **overwrites** the core values if `presetMode != 7` (not Custom), then applies preset-specific tweaks. It also turns enum settings into concrete numbers (mobility → move/gravity/jump percentages, water → a height, and so on).

When you add a setting:
1. Add a `createWorkshopSetting*` call in the right category, with a sort-order number.
2. Decide whether presets should force it. If they should, add it to the preset block.
3. Document it in [hosting.md](hosting.md).

## Limits to keep in mind

| Resource | Used (v1.3.2) | Workshop limit |
|---|---|---|
| Global variables | 113 (indices up to 112) | 128 |
| Player variables | 27 | 128 |
| Subroutines | 21 | 128 |
| Elements | ~9,800 | 32,768 |
| Extension points | 24 / 24 | all used |

Global variable slots are the tightest limit. Reuse existing variables where it makes sense, and never renumber existing ones.

## Odd bits worth knowing

- **Rule names can't contain "Blizzard"**, so the map rule is called "Blizz World".
- **`Player rank - *`** rules match an empty player name, so they never fire. They're placeholders for a rank-outline system.
- **`†Tombstone†`** removes players with specific names from the game.
- **`Teams - *`**: most team rules are disabled. `TDMcollision` and the TDM branch in the visuals are live but only matter in Team Deathmatch.
- **`HUD - Watermark`** is controlled by `WatermarkEnabled`, which `Settings - Watermark` sets to false.
- **`Settings - Red-green colorblind filter`** is a disabled rule. Enable it to switch the target visuals to blue/yellow.
