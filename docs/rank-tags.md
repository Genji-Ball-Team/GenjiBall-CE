# Rank tags

v1.3.3R shows the ranked leaderboard's top 10 in the lobby: a tag over each of their heads with their place and rating (`#1 | 2074`), and a top 10 list on the right of the screen. Everyone else gets no tag. The game doesn't know anyone's rating: the players, their places and ratings come from one generated rule, `RANKS - generated`, that the host tool ([genjiball-host-tool](https://github.com/Genji-Ball-Team/genjiball-host-tool) "Ranked code generator") fills in from the ranked server's leaderboard ([genjiball-ranked](https://github.com/Genji-Ball-Team/genjiball-ranked) `GET /api/leaderboard`) for the host's region. No share codes: the host pastes the code the host tool gives them.

All three repos depend on this page. Change it before changing the rule.

## The generated rule

In `workshop/genjiball.txt` (and the release asset), the rule looks like this, on one action line:

```
rule ("RANKS - generated") {
    event {
        Ongoing - Global;
    }
    actions {
        Set Global Variable(rankTags, Array(Custom String("Top 10 on 2026-10-05"), Array(Custom String("#10 | 1702"), Custom Color(255, 215, 0, 255), Custom String("#10 Kenzo - 1702"), Custom String("Kenzo")), …));
    }
}
```

The host tool:

1. Finds the line `rule ("RANKS - generated") {`. It's there exactly once. If it isn't, it stops with an error instead of guessing.
2. Replaces everything from that line to the first line after it that is exactly `}` with its own rule, in the same shape.
3. Leaves the rest of the code untouched.

The rule sets the global variable `rankTags` and does nothing else. Its source is `src/features/rank-tags.opy`; the repo's version has no players, only a line saying the top 10 comes with the host tool's code.

## `rankTags`

```
Array(
    Custom String("<line under the list's header>"),
    Array(Custom String("<label>"), Custom Color(r, g, b, a), Custom String("<list line>"), Custom String("<name>")),
    …
)
```

- **Index 0**: one line shown under "Live leaderboard: genjiball.us", for example `Top 10 on 2026-10-05`.
- **Index 1 onward**: one array per top player, **the best last** (index 1 is #10 of a full top 10). At most 60.
  - `label`: the tag over the player: their place and rating, `#1 | 2074`.
  - colour: `Custom Color` with 0–255 values, used for the tag and the list line. The host tool uses the colour of the player's tier on the site.
  - `list line`: the player's line in the top 10 list, `#1 MauMau - 2074`. The game shows whatever this says.
  - then the player's name. The game takes any number of names per entry, all with the same tag, but the host tool writes one.

A player gets the tag of the last entry that lists their name. The name must be the in-game display name exactly as the Workshop writes it (`Custom String("{0}", Event Player)`): the BattleTag without `#1234`. The match is case-sensitive.

### Strings

- A `Custom String` holds at most 128 characters. Labels, list lines and names stay well under that.
- Escape `"` as `\"` and `\` as `\\`. Leave out names that contain `{` or `}`: the Workshop reads them as placeholders.
- Every string and colour costs Workshop elements, and the code has room for about 20,000 more. Ten entries cost about 50.

## In game

- The entry is looked up once per player, a moment after they first spawn. A new code with new names needs a new lobby.
- Tags follow FFA slots: one in-world text per slot (12), shown over the player in that slot while they are alive and tagged. Nothing is left behind when a player leaves.
- The list is on the right: "Live leaderboard: genjiball.us" (sort order -100), index 0 (-99), then each entry at -30 minus its index, so the best is first and no entry's line can go above the header. Simple HUD (Interact) hides it, with "Press [Interact] to hide" (-20) except in Sandbox.
- `70 - Ranked` in the Workshop settings turns the tags (`rank tags`) and the list (`top 10 list`) off, and sets the tag's height and size ([hosting.md](hosting.md#70---ranked)).
- There's no live rating in game. Tags change when the host gets a new code from the host tool.
