# Hosting a game

## Importing the code

### With an import code

| Version | Import code | Published by |
|---|---|---|
| v1.3.2 (current) | **`C62PC`** | FROZONE |

In Overwatch: **Play → Custom Games → Import Code**, and enter the code.

When a new version is released, a maintainer adds its import code to this table and to the release notes. Import codes can only be created in-game.

### By pasting the Workshop code

1. Get the Workshop code from the latest [release](../../../releases). That's the stable version. [`workshop/genjiball.txt`](../workshop/genjiball.txt) on `main` is the latest development build, and each version branch (e.g. `v1.3.2`) has the code for that release.
2. In Overwatch: **Play → Custom Games → Create**.
3. Open **Settings** and click the **Import** / paste icon in the top right. Your clipboard needs to contain the code.
4. Change anything you want under **Settings → Workshop → Settings** (see below), then start the game.

The lobby is set up for **Deathmatch (FFA)** with up to **10 players** and 12 spectators. Only Genji is allowed.

## Maps

Workshop Island (Night) is the only map enabled by default. The code also supports the maps below. Enable them under **Settings → Modes → Deathmatch → Maps**.

| Map | Arena radius | Notes |
|---|---|---|
| Workshop Island / Island Night | 60 | The main map. It has water around the island (see `water`). |
| Workshop Expanse / Expanse Night | 50 | Used by the Rapid preset |
| Workshop Green Screen | 60 | |
| Workshop Chamber | 29.7 | The ball bounces off the chamber walls |
| Oasis (University) | 25 | Small |
| King's Row / King's Row Winter | 23 | Small. **Lower the max players.** |
| Blizzard World / Winter | 23 | Small. **Lower the max players.** |

## Workshop settings

These appear in the custom game under **Settings → Workshop → Settings**, grouped by category.

### Presets decide most settings

`00 - Preset` is the most important setting. **Every preset except Custom overwrites** the Ball, Arena, Player mobility and Match settings with fixed values. If you change "max speed" and nothing happens, that's why. Set the preset to **Custom** to use your own values.

| Preset | What it's for | Differences from Default |
|---|---|---|
| **Default** | Standard casual play | none |
| **Tournament** | The current tournament ruleset | Tournament mode on, anti-ghost off, AntiOrbit off |
| **Tournament+** | Candidate for future tournaments | Tournament mode on, anti-ghost = steer, AntiOrbit on (radius 14, pressure 2) |
| **Rapid** | Workshop Expanse-style: fast and bouncy | water = flood, motion = rapid, bounce pads on, mobility = balanced |
| **v1** | Dry Workshop Island, as in the early versions | water = none |
| **v7** | v7-style (partial) | water = flood, bounce pads on, mobility = sluggish |
| **Experimental** | Playtesting new rebound physics. Not tournament-safe | physics = experimental, anti-ghost off, AntiOrbit on (radius 14, pressure 2) |
| **Custom** | Everything manual | uses your values for every setting |

What "Default" forces (all non-Custom presets start from this):
match length 15 min, tournament off, 30 rounds, breaks on every 10 rounds for 60 s, ball start speed 60, max speed 400, acceleration 25, motion modern, physics original, water moderate, bounce pads off, mobility agile.

Settings **not** touched by any preset: everything in *50 - Features*, *70 - Teams*, *80 - Visual*, *90 - Debug*, and double sens. Anti-ghost and AntiOrbit are only forced by the presets listed above.

### 10 - Ball

| Setting | Default | Range | What it does |
|---|---|---|---|
| start speed | 60 | 0–200 | Speed of a freshly spawned ball |
| max speed | 400 | 60–800 | Ball speed never goes above this |
| acceleration | 25 | 0–300 | How fast the ball speeds up on its own while flying. The value ÷ 100 is the speed gained per second (25 → +0.25/s). Most of the speed comes from the +5% per deflect |
| motion | modern | modern / rapid / astro / retro | How the ball flies. **modern**: smooth homing curve. **rapid**: turns much faster, travels half the distance per step, and is snappy. **astro**: velocity-based, so it swings and orbits like a planet. **retro**: flies straight at the target with no curve |
| physics engine | original | original / Legacy+ / experimental | **original**: the classic engine. **Legacy+**: a frame-by-frame engine that doesn't use Workshop "chase" (modern/rapid only). **experimental**: deflects mix in some of the ball's incoming direction, and homing ramps back in smoothly. Tuned with the "exp" sliders below |
| anti-ghost correction | off | off / track / steer | Helps a ball that is close to its target but not closing in (a "ghost" ball). **track**: turns harder if the distance stops shrinking. **steer**: turns harder if the ball points more than 35° away from the target. Modern motion only |
| exp incoming min % | 8 | 0–30 | Experimental engine: how much of the incoming ball direction is kept on a straight-on deflect |
| exp incoming max % | 12 | 0–40 | Same, for a side-on (90°) deflect |
| exp homing start % | 55 | 20–100 | Experimental engine: homing strength right after a deflect |
| exp homing hold ms | 40 | 0–250 | How long homing stays at that reduced strength |
| exp homing ramp ms | 240 | 25–1000 | How long it takes to ramp back to full homing |
| exp surface homing % | 70 | 20–100 | Homing strength right after bouncing off a wall or floor |

