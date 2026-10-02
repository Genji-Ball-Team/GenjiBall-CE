# Rank tags

v1.3.3R shows a tag over the head of players in the top tiers (Master, Grandmaster, Ascendant, Champion, God), and a tier guide on the right of the screen. Lower and new players get no tag. The game doesn't know anyone's rating: the tiers and the names in each come from one generated rule, `RANKS - generated`, that the host tool ([genjiball-host-tool](https://github.com/Genji-Ball-Team/genjiball-host-tool) "Ranked code generator") fills in from the ranked server ([genjiball-ranked](https://github.com/Genji-Ball-Team/genjiball-ranked) "Rank tags endpoint"). No share codes: the host pastes the code the host tool gives them.

All three repos depend on this page. Change it before changing the rule.

## The generated rule

In `workshop/genjiball.txt` (and the release asset), the rule looks like this, on one action line:

```
rule ("RANKS - generated") {
    event {
        Ongoing - Global;
    }
    actions {
        Set Global Variable(rankTags, Array(Custom String("Ranks update daily"), Array(Custom String("Master"), Custom Color(255, 215, 0, 255), Custom String("Master")), …));
    }
}
```

The host tool:

1. Finds the line `rule ("RANKS - generated") {`. It's there exactly once. If it isn't, it stops with an error instead of guessing.
2. Replaces everything from that line to the first line after it that is exactly `}` with its own rule, in the same shape.
3. Leaves the rest of the code untouched.

The rule sets the global variable `rankTags` and does nothing else. Its source is `src/features/rank-tags.opy`; the repo's version has the tiers but no names.

## `rankTags`

```
Array(
    Custom String("<line under the guide's header>"),
    Array(Custom String("<label>"), Custom Color(r, g, b, a), Custom String("<guide line>"), Custom String("<name>"), Custom String("<name>"), …),
    …
)
```

- **Index 0**: one line shown under "Live leaderboard: genjiball.us", for example `Ranks updated 2026-10-03`.
- **Index 1 onward**: one array per tier, **lowest tier first**. Any number of tiers.
  - `label`: the tag over the player (`Grandmaster`).
  - colour: `Custom Color` with 0–255 values, used for the tag and the guide line.
  - `guide line`: the tier's line in the guide, as the server wants it shown (`Grandmaster - 1600`). The thresholds come from the server's rating scale; the game shows whatever this says.
  - then the names of the players in that tier, as many as there are. A tier can have none.

A player gets the tag of the highest tier that lists their name. The name must be the in-game display name exactly as the Workshop writes it (`Custom String("{0}", Event Player)`): the BattleTag without `#1234`. The match is case-sensitive.

### Strings

- A `Custom String` holds at most 128 characters. Labels, guide lines and names stay well under that.
- Escape `"` as `\"` and `\` as `\\`. Leave out names that contain `{` or `}`: the Workshop reads them as placeholders.
- Every string and colour costs Workshop elements, and the code has room for about 20,000 more. Keep the whole rule under about 500 names (only the top tiers are listed, so far fewer in practice).

## In game

- The tier is looked up once per player, a moment after they first spawn. A new code with new names needs a new lobby.
- Tags follow FFA slots: one in-world text per slot (12), shown over the player in that slot while they are alive and tagged. Nothing is left behind when a player leaves.
- The guide is on the right, highest tier first, hidden with simple HUD (Interact), with "Press [Interact] to hide" except in Sandbox.
- There's no live rating in game. Tags change when the host gets a new code from the host tool.
