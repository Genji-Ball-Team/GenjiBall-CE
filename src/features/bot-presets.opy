#Bot presets: the numbers (BotTuning) and shot table (BotShotColumn rows) of each preset.
#A new preset is a new BotPreset entry and a new branch in botLoadPreset. How to read
#and add one: docs/bots.md.

rule "Bots - spawn":
    #One bot, the preset picked in "50 - Features > bot"
    @Condition botSetting != BotPreset.NONE

    createDummy(Hero.GENJI, Team.ALL, 12, null, hostPlayer)


rule "Bots - setup":
    @Event eachPlayer
    @Condition botSetting != BotPreset.NONE
    @Condition eventPlayer.isDummy() == true
    @Condition eventPlayer.botHook[BotHook.PRESET] == BotPreset.NONE

    eventPlayer.botHook[BotHook.PRESET] = botSetting
    botLoadPreset()
    eventPlayer.botState = [0, -1, 0, null, null, false, null, BotIntent.SAFE, BotFacing.CAMERA, null, null]
    eventPlayer.botHook[BotHook.DEFLECT] = BotDeflect.PRESS
    eventPlayer.botHook[BotHook.MISS_AT_CAP] = eventPlayer.botTuning[BotTuning.MISS_AT_CAP]
    eventPlayer.botHook[BotHook.DASH_WANTED] = false


