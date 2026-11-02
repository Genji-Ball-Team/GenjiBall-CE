# Bots

The in-game practice bots are Workshop dummies. Every bot runs the same rules: `src/features/bots.opy` (the move library) and `src/features/bot-presets.opy` (spawning and presets). A bot's behaviour comes from its **preset**: a set of numbers and a shot table. Adding a bot means adding a preset, not new rules.

## How a bot plays

A dummy is a bot when its `botHook[BotHook.PRESET]` isn't `NONE`. The core rules never decide anything for a bot. They only read `botHook` (see `BotHook` in `config/constants.opy`):

| Field | Read by | Meaning |
|---|---|---|
| `PRESET` | everything | Which preset the bot runs |
| `DEFLECT` | `Collision - collision sub` | `PRESS`: deflects on contact. `MISS`: lets this ball through. `NONE`: only its own button presses count |
| `MISS_AT_CAP` | `Collision - collision sub` | Dies to a ball at the speed cap |
| `DASH_WANTED`, `DASH_DIRECTION` | `Controls - Shorten deflect length` | Dash at the end of this deflect, facing that direction if set |

Everything else lives in the bot's own player variables, so any number of bots can play at once:

- `botState` (`BotField`): working values. The ball id the brain is on, the shot roll, the nearest enemy, the chosen row, the aim and intent, and which part owns the facing.
- `botTuning` (`BotTuning`): the preset's numbers.
- `botShots`: the preset's shot table.
- `botLoop`: a loop counter.

The parts of a bot:

- **Brain** (`Bots - incoming ball`): runs once for each ball sent at the bot.
  1. Rolls whether to miss (`MISS_SPEED`, `MISS_CHANCE`), and one shot roll from 0 to 99 for the whole ball.
  2. Waits until the ball is near: `NEAR_FACTOR × ballSpeed + NEAR_OFFSET` metres. Then waits a reaction delay between `REACTION_MIN` and `REACTION_MAX`, or `REACTION_FAST_MIN` to `REACTION_FAST_MAX` from ballSpeed `BALL_FAST` on.
  3. Picks the first row of the shot table whose chance is over the roll and whose condition holds, then turns to aim (`AIM_RATE`).
  4. If `EARLY_LEAD` is set, presses deflect that many seconds before contact (at most one tick less than a deflect lasts).
  5. After the deflect, a safe dash (after a shot at the enemy), a dash away (`DASH_AWAY`) or maybe a ghost dash.
- **Facing owner** (`botState[FACING]`): `CAMERA`, `AIM`, `DASH`, `PUNISH` or `ACE`. Only the owner turns the bot. The camera and the spin only run while it's `CAMERA`. The brain takes over from `PUNISH` when it aims.
- **Dashes**: `botDash` asks the core for a dash (`DASH_WANTED`) and faces its direction. `Bots - edash` dashes into the ball, or at the next player while they deflect or dash. A dash asked for after the deflect ends is dropped.
- **Camera, movement, jumping**: run on their own, from the preset's numbers.
- **Reset** (`Bots - reset`): on spawn and whenever the ball is gone. It clears the dash and aim and marks the brain's ball stale, so a brain still waiting stops.

## The shot table

Each row is `[condition, shot, chance, intent]` (`BotShotColumn`):

- **condition** (`BotCondition`): when the row may be used, for example `I_CAN_DASH` or `ENEMY_OFF_MAP`.
- **shot** (`BotShot`): where the ball goes, for example `AT_ENEMY` or `CORNER_NEAR_ENEMY`.
- **chance**: the row is used when the ball's roll (0–99) is under it. Rows share one roll, so the chances are cumulative thresholds, not separate dice: `[A, 30]` then `[B, 65]` then `[C, 100]` gives A 30 %, B 35 % and C 35 %.
- **intent** (`BotIntent`): what the shot is for (`SAFE`, `AT_ENEMY`, `RISKY`), for moves that react to it.

The table should end in an `ALWAYS` row with chance 100. Without one, the bot deflects where it already faces.

"Enemy" means the nearest living player who isn't a bot, worked out once per ball. Map numbers are measured from `circleCenter`: `OFF_MAP` is the half-width of the floor, and `EDGE` is how close to it counts as near the edge.

### zBozo

| Condition | Shot | Chance | Intent |
|---|---|---|---|
| `I_CAN_DASH` | `AT_ANYONE` | 11 | `AT_ENEMY` |
| `I_CAN_DASH` | `RANDOM` | 100 | `RISKY` |
| `ALWAYS` | `AWAY` | 100 | `SAFE` |

### firebuss

