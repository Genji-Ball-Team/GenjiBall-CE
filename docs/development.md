# Developer guide

## Why OverPy?

The Overwatch Workshop's native text format is verbose and hard to diff. It's also impossible to split into files. [OverPy](https://github.com/Zezombye/overpy) is a Python-like language that compiles to Workshop code and can decompile it back. That gives us:

- readable code (`if ballSpeed > 150:` instead of `If(Compare(Global.ballSpeed, >, 150));`)
- one file per feature, so PRs touch small, reviewable files
- comments that survive round trips
- compile-time warnings for common Workshop mistakes

The OverPy version is pinned in `package.json`, so everyone builds identical output.

## Commands

| Command | What it does |
|---|---|
| `npm ci` | Install the pinned OverPy version |
| `npm run build` | Compile `src/main.opy` → `workshop/genjiball.txt` |
| `npm run check` | Compile and fail if `workshop/genjiball.txt` is stale, a [feel-locked](#feel-lock) rule changed, a Workshop limit is nearly used up, or the [settings tables](#settings-docs) in `docs/hosting.md` are out of date (this is what CI runs). Also prints the [resource budget](architecture.md#limits-to-keep-in-mind) |
| `npm run feel-lock:update` | Rewrite `tools/feel-lock.json` after a deliberate ball feel change |
| `npm run docs:settings` | Regenerate the [settings tables](#settings-docs) in `docs/hosting.md` from `src/` |
| `npm run decompile -- in.txt out.opy` | Turn Workshop code copied from the game into OverPy |

The build prints many **warnings** (chased variables in conditions, dark colors, legacy impulse flags). They were all present in v1.3.2 and are not errors. It's still welcome to fix them, one topic per PR.

## Feel-lock

The Workshop has no tests, so a refactor could change how the ball feels without anyone noticing. The feel-lock guards against that. `tools/feel-lock.json` is a snapshot of the **compiled** code of the core rules, in their list order:

- every rule and subroutine in `src/core/collision.opy`, `src/core/ball-physics.opy` and `src/core/round-flow.opy` (new rules added to those files are locked automatically)
- the dash/deflect timing rules in `src/core/controls.opy` (listed by name in `tools/feel-lock.mjs`)

`npm run check` compiles the source and compares. It fails, naming the rule, when a locked rule's compiled code changes, a locked rule is added, removed or renamed, or the locked rules change order relative to each other. Because it compares compiled code, comments and formatting in the source don't count, but any change to a value, condition or action does.

What it doesn't lock: rules outside that list, and a locked rule's absolute position. Adding a HUD rule early in the list is fine. Placing a rule between locked rules that reacts to the same variables in the same tick can still change feel, so check [Rule order](architecture.md#rule-order) when you do that.

**When the check fails:**

- If you didn't mean to change ball feel (a cleanup, a rename, moving code around), your change isn't behaviour-neutral. Fix it until the check passes.
- If you did mean to, run `npm run feel-lock:update` and commit `tools/feel-lock.json` with your change. Its diff shows reviewers exactly which compiled rules changed. The PR needs the **`ball feel`** label (CI fails without it) and an in-game playtest. New feel changes should be a default-off toggle, per the label's description.

## Settings docs

The settings tables in [hosting.md](hosting.md#workshop-settings) are generated from the `createWorkshopSetting*` calls in `src/`. Each table follows a `<!-- settings: <category> -->` comment. `npm run docs:settings` (`tools/docs-settings.mjs`) rewrites them:

- **Setting**, **Default** and **Range** come from the source, in the in-game sort order. Enums list their options, and on/off settings have no range.
- **What it does** is hand-written. Edit it in `hosting.md` as usual, and the script keeps it, matched by setting name.
- A unit after a range (`1–10 s`, `0–10 m`, `5–180°`) is hand-written too, and kept the same way.

`npm run check` fails when the tables don't match the source, when a setting has no description, when a category has no table, or when a setting's category or name is blank or contains `{`, `}` or `:` (the Workshop rejects those). After adding, renaming or changing a setting, run `npm run docs:settings`, write the description of any new row, and commit `docs/hosting.md`. A renamed setting gets a new, empty row: the script names the row it removed, so you can copy the description over. A new category needs its own `### <category>` section with the comment and a table header, which the script then fills.

## Testing in-game

1. `npm run build`
2. Open `workshop/genjiball.txt`, select all, and copy.
3. In a new custom game lobby: **Settings → Import**, top right. Importing on top of an existing game can fail with "Categories and names of Workshop Settings may not be blank…"; create a new custom game instead.
4. Useful settings for testing: `50 - Features > bot` for someone to hit the ball at, `90 - Debug > debug HUD`, and `50 - Features > Sandbox mode` for repeatable ball spawns.

## OverPy quick reference

```python
rule "Controls - Dash cooldown":          # rule name shows up in-game
    @Event eachPlayer                      # omit for a global rule
    @Condition eventPlayer.isAlive() == true
    @Condition eventPlayer.isUsingAbility1() == true

    eventPlayer.dashOnCooldown = true
    waitUntil(not eventPlayer.isUsingAbility1(), 0.5)


def startRound():                          # subroutine
    @Name "Active game - start round"      # the name shown in the Workshop editor
    ...

startRound()                               # Call Subroutine
async(startBall, AsyncBehavior.RESTART)    # Start Rule(startBall, Restart Rule)
```

The full language reference is in the [OverPy README](https://github.com/Zezombye/overpy#readme). The sections below cover what people new to OverPy tend to trip over in this repo.

### Blocks and annotations

- Blocks work like Python: a line ending in `:` opens a block, and indentation (4 spaces) closes it. A wrong indent silently moves an action into or out of an `if`, so check it in the diff.
- `@Event`, `@Condition`, `@Name` and `@Disabled` go at the top of a rule or `def`, before any action.
- `@Event eachPlayer` runs the rule once per player, with `eventPlayer` set. Without `@Event`, it's a global rule that runs once.
- Every `@Condition` must be true for the rule to fire (they're joined with "and"). A rule with no condition fires once at the start (an `eachPlayer` rule, once for each player).
- `@Name` sets the name a `def` shows in the Workshop editor. Rules and subroutines are named `<Area> - <what it does>` (`Controls - Dash cooldown`); the docs and the [feel-lock](#feel-lock) refer to them by those names.
- `@Disabled` keeps a rule in the code but turns it off, the same as unticking it in the Workshop editor.

### Waits, loops and subroutines

- `wait(0.05)` pauses the rule. The Workshop's shortest wait is about one tick (0.016 s), so `wait(0)` waits one tick.
- `wait(0.05, Wait.ABORT_WHEN_FALSE)` stops the rule if its conditions turn false during the wait. `Wait.RESTART_WHEN_TRUE` restarts it from the top when they turn true again.
- `waitUntil(condition, timeout)` waits until the condition is true or the timeout runs out, whichever comes first.
- `if ruleCondition: loop()` repeats the rule from the top while its conditions still hold. A loop **must** wait at least one tick per pass; a loop without a wait overloads the server, and the Workshop can shut the game down.
- Calling a `def` (`startRound()`) is `Call Subroutine`: the caller waits for it to finish. `async(startBall, AsyncBehavior.RESTART)` is `Start Rule`: it runs alongside the caller, and `RESTART` restarts it if it's already running (`AsyncBehavior.NOOP` leaves it running instead). Restarting a subroutine that has a `wait` over and over can eventually crash the server, which is what the `w_start_rule_crash` build warning is about. The ball engines already do this (they did in v1.3.2), but don't add `RESTART` calls to a subroutine with waits on a trigger that fires repeatedly.

### Macros and enums

- `#!define NAME value` is a macro: OverPy pastes `value` wherever `NAME` appears, before compiling. It costs nothing at runtime, but each use compiles to its own copy of the code. `MANUAL` and `BALL_FEEL_DEFAULTS` in `src/config/constants.opy` are examples.
- `enum` gives names to numbers: the first entry is 0, the next 1, and so on. `Preset.CUSTOM` compiles to the same number as before, so swapping a magic number for an enum doesn't change the compiled code. Enums index the packed arrays: `ballFeel[BallFeel.HIT_RADIUS]`.
- **A macro is the wrong tool when the copies matter.** A Workshop setting is the classic case: every copy of `createWorkshopSetting*` is a separate reference, and each setting may only be referenced once (see [When you add a setting](architecture.md#settings-and-presets)). A long macro used in many places also costs elements each time.

### Chased variables

`chaseAtRate(...)` and `chaseOverTime(...)` make the Workshop move a variable toward a value every tick on its own, without any rule setting it. The ball's position, speed and direction are chased this way. Because of a Workshop bug, a rule **condition** that reads a chased variable may not fire when you'd expect, which is what the many `w_ow2_rule_condition_chase` build warnings say.

The existing rules are tuned around this behaviour (it was already in v1.3.2), so don't "fix" those conditions in the core rules: the timing change is a feel change. In new rules, avoid conditions on chased variables. Check the value in a looping rule instead. Use `evalOnce(...)` when you need a variable's value right now rather than its live, chased value, for example `phasePosition[PhasePoint.LAST] = evalOnce(ballPosition)`.

### `goto` and labels

Some rules contain `goto lbl_0` and `lbl_0:`. They come from the decompiler: v1.3.2 used the Workshop's `Skip` and `Skip If` actions, which jump forward a number of actions, and when the decompiler can't turn a skip into an `if` block, it writes a `goto`. Rewriting them as `if` blocks is welcome, as long as the behaviour stays the same. The rewrite changes the compiled code, though, so inside [feel-locked](#feel-lock) rules it fails the check and isn't worth it.

## Adding variables

Variables are declared in `src/config/variables.opy` with a **fixed index**:

```python
globalvar ballSpeed 22
playervar kills 26
```

- Pick an unused index for new variables. The limit is 127. `npm run check` shows how many global slots are left. Skip the slots variant branches use (global 71–74 and 108 for `v1.3.3T`, see [Odd bits](architecture.md#odd-bits-worth-knowing)), or merging `main` into them clashes.
- Never change an existing index. It keeps diffs and in-game inspector output stable.
- Name new variables in `camelCase`. Many older names are inconsistent; rename them only in a PR dedicated to that.

## Bringing in-game edits back

If someone made changes in the in-game Workshop editor:

```sh
npm run decompile -- their-export.txt their-export.opy
```

Then copy the changed rules into the right files under `src/` (`src/main.opy` lists them), and run `npm run build`. Compare `workshop/genjiball.txt` with their export to confirm nothing was missed.

**Decompiler bug workaround:** OverPy 9.7.16 decompiles `Start Rule(x, Restart Rule)` as `startRule(x)`, which it then refuses to compile. `tools/decompile.mjs` rewrites it to `async(x, AsyncBehavior.RESTART)` automatically.

## How this repo was created

`original/genjiball-v1.3.2.txt` is the Workshop export as it came out of the game. It was decompiled with OverPy 9.7.16 and split into feature files by rule-name prefix, keeping the original order (they have since been moved into the folders under `src/`, still in that order). We then verified:

1. the split source compiles to exactly the same output as the unsplit decompile, and
2. decompiling that compiled output gives back the same OverPy, byte for byte.

So `workshop/genjiball.txt` is functionally the same as the original, though its formatting differs. If anything ever looks wrong in-game, the original export is still in `original/` for comparison.
