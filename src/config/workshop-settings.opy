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
    experimentalReboundMin = createWorkshopSettingInt("10 - Ball", "exp incoming min %", 8, 0, 30, 6) / 100
    experimentalReboundMax = createWorkshopSettingInt("10 - Ball", "exp incoming max %", 12, 0, 40, 7) / 100
    experimentalHomingStart = createWorkshopSettingInt("10 - Ball", "exp homing start %", 55, 20, 100, 8) / 100
    experimentalHomingHold = createWorkshopSettingInt("10 - Ball", "exp homing hold ms", 40, 0, 250, 9) / 1000
    experimentalHomingRamp = createWorkshopSettingInt("10 - Ball", "exp homing ramp ms", 240, 25, 1000, 10) / 1000
    experimentalSurfaceHoming = createWorkshopSettingInt("10 - Ball", "exp surface homing %", 70, 20, 100, 11) / 100
    #20 - Arena: core arena/environment tuning is preset-controlled unless Preset is Custom.
    waterLevel = createWorkshopSettingEnum("20 - Arena", "water", 0, ["moderate", "none", "minimal", "flood"])
    bouncePadToggle = createWorkshopSettingBool("20 - Arena", "bounce pads", false, 1)
    #30 - Player: mobility is preset-controlled unless Preset is Custom. Double sens is a casual add-on.
    mobilityMode = createWorkshopSettingEnum("30 - Player", "mobility", 0, ["agile", "balanced", "sluggish"])
    doubleSensEnabled = createWorkshopSettingBool("30 - Player", "double sens", false, 1)
    #40 - Match: match/tournament structure is preset-controlled unless Preset is Custom.
    matchTime = createWorkshopSettingInt("40 - Match", "match length", 15, 5, 60) * 60
    tournamentMode = createWorkshopSettingBool("40 - Match", "tournament mode", false, 1)
    totalRounds = createWorkshopSettingInt("40 - Match", "tournament rounds", 30, 1, 50, 2)
    breaksEnabled = createWorkshopSettingBool("40 - Match", "breaks", true, 3)
    roundsUntilBreak = createWorkshopSettingInt("40 - Match", "break every", 10, 4, 25, 4)
    breakLength = createWorkshopSettingInt("40 - Match", "break length", 60, 1, 120, 5)
    #50 - Features: casual/gameplay add-ons. Presets leave these manual.
    Abilities = createWorkshopSettingBool("50 - Features", "custom abilities", false)
    bozo_Bot = createWorkshopSettingBool("50 - Features", "bot", false, 1)
    duelMode = createWorkshopSettingBool("50 - Features", "duels", false, 2)
    endlessMode = createWorkshopSettingBool("50 - Features", "endless mode", false, 3)
    Sandbox = createWorkshopSettingBool("50 - Features", "Sandbox mode", false, 4)
    #60 - Competitive: competitive test systems. Tournament controls these explicitly.
    antiOrbitMode = createWorkshopSettingBool("60 - Competitive", "AntiOrbit", false)
    antiOrbitRadius = createWorkshopSettingInt("60 - Competitive", "AntiOrbit radius", 14, 10, 20, 1)
    antiOrbitPressureRate = createWorkshopSettingInt("60 - Competitive", "AntiOrbit pressure", 2, 1, 5, 2) / 100
    #80 - Visual: visual helpers. Presets leave these manual.
    xray = createWorkshopSettingBool("80 - Visual", "x-ray", false)
    tracingMode = createWorkshopSettingBool("80 - Visual", "tracing mode", false, 1)
    killCounterEnabled = createWorkshopSettingBool("80 - Visual", "kill tracker", false, 2)
    #90 - Debug: developer/test HUD helpers. Presets leave these manual.
    debugRules = createWorkshopSettingBool("90 - Debug", "debug HUD", false)
    #Shared core ruleset defaults for every non-Custom preset.
    #Custom (index 7) intentionally skips this block so every visible setting is manual.
    if presetMode != Preset.CUSTOM:
        matchTime = 900
        tournamentMode = false
        totalRounds = 30
        breaksEnabled = true
        roundsUntilBreak = 10
        breakLength = 60
        ballSpawnSpeed = 60
        ballSpeedCap = 400
        ballAcceleration = 0.25
        ballMotion = BallMotion.MODERN
        ballPhysicsMode = BallPhysics.ORIGINAL
        waterLevel = Water.MODERATE
        bouncePadToggle = false
        mobilityMode = Mobility.AGILE
        if presetMode == Preset.TOURNAMENT:
            #Tournament: current conservative tournament setup.
            tournamentMode = true
            antiGhostMode = AntiGhost.OFF
            antiOrbitMode = false
        elif presetMode == Preset.TOURNAMENT_PLUS:
            #Tournament+: future tournament candidate with AntiOrbit and steer-based anti-ghost correction.
            #Original physics remains forced until Legacy+/Experimental are tournament-proven.
            tournamentMode = true
            antiGhostMode = AntiGhost.STEER
            antiOrbitMode = true
            antiOrbitRadius = 14
            antiOrbitPressureRate = 0.02
        elif presetMode == Preset.RAPID:
            #Rapid: Workshop Expanse-style fast/bouncy preset.
            waterLevel = Water.FLOOD
            ballMotion = BallMotion.RAPID
            bouncePadToggle = true
            mobilityMode = Mobility.BALANCED
        elif presetMode == Preset.V1:
            #v1: dry Workshop Island feel with otherwise standard gameplay.
            waterLevel = Water.NONE
        elif presetMode == Preset.V7:
            #v7-style preset shell. Deeper v7 parity remains deferred.
            waterLevel = Water.FLOOD
            bouncePadToggle = true
            mobilityMode = Mobility.SLUGGISH
        elif presetMode == Preset.EXPERIMENTAL:
            #Experimental: curated rebound-physics test ruleset, not tournament-safe yet.
            #Keep the bot setting manual so Bot + Experimental can be tested together.
            ballPhysicsMode = BallPhysics.EXPERIMENTAL
            antiGhostMode = AntiGhost.OFF
            antiOrbitMode = true
            antiOrbitRadius = 14
            antiOrbitPressureRate = 0.02
    if ballMotion == BallMotion.MODERN:
        motionMultiplier = 1
    elif ballMotion == BallMotion.RAPID:
        motionMultiplier = 0.5
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