### 20 - Arena

| Setting | Default | What it does |
|---|---|---|
| water | moderate | Workshop Island only. The height at which the ball skims off the water outside the island: **moderate** (y = −15), **none** (no water), **minimal** (y = −26), **flood** (y = −0.5, almost at island level) |
| bounce pads | off | Four blue rings, 12 m from the center. Press Jump on one for a big vertical launch (3 s cooldown per player) |

### 30 - Player

| Setting | Default | What it does |
|---|---|---|
| mobility | agile | **agile**: 190% move speed, 80% gravity, 180% jump. **balanced**: 150 / 90 / 150. **sluggish**: 100 / 100 / 100 (normal Genji) |
| double sens | off | Players can press Ultimate to switch between 100% and 275% aim sensitivity. Disabled while custom abilities are on, because they use Ultimate |

### 40 - Match

| Setting | Default | Range | What it does |
|---|---|---|---|
| match length | 15 | 5–60 min | Ignored in tournament mode |
| tournament mode | off | | Plays a fixed number of rounds instead of using a timer. Also: non-targets can't dash into the water, and a basic anti-orbit rule applies (if AntiOrbit is off, stalling a ball slower than 80 within 20 m for 7.5 s puts you to sleep) |
| tournament rounds | 30 | 1–50 | Rounds until the match ends |
| breaks | on | | Take a break every N rounds |
| break every | 10 | 4–25 | Rounds between breaks |
| break length | 60 | 1–120 s | Length of the break (the ball spawn countdown is extended) |

### 50 - Features

| Setting | Default | What it does |
|---|---|---|
| custom abilities | off | Each player picks one extra ability. See [playing.md](playing.md#custom-abilities) |
| bot | off | Adds the "zSh4d0Ws bozo" practice bot |
| duels | off | 1v1 at a time, with a queue |
| endless mode | off | The ball doesn't reset after a kill |
| Sandbox mode | off | Practice tool for the host. See [Sandbox](#sandbox-mode) |

### 60 - Competitive

| Setting | Default | Range | What it does |
|---|---|---|---|
| AntiOrbit | off | | Punishes stalling a slow ball around yourself. See [playing.md](playing.md#anti-orbit) |
| AntiOrbit radius | 14 | 10–20 m | How close the ball has to be to count as orbiting |
| AntiOrbit pressure | 2 | 1–5 | How fast repeated orbiting shortens the punishment timer |

### 70 - Teams

These only matter if you switch the custom game to **Team Deathmatch**. Team support is **incomplete** in v1.3.2, and most team rules are disabled in the code. See `src/rules/18-teams.opy`.

| Setting | Default | What it does |
|---|---|---|
| score to win | 0 | 0 = use the match timer |
| passing | off | Lets you pass the ball to a teammate |
| dash passing | off | Dashing also counts as a pass |

### 80 - Visual

| Setting | Default | What it does |
|---|---|---|
| x-ray | off | Shows the target where the ball is when a wall blocks their view |
| tracing mode | off | The target must keep the ball in view to be able to deflect |
| kill tracker | off | Host-only kill leaderboard on the left |

### 90 - Debug

| Setting | Default | What it does |
|---|---|---|
| debug HUD | off | Host-only: server load, ball speed/engine/distance/turn rate, AntiOrbit values |

## Sandbox mode

Sandbox lets the host set exactly where the ball spawns, which way it flies, and how fast, for practicing specific situations. In sandbox:

- The round only starts when the **host holds Ultimate + Reload**.
- **Hold Reload** to switch between editing position, direction and speed.
- **Jump / Crouch** changes the axis (x/y/z). Press both to flip between + and −.
- **Interact** adds or subtracts. Hold **Ultimate** while doing it for bigger steps.
- The current values are shown on the HUD, and the spawn point and direction are drawn in the world.
- The host is always the target.
