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
    eventPlayer.botState = [0, -1, 0, null, null, false, null, BotIntent.SAFE, BotFacing.CAMERA]
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
        #50 % double jumps, 3-7 s after a single, 5-15 s after a double
        eventPlayer.botTuning = [0.1, 0, 0, 0, true, 0, 0, 0, 10000, 35, 10, 80, 18, 8, 30, 100, true, true, BotCamera.BETWEEN, 1000, true, BotMovement.ROAM, 50, 3, 7, 5, 15]
        #Dash ready: 11 % at a random player, else a random direction. Dash down: away from everyone
        eventPlayer.botShots = [
            [BotCondition.I_CAN_DASH, BotShot.AT_ANYONE, 11, BotIntent.AT_ENEMY],
            [BotCondition.I_CAN_DASH, BotShot.RANDOM, 100, BotIntent.RISKY],
            [BotCondition.ALWAYS, BotShot.AWAY, 100, BotIntent.SAFE]
        ]
