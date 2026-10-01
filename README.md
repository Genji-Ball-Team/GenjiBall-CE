# Genji Ball 1.3T (archive)

**Genji Ball 1.3T** is the Team Deathmatch version of Genji Ball made by **zSh4d0W**, built on v1.3.1. Players are split into two teams of up to 5, and a team scores when the other team has no one left alive. With passing turned on, a deflect can pass the ball to a teammate.

This branch is an **archive**. It isn't developed further. Teams development continues on `main`-based variants (`v1.3.3T` onward), using this version as the reference for how Teams played. See [docs/branching.md on `main`](../../blob/main/docs/branching.md).

## Files

| Path | What it is |
|---|---|
| `original/genjiball-v1.3T.txt` | The Workshop export as it came out of the game |
| `src/main.opy` | That export decompiled with OverPy 9.7.16, unchanged |
| `workshop/genjiball.txt` | `src/main.opy` compiled again. Paste this into the Workshop to play it |

`npm ci`, then `npm run build` to compile and `npm run check` to confirm `workshop/genjiball.txt` is up to date.

## How faithful the compiled code is

Decompiling `workshop/genjiball.txt` gives back `src/main.opy` byte for byte, and compiling it gives the same `workshop/genjiball.txt`. The formatting differs from the original export (for example `vect(0, -1, 0)` becomes `Vector.DOWN`), but the rules behave the same.

One known difference: the original had an empty `If` around a placeholder setting, `_custom settings` > "↓ only with "custom" preset", which only served as a label in the settings list. OverPy drops empty `If`s, so that label is missing from the compiled code. It doesn't affect gameplay. The original export in `original/` still has it.

## Credits

- **zSh4d0W**: 1.3T (Team Deathmatch, passing)
- **Mazawrath**: original creator of Genji Ball
- **ØøØøØzZØøØøØ** and the Official Genji Dodgeball community: numerous updates

See [CREDITS.md on `main`](../../blob/main/CREDITS.md) for everyone involved, and [LICENSE.md on `main`](../../blob/main/LICENSE.md) for the license status.
