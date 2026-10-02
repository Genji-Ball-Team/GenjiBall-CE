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

### Endless mode

When someone dies, the ball keeps flying and goes after the player it's heading toward. The final-duel setup is skipped.

### Tracing mode

If you're the target, you have to **keep the ball in view** (by default within 45° of your crosshair). Look away for more than about 0.3 s and you can't deflect.

### X-ray

When you're the target and a wall blocks your view of the ball, a heart icon shows where it is. It's red, or blue with the red-green colorblind filter on.

### Bot

Adds one practice bot, **"zSh4d0Ws bozo"**. It deflects, dashes and jumps. It's good for testing or solo practice.

### Anti-orbit

"Orbiting" means keeping a slow ball circling you instead of deflecting it, to stall. With anti-orbit on, if you're the target, the ball stays within 14 m of you, and it's slower than 80 for about 5.5–7.5 seconds, you're put to sleep for 5 s and knocked away (these are the defaults; the host can change them). The longer you keep orbiting, the shorter the timer gets.
