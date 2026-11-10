# Hosting a game

## Importing the code

### With an import code

| Version | Import code | Published by |
|---|---|---|
| v1.3.3 (current) | **`926FG`** | Genji Ball Team |
| v1.3.2 | **`C62PC`** | FROZONE (Frozonovic) |
| v1.3.3T (Team Deathmatch, [own page](https://workshop.codes/GenjiBall-CE-Teams)) | **`11M60`** | Genji Ball Team |

In Overwatch: **Play → Custom Games → Import Code**, and enter the code.

When a new version is released, a maintainer adds its import code to this table and to the release notes. Import codes can only be created in-game.

### By pasting the Workshop code

1. Get the Workshop code from the latest [release](../../../releases). That's the stable version. [`workshop/genjiball.txt`](../workshop/genjiball.txt) on `main` is the latest development build, and each version branch (e.g. `v1.3.2`) has the code for that release.
2. In Overwatch: **Play → Custom Games → Create**.
3. Open **Settings** and click the **Import** / paste icon in the top right. Your clipboard needs to contain the code. Import into a new custom game, not on top of an existing one: pasting over a game that already has Workshop settings can fail with "Categories and names of Workshop Settings may not be blank and may not contain '{', '}', or ':'".
4. Change anything you want under **Settings → Workshop → Settings** (see below), then start the game.

The lobby is set up for **Deathmatch (FFA)** with up to **10 players** and 12 spectators. Only Genji is allowed.

### Ranked lobbies

This branch (`v1.3.3R`) is the ranked version. The code is already set up for a ranked lobby, the same setup as the v1.3.2 RANKED version:

- **Deathmatch (FFA)** on **Workshop Island Night** only, up to **10 players**, 12 spectators. Don't enable other maps.
- Workshop settings at their defaults: preset **Default**, no bot. The ball and players feel as in v1.3.3 `Default`, plus the network resync (the ball's direction is resent to every client 20 times a second) and double sens on by default. The ranked code has no ball, arena, player or match settings: they're fixed to v1.3.3's `Default` values, so a host can't change them by mistake.
- `70 - Ranked > ranked logging` on (the default), and **Enable Workshop Inspector Log File** on in the Overwatch options, so the match reaches a log file the host tool can upload.

The code shows the leaderboard's top 10 in the lobby: a tag over each of them with their place and rating (`#1 | 2074`), and a top 10 list on the right. Other players in a rank tier get the tier's name as their tag. They come from the host tool, which builds the code with the region's current tiers and top 10 ([rank-tags.md](rank-tags.md)); the code in this repo has no players, so it shows no tags.

**Sitting out.** You play the first round, then sit out: you stay in your slot, dead, and the lobby plays without you. Press **Crouch + Interact** to play again from the next round, and again to sit out from the next round; the HUD on the left says which. Pressing it during the pause after a round win counts for the round right after. While the lobby waits for players, it takes effect at once. You don't count as a player while you sit out, so with you and one other player the lobby waits for more. You never play a tiebreaker while you sit out: if time runs out with you tied for the top score with one player, there's no tiebreaker and the match ends. The tie is decided at the end of the pause after the round win, so pressing the button in that pause puts you in or out of it. The host tool turns its AFK on while you sit out. If the host leaves, the new host plays until they press it. In a tourney lobby you play from the start, and the button still works.

**Lobby bot.** When one player would be alone (the only one in the lobby, or the only one besides you while you sit out), **[BOT] Genji Bot** joins and plays with them, so no one waits on their own. It leaves before the next round once a second player can play, and at once when no one plays. Rounds with the bot aren't logged, so they don't count, even if the bot leaves partway through one; the rounds without it are rated as usual. A match in which every round was played with the bot has nothing to rate, and the server rejects its upload ([Lobby bot](ranked-log.md#lobby-bot)). A round with the bot gives no one a point, and the bot never plays a tiebreaker. The match timer runs while it plays. If you play the bot yourself, you sit out from the first round without it. No setting, and never in a tourney lobby. The bot is FealthyC's, built on gybbus's bots.

Anything else makes the match unranked, and the game says so at the top of the screen ("UNRANKED: this match won't count", with the reason): see [Unranked matches](ranked-log.md#unranked-matches). The data center is your choice (the v1.3.2 RANKED code forced Netherlands; this one doesn't).

### Tourney lobbies

For a tourney, the host tool gives the lobby's host a **tourney code**: the ranked code with the `TOURNEY - generated` rule filled in ([tourney-rule.md](tourney-rule.md)). The lobby setup is the ranked one, except the preset:

- Preset **Tournament** instead of Default. Any other preset makes the match unranked ("the preset isn't Tournament").
- The match lasts the tourney's number of rounds, from the code, with no match timer or tiebreaker. Every round counts, restarts included. The HUD on the right shows the tourney, the lobby and `ROUND: x / N`.
- Ranked logging is always on, whatever `70 - Ranked > ranked logging` says. Keep **Enable Workshop Inspector Log File** on.
- After the last round, everyone sees the **final standings** at the top of the screen for 30 s: place, name, round wins and kills, with the tourney, the lobby and the match key. Take the screenshot then (spectators see it too). Then the match ends and the lobby resets; close it rather than play another match with the same code.

## Maps

The ranked code only plays on **Workshop Island Night**, the only map enabled in its lobby settings. On any other map the game shows "This map isn't supported" and no round starts. The arena's radius is 60 m, with water around the island.

## Workshop settings

These appear in the custom game under **Settings → Workshop → Settings**, grouped by category.

<!-- The settings tables are generated from src/ by `npm run docs:settings`. Edit only the "What it does" column and the units after a range. See docs/development.md, "Settings docs". -->

### 00 - Preset

`00 - Preset` picks the ruleset: **Default** for a ranked match, **Tournament** for a tourney (the host tool's tourney code). Both play with the same fixed values; Tournament only turns tournament mode on.

<!-- settings: 00 - Preset -->
| Setting | Default | Range | What it does |
|---|---|---|---|
| preset | Default | Default / Tournament | Which ruleset to play. See the table below |

| Preset | What it's for | Differences from Default |
|---|---|---|
| **Default** | A ranked match | none |
| **Tournament** | A tourney | Tournament mode on: the match ends after 30 rounds (a tourney code sets its own) with a 60 s break every 10, no match timer, no dashing into the water, and the target is put to sleep after 7.5 s with a ball slower than 80 within 20 m (basic anti-orbit) |

The fixed values, v1.3.3's `Default`: match length 15 min, 30 rounds, breaks every 10 rounds for 60 s, ball spawn countdown 5 s, ball respawn delay 2 s, round win pause 2 s, ball start speed 60, max speed 400, acceleration 25, modern motion, the v1.3.2 ball feel, water moderate (the ball skims off it at y = -15), center exclusion size 3.5, mobility agile (move speed 190%, gravity 80%, jump 180%), dash cooldown 3.04 s, dash hit knockdown 1 s and knockdown cooldown 0.6 s.

### 30 - Player

<!-- settings: 30 - Player -->
| Setting | Default | Range | What it does |
|---|---|---|---|
| double sens | on | | Players can press Ultimate to switch between 100% aim sensitivity and "double sens %". |
| double sens % | 275 | 100–500 | The high aim sensitivity double sens switches to |

### 70 - Ranked

<!-- settings: 70 - Ranked -->
| Setting | Default | Range | What it does |
|---|---|---|---|
| ranked logging | on | | Writes the match to the Workshop inspector log for the ranked leaderboard: match start and end, players joining and leaving, each round with its elimination order and winner, and every kill and deflect. Turn on **Enable Workshop Inspector Log File** in the Overwatch options so it reaches a file the host tool can upload. Keeps the Workshop inspector on, which v1.3.3 turns off to save server load. **off**: nothing is logged, the match can't count, and the inspector is turned off as in v1.3.3. A [tourney code](#tourney-lobbies) keeps it on. Format: [ranked-log.md](ranked-log.md) |
| rank tags | on | | The tag over the head of the leaderboard's top 10, with their place and rating, and of other players in a rank tier, with its name ([rank-tags.md](rank-tags.md)). **off**: no tags. The `RANKS - generated` rule stays, and the top 10 list is separate. Doesn't affect ranked logging |
| rank tag height | 1.5 | 0–5 m | How far above the player's position the tag sits |
| rank tag size | 1 | 0.5–4 | The tag's in-world text size |
| top 10 list | on | | The leaderboard's top 10 on the right of the screen, with the "Live leaderboard: genjiball.us" line and "Press [Interact] to hide". **off**: none of it. Doesn't affect the tags or ranked logging |
| ranked debug HUD | off | | Host only, for debugging: the ranked log's state on the left (ranked logging on or off, whether `MATCH_START` is logged, the current round and whether it's open, players alive in the round, ids handed out, the unranked reasons). Checks logging works without the Workshop inspector open. Doesn't change what's logged, and the match still counts |

### 80 - Visual

<!-- settings: 80 - Visual -->
| Setting | Default | Range | What it does |
|---|---|---|---|
| red-green colorblind filter | off | | Red-green safe colours: the target, the ball and the target's "BALL SPAWNING IN" countdown are blue instead of red, and the target sees a yellow circle around the ball instead of a blue one |

### 90 - Debug

<!-- settings: 90 - Debug -->
| Setting | Default | Range | What it does |
|---|---|---|---|
| debug HUD | off | | Host-only: server load, and the ball's speed, distance to the target and turn rate |
