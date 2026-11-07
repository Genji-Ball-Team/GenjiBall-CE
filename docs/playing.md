# How to play

## The goal

Everyone plays Genji. A glowing ball spawns in the middle of the arena and homes in on one player, **the target**. If the ball reaches the target, the target dies. The target survives by **deflecting** the ball, which sends it at someone else.

Stay alive longest to win the round. Each round won is worth 1 point.

## A round, step by step

1. **Countdown.** "BALL SPAWNING IN: 5" appears above the center of the arena. The text is red if you are the first target (blue with the red-green colorblind filter).
2. **Spawn.** The ball appears at the center and flies toward the target's head.
3. **Deflect.** If the target is deflecting (or dashing) when the ball gets within about 1.9 m, the ball changes direction:
   - It flies **where you are looking**.
   - The new target is the living player **closest to your crosshair**. You pick who gets it by aiming at them.
   - The ball gets **5% faster** on each hit, up to the max speed of 400.
4. **Miss.** If the ball reaches you and you aren't deflecting, you die. The last person who hit it gets the kill. The ball disappears, a random player (never the person who just hit it) becomes the new target, and it respawns after 2 seconds.
5. **Final duel.** When only two players are left, both are placed on opposite sides of the arena and frozen for 1.5 seconds. Then it's a 1v1.
6. **Round won.** The last player alive gets a point. Everyone respawns and the next round starts.

Players who join mid-round sit out (dead, spectating) until the next round.

### Dash-hitting

You can also hit the ball by **dashing into it**. It redirects the same way, but you're knocked down for 1 second. Use it when you can't deflect in time.

## Controls

| Input | What it does |
|---|---|
| **Secondary fire** or **Ability 2** | Deflect (it lasts 0.3 s, then both dash and deflect are locked for 0.5 s) |
| **Primary fire** or **Ability 1** | Dash (Swift Strike). Cooldown is about 3 s, and it resets when you get a kill |
| **Reload** (tap) | Switch between third person (default) and first person |
| **Interact** (tap) | Simple HUD: hides the Discord/controls text |
| **Interact** (hold) | Zen mode: hides the hero HUD and shows big Dash/Deflect ready indicators |
| **Melee** | Toggle anti-rubberbanding (see below) |
| **Ultimate** | Toggle double sensitivity (on by default in ranked, off in v1.3.3 unless the host enabled it) |

Quick melee, primary fire shurikens and Dragonblade are disabled.

### Anti-rubberbanding

On a laggy connection, pressing an ability button can make the server and your client disagree, which causes rubberbanding. With anti-rubberbanding **on**, your ability buttons are locked, and the Workshop presses them for you when you use primary/secondary fire. Try it if your deflects feel delayed. You can see its state in the left HUD.

## The HUD

- **Target:** `⚠ PlayerName ⚠` on the left. It turns red when the target is you.
- **Ball speed:** color-coded, from blue (slow) to black (absurd). There are a few jokes at certain speeds.
- **Version:** top right.
- In the world, the ball is a red orb for the target and white for everyone else. The target sees a blue circle around the ball and a red aura around themselves, and everyone else sees a red aura on the target. With the red-green colorblind filter on, red is blue and the target's circle is yellow.

## Tiebreakers and the end of the match

The match lasts 15 minutes. When time runs out, the current round finishes. If two or more players are tied for the highest score, only they come back for a **tiebreaker** round, and it repeats until there's a single winner.

In **tournament mode** there's no timer. The match ends after 30 rounds (a tourney sets its own), with a 60 s break every 10. If you're the target and keep a slow ball (under 80) within 20 m of you for 7.5 s instead of deflecting it, you're put to sleep (basic anti-orbit). See [hosting.md](hosting.md#00---preset).
