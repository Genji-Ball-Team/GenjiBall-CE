# Branches, versions and releases

## Branches

| Branch | What it is |
|---|---|
| `main` | **Active development.** PRs go here, which is GitHub's default. It can contain changes that haven't been released yet. |
| `v1.3.2`, `v1.3.1`, … | **Released versions.** Each is a snapshot created when that version shipped. Only used for hotfixes to that version. |
| `v1.3.2T`, … | **Variants** (e.g. **T** = Teams). Long-lived branches with their own changes on top of a base version. |
| `feature/…`, `fix/…` | Your working branches (in your fork, or here if you're a maintainer) |

For players: the **stable** Workshop code is on the [Releases](../../../releases) page. `workshop/genjiball.txt` on `main` is the latest development build.

## Day-to-day flow

```
fix/some-bug ──PR──▶ main ──tag 1.3.3──▶ release
                       │
                       ├──▶ v1.3.3   (branch created at release)
                       └──▶ v1.3.2T  (variant; merge main or a release into it to pick up fixes)
```

1. Contributors branch off `main` and open PRs against `main`.
2. A maintainer reviews the PR, CI passes, and it's merged.

## Cutting a release

When `main` is ready to ship as, say, 1.3.3:

1. Bump the version text in a PR:
   - `src/settings.opy`: the lobby description and mode name
   - `src/rules/03-hud.opy`: the `"version 1.3.3"` HUD text
   - `package.json`: `version`
   - `CHANGELOG.md`: move "Unreleased" under a `## v1.3.3` heading
2. After it's merged, tag the commit and create the version branch:
   ```sh
   git switch main && git pull
   git tag -a 1.3.3 -m "Genji Ball CE v1.3.3"
   git branch v1.3.3
   git push origin 1.3.3 v1.3.3
   ```
3. The **Release** workflow builds the Workshop code and publishes a GitHub release with `genjiball-v1.3.3.txt` attached. If the tag is ever re-pushed, the workflow replaces the attached file and keeps the release notes.

**Tags have no `v`** (`1.3.3`, `1.3.2T`) because the branches already use `v1.3.3`-style names. A tag and a branch with the same name make Git commands ambiguous.

## Hotfixing an old version

Only needed if people still play an older version while `main` has moved on:

1. Open a PR against that version branch (e.g. `v1.3.2`).
2. After it's merged, tag it with a fourth number: `1.3.2.1`.
3. If the bug also exists on `main`, fix it there too (cherry-pick or a separate PR).

## Variants

Variants like `v1.3.2T` (Teams) live on their own branch:

```sh
git switch -c v1.3.2T 1.3.2    # start from the 1.3.2 release
# change the version text to 1.3.2T, commit
git push -u origin v1.3.2T
```

PRs for a variant target its branch. To pick up fixes from `main`, merge `main` (or a release tag) into the variant. Release it by tagging `1.3.2T`.

## Adding an older version

If you have the Workshop code for an older version (e.g. v1.3.1):

```sh
git switch --orphan v1.3.1
git checkout main -- package.json package-lock.json tools .gitignore .gitattributes .github
# put the export at original/genjiball-v1.3.1.txt
npm ci
npm run decompile -- original/genjiball-v1.3.1.txt src/main.opy
npm run build
```

You can split it into `src/rules/` the same way the current version is, but archived versions don't need it.
