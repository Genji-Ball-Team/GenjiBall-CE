# How to play

## The goal

Everyone plays Genji. A glowing ball spawns in the middle of the arena and homes in on one player, **the target**. If the ball reaches the target, the target dies. The target survives by **deflecting** the ball, which sends it at someone else.

Stay alive longest to win the round. Each round won is worth 1 point.

## A round, step by step

1. **Countdown.** "BALL SPAWNING IN: 5" appears above the center of the arena. The text is red if you are the first target (blue with the red-green colorblind filter).
2. **Spawn.** The ball appears at the center and flies toward the target's head.
3. **Deflect.** If the target is deflecting (or dashing) when the ball gets within about 1.9 m (by default), the ball changes direction:
   - It flies **where you are looking**.
   - The new target is the living player **closest to your crosshair**. You pick who gets it by aiming at them.
   - The ball gets **5% faster** on each hit by default, up to the max speed (400 by default).
4. **Miss.** If the ball reaches you and you aren't deflecting, you die. The last person who hit it gets the kill. The ball disappears, a random player (never the person who just hit it) becomes the new target, and it respawns after 2 seconds (by default).
5. **Final duel.** When only two players are left, both are placed on opposite sides of the arena and frozen for 1.5 seconds. Then it's a 1v1.
6. **Round won.** The last player alive gets a point. Everyone respawns and the next round starts.

Players who join mid-round sit out (dead, spectating) until the next round.

### Dash-hitting

You can also hit the ball by **dashing into it**. It redirects the same way, but you're knocked down for 1 second (by default; the host can change it). Use it when you can't deflect in time.

## Controls

| Input | What it does |
|---|---|
| **Secondary fire** or **Ability 2** | Deflect (by default it lasts 0.3 s, then both dash and deflect are locked for 0.5 s) |
| **Primary fire** or **Ability 1** | Dash (Swift Strike). Cooldown is about 3 s by default, and it resets when you get a kill |
| **Reload** (tap) | Switch between third person (default) and first person |
| **Interact** (tap) | Simple HUD: hides the Discord/controls text |
| **Interact** (hold) | Zen mode: hides the hero HUD and shows big Dash/Deflect ready indicators |
| **Melee** | Toggle anti-rubberbanding (see below) |
| **Ultimate** | Toggle double sensitivity (only if the host enabled it) |
| **Jump** on a blue ring | Bounce pad (only if the host enabled bounce pads) |

Quick melee, primary fire shurikens and Dragonblade are disabled.

### Anti-rubberbanding

On a laggy connection, pressing an ability button can make the server and your client disagree, which causes rubberbanding. With anti-rubberbanding **on**, your ability buttons are locked, and the Workshop presses them for you when you use primary/secondary fire. Try it if your deflects feel delayed. You can see its state in the left HUD.

## The HUD

- **Target:** `⚠ PlayerName ⚠` on the left. It turns red when the target is you.
- **Ball speed:** color-coded, from blue (slow) to black (absurd). There are a few jokes at certain speeds.
- **Version:** top right.
- In the world, the ball is a red orb for the target and white for everyone else. The target sees a blue circle around the ball and a red aura around themselves, and everyone else sees a red aura on the target. With the red-green colorblind filter on, red is blue and the target's circle is yellow.

## Tiebreakers and the end of the match

The match lasts 15 minutes by default. When time runs out, the current round finishes. If two or more players are tied for the highest score, only they come back for a **tiebreaker** round, and it repeats until there's a single winner.

In **tournament mode** there's no timer. The match ends after a fixed number of rounds, with optional breaks. See [hosting.md](hosting.md#40---match).

## Optional modes the host can turn on

These are all Workshop settings. See [hosting.md](hosting.md) for how to enable them.

### Custom abilities

Each player gets one extra ability. **Hold Reload** between rounds, while the ball isn't out, to cycle through them.

