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
  2. Waits until the ball is near: `NEAR_FACTOR × ballSpeed + NEAR_OFFSET` metres. Then waits a reaction delay between `REACTION_MIN` and `REACTION_MAX`.
  3. Picks the first row of the shot table whose chance is over the roll and whose condition holds, then turns to aim (`AIM_RATE`).
  4. If `EARLY_LEAD` is set, presses deflect that many seconds before contact (at most one tick less than a deflect lasts).
  5. After the deflect, maybe ghost dashes.
- **Facing owner** (`botState[FACING]`): `CAMERA`, `AIM` or `DASH`. Only the owner turns the bot. The camera and the spin only run while it's `CAMERA`.
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

### Fit check: firebuss

The library was built so that firebuss's shot logic is only a table:

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

## Adding things

- **A condition**: add a `BotCondition` entry, then a `case` in `botCheckCondition` that sets `botState[PASSED]`. Put any number it needs in `BotTuning` rather than in the code.
- **A shot**: add a `BotShot` entry, then a `case` in `botAimShot` that sets `botState[AIM]` to a world direction. Call `botAimError` after it if the shot should miss by the preset's aim error.
- **A move** (camera, movement, dash): add a rule in `bots.opy` that checks `botHook[PRESET] != NONE` and a `BotTuning` switch. If it turns the bot, it must only run while `botState[FACING]` is its owner. If it dashes, set `botHook[DASH_DIRECTION]` and call `botDash`.
- **A preset**: add a `BotPreset` entry and a branch in `botLoadPreset` that sets `botTuning` (every `BotTuning` field, in order) and `botShots`.

New `BotTuning` fields go at the end, and every preset needs a value for them.

## Limits

- The bots stay out of the feel-locked core rules. If a bot needs something new from them, that's a hook in `botHook`, in its own `ball feel` PR.
- The whole bot library should stay under about 4,000 Workshop elements. `npm run check` prints the total.