By gybbus. Its hard shots, in priority order:

| Condition | Shot | Chance | Intent |
|---|---|---|---|
| `ME_OFF_MAP` | `DOWN` | 100 | `SAFE` |
| `NO_ENEMY` | `DOWN` | 100 | `SAFE` |
| `ENEMY_OFF_MAP` | `DOWN` | 100 | `SAFE` |
| `AIR_NEAR_EDGE` | `UNDER_MAP` | 100 | `SAFE` |
| `ENEMY_CANT_DASH` | `AT_ENEMY` | 100 | `AT_ENEMY` |
| `ENEMY_FAR` | `UP` | 75 | `SAFE` |
| `ALWAYS` | `FLOOR_BEHIND_ENEMY` | 30 | `RISKY` |
| `ALWAYS` | `CORNER_NEAR_ENEMY` | 65 | `RISKY` |
| `ALWAYS` | `WALL_NEAR_ENEMY` | 100 | `RISKY` |

The shared roll is firebuss's own: when the enemy is far and the `UP` row's roll fails, the roll is 75 or more, so the shot is always the wall.

Its other moves, all from the library:

- **Early deflect** (`EARLY_LEAD` 0.12): it presses deflect itself about 0.12 s before contact, so a late press can fail.
- **Safe dash** (`SAFE_DASH`): after an `AT_ENEMY` shot, it dashes sideways, to the side nearer the middle.
- **Brad shot** (`BRAD_SPEED` 100): while it aims, if the ball is coming round it (`ORBIT_LINE`), it dashes at the enemy and the shot goes into their face.
- **Dash guard** (`DASH_GUARD` 20 m): its edash and ghost dash are dropped while another player within 20 m has their dash ready. The safe dash and brad shot don't check this.
- **Punish** (`PUNISH_SPEED` 90): after a human deflects a ball this fast, it turns to the nearest player until its own ball comes.
- **Human camera** (`CAMERA` `HUMAN`): looks at the ball, or the nearest human between balls, a little off, turning at 350–700°/s.
- **Circling** (`MOVEMENT` `CIRCLE`): strafes round the nearest human, closing in past 14 m and backing off under 6 m, with 15 % short pauses. Back to the middle past 16 m.
- **Jumps**: a double jump as the ball comes in (`IMPACT_JUMP` 60 %, always past `EDGE`, so a shot can go under the map), and random jumps every 1–3.5 s, 40 % of them double.

Left out on purpose: firebuss's **anti-stun**, which cleared its own knockdown and stun. With it, a dash hit couldn't knock the bot down. Without it, the bot plays by the same rules as everyone else. Its random jumps now only run while the ball is out, like zBozo's.

### lucybuss

By gybbus. Its down/up shots, then zBozo's table for the rest:

| Condition | Shot | Chance | Intent |
|---|---|---|---|
| `ME_OFF_MAP` | `DOWN` | 100 | `SAFE` |
| `ALL_FAR` | `UP` | 30 | `SAFE` |
| `ALWAYS` | `DOWN` | 60 | `SAFE` |
| `I_CAN_DASH` | `AT_ANYONE` | 64 | `AT_ENEMY` |
| `I_CAN_DASH` | `RANDOM` | 100 | `RISKY` |
| `ALWAYS` | `AWAY` | 100 | `SAFE` |

60 % of balls go down, or half of those up while every other player is over 30 m away. zBozo's rows get the roll's last 40, so its 1 in 9 at a player is 4 of those (10 %). Off the map it always shoots down; the original let 10 % of balls over speed 90 through to the other rows.

Its other moves:

- **Misses** 30 % of balls from speed 110 (`MISS_SPEED`, `MISS_CHANCE`), and dies at the cap.
- **Ace dash** (`ACE_CHANCE` 30): when the ball reaches a player within 10 m of it (within 0.3 × ballSpeed of their eyes), it dashes along where that player looks.
- **Down or up near the ball** (`SPIN_NEAR_BALL` `DOWN_UP`): while the ball is near and its dash is down, it looks down, or half the time up while every other player is over 30 m away.
- Edash and ghost dash, the camera between ball and target, and zBozo's walking with the middle 30 m away (`WALK_EDGE`). Random jumps every 1–2 s, half of them double.

The original had no rule that faced the ghost dash, so it went where the bot was looking. Here it uses the library's ghost dash, like zBozo's.

### azertybuss

By gybbus. Floor shots after a human reaction delay (0.03–0.12 s, 0.01–0.04 s from speed 100):

