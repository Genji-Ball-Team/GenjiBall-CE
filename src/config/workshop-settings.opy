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
    #15 - Ball Feel: v1.3.2 values by default, used only with "custom ball feel" on.
    #Presets force it off. One entry per BallFeel field (config/constants.opy), in that order.
    ballFeel = [
        createWorkshopSettingBool("15 - Ball Feel", "custom ball feel", false, 0),
        createWorkshopSettingFloat("15 - Ball Feel", "speed per deflect", 1.05, 1, 2, 1),
        createWorkshopSettingFloat("15 - Ball Feel", "hit radius", 1.9, 0.5, 5, 2),
        createWorkshopSettingFloat("15 - Ball Feel", "turn rate modern", 1.75, 0.25, 20, 3),
        createWorkshopSettingFloat("15 - Ball Feel", "turn rate rapid", 5, 0.25, 20, 4),
        createWorkshopSettingFloat("15 - Ball Feel", "deflect curve rate", 6, 0, 20, 5),
        createWorkshopSettingFloat("15 - Ball Feel", "deflect curve time", 0.05, 0, 1, 6),
        createWorkshopSettingFloat("15 - Ball Feel", "deflect window", 0.3, 0.05, 2, 7),
        createWorkshopSettingFloat("15 - Ball Feel", "deflect lockout", 0.5, 0, 3, 8),
        createWorkshopSettingInt("15 - Ball Feel", "fast ball speed", 150, 0, 800, 9),
        createWorkshopSettingBool("15 - Ball Feel", "chamber floor bounce", false, 10),
        createWorkshopSettingBool("15 - Ball Feel", "reliable hit detection", false, 11)
    ]
    #20 - Arena: core arena/environment tuning is preset-controlled unless Preset is Custom.
    waterLevel = createWorkshopSettingEnum("20 - Arena", "water", 0, ["moderate", "none", "minimal", "flood"])
    bouncePadToggle = createWorkshopSettingBool("20 - Arena", "bounce pads", false, 1)
    #One entry per ArenaSetting field (config/constants.opy), in that order.
    arenaSettings = [
        createWorkshopSettingFloat("20 - Arena", "center exclusion size", 3.5, 0, 10, 2),
        createWorkshopSettingFloat("20 - Arena", "arena radius", 0, 0, 100, 3),
        createWorkshopSettingInt("20 - Arena", "bounce pad strength", 30, 5, 60, 4),
        createWorkshopSettingFloat("20 - Arena", "bounce pad distance", 12, 4, 40, 5),
        createWorkshopSettingFloat("20 - Arena", "bounce pad range", 2.75, 0.5, 10, 6),
        createWorkshopSettingInt("20 - Arena", "bounce pad cooldown", 3, 1, 10, 7)
    ]
    #30 - Player: mobility, dash and dash hit settings are preset-controlled unless Preset is Custom.
    #Double sens is a casual add-on.
    mobilityMode = createWorkshopSettingEnum("30 - Player", "mobility", 0, ["agile", "balanced", "sluggish", "custom"])
    #Only used with mobility = custom. Every other mobility overwrites them below.
    #Gravity stays above 0: currentGravity == 0 means "in the water" (maps/restrictions.opy).
    moveSpeed = createWorkshopSettingInt("30 - Player", "custom move speed %", 190, 20, 300, 1)
    gravity = createWorkshopSettingInt("30 - Player", "custom gravity %", 80, 10, 300, 2)
    jumpVerticalSpeed = createWorkshopSettingInt("30 - Player", "custom jump %", 180, 20, 300, 3)
    #One entry per PlayerSetting field (config/constants.opy), in that order.
    playerSettings = [
        createWorkshopSettingFloat("30 - Player", "dash cooldown", 3.04, 0, 10, 4),
        createWorkshopSettingFloat("30 - Player", "dash hit knockdown", 1, 0, 3, 5),
        createWorkshopSettingFloat("30 - Player", "dash hit knockdown cooldown", 0.6, 0, 5, 6)
    ]
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
    #60 - Competitive: competitive test systems. Tournament, Tournament+ and Experimental force them.
    antiOrbitMode = createWorkshopSettingBool("60 - Competitive", "AntiOrbit", false)
    antiOrbitRadius = createWorkshopSettingInt("60 - Competitive", "AntiOrbit radius", 14, 10, 20, 1)
    antiOrbitPressureRate = createWorkshopSettingInt("60 - Competitive", "AntiOrbit pressure", 2, 1, 5, 2) / 100
    #One entry per CompetitiveSetting field (config/constants.opy), in that order.
    competitiveSettings = [
        createWorkshopSettingInt("60 - Competitive", "AntiOrbit speed", 80, 10, 400, 3),
        createWorkshopSettingFloat("60 - Competitive", "AntiOrbit timer", 7.5, 1, 30, 4),
        createWorkshopSettingFloat("60 - Competitive", "AntiOrbit min timer", 5.5, 1, 30, 5),
        createWorkshopSettingFloat("60 - Competitive", "AntiOrbit sleep", 5, 0, 10, 6),
        createWorkshopSettingInt("60 - Competitive", "basic anti-orbit radius", 20, 5, 40, 7),
        createWorkshopSettingInt("60 - Competitive", "basic anti-orbit speed", 80, 10, 400, 8),
        createWorkshopSettingFloat("60 - Competitive", "basic anti-orbit timer", 7.5, 1, 30, 9)
    ]
    #Add-ons no preset forces, in one array.
    #One entry per AddOnSetting field (config/constants.opy), in that order.
    #Each setting may only be read once, so read them here and nowhere else.
    addOnSettings = [
        createWorkshopSettingBool("30 - Player", "double sens", false, 7),
        createWorkshopSettingBool("50 - Features", "custom abilities", false),
        createWorkshopSettingBool("80 - Visual", "x-ray", false),
        createWorkshopSettingBool("80 - Visual", "tracing mode", false, 1),
        createWorkshopSettingBool("90 - Debug", "debug HUD", false),
        createWorkshopSettingBool("50 - Features", "duels", false, 2),
        createWorkshopSettingBool("50 - Features", "endless mode", false, 3),
        createWorkshopSettingBool("50 - Features", "Sandbox mode", false, 4),
        createWorkshopSettingBool("80 - Visual", "kill tracker", false, 3),
        createWorkshopSettingInt("30 - Player", "double sens %", 275, 100, 500, 8),
        createWorkshopSettingInt("80 - Visual", "tracing view angle", 45, 5, 180, 2),
        createWorkshopSettingBool("80 - Visual", "red-green colorblind filter", false, 4),
        createWorkshopSettingBool("80 - Visual", "watermark", false, 5),
        createWorkshopSettingBool("20 - Arena", "water ledge fix", false, 8)
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
            #match, tourn, rounds, breaks, every, length, start, max, accel, motion,               physics,                  feel,  water,          pads,  mobility,          anti-ghost,      AntiOrbit, radius, pressure, countdown, respawn, win pause, orbit spd, orbit t, min t,  sleep,  basic r, basic spd, basic t, dash cd, knockdown, knock cd, center, radius, pad str, pad dist, pad range, pad cd
            [900,   false, 30,     true,   10,    60,     60,    400, 0.25,  BallMotion.MODERN,    BallPhysics.ORIGINAL,     false, Water.MODERATE, false, Mobility.AGILE,    MANUAL,          MANUAL,    MANUAL, MANUAL,   5,         2,       2,         MANUAL,    MANUAL,  MANUAL, MANUAL, MANUAL, MANUAL,    MANUAL,  3.04,    1,         0.6,      3.5,    0,      30,      12,       2.75,      3],    #Default
            [900,   true,  30,     true,   10,    60,     60,    400, 0.25,  BallMotion.MODERN,    BallPhysics.ORIGINAL,     false, Water.MODERATE, false, Mobility.AGILE,    AntiGhost.OFF,   false,     MANUAL, MANUAL,   5,         2,       2,         80,        7.5,     5.5,   5,      20,      80,        7.5,     3.04,    1,         0.6,      3.5,    0,      30,      12,       2.75,      3],    #Tournament
            [900,   true,  30,     true,   10,    60,     60,    400, 0.25,  BallMotion.MODERN,    BallPhysics.ORIGINAL,     false, Water.MODERATE, false, Mobility.AGILE,    AntiGhost.STEER, true,      14,     0.02,   5,         2,       2,         80,        7.5,     5.5,   5,      20,      80,        7.5,     3.04,    1,         0.6,      3.5,    0,      30,      12,       2.75,      3],    #Tournament+
            [900,   false, 30,     true,   10,    60,     60,    400, 0.25,  BallMotion.RAPID,     BallPhysics.ORIGINAL,     false, Water.FLOOD,    true,  Mobility.BALANCED, MANUAL,          MANUAL,    MANUAL, MANUAL,   5,         2,       2,         MANUAL,    MANUAL,  MANUAL, MANUAL, MANUAL, MANUAL,    MANUAL,  3.04,    1,         0.6,      3.5,    0,      30,      12,       2.75,      3],    #Rapid
            [900,   false, 30,     true,   10,    60,     60,    400, 0.25,  BallMotion.MODERN,    BallPhysics.ORIGINAL,     false, Water.NONE,     false, Mobility.AGILE,    MANUAL,          MANUAL,    MANUAL, MANUAL,   5,         2,       2,         MANUAL,    MANUAL,  MANUAL, MANUAL, MANUAL, MANUAL,    MANUAL,  3.04,    1,         0.6,      3.5,    0,      30,      12,       2.75,      3],    #v1
            [900,   false, 30,     true,   10,    60,     60,    400, 0.25,  BallMotion.MODERN,    BallPhysics.ORIGINAL,     false, Water.FLOOD,    true,  Mobility.SLUGGISH, MANUAL,          MANUAL,    MANUAL, MANUAL,   5,         2,       2,         MANUAL,    MANUAL,  MANUAL, MANUAL, MANUAL, MANUAL,    MANUAL,  3.04,    1,         0.6,      3.5,    0,      30,      12,       2.75,      3],    #v7
            [900,   false, 30,     true,   10,    60,     60,    400, 0.25,  BallMotion.MODERN,    BallPhysics.EXPERIMENTAL, false, Water.MODERATE, false, Mobility.AGILE,    AntiGhost.OFF,   true,      14,     0.02,   5,         2,       2,         80,        7.5,     5.5,   5,      20,      80,        7.5,     3.04,    1,         0.6,      3.5,    0,      30,      12,       2.75,      3],    #Experimental
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
        ballFeel[BallFeel.CUSTOM] = presetRow[PresetColumn.BALL_FEEL]
        waterLevel = presetRow[PresetColumn.WATER]
        bouncePadToggle = presetRow[PresetColumn.BOUNCE_PADS]
        mobilityMode = presetRow[PresetColumn.MOBILITY]
        setballspawncountdownoriginal = presetRow[PresetColumn.SPAWN_COUNTDOWN]
        roundTimings = [presetRow[PresetColumn.RESPAWN_DELAY], presetRow[PresetColumn.WIN_PAUSE]]
        if presetRow[PresetColumn.ORBIT_SPEED] != MANUAL:
            competitiveSettings = presetRow.slice(PresetColumn.ORBIT_SPEED, PresetColumn.DASH_COOLDOWN - PresetColumn.ORBIT_SPEED)
        playerSettings = presetRow.slice(PresetColumn.DASH_COOLDOWN, PresetColumn.CENTER_SIZE - PresetColumn.DASH_COOLDOWN)
        arenaSettings = presetRow.slice(PresetColumn.CENTER_SIZE, len(presetRow) - PresetColumn.CENTER_SIZE)
        if presetRow[PresetColumn.ANTI_GHOST] != MANUAL:
            antiGhostMode = presetRow[PresetColumn.ANTI_GHOST]
        if presetRow[PresetColumn.ANTI_ORBIT] != MANUAL:
            antiOrbitMode = presetRow[PresetColumn.ANTI_ORBIT]
        if presetRow[PresetColumn.ANTI_ORBIT_RADIUS] != MANUAL:
            antiOrbitRadius = presetRow[PresetColumn.ANTI_ORBIT_RADIUS]
        if presetRow[PresetColumn.ANTI_ORBIT_PRESSURE] != MANUAL:
            antiOrbitPressureRate = presetRow[PresetColumn.ANTI_ORBIT_PRESSURE]
    if not ballFeel[BallFeel.CUSTOM]:
        ballFeel = BALL_FEEL_DEFAULTS
    #Mobility.CUSTOM keeps the "custom ... %" settings read above.
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
