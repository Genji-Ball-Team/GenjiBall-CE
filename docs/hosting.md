# Hosting a game

## Importing the code

### With an import code

| Version | Import code | Published by |
|---|---|---|
| v1.3.3 (current) | **`926FG`** | Genji Ball Team |
| v1.3.2 | **`C62PC`** | FROZONE (Frozonovic) |
| v1.3.3T (Team Deathmatch, [own page](https://workshop.codes/GenjiBall-CE-Teams)) | **`11M60`** | Genji Ball Team |

In Overwatch: **Play → Custom Games → Import Code**, and enter the code.

When a new version is released, a maintainer adds its import code to this table and to the release notes. Import codes can only be created in-game.

### By pasting the Workshop code

1. Get the Workshop code from the latest [release](../../../releases). That's the stable version. [`workshop/genjiball.txt`](../workshop/genjiball.txt) on `main` is the latest development build, and each version branch (e.g. `v1.3.2`) has the code for that release.
2. In Overwatch: **Play → Custom Games → Create**.
3. Open **Settings** and click the **Import** / paste icon in the top right. Your clipboard needs to contain the code. Import into a new custom game, not on top of an existing one: pasting over a game that already has Workshop settings can fail with "Categories and names of Workshop Settings may not be blank and may not contain '{', '}', or ':'".
4. Change anything you want under **Settings → Workshop → Settings** (see below), then start the game.

The lobby is set up for **Deathmatch (FFA)** with up to **10 players** and 12 spectators. Only Genji is allowed.

## Maps

Workshop Island (Night) is the only map enabled by default. The mode supports the Workshop maps below. Enable them under **Settings → Modes → Deathmatch → Maps**. On any other map the game shows "This map isn't supported" with the list of supported maps, and no round starts.

| Map | Arena radius | Notes |
|---|---|---|
| Workshop Island / Island Night | 60 | The main map. It has water around the island (see `water`). |
| Workshop Expanse / Expanse Night | 50 | Used by the Rapid preset |
| Workshop Green Screen | 60 | |
| Workshop Chamber | 29.7 | The ball bounces off the chamber walls |

Non-Workshop maps can't be enabled: Overwatch says "The current set of workshop extensions prohibits non-workshop maps", and the mode needs its extensions for the ball and its effects ([reported in 2023](https://us.forums.blizzard.com/en/overwatch/t/deathmatch-unavailable-with-workshop-extensions-enabled/783801)). Oasis University, King's Row and Blizzard World used to have arenas. They are commented out in `src/maps/arenas.opy`, so they can come back if Overwatch lifts this.

## Workshop settings

These appear in the custom game under **Settings → Workshop → Settings**, grouped by category.

<!-- The settings tables are generated from src/ by `npm run docs:settings`. Edit only the "What it does" column and the units after a range. See docs/development.md, "Settings docs". -->

### Presets decide most settings

`00 - Preset` is the most important setting. **Every preset except Custom overwrites** the Ball, Arena, Player (mobility, dash and dash hit) and Match settings with fixed values, and turns *15 - Ball Feel* off. If you change "max speed" and nothing happens, that's why. Set the preset to **Custom** to use your own values.

<!-- settings: 00 - Preset -->
| Setting | Default | Range | What it does |
|---|---|---|---|
| preset | Default | Default / Tournament / Tournament+ / Rapid / v1 / v7 / Experimental / Custom | Which ruleset to play. See the table below |

| Preset | What it's for | Differences from Default |
|---|---|---|
| **Default** | Standard casual play | none |
| **Tournament** | The current tournament ruleset | Tournament mode on, anti-ghost off, AntiOrbit off, AntiOrbit and basic anti-orbit tuning at their defaults |
| **Tournament+** | Candidate for future tournaments | Tournament mode on, anti-ghost = steer, AntiOrbit on (radius 14, pressure 2), AntiOrbit and basic anti-orbit tuning at their defaults |
| **Rapid** | Workshop Expanse-style: fast and bouncy | water = flood, motion = rapid, bounce pads on, mobility = balanced |
| **v1** | Dry Workshop Island, as in the early versions | water = none |
| **v7** | v7-style (partial) | water = flood, bounce pads on, mobility = sluggish |
| **Experimental** | Playtesting new rebound physics. Not tournament-safe | physics = experimental, anti-ghost off, AntiOrbit on (radius 14, pressure 2), AntiOrbit and basic anti-orbit tuning at their defaults |
| **Custom** | Everything manual | uses your values for every setting |

What "Default" forces (all non-Custom presets start from this):
match length 15 min, tournament off, 30 rounds, breaks on every 10 rounds for 60 s, ball spawn countdown 5 s, ball respawn delay 2 s, round win pause 2 s, ball start speed 60, max speed 400, acceleration 25, motion modern, physics original, custom ball feel off, water moderate, bounce pads off, center exclusion size 3.5, arena radius 0 (the map's), bounce pad strength 30, distance 12, range 2.75 and cooldown 3 s, mobility agile, dash cooldown 3.04 s, dash hit knockdown 1 s and knockdown cooldown 0.6 s.

Settings **not** touched by any preset: everything in *50 - Features*, *80 - Visual*, *90 - Debug*, water ledge fix, double sens and double sens %, and tracing view angle. The "custom ... %" mobility sliders are never forced either, but no preset picks mobility = custom, so they only apply with Preset = Custom. Anti-ghost, AntiOrbit and the rest of *60 - Competitive* are only forced by the presets listed above. The AntiOrbit speed, timer, min timer and sleep and the three basic anti-orbit settings are forced together, to their defaults.

### 10 - Ball

<!-- settings: 10 - Ball -->
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

### 15 - Ball Feel

The numbers behind how the ball flies, hits and deflects. Every default is the v1.3.2 value. The sliders only apply with **custom ball feel** on, and every preset except Custom turns it off, so Default, Tournament and Tournament+ always play like v1.3.2.

<!-- settings: 15 - Ball Feel -->
| Setting | Default | Range | What it does |
|---|---|---|---|
| custom ball feel | off | | Use the sliders below. Off uses the defaults, whatever the sliders say. Only Preset = Custom can turn it on |
| speed per deflect | 1.05 | 1–2 | The ball's speed is multiplied by this on each deflect, up to max speed (1.05 = +5%) |
| hit radius | 1.9 | 0.5–5 m | How close the ball has to get to the target's eyes to hit them (deflect or kill) |
| turn rate modern | 1.75 | 0.25–20 | How fast the ball turns towards its target with motion = modern |
| turn rate rapid | 5 | 0.25–20 | Same, with motion = rapid |
| deflect curve rate | 6 | 0–20 | Motion = modern (not the experimental engine): the turn rate right after a deflect, for a sharper curve |
| deflect curve time | 0.05 | 0–1 s | How long that curve rate lasts |
| deflect window | 0.3 | 0.05–2 s | How long a deflect lasts |
| deflect lockout | 0.5 | 0–3 s | After a deflect, how long dash and deflect are locked |
| fast ball speed | 150 | 0–800 | Above this speed, the game also checks points between frames so a fast ball can't skip past the target. Lower is more reliable but costs more server load |
| reliable hit detection | off | | **on**: the between-frames check from "fast ball speed" runs at every speed, every tick, so a hit isn't missed at low speed. Costs more server load |

### 20 - Arena

<!-- settings: 20 - Arena -->
| Setting | Default | Range | What it does |
|---|---|---|---|
| water | moderate | moderate / none / minimal / flood | Workshop Island only. The height at which the ball skims off the water outside the island: **moderate** (y = −15), **none** (no water), **minimal** (y = −26), **flood** (y = −0.5, almost at island level) |
| bounce pads | off | | Four blue rings around the center (12 m out by default). Press Jump on one for a big vertical launch (3 s cooldown per player by default). Tuned with the bounce pad settings below |
| center exclusion size | 3.5 | 0–10 m | Radius of the black sphere at the center that pushes players out |
| arena radius | 0 | 0–100 m | **0** uses the map's radius (see [Maps](#maps)), anything else replaces it. The radius is at least 10 and at least 1.5 × (center exclusion size + 0.5), so final duel spawns stay in bounds and outside the center |
| bounce pad strength | 30 | 5–60 | Upward launch of a bounce pad |
| bounce pad distance | 12 | 4–40 m | Distance of each pad from the center |
| bounce pad range | 2.75 | 0.5–10 m | How close to a pad you have to be to bounce |
| bounce pad cooldown | 3 | 1–10 s | Seconds before a player can bounce again |
| water ledge fix | off | | Workshop Island only. Below y = −1.5 the water pushes players up and toward the center, which can drag a player who dashes in next to the island under the ledge and pin them there. **on**: under the island (within 21 m of the center), players are pushed straight out instead. Everywhere else the water behaves as in v1.3.2. No preset turns it on |

### 30 - Player

<!-- settings: 30 - Player -->
| Setting | Default | Range | What it does |
|---|---|---|---|
| mobility | agile | agile / balanced / sluggish / custom | **agile**: 190% move speed, 80% gravity, 180% jump. **balanced**: 150 / 90 / 150. **sluggish**: 100 / 100 / 100 (normal Genji). **custom**: the three sliders below |
| custom move speed % | 190 | 20–300 | Move speed with mobility = custom |
| custom gravity % | 80 | 10–300 | Gravity with mobility = custom |
| custom jump % | 180 | 20–300 | Jump height with mobility = custom |
| dash cooldown | 3.04 | 0–10 s | Seconds after a dash ends before you can dash again |
| dash hit knockdown | 1 | 0–3 s | How long hitting the ball with a dash knocks you down |
| dash hit knockdown cooldown | 0.6 | 0–5 s | After a dash hit knockdown, how long before another dash hit can knock you down |
| double sens | off | | Players can press Ultimate to switch between 100% aim sensitivity and "double sens %". Disabled while custom abilities are on, because they use Ultimate |
| double sens % | 275 | 100–500 | The high aim sensitivity double sens switches to |

### 40 - Match

<!-- settings: 40 - Match -->
| Setting | Default | Range | What it does |
|---|---|---|---|
| match length | 15 | 5–60 min | Ignored in tournament mode |
| tournament mode | off | | Plays a fixed number of rounds instead of using a timer. Also: non-targets can't dash into the water, and a basic anti-orbit rule applies (if AntiOrbit is off, stalling a ball slower than 80 within 20 m for 7.5 s puts you to sleep by default; tuned in [60 - Competitive](#60---competitive)) |
| tournament rounds | 30 | 1–50 | Rounds until the match ends |
| breaks | on | | Take a break every N rounds |
| break every | 10 | 4–25 | Rounds between breaks |
| break length | 60 | 1–120 s | Length of the break (the ball spawn countdown is extended) |
| ball spawn countdown | 5 | 1–30 s | Countdown before the ball spawns at the start of a round |
| ball respawn delay | 2 | 1–10 s | Countdown before the ball respawns after a kill, while the round goes on |
| round win pause | 2 | 0–10 s | Pause after "… has won the round" (or a duel win) before the next round starts |

### 50 - Features

<!-- settings: 50 - Features -->
| Setting | Default | Range | What it does |
|---|---|---|---|
| custom abilities | off | | Each player picks one extra ability. See [playing.md](playing.md#custom-abilities) |
| bot | off | | Adds the "zSh4d0Ws bozo" practice bot |
| duels | off | | 1v1 at a time, with a queue |
| endless mode | off | | The ball doesn't reset after a kill |
| Sandbox mode | off | | Practice tool for the host. See [Sandbox](#sandbox-mode) |

### 60 - Competitive

<!-- settings: 60 - Competitive -->
| Setting | Default | Range | What it does |
|---|---|---|---|
| AntiOrbit | off | | Punishes stalling a slow ball around yourself. See [playing.md](playing.md#anti-orbit) |
| AntiOrbit radius | 14 | 10–20 m | How close the ball has to be to count as orbiting |
| AntiOrbit pressure | 2 | 1–5 | How fast repeated orbiting shortens the punishment timer |
| AntiOrbit speed | 80 | 10–400 | The ball only counts as orbiting while it's slower than this |
| AntiOrbit timer | 7.5 | 1–30 s | Seconds of orbiting before you're put to sleep, before pressure shortens it |
| AntiOrbit min timer | 5.5 | 1–30 s | Pressure never shortens the timer below this |
| AntiOrbit sleep | 5 | 0–10 s | How long an orbiting player sleeps |
| basic anti-orbit radius | 20 | 5–40 m | Tournament mode with AntiOrbit off: how close the ball has to be to count as orbiting |
| basic anti-orbit speed | 80 | 10–400 | Same, the ball only counts while it's slower than this |
| basic anti-orbit timer | 7.5 | 1–30 s | Same, seconds of orbiting before you're put to sleep (for 5 s) |

### 70 - Ranked

<!-- settings: 70 - Ranked -->
| Setting | Default | Range | What it does |
|---|---|---|---|
| ranked logging | on | | Writes the match to the Workshop inspector log for the ranked leaderboard: match start and end, and players joining and leaving. Turn on **Enable Workshop Inspector Log File** in the Overwatch options so it reaches a file the host tool can upload. **off**: nothing is logged and the match can't count. Format: [ranked-log.md](ranked-log.md) |

### 80 - Visual

<!-- settings: 80 - Visual -->
| Setting | Default | Range | What it does |
|---|---|---|---|
| x-ray | off | | Shows the target where the ball is when a wall blocks their view |
| tracing mode | off | | The target must keep the ball in view to be able to deflect |
| tracing view angle | 45 | 5–180° | How far from the crosshair the ball may be and still count as in view |
| kill tracker | off | | Host-only kill leaderboard on the left |
| red-green colorblind filter | off | | Red-green safe colours: the target, the ball, the x-ray icon and the target's "BALL SPAWNING IN" countdown are blue instead of red, the target sees a yellow circle around the ball instead of a blue one, and used bounce pads show yellow instead of white |
| watermark | off | | Shows the original author's credit (u/Mazawrath) on the left of everyone's HUD |

### 90 - Debug

<!-- settings: 90 - Debug -->
| Setting | Default | Range | What it does |
|---|---|---|---|
| debug HUD | off | | Host-only: server load, ball speed/engine/distance/turn rate, AntiOrbit values |

## Sandbox mode

Sandbox lets the host set exactly where the ball spawns, which way it flies, and how fast, for practicing specific situations. In sandbox:

- The round only starts when the **host holds Ultimate + Reload**.
- **Hold Reload** to switch between editing position, direction and speed.
- **Jump / Crouch** changes the axis (x/y/z). Press both to flip between + and −.
- **Interact** adds or subtracts. Hold **Ultimate** while doing it for bigger steps.
- The current values are shown on the HUD, and the spawn point and direction are drawn in the world.
- The host is always the target.