| # | Ability | Input | Cooldown |
|---|---|---|---|
| 1 | **Super jump**: jump very high | Crouch on the ground, then Jump | 10 s |
| 2 | **Switch target**: steal the target and turn the ball toward you. Double-tap to take the target *without* turning the ball | Ultimate (while the ball is out and you're not the target) | 20 s (15 s double-tap) |
| 3 | **Blink**: teleport up to 20 m where you're looking, passing through the ball | Ultimate | 10 s |
| 4 | **Critical slash**: your next hit is a crit | Ultimate | 17 s after the crit hit |

Cooldowns reset when a round ends and when the final duel starts.

> Known issue since v1.3.2: the rule that gives Critical slash its speed boost (`Gb Abilities - stack crit slashes`) is disabled. A crit hit currently also skips the normal 5% speed-up, so it effectively does *less*. See `src/features/abilities-experimental.opy`.

### Duels

Only two players fight at a time. Everyone else waits in a queue, in the order they died, and the winner stays on. The top of the screen shows the current duel, and dead players see how many rounds until their turn.

### 1v1

Its own mode (the "1v1" setting), with the same queue as duels: everyone else waits dead and spectating. Every round you win is a point, and the first to 15 ("1v1 first to") takes the set and stays on. The loser goes to the end of the queue and the next player comes in at 0–0. Leaving mid-set loses it.

- The ball goes to each player in turn, point by point. The first point of a set goes to a random player.
- Between points, both players go back to their sides, with the ball countdown "1v1 point countdown". The countdown and freeze at the start of a set are the same as in duels.
- The top of the screen shows the set score and who's next. The scoreboard counts sets won.
- With a "1v1 match length", the set that's running when time runs out is finished, and the most sets won wins. Players tied on sets won play a tiebreaker set.

### Endless mode

When someone dies, the ball keeps flying and goes after the player it's heading toward. The final-duel setup is skipped.

### Tracing mode

If you're the target, you have to **keep the ball in view** (by default within 45° of your crosshair). Look away for more than about 0.3 s and you can't deflect.

### X-ray

When you're the target and a wall blocks your view of the ball, a heart icon shows where it is. It's red, or blue with the red-green colorblind filter on.

### Bot

The host can add one practice bot, named **`[BOT] <bot>`**. It's good for testing or solo practice.

- **zBozo** (named after zSh4d0W): deflects almost every ball, shoots in random directions or now and then at a player, edashes and ghost dashes, and walks and jumps around.
- **firebuss** (by gybbus): plays like a person. It shoots at you when your dash is down and dashes out of the way, otherwise sends the ball at the floor behind you, a corner or a wall, or under the map from the edge. It circles you, jumps as the ball comes, and at high speed can dash in so an orbiting ball goes into your face. It won't dash while you're close with your dash ready. It can be knocked down like anyone else.
- **lucybuss** (by gybbus): mostly shoots the ball straight down, or up when you're far away, and otherwise plays like zBozo. It misses about a third of balls from speed 110, and now and then dashes past you as the ball reaches you.
- **Monx** (by gybbus): a ball machine for drills. It stays on one spot, never misses, and sends the ball back the same way every time: into the floor, as a long bounce or at you ("Monx shots"). The host picks its spot and the speed it sends the ball at ("Monx spot", "Monx ball speed").
- **My bot**: built by the host from parts of the others: whose shots, movement, moves after a shot and deflect it uses ("My bot ..." settings).
- **azertybuss** (by gybbus): takes a human moment to react, then sends most balls into the floor, now and then at a player, and dashes sideways after its shots. It strafes and hops around like a player.

The bot isn't held to tracing mode or anti-orbit, and it isn't listed on the kill tracker (knocking it out still counts for you). It scores round wins like anyone else. There's no bot in the Tournament presets, or with duels or 1v1 on.

### Anti-orbit

"Orbiting" means keeping a slow ball circling you instead of deflecting it, to stall. With anti-orbit on, if you're the target, the ball stays within 14 m of you, and it's slower than 80 for about 5.5–7.5 seconds, you're put to sleep for 5 s and knocked away (these are the defaults; the host can change them). The longer you keep orbiting, the shorter the timer gets.
