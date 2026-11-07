#Workshop settings (host-configurable options)
#Ranked only has what a ranked or tourney lobby uses. The ball, arena, player and match values are
#fixed below: they're v1.3.3's Default preset, and any other value would make the match unranked.

rule "Settings - Workshop settings":
    #00 - Preset: Default for a ranked match, Tournament for a tourney (the host tool's tourney code)
    presetMode = createWorkshopSettingEnum("00 - Preset", "preset", 0, ["Default", "Tournament"])
    #Add-ons no preset forces, in one array.
    #One entry per AddOnSetting field (config/constants.opy), in that order.
    #Each setting may only be read once, so read them here and nowhere else.
    #Double sens is on by default in ranked: hosts and players asked for it there.
    addOnSettings = [
        createWorkshopSettingBool("30 - Player", "double sens", true, 7),
        createWorkshopSettingInt("30 - Player", "double sens %", 275, 100, 500, 8),
        createWorkshopSettingBool("80 - Visual", "red-green colorblind filter", false, 4),
        createWorkshopSettingBool("90 - Debug", "debug HUD", false)
    ]
    #70 - Ranked: one entry per RankedField (config/constants.opy), in that order.
    #LOGGING to DEBUG_HUD are settings; the rest is set by features/ranked-log.opy.
    rankedState = [
        createWorkshopSettingBool("70 - Ranked", "ranked logging", true, 0),
        createWorkshopSettingBool("70 - Ranked", "rank tags", true, 1),
        createWorkshopSettingFloat("70 - Ranked", "rank tag height", 1.5, 0, 5, 2),
        createWorkshopSettingFloat("70 - Ranked", "rank tag size", 1, 0.5, 4, 3),
        createWorkshopSettingBool("70 - Ranked", "top 10 list", true, 4),
        createWorkshopSettingBool("70 - Ranked", "ranked debug HUD", false, 5),
        false
    ]
    #The ruleset, the same for both presets: Tournament only adds tournament mode (round limit, breaks,
    #no dashing into the water, basic anti-orbit). A tourney code turns it on too (features/tourney.opy).
    tournamentMode = presetMode == Preset.TOURNAMENT
    #Match: 15 min, or 30 rounds with a 60 s break every 10 in tournament mode
    matchTime = 900
    totalRounds = 30
    breaksEnabled = true
    roundsUntilBreak = 10
    breakLength = 60
    setballspawncountdownoriginal = 5
    #One entry per RoundTiming field (config/constants.opy), in that order: ball respawn delay, round win pause
    roundTimings = [2, 2]
    #Ball: start speed, max speed, speed gained per second
    ballSpawnSpeed = 60
    ballSpeedCap = 400
    ballAcceleration = 0.25
    ballFeel = BALL_FEEL_DEFAULTS
    #Moderate water: the ball skims off it at y = -15
    waterLevel = -15
    #Agile mobility: move speed, gravity and jump in %. Gravity stays above 0: currentGravity == 0 means
    #"in the water" (maps/restrictions.opy).
    moveSpeed = 190
    gravity = 80
    jumpVerticalSpeed = 180
    #One entry per PlayerSetting field (config/constants.opy), in that order: dash cooldown, dash hit knockdown and its cooldown
    playerSettings = [3.04, 1, 0.6]
