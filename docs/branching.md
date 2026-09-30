# Branches, versions and releases

## Branches

| Branch | What it is |
|---|---|
| `main` | The latest **stable** release. It's what people see first on GitHub. Don't open PRs against it directly. |
| `v1.3.2` | Development of the 1.3.x line. **PRs go here.** |
| `v1.3.1`, `v1.2.x`, … | Older versions, kept for reference and occasional fixes |
| `v1.3.2T`, … | Variants (e.g. **T** = Teams). Long-lived branches that share history with their base version |
| `feature/…`, `fix/…` | Your working branches (in your fork, or here if you're a maintainer) |

The version number shown in-game is set in two places. Update both when bumping:
- `src/config/lobby.opy`: the lobby description and mode name
- `src/ui/hud.opy`: the `"version 1.3.2"` HUD text

Also update `version` in `package.json`.

## Flow

```
fix/some-bug ──PR──▶ v1.3.2 ──(release)──▶ main
                        │
                        └──branch──▶ v1.3.2T  (teams variant; merge v1.3.2 into it to pick up fixes)
```

1. Contributors open PRs against the version branch.
2. A maintainer reviews it, CI passes, and the PR is merged.
3. When the branch is ready to release, a maintainer:
   - moves the "Unreleased" section of `CHANGELOG.md` under a version heading
   - merges the version branch into `main` (for the latest stable line)
   - tags the commit with the version number, **without a `v`**: `git tag 1.3.3 && git push origin 1.3.3`
4. The **Release** workflow builds the Workshop code and publishes a GitHub release with `genjiball-v1.3.3.txt` attached.

Tags have no `v` because the branches already use `v1.3.2`-style names. A tag and a branch with the same name would make Git commands ambiguous. Variants are tagged the same way: `1.3.2T`.

## Starting a new version or variant

```sh
git switch v1.3.2
git switch -c v1.3.2T
# bump the version text (see above), commit, push
git push -u origin v1.3.2T
```

## Adding an older version

If you have the Workshop code for an older version (e.g. v1.3.1):

```sh
git switch --orphan v1.3.1         # or branch from the closest ancestor
# put the export at original/genjiball-v1.3.1.txt
npm run decompile -- original/genjiball-v1.3.1.txt src/main.opy
npm run build
```

You can split it into folders the same way the current version is, but it's not required for archived versions.
