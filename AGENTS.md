# Genji Ball CE

Genji Ball Community Edition is an Overwatch Workshop game mode. The source is [OverPy](https://github.com/Zezombye/overpy) in `src/` (entry point `src/main.opy`), which compiles to `workshop/genjiball.txt`.

- Never edit `workshop/genjiball.txt` by hand. Edit `src/`, build, and commit both.
- `original/` holds untouched Workshop exports. Don't edit them.

## Commands

| Command | Use |
|---|---|
| `npm ci` | Install the pinned OverPy |
| `npm run build` | Compile `src/` to `workshop/genjiball.txt` |
| `npm run check` | What CI runs: stale build, feel-lock, resource budget, settings docs. **It must pass before a change is done.** |
| `npm run docs:settings` | Regenerate the settings tables in `docs/hosting.md` after adding, renaming or changing a setting |

The build prints many warnings (chased variables in conditions, dark colors, legacy impulse flags). They were already there in v1.3.2 and are expected. Only new warnings from your change matter.

## You can't test in-game

Nothing here runs outside Overwatch. When behaviour could change, say in the PR exactly what needs checking in a custom game, and suggest the `playtest needed` label. Don't tick the "tested in a custom game" checkbox.

## Ball and player feel

Tournament players rely on the game feeling identical between versions. Full rules: "Ball and player feel" in [CONTRIBUTING.md](CONTRIBUTING.md#ball-and-player-feel).

- Any change to how the ball moves, collides or deflects, or how a player moves or controls, goes behind a Workshop setting that is **off by default** and keeps the old behaviour when off.
- `Default`, `Tournament` and `Tournament+` never turn such a toggle on.
- Making a hardcoded number configurable is fine if the default is the current value.
- **If the feel-lock fails, your change isn't behaviour-neutral: fix the change.** Never run `npm run feel-lock:update` to make the check pass, unless the task is a deliberate feel change (then the PR needs the `ball feel` label).

## Variables

Every variable has a fixed index in `src/config/variables.opy`. Never renumber one. A new variable takes an unused index (skip the slots variant branches use, see `docs/development.md`, "Adding variables"). The Workshop allows 128 global and 128 player variables; global slots are the tightest, so prefer packing related values into an existing array.

## Workshop settings

- Each `createWorkshopSetting*` call is referenced **once**, in `Settings - Workshop settings` (`src/config/workshop-settings.opy`).
- Setting names must be unique ignoring case and spacing. Categories and names may not be blank or contain `{`, `}` or `:` (`npm run check` fails).
- To read many settings without spending globals, pack them into one array indexed by an enum, like `experimentalTuning` / `ExperimentalTuning` and `addOnSettings` / `AddOnSetting`.
- Never use a macro that expands a setting in more than one place: each use compiles to another reference (see #62 / PR #68).
- Then run `npm run docs:settings` and write the new row's description in `docs/hosting.md`.

## Rule order matters

The Workshop runs rules top to bottom, and include order in `src/main.opy` is rule order. Before moving a rule, or adding one that reacts to the same variables as an existing rule, read [Rule order](docs/architecture.md#rule-order). Includes marked `#ORDER:` in `main.opy` are order-sensitive.

## PR habits

- One topic per PR, branched from `main`. Fill in `.github/PULL_REQUEST_TEMPLATE.md`.
- Add a line to `CHANGELOG.md` under "Unreleased".
- Update `docs/` when a setting, control or game rule changes.
- Match the surrounding code: comment style, `camelCase` for new names, named constants from `src/config/constants.opy` instead of magic numbers.

## Other repos

Ranked spans three repos in the Genji-Ball-Team org, cloned side by side in the same parent folder:

| Repo | What it is |
|---|---|
| `GenjiBall-CE` (this one) | The game. Ranked logging and rank tags live on the `v1.3.3R` branch only, never on `main` |
| `genjiball-ranked` | Cloudflare Worker: upload API, log parser, ratings, website |
| `genjiball-host-tool` | Tauri app: watches the host's Workshop log folder and uploads matches |

- The log format in `docs/ranked-log.md` (on `v1.3.3R`) is the contract between all three. Change it there first, in its own PR, then update the parser and host tool. Bump the format version when an old parser would misread the new lines.
- An issue here may need work in another repo. Check that repo's issues before starting, keep one PR per repo, and link them to each other (`Genji-Ball-Team/genjiball-ranked#3`).
- A sibling repo that isn't cloned yet: use `gh -R Genji-Ball-Team/<repo>` rather than guessing its contents. Each repo has its own `AGENTS.md`; follow it when working there.
- PRs into a branch other than `main` (like `v1.3.3R`) don't auto-close issues. Close them by hand after the merge.

## Where to read more

- [docs/development.md](docs/development.md): commands, feel-lock, settings docs, OverPy reference and pitfalls, adding variables
- [docs/architecture.md](docs/architecture.md): source layout, game loop, collision, physics, rule order, settings and presets, limits
- [docs/hosting.md](docs/hosting.md): every Workshop setting and preset, as hosts see them
- [docs/branching.md](docs/branching.md): branches, variants, cutting a release
