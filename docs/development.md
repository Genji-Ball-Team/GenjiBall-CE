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
| `npm run check` | Compile and fail if `workshop/genjiball.txt` is stale or a [feel-locked](#feel-lock) rule changed (this is what CI runs) |
| `npm run feel-lock:update` | Rewrite `tools/feel-lock.json` after a deliberate ball feel change |
| `npm run decompile -- in.txt out.opy` | Turn Workshop code copied from the game into OverPy |

The build prints many **warnings** (chased variables in conditions, dark colors, legacy impulse flags). They were all present in v1.3.2 and are not errors. It's still welcome to fix them, one topic per PR.

## Feel-lock

The Workshop has no tests, so a refactor could change how the ball feels without anyone noticing. The feel-lock guards against that. `tools/feel-lock.json` is a snapshot of the **compiled** code of the core rules, in their list order:

- every rule and subroutine in `08-collision.opy`, `09-ball-physics.opy` and `06-round-flow.opy` (new rules added to those files are locked automatically)
- the dash/deflect timing rules in `05-controls.opy` (listed by name in `tools/feel-lock.mjs`)

`npm run check` compiles the source and compares. It fails, naming the rule, when a locked rule's compiled code changes, a locked rule is added, removed or renamed, or the locked rules change order relative to each other. Because it compares compiled code, comments and formatting in the source don't count, but any change to a value, condition or action does.

What it doesn't lock: rules outside that list, and a locked rule's absolute position. Adding a HUD rule early in the list is fine. Placing a rule between locked rules that reacts to the same variables in the same tick can still change feel, so check [Rule order](architecture.md#rule-order) when you do that.

**When the check fails:**

- If you didn't mean to change ball feel (a cleanup, a rename, moving code around), your change isn't behaviour-neutral. Fix it until the check passes.
- If you did mean to, run `npm run feel-lock:update` and commit `tools/feel-lock.json` with your change. Its diff shows reviewers exactly which compiled rules changed. The PR needs the **`ball feel`** label (CI fails without it) and an in-game playtest. New feel changes should be a default-off toggle, per the label's description.

## Testing in-game

1. `npm run build`
2. Open `workshop/genjiball.txt`, select all, and copy.
3. In a custom game lobby: **Settings → Import**, top right.
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

- `@Disabled` disables a rule without deleting it.
- `if ruleCondition: loop()` is the usual "repeat while conditions hold" pattern.
- `goto lbl_0` / `lbl_0:` come from the decompiler (Workshop `Skip`). Rewriting them as normal `if` blocks is welcome, as long as the behavior stays the same.
- The full language reference is in the [OverPy README](https://github.com/Zezombye/overpy#readme).

## Adding variables

Variables are declared in `src/variables.opy` with a **fixed index**:

```python
globalvar ballSpeed 22
playervar kills 26
```

- Pick an unused index for new variables. The highest global index in v1.3.2 is 112, and the limit is 127.
- Never change an existing index. It keeps diffs and in-game inspector output stable.
- Name new variables in `camelCase`. Many older names are inconsistent; rename them only in a PR dedicated to that.

## Bringing in-game edits back

If someone made changes in the in-game Workshop editor:

```sh
npm run decompile -- their-export.txt their-export.opy
```

Then copy the changed rules into the right files under `src/rules/`, and run `npm run build`. Compare `workshop/genjiball.txt` with their export to confirm nothing was missed.

**Decompiler bug workaround:** OverPy 9.7.16 decompiles `Start Rule(x, Restart Rule)` as `startRule(x)`, which it then refuses to compile. `tools/decompile.mjs` rewrites it to `async(x, AsyncBehavior.RESTART)` automatically.

## How this repo was created

`original/genjiball-v1.3.2.txt` is the Workshop export as it came out of the game. It was decompiled with OverPy 9.7.16 and split into `src/rules/*` by rule-name prefix, keeping the original order. We then verified:

1. the split source compiles to exactly the same output as the unsplit decompile, and
2. decompiling that compiled output gives back the same OverPy, byte for byte.

So `workshop/genjiball.txt` is functionally the same as the original, though its formatting differs. If anything ever looks wrong in-game, the original export is still in `original/` for comparison.
