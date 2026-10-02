## What does this change?

<!-- A short description. Link the issue if there is one: "Fixes #12" -->

<!-- PRs normally target `main`. Only target a version branch (v1.3.2, v1.3.3T, ...)
     for a variant, or for a hotfix to an old release. See docs/branching.md. -->

## Checklist

- [ ] I edited the OverPy source in `src/`, not `workshop/genjiball.txt` by hand
- [ ] I ran `npm run build` and committed the updated `workshop/genjiball.txt`
- [ ] Touches ball/player feel → behind a default-off toggle, labelled `ball feel` / `player feel` (see "Ball and player feel" in `CONTRIBUTING.md`)
- [ ] If `tools/feel-lock.json` changed: this is a deliberate ball feel change and the PR has the `ball feel` label
- [ ] I tested it in a custom game (paste `workshop/genjiball.txt` into the Workshop)
- [ ] I updated the docs in `docs/` if I changed settings, controls or gameplay
- [ ] I added a line to `CHANGELOG.md` under "Unreleased"

## How did you test it?

<!-- Map, player count, settings/preset used, anything unusual. -->