def botLoadPreset():
    @Name "Bots - load preset"

    #zBozo, named after zSh4d0W: random shots, edash and ghost dash, odd walking
    if eventPlayer.botHook[BotHook.PRESET] == BotPreset.ZBOZO:
        eventPlayer.startForcingName("[BOT] zBozo")
        #In BotTuning order: near 0.1 * speed + 0; no reaction delay; dies at the cap, no other miss; pressed on contact;
        #aim rate 10000, error 35° below speed 80 and 10° from it; off map 18 m, edge 8 m, enemy far 30 m, fast ball 100;
        #edash, ghost dash; camera between ball and target at 1000, spins near the ball; roams;
        #50 % double jumps, 3-7 s after a single, 5-15 s after a double;
        #no dash guard, safe dash, brad shot, punish or jump before impact (the circling numbers are unused);
        #back to the middle past 18 m; no fast reaction, ace dash or dash away
        eventPlayer.botTuning = [0.1, 0, 0, 0, true, 0, 0, 0, 10000, 35, 10, 80, 18, 8, 30, 100, true, true, BotCamera.BETWEEN, 1000, BotSpin.RANDOM, BotMovement.ROAM, 50, 3, 7, 5, 15, 0, false, 0, 0, 0, 0, 0, 0, 0, 18, 0, 0, 0, 0]
        #Dash ready: 11 % at a random player, else a random direction. Dash down: away from everyone
        eventPlayer.botShots = [
            [BotCondition.I_CAN_DASH, BotShot.AT_ANYONE, 11, BotIntent.AT_ENEMY],
            [BotCondition.I_CAN_DASH, BotShot.RANDOM, 100, BotIntent.RISKY],
            [BotCondition.ALWAYS, BotShot.AWAY, 100, BotIntent.SAFE]
        ]

    #firebuss, by gybbus: hard shots by priority, early deflect, safe dash, brad shot, circling
    elif eventPlayer.botHook[BotHook.PRESET] == BotPreset.FIREBUSS:
        eventPlayer.startForcingName("[BOT] firebuss")
        #In BotTuning order: near 0.45 * speed + 8; no reaction delay; dies at the cap, no other miss; presses deflect 0.12 s early;
        #aim rate 10000, no aim error; off map 18 m, edge 8 m, enemy far 30 m, fast ball 100;
        #edash, ghost dash; human camera at 350-700, no spin; circles;
        #40 % double jumps, 1-3.5 s after either;
        #no dash while another player within 20 m has theirs ready; safe dash; brad shot from speed 100; punish from 90;
        #jump before impact 60 % within 0.35 * speed + 5 m; circles at 6-14 m, back to the middle past 16 m;
        #no fast reaction, ace dash or dash away
        eventPlayer.botTuning = [0.45, 8, 0, 0, true, 0, 0, 0.12, 10000, 0, 0, 80, 18, 8, 30, 100, true, true, BotCamera.HUMAN, 700, BotSpin.NONE, BotMovement.CIRCLE, 40, 1, 3.5, 1, 3.5, 20, true, 100, 90, 60, 0.35, 5, 6, 14, 16, 0, 0, 0, 0]
        #The first row that holds wins; the chances share one roll per ball (see docs/bots.md)
        eventPlayer.botShots = [
            [BotCondition.ME_OFF_MAP, BotShot.DOWN, 100, BotIntent.SAFE],
            [BotCondition.NO_ENEMY, BotShot.DOWN, 100, BotIntent.SAFE],
            [BotCondition.ENEMY_OFF_MAP, BotShot.DOWN, 100, BotIntent.SAFE],
            [BotCondition.AIR_NEAR_EDGE, BotShot.UNDER_MAP, 100, BotIntent.SAFE],
            [BotCondition.ENEMY_CANT_DASH, BotShot.AT_ENEMY, 100, BotIntent.AT_ENEMY],
            [BotCondition.ENEMY_FAR, BotShot.UP, 75, BotIntent.SAFE],
            [BotCondition.ALWAYS, BotShot.FLOOR_BEHIND_ENEMY, 30, BotIntent.RISKY],
            [BotCondition.ALWAYS, BotShot.CORNER_NEAR_ENEMY, 65, BotIntent.RISKY],
            [BotCondition.ALWAYS, BotShot.WALL_NEAR_ENEMY, 100, BotIntent.RISKY]
        ]

    #lucybuss, by gybbus: down/up shots, misses fast balls, ace dash
    elif eventPlayer.botHook[BotHook.PRESET] == BotPreset.LUCYBUSS:
        eventPlayer.startForcingName("[BOT] lucybuss")
        #In BotTuning order: near 0.1 * speed + 0; no reaction delay; dies at the cap, misses 30 % from speed 110; pressed on contact;
        #aim rate 10000, error 35° below speed 80 and 10° from it; off map 18 m, edge 8 m, enemy far 30 m, fast ball 100;
        #edash, ghost dash; camera between ball and target at 1000, looks down (or up) near the ball; roams;
        #50 % double jumps, 1-2 s after either;
        #no dash guard, safe dash, brad shot, punish or jump before impact (the circling numbers are unused);
        #back to the middle past 30 m; no fast reaction; ace dash 30 %; no dash away
        eventPlayer.botTuning = [0.1, 0, 0, 0, true, 110, 30, 0, 10000, 35, 10, 80, 18, 8, 30, 100, true, true, BotCamera.BETWEEN, 1000, BotSpin.DOWN_UP, BotMovement.ROAM, 50, 1, 2, 1, 2, 0, false, 0, 0, 0, 0, 0, 0, 0, 30, 0, 0, 30, 0]
        #Off the map: down. Else 60 %: up while everyone is far (half of that), else down. Else zBozo's table, its 11 % scaled to the 40 % left
        eventPlayer.botShots = [
            [BotCondition.ME_OFF_MAP, BotShot.DOWN, 100, BotIntent.SAFE],
            [BotCondition.ALL_FAR, BotShot.UP, 30, BotIntent.SAFE],
            [BotCondition.ALWAYS, BotShot.DOWN, 60, BotIntent.SAFE],
            [BotCondition.I_CAN_DASH, BotShot.AT_ANYONE, 64, BotIntent.AT_ENEMY],
            [BotCondition.I_CAN_DASH, BotShot.RANDOM, 100, BotIntent.RISKY],
            [BotCondition.ALWAYS, BotShot.AWAY, 100, BotIntent.SAFE]
        ]

    #azertybuss, by gybbus: floor bounces with a human delay, dashes away after a shot, strafes and hops
    elif eventPlayer.botHook[BotHook.PRESET] == BotPreset.AZERTYBUSS:
        eventPlayer.startForcingName("[BOT] azertybuss")
        #In BotTuning order: near 0.3 * speed + 8; reacts in 0.03-0.12 s; dies at the cap, no other miss; pressed on contact;
        #aim rate 10000, error 6° (about 1.5 m at 15 m); off map 20.5 m (the water), edge 8 m, enemy far 30 m, fast ball 100;
        #no edash or ghost dash; human camera at 175-350, no spin; strafes;
        #80 % double jumps, 0.55-1.35 s after a single, 0.3-0.9 s after a double;
        #no dash guard, safe dash, brad shot, punish or jump before impact (the circling numbers are unused);
        #back to the middle past 15 m; reacts in 0.01-0.04 s from speed 100; no ace dash; dashes away 55 %
        eventPlayer.botTuning = [0.3, 8, 0.03, 0.12, true, 0, 0, 0, 10000, 6, 6, 80, 20.5, 8, 30, 100, false, false, BotCamera.HUMAN, 350, BotSpin.NONE, BotMovement.STRAFE, 80, 0.55, 1.35, 0.3, 0.9, 0, false, 0, 0, 0, 0, 0, 0, 0, 15, 0.01, 0.04, 0, 55]
        #Fast balls: 70 % down, then 5 % at a player and a 50/50 bounce. Slow: 15 % at a player, then a 50/50 bounce
        eventPlayer.botShots = [
            [BotCondition.ME_OFF_MAP, BotShot.DOWN, 100, BotIntent.SAFE],
            [BotCondition.BALL_FAST, BotShot.RANDOM_DOWN, 70, BotIntent.SAFE],
            [BotCondition.BALL_FAST, BotShot.AT_ANYONE, 75, BotIntent.AT_ENEMY],
            [BotCondition.BALL_FAST, BotShot.SHALLOW_BOUNCE, 87, BotIntent.RISKY],
            [BotCondition.BALL_FAST, BotShot.STEEP_BOUNCE, 100, BotIntent.RISKY],
            [BotCondition.ALWAYS, BotShot.AT_ANYONE, 15, BotIntent.AT_ENEMY],
            [BotCondition.ALWAYS, BotShot.SHALLOW_BOUNCE, 57, BotIntent.RISKY],
            [BotCondition.ALWAYS, BotShot.STEEP_BOUNCE, 100, BotIntent.RISKY]
        ]
