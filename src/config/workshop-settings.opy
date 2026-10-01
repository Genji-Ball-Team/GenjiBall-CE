#Workshop settings (host-configurable options)

rule "Settings - Workshop settings":
    #- Experimental is a curated playtest ruleset for rebound physics and
    #competitive fixes, while still allowing manual bot/feature testing.
    #00 - Preset: ruleset identity. Custom is last and has no runtime overrides.
    presetMode = createWorkshopSettingEnum("00 - Preset", "preset", 0, ["Default", "Tournament", "Tournament+", "Rapid\n~Workshop Expanse", "v1", "v7", "Experimental", "Custom"])
    #10 - Ball: core ball tuning is preset-controlled unless Preset is Custom.
    ballSpawnSpeed = createWorkshopSettingInt("10 - Ball", "start speed", 60, 0, 200)
    ballSpeedCap = createWorkshopSettingInt("10 - Ball", "max speed", 400, 60, 800, 1)
    ballAcceleration = createWorkshopSettingInt("10 - Ball", "acceleration", 25, 0, 300, 2) / 100
    ballMotion = createWorkshopSettingEnum("10 - Ball", "motion", 0, ["modern", "rapid\n~Workshop Expanse", "astro", "retro"], 3)
    ballPhysicsMode = createWorkshopSettingEnum("10 - Ball", "physics engine", 0, ["original", "Legacy+", "experimental"], 4)
    antiGhostMode = createWorkshopSettingEnum("10 - Ball", "anti-ghost correction", 0, ["off", "track", "steer"], 5)
    #Experimental tuning sliders. These only affect the Experimental physics engine.
    #One entry per ExperimentalTuning field (config/constants.opy), in that order.
    experimentalTuning = [
        createWorkshopSettingInt("10 - Ball", "exp incoming min %", 8, 0, 30, 6) / 100,
        createWorkshopSettingInt("10 - Ball", "exp incoming max %", 12, 0, 40, 7) / 100,
        createWorkshopSettingInt("10 - Ball", "exp homing start %", 55, 20, 100, 8) / 100,
        createWorkshopSettingInt("10 - Ball", "exp homing hold ms", 40, 0, 250, 9) / 1000,
        createWorkshopSettingInt("10 - Ball", "exp homing ramp ms", 240, 25, 1000, 10) / 1000,
        createWorkshopSettingInt("10 - Ball", "exp surface homing %", 70, 20, 100, 11) / 100
    ]
    #20 - Arena: core arena/environment tuning is preset-controlled unless Preset is Custom.
    waterLevel = createWorkshopSettingEnum("20 - Arena", "water", 0, ["moderate", "none", "minimal", "flood"])
    bouncePadToggle = createWorkshopSettingBool("20 - Arena", "bounce pads", false, 1)
    #30 - Player: mobility is preset-controlled unless Preset is Custom. Double sens is a casual add-on.
    mobilityMode = createWorkshopSettingEnum("30 - Player", "mobility", 0, ["agile", "balanced", "sluggish"])
    #40 - Match: match/tournament structure is preset-controlled unless Preset is Custom.
    matchTime = createWorkshopSettingInt("40 - Match", "match length", 15, 5, 60) * 60
    tournamentMode = createWorkshopSettingBool("40 - Match", "tournament mode", false, 1)
    totalRounds = createWorkshopSettingInt("40 - Match", "tournament rounds", 30, 1, 50, 2)
    breaksEnabled = createWorkshopSettingBool("40 - Match", "breaks", true, 3)
    roundsUntilBreak = createWorkshopSettingInt("40 - Match", "break every", 10, 4, 25, 4)
    breakLength = createWorkshopSettingInt("40 - Match", "break length", 60, 1, 120, 5)
    setballspawncountdownoriginal = createWorkshopSettingInt("40 - Match", "ball spawn countdown", 5, 1, 30, 6)
    #One entry per RoundTiming field (config/constants.opy), in that order.
    roundTimings = [
        createWorkshopSettingInt("40 - Match", "ball respawn delay", 2, 1, 10, 7),
        createWorkshopSettingInt("40 - Match", "round win pause", 2, 0, 10, 8)
    ]
    #50 - Features: casual/gameplay add-ons. Presets leave these manual. The rest are in addOnSettings below.
    bozo_Bot = createWorkshopSettingBool("50 - Features", "bot", false, 1)
    #60 - Competitive: competitive test systems. Tournament controls these explicitly.
    antiOrbitMode = createWorkshopSettingBool("60 - Competitive", "AntiOrbit", false)
    antiOrbitRadius = createWorkshopSettingInt("60 - Competitive", "AntiOrbit radius", 14, 10, 20, 1)
    antiOrbitPressureRate = createWorkshopSettingInt("60 - Competitive", "AntiOrbit pressure", 2, 1, 5, 2) / 100
    #Add-ons no preset forces, in one array.
    #One entry per AddOnSetting field (config/constants.opy), in that order.
    #Each setting may only be read once, so read them here and nowhere else.
    addOnSettings = [
        createWorkshopSettingBool("30 - Player", "double sens", false, 1),
        createWorkshopSettingBool("50 - Features", "custom abilities", false),
        createWorkshopSettingBool("80 - Visual", "x-ray", false),
        createWorkshopSettingBool("80 - Visual", "tracing mode", false, 1),
        createWorkshopSettingBool("90 - Debug", "debug HUD", false),
        createWorkshopSettingBool("50 - Features", "duels", false, 2),
        createWorkshopSettingBool("50 - Features", "endless mode", false, 3),
        createWorkshopSettingBool("50 - Features", "Sandbox mode", false, 4),
        createWorkshopSettingBool("80 - Visual", "kill tracker", false, 2)
    ]
    #Presets: one row per preset, in Preset order, one column per forced setting
    #(PresetColumn in config/constants.opy). MANUAL keeps the host's value.
    #Custom has no row, so every visible setting stays manual.
    #Tournament: current conservative tournament setup.
    #Tournament+: future tournament candidate with AntiOrbit and steer-based anti-ghost correction.
    #  Original physics stays forced until Legacy+/Experimental are tournament-proven.
    #Rapid: Workshop Expanse-style fast/bouncy preset.
    #v1: dry Workshop Island feel with otherwise standard gameplay.
    #v7: v7-style preset shell. Deeper v7 parity remains deferred.
    #Experimental: curated rebound-physics test ruleset, not tournament-safe yet.
    #  The bot setting stays manual so Bot + Experimental can be tested together.
    if presetMode != Preset.CUSTOM:
        presetRow = [
            #match, tourn, rounds, breaks, every, length, start, max, accel, motion,               physics,                  water,          pads,  mobility,          anti-ghost,      AntiOrbit, radius, pressure, countdown, respawn, win pause
            [900,   false, 30,     true,   10,    60,     60,    400, 0.25,  BallMotion.MODERN,    BallPhysics.ORIGINAL,     Water.MODERATE, false, Mobility.AGILE,    MANUAL,          MANUAL,    MANUAL, MANUAL,   5,         2,       2],    #Default
            [900,   true,  30,     true,   10,    60,     60,    400, 0.25,  BallMotion.MODERN,    BallPhysics.ORIGINAL,     Water.MODERATE, false, Mobility.AGILE,    AntiGhost.OFF,   false,     MANUAL, MANUAL,   5,         2,       2],    #Tournament
            [900,   true,  30,     true,   10,    60,     60,    400, 0.25,  BallMotion.MODERN,    BallPhysics.ORIGINAL,     Water.MODERATE, false, Mobility.AGILE,    AntiGhost.STEER, true,      14,     0.02,   5,         2,       2],    #Tournament+
            [900,   false, 30,     true,   10,    60,     60,    400, 0.25,  BallMotion.RAPID,     BallPhysics.ORIGINAL,     Water.FLOOD,    true,  Mobility.BALANCED, MANUAL,          MANUAL,    MANUAL, MANUAL,   5,         2,       2],    #Rapid
            [900,   false, 30,     true,   10,    60,     60,    400, 0.25,  BallMotion.MODERN,    BallPhysics.ORIGINAL,     Water.NONE,     false, Mobility.AGILE,    MANUAL,          MANUAL,    MANUAL, MANUAL,   5,         2,       2],    #v1
            [900,   false, 30,     true,   10,    60,     60,    400, 0.25,  BallMotion.MODERN,    BallPhysics.ORIGINAL,     Water.FLOOD,    true,  Mobility.SLUGGISH, MANUAL,          MANUAL,    MANUAL, MANUAL,   5,         2,       2],    #v7
            [900,   false, 30,     true,   10,    60,     60,    400, 0.25,  BallMotion.MODERN,    BallPhysics.EXPERIMENTAL, Water.MODERATE, false, Mobility.AGILE,    AntiGhost.OFF,   true,      14,     0.02,   5,         2,       2],    #Experimental
        ][presetMode]
        matchTime = presetRow[PresetColumn.MATCH_TIME]
        tournamentMode = presetRow[PresetColumn.TOURNAMENT_MODE]
        totalRounds = presetRow[PresetColumn.TOTAL_ROUNDS]
        breaksEnabled = presetRow[PresetColumn.BREAKS_ENABLED]
        roundsUntilBreak = presetRow[PresetColumn.ROUNDS_UNTIL_BREAK]
        breakLength = presetRow[PresetColumn.BREAK_LENGTH]
        ballSpawnSpeed = presetRow[PresetColumn.BALL_SPAWN_SPEED]
        ballSpeedCap = presetRow[PresetColumn.BALL_SPEED_CAP]
        ballAcceleration = presetRow[PresetColumn.BALL_ACCELERATION]
        ballMotion = presetRow[PresetColumn.BALL_MOTION]
        ballPhysicsMode = presetRow[PresetColumn.BALL_PHYSICS]
        waterLevel = presetRow[PresetColumn.WATER]
        bouncePadToggle = presetRow[PresetColumn.BOUNCE_PADS]
        mobilityMode = presetRow[PresetColumn.MOBILITY]
        setballspawncountdownoriginal = presetRow[PresetColumn.SPAWN_COUNTDOWN]
        roundTimings = [presetRow[PresetColumn.RESPAWN_DELAY], presetRow[PresetColumn.WIN_PAUSE]]
        if presetRow[PresetColumn.ANTI_GHOST] != MANUAL:
            antiGhostMode = presetRow[PresetColumn.ANTI_GHOST]
        if presetRow[PresetColumn.ANTI_ORBIT] != MANUAL:
            antiOrbitMode = presetRow[PresetColumn.ANTI_ORBIT]
        if presetRow[PresetColumn.ANTI_ORBIT_RADIUS] != MANUAL:
            antiOrbitRadius = presetRow[PresetColumn.ANTI_ORBIT_RADIUS]
        if presetRow[PresetColumn.ANTI_ORBIT_PRESSURE] != MANUAL:
            antiOrbitPressureRate = presetRow[PresetColumn.ANTI_ORBIT_PRESSURE]
    if mobilityMode == Mobility.AGILE:
        moveSpeed = 190
        gravity = 80
        jumpVerticalSpeed = 180
    elif mobilityMode == Mobility.BALANCED:
        moveSpeed = 150
        gravity = 90
        jumpVerticalSpeed = 150
    elif mobilityMode == Mobility.SLUGGISH:
        moveSpeed = 100
        gravity = 100
        jumpVerticalSpeed = 100
    if waterLevel == Water.MODERATE:
        waterLevel = -15
    elif waterLevel == Water.NONE:
        waterLevel = -1000
    elif waterLevel == Water.MINIMAL:
        waterLevel = -26
    elif waterLevel == Water.FLOOD:
        waterLevel = -0.5
    if bozo_Bot:
        bozo_Bot = 1


rule "Settings - Watermark":
    WatermarkEnabled = false


rule "Settings - Red-green colorblind filter":
    @Disabled
    
    RedGreenColorblindMode = true
