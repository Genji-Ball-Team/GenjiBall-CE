# Contributing to Genji Ball CE

Thanks for helping out. You don't need to be a programmer to contribute. Bug reports, playtest feedback and docs fixes are all valuable.

## Ways to help

- **Report a bug.** [Open an issue](../../issues/new/choose). Say which version, which settings, and how to reproduce it. A clip helps a lot.
- **Suggest a feature.** Open a feature request. Most new features should be opt-in behind a Workshop setting, so they don't change the default game.
- **Improve the docs.** Everything in `docs/` is plain Markdown, so you can edit it right on GitHub.
- **Change the code.** Read on.

## Setting up (about 5 minutes)

You need [Node.js](https://nodejs.org/) 20 or newer, and Git.

```sh
git clone https://github.com/Genji-Ball-Team/GenjiBall-CE.git
cd GenjiBall-CE
npm ci
npm run build
```

For editing, [VS Code](https://code.visualstudio.com/) with the **OverPy** extension (`zezombye.overpy`) gives you syntax highlighting and autocomplete. The repo recommends it when you open the folder.

## Making a change

1. **Create a branch from `main`.** That's where development happens. (Working on a variant like `v1.3.2T`, or a hotfix for an old version? Branch from that branch instead. See [docs/branching.md](docs/branching.md).)
   ```sh
   git switch main
   git pull
   git switch -c fix/ball-clips-through-floor
   ```
2. **Edit the OverPy source** in `src/`. Don't edit `workshop/genjiball.txt` by hand, because it's regenerated on every build. [docs/development.md](docs/development.md) explains which file holds what.
3. **Build:** `npm run build`
4. **Test in-game.** Paste `workshop/genjiball.txt` into a custom game and try it. A second player, or the bot (`50 - Features > bot`), makes testing much easier.
5. **Commit both** your `src/` changes and the rebuilt `workshop/genjiball.txt`.
6. **Open a pull request** against `main` (GitHub's default) and fill in the template.

CI compiles your branch and fails if `workshop/genjiball.txt` doesn't match `src/`. If it fails, run `npm run build` and commit again.

### Made your change in the in-game Workshop editor instead?

That's fine. Copy the Workshop code out of the game, then:

```sh
npm run decompile -- my-export.txt my-export.opy
```

Find the rules you changed in `my-export.opy` and copy them into the matching file in `src/rules/`. Then build and check that `git diff` only shows your change.

## Guidelines

- **Keep gameplay changes opt-in** unless there's agreement on Discord or in the issue that the default should change. Tournament players rely on the default feel staying stable.
- **Don't change a variable's index** in `src/variables.opy`. Add new variables with an unused index. The Workshop has a limit of 128 global and 128 player variables. `npm run check` shows how many are left.
- **Rule order matters.** Rules run top to bottom, and `main.opy` includes files in order. Put new rules next to the ones they relate to.
- **Keep one topic per PR.** A small PR gets reviewed and merged much faster than a big one.
- **Explain the "why"** in comments for anything non-obvious, especially physics tuning numbers.
- **Update the docs** if you change a setting, control, or rule of the game.
- **Add a CHANGELOG line** under "Unreleased".

## Code of conduct

Be decent to each other. See [CODE_OF_CONDUCT.md](CODE_OF_CONDUCT.md).

## License of contributions

By opening a PR, you agree your contribution can be distributed as part of Genji Ball CE. See [LICENSE.md](LICENSE.md).