| Condition | Shot | Chance | Intent |
|---|---|---|---|
| `ME_OFF_MAP` | `DOWN` | 100 | `SAFE` |
| `BALL_FAST` | `RANDOM_DOWN` | 70 | `SAFE` |
| `BALL_FAST` | `AT_ANYONE` | 75 | `AT_ENEMY` |
| `BALL_FAST` | `SHALLOW_BOUNCE` | 87 | `RISKY` |
| `BALL_FAST` | `STEEP_BOUNCE` | 100 | `RISKY` |
| `ALWAYS` | `AT_ANYONE` | 15 | `AT_ENEMY` |
| `ALWAYS` | `SHALLOW_BOUNCE` | 57 | `RISKY` |
| `ALWAYS` | `STEEP_BOUNCE` | 100 | `RISKY` |

The original rolled again for each step: 70 % down at speed 100+, then 15 % at a player, then a coin flip between a shallow and a steep bounce. The fast rows give the same split from one roll. "Off the map" is past 20.5 m, where the original checked for the water. Its aim error at a player was up to 1.5 m; here it's 6°, about that at 15 m.

Its other moves:

- **Dash away** (`DASH_AWAY` 55): after a shot, it dashes sideways (70–120° off its aim). Always after a shot at a player. If that would take it past `WALK_EDGE` (15 m), it dashes toward a spot near the middle.
- **Strafing** (`MOVEMENT` `STRAFE`): stops 15 % of the time, strafes 35 %, walks forward or back 25 %, diagonally 25 %. Back toward the middle past 15 m.
- **Human camera** at 175–350°/s, and jumps all the time the ball is out: 80 % double.

No edash and no ghost dash, as in the original (its ghost dash was never triggered).

### Monx

By gybbus: a ball machine for positioning and shot-reading drills. Its settings are in "50 - Features" (see [hosting.md](hosting.md#50---features)).

- **Pinned** (`MOVEMENT` `PINNED`): `Bots - pinned` forces it to `PIN_SPOT` and does it again every 1.25 s, which also puts it back after the final duel teleport. "Monx spot" picks the spot: 25 m from the middle and 1.5 m up, like the original, on four sides, or 12 m out on the floor. In an arena under 27 m it stands at the radius minus 2 m. No walking, jumping or dashing.
- **Never misses**: deflect pressed on contact, and `MISS_AT_CAP` off, so not even at the speed cap.
- **Shots** ("Monx shots"), no aim error:

| Option | Rows |
|---|---|
| random floor | `ALWAYS` `FLOOR_TO_MIDDLE` 100 |
| long bounce | `ALWAYS` `LONG_TO_MIDDLE` 100 |
| at the player | `ALWAYS` `AT_ANYONE` 100 |
| mix | `FLOOR_TO_MIDDLE` 40, `LONG_TO_MIDDLE` 70, `AT_ANYONE` 100 |

`FLOOR_TO_MIDDLE` goes up to 45° either side of the way to the middle, 45–90° down. The original looked at a new random spot every 1.25 s, 44–90° down and always to one side of the middle (+x and +z), and the ball went wherever it looked. Here each ball rolls its own shot, centred on the middle, so it works from every spot. `LONG_TO_MIDDLE` goes up to 20° off the way to the middle, 10–25° down.

- **Ball speed** (`MACHINE_SPEED`, "Monx ball speed"): after each of its deflects, ballSpeed is set to this, up to the max speed. Ball speed is one global value, so it's set again every time. The ball speeds up as usual after that. 0 leaves the usual speed-up alone.

## Adding things

- **A condition**: add a `BotCondition` entry, then a `case` in `botCheckCondition` that sets `botState[PASSED]`. Put any number it needs in `BotTuning` rather than in the code.
- **A shot**: add a `BotShot` entry, then a `case` in `botAimShot` that sets `botState[AIM]` to a world direction. Call `botAimError` after it if the shot should miss by the preset's aim error.
- **A move** (camera, movement, dash): add a rule in `bots.opy` that checks `botHook[PRESET] != NONE` and a `BotTuning` switch. If it turns the bot, it must only run while `botState[FACING]` is its owner. If it dashes, set `botHook[DASH_DIRECTION]` and call `botDash`.
- **A preset**: add a `BotPreset` entry and a branch in `botLoadPreset` that sets `botTuning` (every `BotTuning` field, in order) and `botShots`.

New `BotTuning` fields go at the end, and every preset needs a value for them.

## Limits

- The bots stay out of the feel-locked core rules. If a bot needs something new from them, that's a hook in `botHook`, in its own `ball feel` PR.
- The whole bot library should stay under about 4,000 Workshop elements. `npm run check` prints the total.
