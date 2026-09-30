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
| `npm run check` | Compile and fail if `workshop/genjiball.txt` is stale (this is what CI runs) |
| `npm run decompile -- in.txt out.opy` | Turn Workshop code copied from the game into OverPy |

The build prints many **warnings** (chased variables in conditions, dark colors, legacy impulse flags). They were all present in v1.3.2 and are not errors. It's still welcome to fix them, one topic per PR.

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

Variables are declared in `src/config/variables.opy` with a **fixed index**:

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

Then copy the changed rules into the right files under `src/` (`src/main.opy` lists them), and run `npm run build`. Compare `workshop/genjiball.txt` with their export to confirm nothing was missed.

**Decompiler bug workaround:** OverPy 9.7.16 decompiles `Start Rule(x, Restart Rule)` as `startRule(x)`, which it then refuses to compile. `tools/decompile.mjs` rewrites it to `async(x, AsyncBehavior.RESTART)` automatically.

## How this repo was created

`original/genjiball-v1.3.2.txt` is the Workshop export as it came out of the game. It was decompiled with OverPy 9.7.16 and split into feature files by rule-name prefix, keeping the original order (they have since been moved into the folders under `src/`, still in that order). We then verified:

1. the split source compiles to exactly the same output as the unsplit decompile, and
2. decompiling that compiled output gives back the same OverPy, byte for byte.

So `workshop/genjiball.txt` is functionally the same as the original, though its formatting differs. If anything ever looks wrong in-game, the original export is still in `original/` for comparison.
