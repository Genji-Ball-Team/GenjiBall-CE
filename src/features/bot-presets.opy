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
        #no dash guard, safe dash, brad shot, punish or jump before impact (the circling numbers are unused)
        eventPlayer.botTuning = [0.1, 0, 0, 0, true, 0, 0, 0, 10000, 35, 10, 80, 18, 8, 30, 100, true, true, BotCamera.BETWEEN, 1000, true, BotMovement.ROAM, 50, 3, 7, 5, 15, 0, false, 0, 0, 0, 0, 0, 0, 0, 0]
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
        #jump before impact 60 % within 0.35 * speed + 5 m; circles at 6-14 m, back to the middle past 16 m
        eventPlayer.botTuning = [0.45, 8, 0, 0, true, 0, 0, 0.12, 10000, 0, 0, 80, 18, 8, 30, 100, true, true, BotCamera.HUMAN, 700, false, BotMovement.CIRCLE, 40, 1, 3.5, 1, 3.5, 20, true, 100, 90, 60, 0.35, 5, 6, 14, 16]
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
