# Ranked log format

v1.3.3R writes what happens in a match to the Workshop log, the host tool uploads it, and the ranked server ([genjiball-ranked](https://github.com/Genji-Ball-Team/genjiball-ranked)) turns it into matches, rounds and ratings. All three depend on this page. Change it before changing the logging code, and bump the [format version](#versions) when an old parser would misread the new lines.

The example log [`ranked-log-example.txt`](ranked-log-example.txt) is a full short match in this format. It's the parser's test file, and [Example](#example) says what it should parse to.

## The log file

`Log To Inspector` lines go to the Workshop inspector. With the Overwatch option **Enable Workshop Inspector Log File** on (Options → Gameplay → General), they are also written to a text file on the host's PC:

```
Documents/Overwatch/Workshop/Log-<date>-<time>.txt
```

With the inspector disabled, nothing reaches the file. v1.3.3 disables it at start to save server load, so v1.3.3R keeps it on while ranked logging is on.

The Workshop adds a prefix to every line: `[hh:mm:ss] ` (then one space). It isn't the time of day: it counts from when the game started, the same clock as [`time`](#time) in whole seconds (`[00:00:08]` for `8.02`). The parser strips it and doesn't use it. Everything after the prefix is ours:

```
[00:00:28] KILL|28.40|Sparrow|Ghost|1|4
```

In the playtest, the next match in the same lobby started a new file, with `time` from 0 again. The parser still allows several matches in one file. A file can also hold other lines (an inspector log from another mode, the [legacy](#legacy-v132-logs) `KILL` lines). The parser reads the file top to bottom, starts a match at each [`GBR`](#events) line and ignores lines it doesn't know.

### One match in several files

The file is written while the match is played. Each time the host moves to spectator, and again when they come back, Overwatch starts a **new file that repeats the whole log so far**, and the old file stops there. So the same match can be in several files, each one a longer copy of the one before.

The `matchKey` in `GBR` tells them apart: lines with the same host and the same `matchKey` are the same match. The host tool may upload every file. The server keeps, for each host and `matchKey`, the copy with the most lines and drops the others, so a match is never counted twice. A copy with fewer lines is always the start of the longer one.

## Lines

One event per line, fields separated by `|`:

```
TYPE|time|field|field|…
```

- `TYPE` is upper case. `time` is always the second field.
- No field ever contains `|` or a line break. Player names can't contain either.
- An empty field means "none" (for example `KILL` with no attacker).
- Player fields are [player ids](#players), not names, except in `JOIN` and the names in `KILL`.
- Numbers are written the way the Workshop formats them (`28.4`, `28.40` or `28`). The parser accepts both `.` and `,` as the decimal mark, in case the Workshop formats numbers by the host's language.
- A newer game may append fields to the end of a line. The parser ignores fields it doesn't know. Fields are never reordered or removed without a new format version.

### Time

`time` is the Workshop's **Total Time Elapsed** in seconds, as v1.3.2 RANKED logged it. It counts from when the game instance started, not from `MATCH_START`, and starts again from 0 in the next match. So:

- match time = `time` − the `time` of the match's `MATCH_START`
- order events by their position in the file, not by `time`. Two events in the same tick have the same `time`, and two rules that fire in the same tick may log in either order. Nothing in the format depends on the order of lines with the same `time`, except where this page says so.

## Players

What the Workshop knows about a player: their **display name** (the BattleTag without the `#1234` number), their slot, their hero, and whether they're a bot. Nothing else identifies the account. Names change, and two players in one lobby can have the same name.

So the game gives every player a **player id** when they join: a whole number, starting at 1 in each match and never reused in that match. The name is logged once, in `JOIN`, and every other line uses the id.

- The id stays the same while the player stays in the lobby. It's stored on the player, so moving slots doesn't change it.
- A player who leaves and comes back gets a `LEAVE`, then a new `JOIN` with a new id.
- Two players with the same name get different ids, so the log is never ambiguous within a match.
- Players already in the lobby when the match starts get their `JOIN` right after `MATCH_START`, or when they spawn if they haven't yet. `JOIN` waits for the spawn so the name is known: an AI bot logged as it took the slot had no name yet (`Entity 84`). Spectators aren't players and get no id until they join a slot.

Which **account** a name belongs to is the server's job, not the log's: the server maps names to players, and admins merge names (genjiball-ranked "Admin: merge aliases and names"). When one match has two players with the same name, the server must not guess which is which. It keeps the match for an admin to review.

## Matches and rounds

A **match** is everything from `GBR` to `MATCH_END`. If the file ends without `MATCH_END` (the host closed the lobby, the game crashed), the match is incomplete: rounds that have a `ROUND_END` can still be used, and the rest is dropped.

A **round** is one round of play, from `ROUND_START` to `ROUND_END`. Rounds are numbered from 1 in each match, and the number goes up at every `ROUND_START`, including a round that restarts because everyone died and a tiebreaker round. The final duel isn't a round of its own: it's the end of the round it happens in.

Which players are in a round:

- **In the round:** the players listed in `ROUND_START`, every player alive when the round starts. In a tiebreaker, only the tied players are alive, so only they are listed.
- **Eliminated:** each gets one `ELIM`, in the order they went out.
- **Left:** a player who leaves during the round gets a `LEAVE` and no `ELIM`. The server drops them from that round: no rating change for them, the others are rated on their order without them. Leaving is normal and is never punished.
- **Joined:** a player who joins during a round isn't in it. They play from the next round.
- **Winner:** the last player alive, in `ROUND_END`.

## Events

`id` is a [player id](#players), `round` a round number. Every line starts with `TYPE|time`, left out of the fields column.

| Type | Fields | When |
|---|---|---|
| `GBR` | `format`, `gameVersion`, `matchKey` | First line of every match, before `MATCH_START`. `format` is the [format version](#versions) (`1`), `gameVersion` the build (`1.3.3R`). `matchKey` is 12 random digits picked at match start, the same in every [copy of the match](#one-match-in-several-files). Treat it as text, not a number. |
| `MATCH_START` | `map`, `preset`, `feel`, `addOns` | Match start. `map` is our own code, not the map's name (which the Workshop translates): `workshop-island-night`, or `other`. `preset` is the Preset setting as named in `docs/hosting.md` (`Default`, …). `feel` is `1` if any ball or player feel toggle is on, else `0`: custom ball feel, water ledge fix, tracing mode, anti-ghost correction (not off) or AntiOrbit. `addOns` lists the gameplay add-ons that are on, comma-separated (`duels`, `endless`, `sandbox`, `abilities`), empty when none. |
| `JOIN` | `id`, `name` | A player joins a slot, or is already in one at `MATCH_START`. |
| `LEAVE` | `id` | A player leaves the lobby or moves to spectator. |
| `ROUND_START` | `round`, `ids` | A round starts. `ids` lists everyone in the round, comma-separated (`1,2,3,4,5`). |
| `ELIM` | `round`, `id`, `killer`, `place` | A player in the round is eliminated: hit by the ball, fell, or anything else. `killer` is the player whose deflect sent the ball, empty when there is none or it's the player themselves. `place` is their finishing place: the number of players still alive after them, plus 1 (the first of 5 out gets `5`). A place can be skipped when someone left the round. |
| `ROUND_END` | `round`, `winner`, `result` | A round ends. `result` is `WIN` (one player left, `winner` is their id), `NONE` (everyone died, `winner` empty, the round restarts) or `ABORT` (the round was stopped before anyone won, `winner` empty). |
| `KILL` | `attacker`, `victim`, `attackerId`, `victimId` | Any player death, in or out of a round (a player who joins mid-round is killed too). The first fields are the v1.3.2 `KILL` line unchanged ([legacy](#legacy-v132-logs)), the ids are new. `attacker` and `attackerId` are empty when there's no attacker or it's the victim themself, as in `ELIM`. `victimId` is empty for a player who has no id yet (not spawned). |
| `DEFLECT` | `round`, `id`, `speed`, `target` | A player deflects the ball, during a round only. `speed` is the ball speed after the deflect, rounded to a whole number; `target` is the player the ball now goes for. Each player can deflect at most once every 0.8 s (deflect window plus lockout), so a round logs at most about 1.25 `DEFLECT` lines per second per player alive. |
| `UNRANKED` | `reason` | The match [won't count](#unranked-matches). Logged once per reason, at `MATCH_START` or when it happens. |
| `MATCH_END` | `result` | `TIME` when the match ends normally (time ran out and any tiebreaker is over). |

`ELIM` and `KILL` for the same death are both logged. The rating uses only `ELIM`. `KILL` is for stats and for one parser path shared with legacy logs. Don't rely on which of the two comes first.

## How the server rates a round

For genjiball-ranked "Rating engine: OpenSkill per round". The server, not the log, decides what counts:

- Only rounds with `ROUND_END` `WIN` are rated. `NONE` and `ABORT` rounds are kept for stats only.
- Finishing order: the winner first, then the `ELIM`s from last to first. Players who left the round are dropped.
- A round is rated if at least 2 players are left after dropping leavers.
- A round where a listed player has neither an `ELIM`, a `LEAVE` nor the win is broken: it isn't rated, and the parser reports it.
- The minimum number of players for a match to count is server config, not part of the log.

## Unranked matches

The game decides when a lobby isn't a ranked setup, shows the warning in game ("Unranked warning") and logs `UNRANKED` with the reason. The server rejects every match with an `UNRANKED` line, even if the host uploads it.

| Reason | When |
|---|---|
| `MAP` | The map isn't Workshop Island Night. |
| `MODE` | The mode isn't free-for-all. |
| `PRESET` | The Preset isn't `Default`. |
| `FEEL` | A ball or player feel toggle is on. |
| `ADD_ON` | A gameplay add-on is on: duels, endless, sandbox or custom abilities. |
| `BOT` | A bot (Zbozo) joined. Logged when it joins. |

With ranked logging turned off in the Workshop settings (`70 - Ranked > ranked logging`), the game logs nothing at all (so there's no logging cost), and the in-game warning is the only sign. The host tool ignores files without a `GBR` line.

The player limit (10) is a lobby setting, so there's no reason for too many players. Too few players is a server rule (above).

## String limits

A Workshop custom string holds at most 128 characters of literal text and 3 placeholders (`{0}`, `{1}`, `{2}`). OverPy splits longer strings into nested ones, but we don't rely on long results: every line stays well under 128 characters.

- Names are only in `JOIN` and `KILL`. A BattleTag name is at most 12 characters, and console names aren't much longer.
- `ROUND_START` lists ids, not names: 10 ids of up to 3 digits is under 40 characters, so the whole line fits one string and never has to be split.

Lines with more than 3 fields (`KILL`, `ELIM`, `DEFLECT`, `MATCH_START`) need nested strings, which OverPy writes from a normal `"…".format(…)`.

## Versions

The `format` field of `GBR` is the format version. This page describes version **1**.

- Adding a field at the end of a line, a new event type or a new `UNRANKED` reason: same version. Old parsers ignore what they don't know.
- Changing or removing a field, or changing what a field means: new version, and the server keeps a parser for each version it has accepted logs in.

The parser rejects a match whose version it doesn't know, with a clear error.

## Legacy v1.3.2 logs

The v1.3.2 RANKED version (`original/genjiball-v1.3.2-ranked.txt`) logged one line per death and nothing else:

```
KILL|time|attacker|victim
```

with `time` the Total Time Elapsed and names, not ids. That's why `KILL` keeps those four fields first. A file without a `GBR` line but with `KILL` lines is a legacy log, handled by genjiball-ranked's legacy parser ("Legacy log parser (v1.3.2 KILL lines)"). It can't tell rounds, joins, leaves or deflects, so it rebuilds them as well as it can and imports them marked as legacy.

## Example

[`ranked-log-example.txt`](ranked-log-example.txt) is one match, format 1, map `workshop-island-night`, preset `Default`, no feel toggles or add-ons, not unranked. It starts with a line that isn't ours, which the parser skips.

Players: 1 Sparrow, 2 Tidal, 3 Mochi, 4 Ghost, 5 Ghost (a second player with the same name, so the server holds this match for review), 6 Nova (joins after round 1).

| Round | In the round | Finishing order (rated) | Notes |
|---|---|---|---|
| 1 | 1, 2, 3, 4, 5 | 1, 5, 3, 4 | Tidal (2) leaves mid-round and is dropped. Places 5, 4, 2: place 3 is skipped. One `ELIM` comes before its `KILL`. |
| 2 | 1, 3, 4, 5, 6 | 6, 5, 1, 4, 3 | Ghost (4) falls: `ELIM` and `KILL` with no killer. |
| 3 | 1, 3, 4, 5, 6 | 1, 4, 5, 3, 6 | |

The match ends with `MATCH_END` `TIME`. Round wins: Sparrow 2, Nova 1.

## Left out

- **Per-tick data** (positions, ball speed every frame): too many lines for the host and the log file. Everything here is logged only when it happens.
- **`TOUCH`**: every time the ball reaches a player it's either a deflect (`DEFLECT`) or an elimination (`ELIM`). A separate touch event would repeat one of the two.
- **Match winner and scores**: the winner of each round is in `ROUND_END`, so scores can be counted from the log.

## To check in a custom game

Seen in the first playtest (2026-10-02, English client): the file is written on the host's PC while the match is played, the prefix counts from the game start, `time` has 2 decimals and a `.` (`8.02`), and each move of the host to or from spectator starts a new file with the whole log so far (3 files for one match, all with the same `matchKey`). The next match in the same lobby started its own file, with `time` from 0 again. Still to check in the release candidate playtest:

- the menu path of **Enable Workshop Inspector Log File**
- the decimal mark in other languages
