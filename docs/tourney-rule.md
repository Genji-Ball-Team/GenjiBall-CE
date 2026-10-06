# Tourney rule

A tourney lobby plays a round-based match instead of a timed one, logs a `TOURNEY` line and ends with a final standings panel the host screenshots ([Tourney matches](ranked-log.md#tourney-matches)). The game doesn't know about tourneys: one generated rule, `TOURNEY - generated`, turns all of it on. The host tool ([genjiball-host-tool#9](https://github.com/Genji-Ball-Team/genjiball-host-tool/issues/9)) fills it in with the lobby's values from the ranked server ([genjiball-ranked](https://github.com/Genji-Ball-Team/genjiball-ranked) "Admin: schedule tourneys, lobbies and hosts"). It works like [`RANKS - generated`](rank-tags.md), and a tourney code has both rules filled in.

All three repos depend on this page. Change it before changing the rule.

## The generated rule

In `workshop/genjiball.txt` (and the release asset), the rule looks like this, on one action line:

```
rule ("TOURNEY - generated") {
    event {
        Ongoing - Global;
    }
    actions {
        Set Global Variable At Index(rankedState, 16, Array(True, Custom String("073518264903"), 30, Custom String("October Cup"), Custom String("Lobby 1/2")));
    }
}
```

The host tool:

1. Finds the line `rule ("TOURNEY - generated") {`. It's there exactly once. If it isn't, it stops with an error instead of guessing.
2. Replaces everything from that line to the first line after it that is exactly `}` with its own rule, in the same shape.
3. Leaves the rest of the code untouched.

The rule sets index **16** of the global variable `rankedState` and does nothing else. Index 16 is fixed (`RankedField.TOURNEY` in `src/config/constants.opy`): the game never moves it. Its source is `src/features/tourney.opy`; the repo's version is off:

```
Set Global Variable At Index(rankedState, 16, Array(False, Custom String(""), 30, Custom String(""), Custom String("")));
```

A ranked code (no tourney) keeps that rule as it is. With it off, the match is a ranked match, exactly as without this rule.

## The values

`Array(on, lobbyKey, roundLimit, name, lobbyLabel)`, in this order (`TourneyField`):

| # | Value | Format | What it does |
|---|---|---|---|
| 0 | on | `True` or `False` | `True` in a tourney code. `False`: everything below is ignored |
| 1 | `lobbyKey` | `Custom String("…")`, digits only | The server's id for the tourney lobby, logged as is in `TOURNEY` (`TOURNEY\|time\|lobbyKey\|roundLimit`). Text, so it keeps a leading `0`. 12 digits, like `matchKey` |
| 2 | `roundLimit` | a whole number, written plainly (`30`) | Rounds the match lasts. Replaces the `tournament rounds` setting and the preset's value. Below 1, the game uses 30 (`TOURNEY_DEFAULT_ROUNDS`). The `TOURNEY` line logs the limit the match plays |
| 3 | name | `Custom String("…")` | The tourney's name, on the right of the HUD and on the final standings (`October Cup`) |
| 4 | lobby label | `Custom String("…")` | The lobby's label next to the name (`Lobby 1/2`) |

### Strings

- Keep the name and the label under 40 characters each: they share a HUD line.
- Escape `"` as `\"` and `\` as `\\`. Leave out `{` and `}`: the Workshop reads them as placeholders.

## In game

With the rule on:

- **Settings.** Tournament mode is on, whatever the preset: no match timer and no timed tiebreaker. Ranked logging is on, whatever `70 - Ranked > ranked logging` says: the rounds are counted by the ranked log, and the server needs the log. The lobby should play the **Tournament** preset; any other preset makes the match unranked (`UNRANKED` `PRESET`, warning "the preset isn't Tournament").
- **Rounds.** Every `ROUND_START` counts toward the limit, restarts included (`NONE` and `ABORT` rounds). The HUD on the right shows the name and label, and `ROUND: x / N` instead of `ROUNDS LEFT`. Breaks work as in tournament mode, except that there's no break after the last round.
- **End.** After the `ROUND_END` of round `N`, the game waits 1 s (`TOURNEY_MATCH_END_DELAY`, so the round's last `KILL` and `LEAVE` lines come first), logs `MATCH_END|time|ROUNDS` and logs nothing more. The next round's ball is held.
- **Final standings.** At the top of everyone's screen, spectators too: "FINAL STANDINGS", the name and label, `Match <matchKey>` (the 12 digits from `GBR`), then one line per player in a slot with an id: `place. name   wins wins   kills kills`. Wins are rounds won (`ROUND_END` `WIN`), kills are `KILL` lines with the player as the attacker, both counted from their last `JOIN`. Most wins first, ties broken by kills, the same wins and kills share a place (1, 2, 2, 4). They stay up 30 s (`TOURNEY_STANDINGS_TIME`) for the host's screenshot, then the match ends and the lobby resets.
