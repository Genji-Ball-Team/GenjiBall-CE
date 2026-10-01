settings {
    "main": {
        "description": "Welcome to Genji Ball! Thanks for enjoying the game! Engage in tournaments and events on: discord.gg/genjiball. For further insights visit: workshop.codes/genjiball.            Do not hesitate to share your feedback!                                  This version was made by zSh4d0W. Originally developed by u/Mazawrath. Numerous updates by members of the Official Genji Dodgeball Server and ØøØøØzZØøØøØ.",
        "modeName": "Genji Ball 1.3T"
    },
    "lobby": {
        "allowPlayersInQueue": true,
        "mapRotation": "afterGame",
        "enableMatchVoiceChat": true,
        "spectatorSlots": 6,
        "team1Slots": 5,
        "team2Slots": 5,
        "returnToLobby": "never",
        "swapTeamsAfterMatch": false,
        "teamBalancing": "afterGame"
    },
    "gamemodes": {
        "ffa": {
            "enabled": false,
            "gameLengthInMn": 15,
            "enableSelfInitiatedRespawn": false
        },
        "tdm": {
            "enabledMaps": [
                "workshopIslandNight"
            ],
            "gameLengthInMn": 15,
            "needsImbalancedTeamScoreToWin": true,
            "team1ScoreToWin": 10,
            "team2ScoreToWin": 10
        },
        "general": {
            "enableHeroSwitching": false,
            "gamemodeStartTrigger": "immediately",
            "heroLimit": "off",
            "enableRandomHeroes": true
        }
    },
    "heroes": {
        "allTeams": {
            "genji": {
                "ability2Cooldown%": 0,
                "enableInfiniteAmmo": true,
                "enablePrimaryFire": false,
                "enableMelee": false,
                "enableSecondaryFire": false,
                "ability1Cooldown%": 38,
                "combatUltGen%": 0,
                "passiveUltGen%": 0
            },
            "torbjorn": {
                "ability2Duration%": 300
            },
            "enabledHeroes": [
                "genji"
            ]
        }
    },
    "workshop": {
        "Passing": true
    }
}

#Global variables

globalvar Target 0
globalvar prevTarget 1
globalvar ballSpeed 2
globalvar ballSpeedCap 3
globalvar ballPosition 4
globalvar ballDirection 5
globalvar ballSpawnCountdown 7
globalvar ballIsOut 8
globalvar RoundInProgress 9
globalvar bouncePadCooldownLength 10
globalvar IsInFinalDuel 11
globalvar bouncePadDistance 12
globalvar bouncePadStrength 13
globalvar bouncePad1 14
globalvar bouncePad2 15
globalvar bouncePad3 16
globalvar bouncePad4 17
globalvar IsEnoughPlayersToStart 18
globalvar CenterOffLimitsSize 20
globalvar SphereSize 21
globalvar circleCenter 22
globalvar RedGreenColorblindMode 23
globalvar WatermarkEnabled 24
globalvar Abilities 26
globalvar Teamsscoretowin 27
globalvar BozoTracing 28
globalvar matchTime 29
globalvar BallCollisionSurfaceNormal 30
globalvar HighestScore 31
globalvar TieBreakerActive 32
globalvar endlessMode 33
globalvar ballSpawnSpeed 34
globalvar bouncePadSuperjumpNerf 35
globalvar enablepassing 36
globalvar passingassistid 37
globalvar totalRounds 38
globalvar roundsUntilBreak 39
globalvar breakLength 40
globalvar roundsUntilBreakInit 41
globalvar setballspawncountdown 42
globalvar setballspawncountdownoriginal 43
globalvar roundEndCall 44
globalvar passingplayer 45
globalvar bouncePadRange 46
globalvar bouncePadToggle 47
globalvar Sandbox 48
globalvar ballMotion 49
globalvar ballDirectionRate 50
globalvar ballAcceleration 51
globalvar ballDirectionRateInit 52
globalvar tournamentmode 53
globalvar breaksenabled 54
globalvar breakInProgress 55
globalvar waterLevel 56
globalvar tracingMode 57
globalvar tracingPoints 58
globalvar mobilityMode 59
globalvar moveSpeed 60
globalvar gravity 61
globalvar jumpVerticalSpeed 62
globalvar phasePosition 63
globalvar phasePosition1 64
globalvar phasePosition2 65
globalvar ballHitPosition 66
globalvar ballNextFramePosition 67
globalvar CollisionSurfaceDistances 68
globalvar CollisionSurfaceIndex 69
globalvar xray 70
globalvar bozo_Bot 71
globalvar bozoBehaviorModes 72
globalvar bozoAggression 73
globalvar bozoWillOrbit 74
globalvar bozoWillGhostDash 75
globalvar bozoWillEdash 76
globalvar OrbitTolerance 77
globalvar IsOrbiting 78
globalvar bozoIsGhostDashing 79
globalvar Sandboxballpos 80
globalvar Sandboxballdir 81
globalvar botJumping 82
globalvar bozoHasJumped 83
globalvar duelMode 84
globalvar duelQueue 85
globalvar presetMode 86
globalvar motionMultiplier 87
globalvar Sandboxballspd 88
globalvar Sandboxxyz 89
globalvar Sandboxplusminus 90
globalvar Sandboxselected 91
globalvar Critalert 92
globalvar HasCollision 93

#Player variables

playervar hasMoved 0
playervar bouncePadCooldown 2
playervar moveSpeed 10
playervar dashNerf 15
playervar thirdPerson 17
playervar stunCooldown 22
playervar simpleHUD 23
playervar currentGravity 26
playervar canDash 27
playervar antiRubberbanding 28
playervar canDeflect 29
playervar dashOnCooldown 30
playervar SpecialAbility 31
playervar outlineColor 32
playervar outlineFade 33
playervar outlineFadeDark 34
playervar outlineFadeBright 35
playervar Abilitycooldown 36
playervar Abilityready 37
playervar Abilitydesc 38
playervar Critslash 39
playervar Critalert 40

#Subroutine names

subroutine playDeathEffect 0
subroutine deflectFail 1
subroutine dashBall 3
subroutine ballCurve 4
subroutine deleteBall 5
subroutine collisionTarget 6
subroutine alert 8
subroutine setupFinal 9
subroutine randomTarget 10
subroutine startRound 11
subroutine simpleIslandCollision 12
subroutine startBall 13
subroutine stopBall 14
subroutine startModernBall 15
subroutine startAstroBall 16
subroutine startRetroBall 17
subroutine TDMcollision 18

#Activated extensions

#!extension beamEffects
#!extension beamSounds
#!extension buffStatusEffects
#!extension debuffStatusEffects
#!extension buffAndDebuffSounds
#!extension energyExplosionEffects
#!extension kineticExplosionEffects
#!extension explosionSounds
#!extension playMoreEffects
#!extension projectiles


#Only remove the following directive if the gamemode does not use tricks such as A+0, A*0, A or "", "am" == "**", etc which would otherwise be optimized out.
#!optimizeStrict

rule "Old description (for historical archival)":
    smallMessage(getAllPlayers(), "Genji Dodgeball v5.2.1P Community Edition! Developed by u/Mazawath. Numerous updates by u/FearlessKat, u/Blink, u/TheRedstoneBla")
    smallMessage(getAllPlayers(), "ELIMINATED#1572, and tumtum9000#1232. Deflect the ball when it is red to target someone else! Use jump pads to get air!")
    smallMessage(getAllPlayers(), "GENJI DODGEBALL v1.0.0N Community Edition! Originally developed by u/Mazawath. Numerous updates by members of the Official Genji")
    smallMessage(getAllPlayers(), "Dodgeball Server. Deflect the ball when it is red to target someone else! Use jump pads to get air!")


rule "Settings - Workshop settings":
    ballSpawnSpeed = createWorkshopSettingInt(".ball", "spawn speed", 40, 0, 200)
    ballSpeedCap = createWorkshopSettingInt(".ball", "max speed", 400, 60, 800, 1)
    ballAcceleration = createWorkshopSettingInt(".ball", "acceleration (25 => 0.25 per second)", 25, 0, 300, 2) / 100
    ballMotion = createWorkshopSettingEnum("physics", "motion", 0, ["modern", "rapid\n~Workshop Expanse", "astro", "retro"])
    waterLevel = createWorkshopSettingEnum("physics", "water", 0, ["none", "minimal", "moderate", "flood"], 1)
    bouncePadToggle = createWorkshopSettingBool("miscellaneous", "bounce pads", false, 1)
    mobilityMode = createWorkshopSettingEnum("miscellaneous", "mobility", 0, ["agile", "balanced", "sluggish"], 3)
    tournamentmode = createWorkshopSettingBool("tournament", "tournament mode", false)
    totalRounds = createWorkshopSettingInt("tournament", "total rounds", 30, 1, 50, 1)
    breaksenabled = createWorkshopSettingBool("tournament", "breaks", true, 2)
    roundsUntilBreak = createWorkshopSettingInt("tournament", "run break every __ rounds", 10, 4, 25, 3)
    breakLength = createWorkshopSettingInt("tournament", "break length", 60, 1, 120, 4)
    if createWorkshopSettingInt("_custom settings", "↓  ↓  ↓  ↓  ↓  ↓  ↓  ↓  ↓  ↓        only with   \"custom\"   preset", 0, 0, 0):
    matchTime = createWorkshopSettingInt(".", "match length (at least 5 minutes)", 15, 5, 60) * 60
    Abilities = createWorkshopSettingBool(".add-ons", "custom abilities", false)
    bozo_Bot = createWorkshopSettingBool(".add-ons", "bot", false, 1)
    duelMode = createWorkshopSettingBool(".add-ons", "duels", false, 2)
    endlessMode = createWorkshopSettingBool(".add-ons", "endless mode", false, 3)
    xray = createWorkshopSettingBool(".add-ons", "x-ray", false, 4)
    tracingMode = createWorkshopSettingBool(".add-ons", "tracing mode", false, 5)
    presetMode = createWorkshopSettingEnum(".presets", "preset", 0, ["custom", "default", "v1", "rapid\n~workshop expanse", "v7"])
    if presetMode == 1:
        waterLevel = 2
        ballMotion = 0
        bouncePadToggle = false
        mobilityMode = 0
    elif presetMode == 2:
        waterLevel = 0
        ballMotion = 0
        bouncePadToggle = false
        mobilityMode = 0
    elif presetMode == 3:
        waterLevel = 3
        ballMotion = 1
        bouncePadToggle = true
        mobilityMode = 1
    elif presetMode == 4:
        waterLevel = 3
        ballMotion = 0
        bouncePadToggle = true
        mobilityMode = 2
    if ballMotion == 0:
        motionMultiplier = 1
    elif ballMotion == 1:
        motionMultiplier = 0.5
    if mobilityMode == 0:
        moveSpeed = 190
        gravity = 80
        jumpVerticalSpeed = 180
    elif mobilityMode == 1:
        moveSpeed = 150
        gravity = 90
        jumpVerticalSpeed = 150
    elif mobilityMode == 2:
        moveSpeed = 100
        gravity = 100
        jumpVerticalSpeed = 100
    if waterLevel == 0:
        waterLevel = -1000
    elif waterLevel == 1:
        waterLevel = -26
    elif waterLevel == 2:
        waterLevel = -15
    elif waterLevel == 3:
        waterLevel = -0.5
    if bozo_Bot:
        bozo_Bot = 1
    Teamsscoretowin = createWorkshopSettingInt(".Teams settings", "Score to win", 15, 0, 30)
    enablepassing = createWorkshopSettingBool(".Teams settings", "Passing", false, 1)
    Sandbox = createWorkshopSettingBool(".add-ons", "Sandbox mode", false, -2)


rule "Settings - Watermark":
    WatermarkEnabled = false


rule "Settings - Red-green colorblind filter":
    @Disabled
    
    RedGreenColorblindMode = true


rule "Initialization - Set Workshop Island":
    @Condition (__getCurrentMap__() == Map.WORKSHOP_ISLAND or __getCurrentMap__() == Map.WORKSHOP_ISLAND_NIGHT) == true
    
    circleCenter = vect(0, 1.199, 0)
    SphereSize = 60


rule "Initialization - Set Workshop Chamber":
    @Condition __getCurrentMap__() == Map.WORKSHOP_CHAMBER
    
    circleCenter = vect(0, 1.199, 0)
    SphereSize = 29.7


rule "Initialization - Set Workshop Expanse Center":
    @Condition (__getCurrentMap__() == Map.WORKSHOP_EXPANSE or __getCurrentMap__() == Map.WORKSHOP_EXPANSE_NIGHT) == true
    
    circleCenter = vect(0, 1.199, 0)
    SphereSize = 50


rule "Initialization - Set Workshop Green Screen":
    @Condition __getCurrentMap__() == Map.WORKSHOP_GREEN_SCREEN
    
    circleCenter = vect(0, 1.199, 0)
    SphereSize = 60


rule "Initialization - Set Oasis University Center":
    @Condition __getCurrentMap__() == Map.OASIS_UNIVERSITY
    
    circleCenter = vect(-192.609, 60.349, 2.252)
    SphereSize = 25


rule "Initialization - Set Kings Row center (NOTE: Lower the max players! This arena is smaller then the others!)":
    @Condition (__getCurrentMap__() == Map.KINGS_ROW or __getCurrentMap__() == Map.KINGS_ROW_WINTER) == true
    
    circleCenter = vect(-20.504, 40.538, -74.601)
    SphereSize = 23


rule "Initialization - player variables":
    @Event eachPlayer
    
    eventPlayer.Critalert = false
    eventPlayer.Abilityready = false
    eventPlayer.Abilitycooldown = 0
    eventPlayer.setStatusEffect(null, Status.INVINCIBLE, 9999)
    eventPlayer.disableRespawn()
    eventPlayer.bouncePadCooldown = bouncePadCooldownLength
    eventPlayer.stunCooldown = 0
    chaseAtRate(eventPlayer.stunCooldown, 0, 1, ChaseRateReeval.NONE)
    eventPlayer.enableDeathSpectateAllPlayers()
    eventPlayer.enableDeathSpectateTargetHud()
    eventPlayer.thirdPerson = true
    eventPlayer.startCamera(updateEveryFrame(raycastHitPosition(eventPlayer.getEyePosition(), eventPlayer + worldVector(vect(-0.5, 0, 0), eventPlayer, Transform.ROTATION) + Vector.UP * 1.5 + eventPlayer.getFacingDirection() * -2, null, getAllPlayers(), false)), eventPlayer + eventPlayer.getFacingDirection() * 1000)
    eventPlayer.simpleHUD = 0
    #eventPlayer.disableGamemodeHud()
    eventPlayer.canDash = true
    eventPlayer.dashOnCooldown = false
    eventPlayer.canDeflect = true
    eventPlayer.antiRubberbanding = false
    eventPlayer.SpecialAbility = 1
    #Has to be last, to avoid variable conflicts!!
    wait(3)
    smallMessage(eventPlayer, "anti-rubberbanding [{0}]".format(inputBindingString(Button.MELEE)))
    smallMessage(eventPlayer, "switch perspective [{0}]".format(inputBindingString(Button.RELOAD)))
    smallMessage(eventPlayer, "simple HUD [{0}]".format(inputBindingString(Button.INTERACT)))


rule "Initialization - global variables":
    setballspawncountdownoriginal = 5
    setballspawncountdown = setballspawncountdownoriginal
    ballSpawnCountdown = setballspawncountdownoriginal
    disableScoring()
    disableGamemodeCompletion()
    disableMusic()
    disableAnnouncer()
    bouncePadStrength = 30
    bouncePadDistance = 12
    bouncePadSuperjumpNerf = 3
    ballSpeed = ballSpawnSpeed
    CenterOffLimitsSize = 3.5
    IsInFinalDuel = false
    bouncePadCooldownLength = 3
    ballPosition = vect(0, -1, 0)
    roundsUntilBreakInit = roundsUntilBreak
    roundEndCall = false
    ballHitPosition = null
    phasePosition = vect(0, -1, 0)
    phasePosition1 = vect(0, -1, 0)
    phasePosition2 = vect(0, -1, 0)
    tracingPoints = 1
    if ballMotion == 0:
        ballDirectionRateInit = 1.75
        ballDirectionRate = ballDirectionRateInit
    elif ballMotion == 1:
        ballDirectionRateInit = 5
        ballDirectionRate = ballDirectionRateInit
    else:
        ballDirectionRate = 6
    duelQueue = []
    Sandboxxyz = 1
    Sandboxselected = 1
    Sandboxballpos = ballPosition
    Sandboxballdir = ballPosition + vect(0, 1, 0)
    Sandboxballspd = ballSpeed
    Sandboxplusminus = 1
    Critalert = false


rule "Initialization - map sphere":
    createEffect(getAllPlayers(), Effect.SPHERE, Color.BLACK, vect(circleCenter.x, circleCenter.y - 0, circleCenter.z), CenterOffLimitsSize, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
    #Workshop Island doesn't need a circle.
    if __getCurrentMap__() != Map.WORKSHOP_ISLAND and __getCurrentMap__() != Map.WORKSHOP_ISLAND_NIGHT:
        createEffect(getAllPlayers(), Effect.LIGHT_SHAFT, Color.BLACK, vect(circleCenter.x, circleCenter.y - 15, circleCenter.z), SphereSize, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
    else:
        createEffect(getAllPlayers().filter(lambda player: distance(player.getPosition(), circleCenter) >= SphereSize - 10), Effect.LIGHT_SHAFT, Color.BLACK, vect(circleCenter.x, circleCenter.y - 15, circleCenter.z), SphereSize, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)


rule "Initialization - bounce pads":
    @Condition bouncePadToggle == true
    
    bouncePadDistance = 12
    bouncePadRange = 2.75
    bouncePad1 = vect(circleCenter.x + bouncePadDistance, circleCenter.y, circleCenter.z)
    bouncePad2 = vect(circleCenter.x + bouncePadDistance * -1, circleCenter.y, circleCenter.z)
    bouncePad3 = vect(circleCenter.x, circleCenter.y, circleCenter.z + bouncePadDistance)
    bouncePad4 = vect(circleCenter.x, circleCenter.y, circleCenter.z + bouncePadDistance * -1)
    createEffect(getAllPlayers().filter(lambda player: player.bouncePadCooldown == 0), Effect.RING, Color.SKY_BLUE, bouncePad1, 2, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
    createEffect(getAllPlayers().filter(lambda player: player.bouncePadCooldown == 0), Effect.RING, Color.SKY_BLUE, bouncePad2, 2, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
    createEffect(getAllPlayers().filter(lambda player: player.bouncePadCooldown == 0), Effect.RING, Color.SKY_BLUE, bouncePad3, 2, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
    createEffect(getAllPlayers().filter(lambda player: player.bouncePadCooldown == 0), Effect.RING, Color.SKY_BLUE, bouncePad4, 2, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
    if RedGreenColorblindMode:
        goto lbl_0
    createEffect(getAllPlayers().filter(lambda player: player.bouncePadCooldown > 0), Effect.RING, Color.WHITE, bouncePad1, 2, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
    createEffect(getAllPlayers().filter(lambda player: player.bouncePadCooldown > 0), Effect.RING, Color.WHITE, bouncePad2, 2, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
    createEffect(getAllPlayers().filter(lambda player: player.bouncePadCooldown > 0), Effect.RING, Color.WHITE, bouncePad3, 2, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
    createEffect(getAllPlayers().filter(lambda player: player.bouncePadCooldown > 0), Effect.RING, Color.WHITE, bouncePad4, 2, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
    return
    lbl_0:
    createEffect(getAllPlayers().filter(lambda player: player.bouncePadCooldown > 0), Effect.RING, Color.YELLOW, bouncePad1, 2, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
    createEffect(getAllPlayers().filter(lambda player: player.bouncePadCooldown > 0), Effect.RING, Color.YELLOW, bouncePad2, 2, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
    createEffect(getAllPlayers().filter(lambda player: player.bouncePadCooldown > 0), Effect.RING, Color.YELLOW, bouncePad3, 2, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
    createEffect(getAllPlayers().filter(lambda player: player.bouncePadCooldown > 0), Effect.RING, Color.YELLOW, bouncePad4, 2, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)


rule "Initialization - Apply high mobility mode":
    @Event eachPlayer
    @Condition isGameInProgress() == true
    
    eventPlayer.setJumpVerticalSpeed(jumpVerticalSpeed)
    eventPlayer.setGravity(gravity)
    eventPlayer.setMoveSpeed(moveSpeed)
    eventPlayer.currentGravity = gravity


rule "Initialization - Match length":
    @Condition isGameInProgress() == true
    @Condition tournamentmode == false
    
    setMatchTime(matchTime)


rule "Initialization - Disable inspector":
    @Disabled
    
    disableInspector()


rule "HUD - community text":
    hudSubheader(getAllPlayers(), "version 1.3.1", HudPosition.RIGHT, -100, Color.ORANGE, HudReeval.VISIBILITY_AND_STRING)
    #Naz: Link to the Official Genji Dodgeball Discord Server
    hudSubheader(getAllPlayers().filter(lambda player: player.simpleHUD == 0), "welcome to genji ball", HudPosition.LEFT, -6, Color.LIME_GREEN, HudReeval.VISIBILITY_AND_STRING)
    hudText(getAllPlayers().filter(lambda player: player.simpleHUD == 0), null, "discord.gg/genjiball", "", HudPosition.LEFT, -5, Color.ORANGE, Color.AQUA, Color.AQUA, HudReeval.VISIBILITY_AND_STRING)
    hudText(getAllPlayers().filter(lambda player: player.simpleHUD == 0), null, "workshop.codes/genjiball", "", HudPosition.LEFT, -5, Color.ORANGE, Color.AQUA, Color.AQUA, HudReeval.VISIBILITY_AND_STRING)


rule "HUD - target player text":
    #white normal
    hudSubtext(getAllPlayers().exclude(Target), "{1}{0}{1}".format(Target, iconString(Icon.WARNING)), HudPosition.LEFT, -3, Color.WHITE, HudReeval.VISIBILITY_AND_STRING)
    #red when you're targeted
    hudSubtext(Target, "{1}{0}{1}".format(Target, iconString(Icon.WARNING)), HudPosition.LEFT, -3, Color.RED, HudReeval.VISIBILITY_AND_STRING)


rule "HUD - ball speed text":
    #Entity creation fail protection
    wait(1)
    #ball speed text color change with speed
    hudSubtext(getAllPlayers() if ballSpeed < 40 else [], "BALL SPEED: {0}".format(ballSpeed), HudPosition.LEFT, -4, Color.BLUE, HudReeval.VISIBILITY_AND_STRING)
    hudSubtext(getAllPlayers() if ballSpeed >= 40 and ballSpeed < 50 else [], "BALL SPEED: {0}".format(ballSpeed), HudPosition.LEFT, -4, Color.SKY_BLUE, HudReeval.VISIBILITY_AND_STRING)
    hudSubtext(getAllPlayers() if ballSpeed >= 50 and ballSpeed < 65 else [], "BALL SPEED: {0}".format(ballSpeed), HudPosition.LEFT, -4, Color.GREEN, HudReeval.VISIBILITY_AND_STRING)
    hudSubtext(getAllPlayers() if ballSpeed >= 65 and ballSpeed < 69 else [], "BALL SPEED: {0}".format(ballSpeed), HudPosition.LEFT, -4, Color.YELLOW, HudReeval.VISIBILITY_AND_STRING)
    hudSubtext(getAllPlayers() if ballSpeed >= 69 and ballSpeed < 70 else [], "BALL SPEED: ;)", HudPosition.LEFT, -4, Color.YELLOW, HudReeval.VISIBILITY_AND_STRING)
    hudSubtext(getAllPlayers() if ballSpeed >= 70 and ballSpeed < 80 else [], "BALL SPEED: {0}".format(ballSpeed), HudPosition.LEFT, -4, Color.YELLOW, HudReeval.VISIBILITY_AND_STRING)
    hudSubtext(getAllPlayers() if ballSpeed >= 80 and ballSpeed < 100 else [], "BALL SPEED: {0}".format(ballSpeed), HudPosition.LEFT, -4, Color.ORANGE, HudReeval.VISIBILITY_AND_STRING)
    hudSubtext(getAllPlayers() if ballSpeed >= 100 and ballSpeed < 150 else [], "BALL SPEED: {0}".format(ballSpeed), HudPosition.LEFT, -4, Color.PURPLE, HudReeval.VISIBILITY_AND_STRING)
    hudSubtext(getAllPlayers() if ballSpeed >= 150 and ballSpeed < 200 else [], "BALL SPEED: {0}".format(ballSpeed), HudPosition.LEFT, -4, Color.VIOLET, HudReeval.VISIBILITY_AND_STRING)
    hudSubtext(getAllPlayers() if ballSpeed >= 200 and ballSpeed < 220 else [], "BALL SPEED: touch grass", HudPosition.LEFT, -4, Color.ROSE, HudReeval.VISIBILITY_AND_STRING)
    hudSubtext(getAllPlayers() if ballSpeed >= 220 and ballSpeed < 350 else [], "BALL SPEED: {0}".format(ballSpeed), HudPosition.LEFT, -4, Color.ROSE, HudReeval.VISIBILITY_AND_STRING)
    hudSubtext(getAllPlayers() if ballSpeed >= 350 and ballSpeed < 400 else [], "BALL SPEED: ???", HudPosition.LEFT, -4, Color.ROSE, HudReeval.VISIBILITY_AND_STRING)
    hudSubtext(getAllPlayers() if ballSpeed >= 400 and ballSpeed < 450 else [], "BALL SPEED: you good??", HudPosition.LEFT, -4, Color.ROSE, HudReeval.VISIBILITY_AND_STRING)
    hudSubtext(getAllPlayers() if ballSpeed >= 450 and ballSpeed < 700 else [], "BALL SPEED: {0}".format(ballSpeed), HudPosition.LEFT, -4, Color.ROSE, HudReeval.VISIBILITY_AND_STRING)
    hudSubtext(getAllPlayers() if ballSpeed >= 700 and ballSpeed < 750 else [], "BALL SPEED: get a life", HudPosition.LEFT, -4, Color.BLACK, HudReeval.VISIBILITY_AND_STRING)
    hudSubtext(getAllPlayers() if ballSpeed >= 750 else [], "BALL SPEED: {0}".format(ballSpeed), HudPosition.LEFT, -4, Color.BLACK, HudReeval.VISIBILITY_AND_STRING)


rule "HUD - controls text":
    hudSubheader(getAllPlayers().filter(lambda player: player.simpleHUD == 0), "change perspective [{0}]".format(inputBindingString(Button.RELOAD)), HudPosition.LEFT, 0, Color.WHITE, HudReeval.VISIBILITY_AND_STRING)
    if Sandbox == false:
        hudSubheader(getAllPlayers().filter(lambda player: player.simpleHUD == 0), "simple hud [{0}]".format(inputBindingString(Button.INTERACT)), HudPosition.LEFT, 0, Color.WHITE, HudReeval.VISIBILITY_AND_STRING)


rule "HUD - add-ons text":
    @Condition isGameInProgress() == true
    
    #hudSubtext(getAllPlayers().filter(lambda player: player.simpleHUD == 0), "-add-ons-", HudPosition.RIGHT, -7, Color.SKY_BLUE, HudReeval.VISIBILITY_AND_STRING)
    #if waterLevel == -0.5:
    #hudSubheader(getAllPlayers().filter(lambda player: player.simpleHUD == 0), "•water: flood", HudPosition.RIGHT, -6, Color.BLUE, HudReeval.VISIBILITY_AND_STRING)
    #elif waterLevel == -15:
    #hudSubheader(getAllPlayers().filter(lambda player: player.simpleHUD == 0), "•water: moderate", HudPosition.RIGHT, -6, Color.BLUE, HudReeval.VISIBILITY_AND_STRING)
    #elif waterLevel == -26:
    #hudSubheader(getAllPlayers().filter(lambda player: player.simpleHUD == 0), "•water: minimal", HudPosition.RIGHT, -6, Color.BLUE, HudReeval.VISIBILITY_AND_STRING)
    #else:
    #hudSubheader(getAllPlayers().filter(lambda player: player.simpleHUD == 0), "•No water", HudPosition.RIGHT, -5, Color.BLUE, HudReeval.VISIBILITY_AND_STRING)
    #__end__()
    #if endlessMode:
    #hudSubheader(getAllPlayers().filter(lambda player: player.simpleHUD == 0), "•endless", HudPosition.RIGHT, -2, Color.BLUE, HudReeval.VISIBILITY_AND_STRING)
    #__end__()
    if tracingMode:
        hudSubheader(getAllPlayers().filter(lambda player: player.simpleHUD == 0), "tracing: dont lose sight with the ball!", HudPosition.TOP, -1, Color.WHITE, HudReeval.VISIBILITY_AND_STRING)
    if tournamentmode:
        hudHeader(getAllPlayers(), "Tournament", HudPosition.RIGHT, 8, Color.BLACK, HudReeval.VISIBILITY_AND_STRING)
        hudSubtext(getAllPlayers(), "ROUNDS LEFT: {0}".format(totalRounds), HudPosition.RIGHT, 9, Color.PURPLE, HudReeval.VISIBILITY_AND_STRING)
        hudSubtext(getAllPlayers(), "ROUNDS UNTIL BREAK: {0}".format(roundsUntilBreak), HudPosition.RIGHT, 10, Color.PURPLE, HudReeval.VISIBILITY_AND_STRING)


rule "HUD - server load and gameplay tips":
    @Disabled
    
    #server load text for lobby owner only
    hudText(hostPlayer, null, "Server Load", getServerLoad(), HudPosition.RIGHT, 0, Color.WHITE, Color.WHITE, Color.WHITE, HudReeval.VISIBILITY_AND_STRING)
    hudText(hostPlayer, null, "Server Load Average", getAverageServerLoad(), HudPosition.RIGHT, 0, Color.WHITE, Color.WHITE, Color.WHITE, HudReeval.VISIBILITY_AND_STRING)
    hudText(hostPlayer, null, "Server Load Peak", getPeakServerLoad(), HudPosition.RIGHT, 0, Color.WHITE, Color.WHITE, Color.WHITE, HudReeval.VISIBILITY_AND_STRING)
    #gameplay tips text (Naz: Moved to the top of the "Settings" section for ease of access)
    hudSubtext(getAllPlayers(), "Deflect or Dash will deflect the ball to an enemy", HudPosition.RIGHT, -10, Color.WHITE, HudReeval.VISIBILITY_AND_STRING)
    hudSubtext(getAllPlayers(), "If you get hit, you die.  Last man standing wins!", HudPosition.RIGHT, -9, Color.WHITE, HudReeval.VISIBILITY_AND_STRING)


rule "HUD - anti rubberbanding hud text":
    @Event eachPlayer
    
    hudSubheader(eventPlayer, "anti-rubberbanding [{0}]: {1}".format(inputBindingString(Button.MELEE), "On" if eventPlayer.antiRubberbanding else "Off"), HudPosition.LEFT, 0, Color.WHITE, HudReeval.VISIBILITY_AND_STRING)


rule "HUD - zen mode cooldown":
    @Event eachPlayer
    
    hudSubtext(eventPlayer if eventPlayer.simpleHUD == 2 else null, "\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n", HudPosition.TOP, 10, Color.WHITE, HudReeval.VISIBILITY_AND_STRING)
    hudHeader(eventPlayer if eventPlayer.simpleHUD == 2 else null, "{0}\nDeflect".format(abilityIconString(Hero.GENJI, Button.ABILITY_2)), HudPosition.TOP, 12, Color.BLUE if eventPlayer.canDeflect and not eventPlayer.hasStatus(Status.KNOCKED_DOWN) and not eventPlayer.hasStatus(Status.ASLEEP) and eventPlayer.isAlive() and not eventPlayer.isUsingAbility2() and not eventPlayer.isUsingAbility1() else Color.GREEN if eventPlayer.isUsingAbility2() else Color.GRAY, HudReeval.VISIBILITY_AND_COLOR)
    hudHeader(eventPlayer if eventPlayer.simpleHUD == 2 else null, "{0}\nDash".format(abilityIconString(Hero.GENJI, Button.ABILITY_1)), HudPosition.TOP, 11, Color.BLUE if eventPlayer.canDash and not eventPlayer.dashOnCooldown and not eventPlayer.hasStatus(Status.KNOCKED_DOWN) and not eventPlayer.hasStatus(Status.ASLEEP) and eventPlayer.isAlive() and not eventPlayer.isUsingAbility1() else Color.GREEN if eventPlayer.isUsingAbility1() else Color.GRAY, HudReeval.VISIBILITY_AND_COLOR)


rule "HUD - Watermark":
    if not WatermarkEnabled:
        goto lbl_0
    #Please don't be a child and try to take credit for this game. If you actually have contributed something you are free to add here. But if not, don't touch this. You are free to disable it.
    hudSubheader(getAllPlayers(), "원작자 u/Mazawrath. v1.0.0N", HudPosition.LEFT, -1000, Color.AQUA, HudReeval.VISIBILITY_AND_STRING, SpecVisibility.ALWAYS)
    lbl_0:


rule "Appearance - target effects":
    @Condition isGameInProgress() == true
    @Disabled
    
    createEffect(getAllPlayers().exclude(Target), Effect.ORB, Color.WHITE, updateEveryFrame(ballPosition), 1, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
    createProjectileEffect(getAllPlayers(), Projectile.SIGMA_HYPERSPHERE, null, updateEveryFrame(ballPosition), ballDirection, 0.01, ProjectileEffectReeval.VISIBILITY_POSITION_DIRECTION_AND_SIZE)
    if getCurrentGamemode() == Gamemode.TDM:
        #if passingplayer == prevTarget and Target.getTeam() == prevTarget.getTeam() or Target == prevTarget:
        #if passingplayer == prevTarget and Target.getTeam() == prevTarget.getTeam():
        #createEffect(Target, Effect.ORB, Color.SKY_BLUE, updateEveryFrame(ballPosition), 1, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
        #createEffect(Target, Effect.GOOD_AURA, Color.BLUE, ballPosition, 1, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
        #createEffect(getAllPlayers().exclude(Target) if Target.isAlive() else null, Effect.GOOD_AURA, Color.RED, Target, 1, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
        #createEffect(localPlayer if localPlayer == Target else null, Effect.GOOD_AURA, Color.GRAY if localPlayer.thirdPerson else Color.RED, localPlayer, 0.8)
        #else:
        createEffect(Target, Effect.ORB, Color.SKY_BLUE if updateEveryFrame(passingplayer.getTeam() == Target.getTeam()) else Color.RED, updateEveryFrame(ballPosition), 1, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
        createEffect(getAllPlayers().exclude(Target) if Target.isAlive() else null, Effect.GOOD_AURA, Color.RED, Target, 1, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
        createEffect(localPlayer if localPlayer == Target else null, Effect.GOOD_AURA, Color.GRAY if localPlayer.thirdPerson else Color.RED, localPlayer, 0.8)
        createEffect(Target, Effect.GOOD_AURA, Color.BLUE, ballPosition, 1, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
    if not RedGreenColorblindMode:
        createEffect(Target, Effect.ORB, Color.RED, updateEveryFrame(ballPosition), 1, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
        createEffect(getAllPlayers().exclude(Target) if Target.isAlive() else null, Effect.GOOD_AURA, Color.RED, Target, 1, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
        createEffect(localPlayer if localPlayer == Target else null, Effect.GOOD_AURA, Color.GRAY if localPlayer.thirdPerson else Color.RED, localPlayer, 0.8)
        createEffect(Target, Effect.GOOD_AURA, Color.BLUE, ballPosition, 1, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
    else:
        createEffect(Target, Effect.ORB, Color.BLUE, updateEveryFrame(ballPosition), 0.4, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
        createEffect(getAllPlayers(), Effect.GOOD_AURA, Color.BLUE, Target, 1, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
        createEffect(Target, Effect.GOOD_AURA, Color.BLUE, Target, 1, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
    if xray:
        createIcon(Target if ballIsOut and not isInLoS(Target.getEyePosition(), ballPosition, BarrierLos.BLOCKED_BY_ALL_BARRIERS) else null, updateEveryFrame(ballPosition), Icon.HEART, IconReeval.VISIBILITY_AND_POSITION, Color.RED)
    #createEffect(updateEveryFrame(getAllPlayers().filter(lambda player: player != Target and (tournamentmode or breaksenabled))), Effect.GOOD_AURA, Color.SKY_BLUE, Target, 1, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)


rule "Appearance - target effectsv2":
    @Condition isGameInProgress() == true
    
    if getCurrentGamemode() == Gamemode.TDM:
        createEffect(updateEveryFrame(getAllPlayers().exclude(getPlayers(Target.getTeam())) if passingplayer == prevTarget and Target.getTeam() == prevTarget.getTeam() else getAllPlayers().exclude(Target)), Effect.ORB, Color.WHITE, updateEveryFrame(ballPosition), 1, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
        #createProjectileEffect(getAllPlayers(), Projectile.SIGMA_HYPERSPHERE, updateEveryFrame(getPlayers(Target.getTeam()).exclude(Target) if passingplayer == prevTarget and Target.getTeam() == prevTarget.getTeam() else null), updateEveryFrame(ballPosition), ballDirection, 0.01, ProjectileEffectReeval.VISIBILITY_POSITION_DIRECTION_AND_SIZE)
    else:
        createEffect(getAllPlayers().exclude(Target), Effect.ORB, Color.WHITE, updateEveryFrame(ballPosition), 1, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
    createProjectileEffect(getAllPlayers(), Projectile.SIGMA_HYPERSPHERE, null, updateEveryFrame(ballPosition), ballDirection, 0.01, ProjectileEffectReeval.VISIBILITY_POSITION_DIRECTION_AND_SIZE)
    if getCurrentGamemode() == Gamemode.TDM:
        createEffect(Target, Effect.ORB, Color.RED, updateEveryFrame(ballPosition), 1, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
        createEffect(updateEveryFrame(getAllPlayers().exclude(Target).exclude(getPlayers(getOppositeTeam(Target.getTeam()))) if passingplayer == prevTarget and Target.getTeam() == prevTarget.getTeam() else null), Effect.ORB, Color.AQUA, updateEveryFrame(ballPosition), 1, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
        createEffect(getAllPlayers().exclude(Target) if Target.isAlive() else null, Effect.GOOD_AURA, Color.RED, Target, 1, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
        createEffect(localPlayer if localPlayer == Target else null, Effect.GOOD_AURA, Color.GRAY if localPlayer.thirdPerson else Color.RED, localPlayer, 0.8)
        createEffect(Target, Effect.GOOD_AURA, Color.BLUE, ballPosition, 1, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
    elif not RedGreenColorblindMode:
        createEffect(Target, Effect.ORB, Color.RED, updateEveryFrame(ballPosition), 1, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
        createEffect(getAllPlayers().exclude(Target) if Target.isAlive() else null, Effect.GOOD_AURA, Color.RED, Target, 1, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
        createEffect(localPlayer if localPlayer == Target else null, Effect.GOOD_AURA, Color.GRAY if localPlayer.thirdPerson else Color.RED, localPlayer, 0.8)
        createEffect(Target, Effect.GOOD_AURA, Color.BLUE, ballPosition, 1, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
    else:
        createEffect(Target, Effect.ORB, Color.BLUE, updateEveryFrame(ballPosition), 0.4, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
        createEffect(getAllPlayers(), Effect.GOOD_AURA, Color.BLUE, Target, 1, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
        createEffect(Target, Effect.GOOD_AURA, Color.BLUE, Target, 1, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
    if xray:
        createIcon(Target if ballIsOut and not isInLoS(Target.getEyePosition(), ballPosition, BarrierLos.BLOCKED_BY_ALL_BARRIERS) else null, updateEveryFrame(ballPosition), Icon.HEART, IconReeval.VISIBILITY_AND_POSITION, Color.RED)


rule "Appearance - ball countdown":
    createInWorldText(null if ballIsOut else getAllPlayers().exclude(Target), "BALL SPAWNING IN: {0}".format(ceil(ballSpawnCountdown)), vect(circleCenter.x, circleCenter.y + 2.5, circleCenter.z), 2.5, Clip.SURFACES, WorldTextReeval.VISIBILITY_POSITION_AND_STRING, Color.SKY_BLUE)
    createInWorldText(null if ballIsOut else Target, "BALL SPAWNING IN: {0}".format(ceil(ballSpawnCountdown)), vect(circleCenter.x, circleCenter.y + 2.5, circleCenter.z), 2.5, Clip.SURFACES, WorldTextReeval.VISIBILITY_POSITION_AND_STRING, Color.RED)


rule "Check for <2 players":
    @Condition isGameInProgress() == true
    @Condition getNumberOfPlayers(Team.ALL) == 1
    @Condition getCurrentGamemode() == Gamemode.FFA
    @Disabled
    
    IsInFinalDuel = false
    IsEnoughPlayersToStart = false
    stopChasing(ballSpawnCountdown)
    deleteBall()
    if RoundInProgress == false:
        goto lbl_0
    RoundInProgress = false
    lbl_0:
    bigMessage(getAllPlayers(), "Waiting for players")


rule "Wait for more players":
    @Condition isGameInProgress() == true
    @Condition (getNumberOfPlayers(Team.ALL) > 1 or (Sandbox == (true or 3))) == true
    @Condition IsEnoughPlayersToStart == false
    @Condition getCurrentGamemode() == Gamemode.FFA
    @Disabled
    
    if Sandbox == true:
        goto lbl_0
    if getNumberOfPlayers(Team.ALL) < 2:
        return
    lbl_0:
    bigMessage(getAllPlayers(), "Lets begin!")
    IsEnoughPlayersToStart = true
    startRound()


rule "Player joins game":
    @Event eachPlayer
    @Condition eventPlayer.hasMoved == false
    @Condition eventPlayer.hasSpawned() == true
    
    if not RoundInProgress or not isGameInProgress():
        goto lbl_0
    kill(eventPlayer)
    lbl_0:
    eventPlayer.teleport(circleCenter + vect(random.randint(-10, 10), 8, random.randint(-10, 10)))
    eventPlayer.hasMoved = true
    eventPlayer.startForcingHero(Hero.GENJI)


rule "Controls - Dash on primary":
    @Event eachPlayer
    @Condition eventPlayer.isHoldingButton(Button.PRIMARY_FIRE) == true
    #Naz: This is remnent code from a dark and lawless time in the development of this game. Leave it be...
    #@Condition "{0}".format(eventPlayer) != "bytestats"
    @Condition eventPlayer.isDummy() != true
    @Condition eventPlayer.isHoldingButton(Button.ABILITY_1) == false
    @Condition eventPlayer.canDash == true
    @Condition eventPlayer.dashOnCooldown == false
    
    if eventPlayer.antiRubberbanding == true:
        eventPlayer.allowButton(Button.ABILITY_1)
        eventPlayer.forceButtonPress(Button.ABILITY_1)
        eventPlayer.disallowButton(Button.ABILITY_1)
    else:
        eventPlayer.forceButtonPress(Button.ABILITY_1)


rule "Controls - Deflect on secondary":
    @Event eachPlayer
    @Condition eventPlayer.isHoldingButton(Button.SECONDARY_FIRE) == true
    #Naz: This is remnent code from a dark and lawless time in the development of this game. Leave it be...
    #@Condition "{0}".format(eventPlayer) != "bytestats"
    @Condition eventPlayer.isDummy() != true
    @Condition eventPlayer.isUsingAbility1() == false
    @Condition eventPlayer.isHoldingButton(Button.ABILITY_2) == false
    @Condition eventPlayer.canDeflect == true
    @Condition enablepassing == false
    
    if eventPlayer.antiRubberbanding == true:
        eventPlayer.allowButton(Button.ABILITY_2)
        eventPlayer.forceButtonPress(Button.ABILITY_2)
        eventPlayer.disallowButton(Button.ABILITY_2)
    else:
        eventPlayer.forceButtonPress(Button.ABILITY_2)


rule "Controls - Dash slow (gravity shift)":
    @Event eachPlayer
    @Condition eventPlayer.isUsingAbility1() == true
    
    eventPlayer.moveSpeed = 0
    chaseAtRate(eventPlayer.moveSpeed, 100, max(eventPlayer.moveSpeed, 16) ** 1.25)
    while eventPlayer.moveSpeed != 100:
        eventPlayer.setMoveSpeed(moveSpeed * (eventPlayer.moveSpeed / 100))
        if eventPlayer.currentGravity == 0:
            goto lbl_0
        eventPlayer.setGravity(gravity * (eventPlayer.moveSpeed / 100))
        lbl_0:
        wait(0.1)
    eventPlayer.setMoveSpeed(moveSpeed)
    if eventPlayer.currentGravity == 0:
        goto lbl_1
    eventPlayer.setGravity(gravity)
    lbl_1:


rule "Controls - Shorten deflect length":
    @Event eachPlayer
    @Condition eventPlayer.isUsingAbility2() == true
    @Condition eventPlayer.isUsingUltimate() == false
    
    wait(0.3)
    if eventPlayer.isDummy() == true:
        if bozoWillEdash == true or bozoWillGhostDash == true:
            eventPlayer.forceButtonPress(Button.ABILITY_1)
            bozoWillGhostDash = false
            bozoWillEdash = false
    eventPlayer.setAbility2Enabled(false)
    eventPlayer.setAbility1Enabled(false)
    eventPlayer.canDeflect = false
    eventPlayer.canDash = false
    wait(0.5)
    eventPlayer.setAbility2Enabled(true)
    eventPlayer.setAbility1Enabled(true)
    eventPlayer.canDeflect = true
    eventPlayer.canDash = true


rule "Controls - Anti rubberbanding disallow buttons":
    @Event eachPlayer
    @Condition eventPlayer.isDummy() != true
    @Condition eventPlayer.antiRubberbanding == true
    
    eventPlayer.disallowButton(Button.ABILITY_1)
    eventPlayer.disallowButton(Button.ABILITY_2)


rule "Controls - dash anti rubberbanding & button queue":
    @Event eachPlayer
    @Condition eventPlayer.isHoldingButton(Button.ABILITY_1) == true
    #Naz: This is remnent code from a dark and lawless time in the development of this game. Leave it be...
    #@Condition "{0}".format(eventPlayer) != "bytestats"
    @Condition eventPlayer.isDummy() != true
    @Condition eventPlayer.isUsingAbility1() == false
    @Condition eventPlayer.canDash == true
    @Condition eventPlayer.dashOnCooldown == false
    
    if eventPlayer.antiRubberbanding == true:
        eventPlayer.allowButton(Button.ABILITY_1)
        eventPlayer.forceButtonPress(Button.ABILITY_1)
        eventPlayer.disallowButton(Button.ABILITY_1)
    else:
        eventPlayer.forceButtonPress(Button.ABILITY_1)


rule "Controls - deflect anti rubberbanding & button queue":
    @Event eachPlayer
    @Condition eventPlayer.isHoldingButton(Button.ABILITY_2) == true
    #Naz: This is remnent code from a dark and lawless time in the development of this game. Leave it be...
    #@Condition "{0}".format(eventPlayer) != "bytestats"
    @Condition eventPlayer.isDummy() != true
    @Condition eventPlayer.isUsingAbility1() == false
    @Condition eventPlayer.isUsingAbility2() == false
    @Condition eventPlayer.canDeflect == true
    
    if eventPlayer.antiRubberbanding == true:
        eventPlayer.allowButton(Button.ABILITY_2)
        eventPlayer.forceButtonPress(Button.ABILITY_2)
        eventPlayer.disallowButton(Button.ABILITY_2)
    else:
        eventPlayer.forceButtonPress(Button.ABILITY_2)


rule "Controls - Dash cooldown":
    @Event eachPlayer
    @Condition eventPlayer.isAlive() == true
    @Condition eventPlayer.isUsingAbility1() == true
    
    eventPlayer.dashOnCooldown = true
    waitUntil(not eventPlayer.isUsingAbility1(), 0.5)
    waitUntil(eventPlayer.dashOnCooldown == false, 3.04)
    eventPlayer.dashOnCooldown = false


rule "Control - Dash reset":
    @Event playerEarnedElimination
    
    eventPlayer.dashOnCooldown = false


rule "Controls - Switch perspective (reload)":
    @Event eachPlayer
    @Condition breakInProgress == false
    @Condition eventPlayer.isHoldingButton(Button.RELOAD) == true
    @Condition eventPlayer.isAlive() == true
    
    if not eventPlayer.thirdPerson:
        eventPlayer.thirdPerson = true
        wait(0.01)
        eventPlayer.startCamera(updateEveryFrame(raycastHitPosition(eventPlayer.getEyePosition(), eventPlayer + worldVector(vect(-0.5, 0, 0), eventPlayer, Transform.ROTATION) + Vector.UP * 1.5 + eventPlayer.getFacingDirection() * -2, null, getAllPlayers(), false)), eventPlayer + eventPlayer.getFacingDirection() * 1000)
        playEffect(eventPlayer, DynamicEffect.BRIGITTE_REPAIR_PACK_ARMOR_SOUND, Color.WHITE, eventPlayer, 10)
    else:
        eventPlayer.stopCamera()
        eventPlayer.thirdPerson = false
        playEffect(eventPlayer, DynamicEffect.BRIGITTE_REPAIR_PACK_ARMOR_SOUND, Color.WHITE, eventPlayer, 10)
    wait(0.1)


rule "Controls - toggle anti rubberbanding (melee)":
    @Event eachPlayer
    @Condition eventPlayer.isHoldingButton(Button.MELEE) == true
    @Condition eventPlayer.isDummy() != true
    
    if eventPlayer.antiRubberbanding == true:
        eventPlayer.antiRubberbanding = false
        eventPlayer.allowButton(Button.ABILITY_1)
        eventPlayer.allowButton(Button.ABILITY_2)
        smallMessage(eventPlayer, "anti rubberbanding: off")
    elif eventPlayer.antiRubberbanding == false:
        eventPlayer.antiRubberbanding = true
        eventPlayer.disallowButton(Button.ABILITY_1)
        eventPlayer.disallowButton(Button.ABILITY_2)
        smallMessage(eventPlayer, "anti rubberbanding: on")
    playEffect(eventPlayer, DynamicEffect.BRIGITTE_REPAIR_PACK_ARMOR_SOUND, Color.WHITE, eventPlayer, 10)
    wait(0.1)


rule "Controls - Simple HUD (Interact)":
    @Event eachPlayer
    @Condition eventPlayer.isHoldingButton(Button.INTERACT) == true
    @Condition eventPlayer.isAlive() == true
    @Condition Sandbox == false
    
    if eventPlayer.simpleHUD == 2:
        eventPlayer.simpleHUD = 0
        eventPlayer.enableHeroHud()
        playEffect(eventPlayer, DynamicEffect.BRIGITTE_REPAIR_PACK_ARMOR_SOUND, Color.WHITE, eventPlayer, 10)
        smallMessage(eventPlayer, "simple hud: off")
        return
    waitUntil(not eventPlayer.isHoldingButton(Button.INTERACT), 0.4)
    if eventPlayer.isHoldingButton(Button.INTERACT):
        if eventPlayer.simpleHUD == 2:
            eventPlayer.simpleHUD = 0
            eventPlayer.enableHeroHud()
            playEffect(eventPlayer, DynamicEffect.BRIGITTE_REPAIR_PACK_ARMOR_SOUND, Color.WHITE, eventPlayer, 10)
            smallMessage(eventPlayer, "simple hud: off")
        else:
            eventPlayer.simpleHUD = 2
            eventPlayer.disableHeroHud()
            playEffect(eventPlayer, DynamicEffect.BRIGITTE_REPAIR_PACK_ARMOR_SOUND, Color.WHITE, eventPlayer, 10)
            smallMessage(eventPlayer, "simple hud: zen mode")
    else:
        if eventPlayer.simpleHUD == 0:
            eventPlayer.simpleHUD = 1
            playEffect(eventPlayer, DynamicEffect.BRIGITTE_REPAIR_PACK_ARMOR_SOUND, Color.WHITE, eventPlayer, 10)
            smallMessage(eventPlayer, "simple hud: on")
        else:
            eventPlayer.simpleHUD = 0
            eventPlayer.enableHeroHud()
            playEffect(eventPlayer, DynamicEffect.BRIGITTE_REPAIR_PACK_ARMOR_SOUND, Color.WHITE, eventPlayer, 10)
            smallMessage(eventPlayer, "simple hud: off")
    wait(0.1)


rule "Controls - Bounce when near pad 1":
    @Event eachPlayer
    @Condition bouncePad1 != null
    @Condition distance(eventPlayer.getPosition(), bouncePad1) <= bouncePadRange
    @Condition eventPlayer.bouncePadCooldown == 0
    @Condition eventPlayer.isAlive() == true
    @Condition eventPlayer.isHoldingButton(Button.JUMP) == true
    @Condition bouncePadToggle == true
    
    if eventPlayer.dashNerf:
        eventPlayer.applyImpulse(Vector.UP, bouncePadStrength - bouncePadSuperjumpNerf, Relativity.TO_WORLD, Impulse.CANCEL_CONTRARY_MOTION)
    else:
        eventPlayer.applyImpulse(Vector.UP, bouncePadStrength, Relativity.TO_WORLD, Impulse.CANCEL_CONTRARY_MOTION)
    eventPlayer.bouncePadCooldown = bouncePadCooldownLength
    playEffect(getAllPlayers(), DynamicEffect.RING_EXPLOSION_SOUND, Color.WHITE, bouncePad1, 25)


rule "Controls - Bounce when near pad 2":
    @Event eachPlayer
    @Condition bouncePad2 != null
    @Condition distance(eventPlayer.getPosition(), bouncePad2) <= bouncePadRange
    @Condition eventPlayer.bouncePadCooldown == 0
    @Condition eventPlayer.isAlive() == true
    @Condition eventPlayer.isHoldingButton(Button.JUMP) == true
    @Condition bouncePadToggle == true
    
    if eventPlayer.dashNerf:
        eventPlayer.applyImpulse(Vector.UP, bouncePadStrength - bouncePadSuperjumpNerf, Relativity.TO_WORLD, Impulse.CANCEL_CONTRARY_MOTION)
    else:
        eventPlayer.applyImpulse(Vector.UP, bouncePadStrength, Relativity.TO_WORLD, Impulse.CANCEL_CONTRARY_MOTION)
    eventPlayer.bouncePadCooldown = bouncePadCooldownLength
    playEffect(getAllPlayers(), DynamicEffect.RING_EXPLOSION_SOUND, Color.WHITE, bouncePad2, 25)


rule "Controls - Bounce when near pad 3":
    @Event eachPlayer
    @Condition bouncePad3 != null
    @Condition distance(eventPlayer.getPosition(), bouncePad3) <= bouncePadRange
    @Condition eventPlayer.bouncePadCooldown == 0
    @Condition eventPlayer.isAlive() == true
    @Condition eventPlayer.isHoldingButton(Button.JUMP) == true
    @Condition bouncePadToggle == true
    
    if eventPlayer.dashNerf:
        eventPlayer.applyImpulse(Vector.UP, bouncePadStrength - bouncePadSuperjumpNerf, Relativity.TO_WORLD, Impulse.CANCEL_CONTRARY_MOTION)
    else:
        eventPlayer.applyImpulse(Vector.UP, bouncePadStrength, Relativity.TO_WORLD, Impulse.CANCEL_CONTRARY_MOTION)
    eventPlayer.bouncePadCooldown = bouncePadCooldownLength
    playEffect(getAllPlayers(), DynamicEffect.RING_EXPLOSION_SOUND, Color.WHITE, bouncePad3, 25)


rule "Controls - Bounce when near pad 4":
    @Event eachPlayer
    @Condition bouncePad4 != null
    @Condition distance(eventPlayer.getPosition(), bouncePad4) <= bouncePadRange
    @Condition eventPlayer.bouncePadCooldown == 0
    @Condition eventPlayer.isAlive() == true
    @Condition eventPlayer.isHoldingButton(Button.JUMP) == true
    @Condition bouncePadToggle == true
    
    if eventPlayer.dashNerf:
        eventPlayer.applyImpulse(Vector.UP, bouncePadStrength - bouncePadSuperjumpNerf, Relativity.TO_WORLD, Impulse.CANCEL_CONTRARY_MOTION)
    else:
        eventPlayer.applyImpulse(Vector.UP, bouncePadStrength, Relativity.TO_WORLD, Impulse.CANCEL_CONTRARY_MOTION)
    eventPlayer.bouncePadCooldown = bouncePadCooldownLength
    playEffect(getAllPlayers(), DynamicEffect.RING_EXPLOSION_SOUND, Color.WHITE, bouncePad4, 25)


def startRound():
    @Name "Active game - start round"
    
    if Sandbox == true:
        waitUntil(hostPlayer.isHoldingButton(Button.ULTIMATE) == true and hostPlayer.isHoldingButton(Button.RELOAD) == true, 99999)
    randomTarget()
    chaseAtRate(ballSpawnCountdown, 0, 1)
    RoundInProgress = true
    chaseAtRate(getAllPlayers().bouncePadCooldown, 0, 1)
    ballSpawnCountdown = setballspawncountdown
    getLivingPlayers(Team.ALL).bouncePadCooldown = bouncePadCooldownLength - 1


rule "Active game - spawn ball":
    @Condition ballSpawnCountdown == 0
    @Condition ballIsOut == false
    @Condition Target.isAlive() == true
    
    if Sandbox == true:
        ballPosition = Sandboxballpos
        ballDirection = directionTowards(Sandboxballpos, Sandboxballdir)
        ballSpeed = Sandboxballspd
    else:
        ballPosition = circleCenter
        ballDirection = directionTowards(ballPosition, Target.getEyePosition())
        ballSpeed = min(ballSpawnSpeed, ballSpeed)
    async(startBall, AsyncBehavior.RESTART)


def setupFinal():
    @Name "Subroutine - setup duel"
    
    if ballIsOut == false:
        goto lbl_0
    deleteBall()
    lbl_0:
    randomTarget()
    stopChasing(ballSpawnCountdown)
    if Sandbox == true:
        waitUntil(hostPlayer.isHoldingButton(Button.ULTIMATE) == true and hostPlayer.isHoldingButton(Button.RELOAD) == true, 99999)
    IsInFinalDuel = true
    chaseAtRate(ballSpawnCountdown, 0, 1)
    getLivingPlayers(Team.ALL).bouncePadCooldown = bouncePadCooldownLength - 1
    if __getCurrentMap__() == Map.WORKSHOP_ISLAND or __getCurrentMap__() == Map.WORKSHOP_ISLAND_NIGHT:
        getLivingPlayers(Team.ALL).filter(lambda player: player.hasMoved)[0].startForcingPosition(circleCenter + vect(-1, 0, 0) * 15, false)
        getLivingPlayers(Team.ALL).filter(lambda player: player.hasMoved)[1].startForcingPosition(circleCenter + vect(1, 0, 0) * 15, false)
    else:
        getLivingPlayers(Team.ALL).filter(lambda player: player.hasMoved)[0].startForcingPosition(circleCenter + vect(-1, 0, 0) * (SphereSize / 1.5), false)
        getLivingPlayers(Team.ALL).filter(lambda player: player.hasMoved)[1].startForcingPosition(circleCenter + vect(1, 0, 0) * (SphereSize / 1.5), false)
    getLivingPlayers(Team.ALL).setStatusEffect(null, Status.ROOTED, 1.5)
    wait(0)
    getLivingPlayers(Team.ALL)[0].setFacing(directionTowards(getLivingPlayers(Team.ALL).filter(lambda player: player.hasMoved)[0].getPosition(), circleCenter), Relativity.TO_WORLD)
    getLivingPlayers(Team.ALL)[1].setFacing(directionTowards(getLivingPlayers(Team.ALL).filter(lambda player: player.hasMoved)[1].getPosition(), circleCenter), Relativity.TO_WORLD)
    bigMessage(getAllPlayers(), "{0} vs. {1}".format(getLivingPlayers(Team.ALL).filter(lambda player: player.hasMoved)[0], getLivingPlayers(Team.ALL).filter(lambda player: player.hasMoved)[1]))
    wait(0.1)
    getLivingPlayers(Team.ALL).filter(lambda player: player.hasMoved)[0].stopForcingPosition()
    getLivingPlayers(Team.ALL).filter(lambda player: player.hasMoved)[1].stopForcingPosition()


rule "Active game - final duel":
    @Condition isGameInProgress() == true
    @Condition len(getLivingPlayers(Team.ALL).filter(lambda player: player.hasMoved)) == 2
    @Condition IsEnoughPlayersToStart == true
    @Condition IsInFinalDuel == false
    @Condition duelMode == false
    @Condition endlessMode == false
    @Condition getCurrentGamemode() == Gamemode.FFA
    
    wait(0.016, Wait.ABORT_WHEN_FALSE)
    if not ruleCondition:
        return
    setupFinal()


rule "Active game - check for last player surviving":
    @Condition isGameInProgress() == true
    @Condition getNumberOfLivingPlayers(Team.ALL) == 1
    @Condition IsEnoughPlayersToStart == true
    @Condition duelMode == false
    @Disabled
    
    IsInFinalDuel = false
    getLivingPlayers(Team.ALL).addToScore(1)
    wait(0.25)
    if (getMatchTime() == 0 or TieBreakerActive) and not tournamentmode:
        #If there is alredy a tiebreaker, then the tiebreaker has ended.
        #if TieBreakerActive:
        #break
        #__end__()
        HighestScore = sorted(getAllPlayers(), lambda player: player.getScore()).last().getScore()
        #Check if there is more then 1 person with the highest score
        if len(getAllPlayers().filter(lambda player: player.getScore() == HighestScore)) > 1:
            #There is more then 1, activate tie breaker
            TieBreakerActive = true
        else:
            TieBreakerActive = false
            if getMatchTime() == 0:
                enableMusic()
                enableGamemodeCompletion()
    stopChasing(ballSpawnCountdown)
    stopChasing(getAllPlayers().bouncePadCooldown)
    bigMessage(getAllPlayers(), "{0} has won the round".format(getLivingPlayers(Team.ALL)[0]))
    wait(2)
    if duelMode:
        goto lbl_0
    if not TieBreakerActive:
        getDeadPlayers(Team.ALL).resurrect()
    else:
        #Kill anyone alive who doesn't have the highest score.
        kill(getLivingPlayers(Team.ALL).filter(lambda player: player.getScore() != HighestScore))
        #During tiebreaker, only revive the people who have the same score as the highest score.
        (getDeadPlayers(Team.ALL).filter(lambda player: player.getScore() == HighestScore)).resurrect()
        wait(0.25)
        bigMessage(getAllPlayers(), "tiebreaker!")
    lbl_0:
    startRound()


rule "Active game - all players dead":
    @Condition getNumberOfLivingPlayers(Team.ALL) == 0
    @Condition isGameInProgress() == true
    @Condition TieBreakerActive == false
    @Condition duelMode == false
    
    IsInFinalDuel = false
    if ballIsOut == false:
        goto lbl_0
    deleteBall()
    lbl_0:
    RoundInProgress = false
    stopChasing(ballSpawnCountdown)
    getDeadPlayers(Team.ALL).resurrect()
    stopChasing(getAllPlayers().bouncePadCooldown)
    getAllPlayers().bouncePadCooldown = bouncePadCooldownLength
    ballSpawnCountdown = setballspawncountdown
    wait(1)
    if ruleCondition:
        loop()
    wait(2)
    if IsEnoughPlayersToStart:
        return
    stopChasing(ballSpawnCountdown)
    startRound()


rule "Active game - end game":
    @Condition getMatchTime() == 0
    @Condition RoundInProgress == false
    @Condition TieBreakerActive == false
    @Condition tournamentmode == false
    @Condition getCurrentGamemode() == Gamemode.FFA
    
    enableMusic()
    enableGamemodeCompletion()


def randomTarget():
    @Name "Active game - target random player"
    
    if Sandbox == true:
        Target = hostPlayer
        goto lbl_0
    Target = random.choice(getLivingPlayers(Team.ALL).filter(lambda player: player.hasMoved and prevTarget != player))
    lbl_0:
    wait(0.1)
    Target = Target
    Target = Target


rule "Active game - target not existing fail safe":
    @Condition Target == null
    
    randomTarget()
    wait(1)
    if ruleCondition:
        loop()


rule "Duels - Global HUD":
    @Condition duelMode == true
    
    hudSubtext(getAllPlayers(), "current duel: {0} vs. {1}".format(getLivingPlayers(Team.ALL)[0], getLivingPlayers(Team.ALL)[1]), HudPosition.TOP, -1, Color.PURPLE, HudReeval.VISIBILITY_AND_STRING)


rule "Duels - Queue HUD":
    @Event eachPlayer
    @Condition duelMode == true
    
    hudSubheader(eventPlayer if eventPlayer.isDead() else null, "You fight in {0} rounds.".format(duelQueue.index(eventPlayer) + 1), HudPosition.TOP, -1, Color.PURPLE, HudReeval.VISIBILITY_AND_STRING)


rule "Duels - kill players when more then two alive":
    @Condition duelMode == true
    @Condition isGameInProgress() == false
    @Condition getNumberOfLivingPlayers(Team.ALL) > 2
    
    kill(getLivingPlayers(Team.ALL).exclude(Target)[0])
    wait(0.5)
    if ruleCondition:
        loop()


rule "Duels - start game":
    @Condition duelMode == true
    @Condition isGameInProgress() == true
    @Condition len(getLivingPlayers(Team.ALL).filter(lambda player: player.hasMoved)) == 2
    
    wait(0.016, Wait.ABORT_WHEN_FALSE)
    if not ruleCondition:
        return
    setupFinal()


rule "Duels - not enough players alive":
    @Condition duelMode == true
    @Condition isGameInProgress() == true
    @Condition getNumberOfLivingPlayers(Team.ALL) < 2
    @Condition len(duelQueue) > 0
    
    deleteBall()
    stopChasing(ballSpawnCountdown)
    if getLivingPlayers(Team.ALL)[0].isAlive():
        getLivingPlayers(Team.ALL).addToScore(1)
        bigMessage(getAllPlayers(), "{0} wins, congrats!".format(getLivingPlayers(Team.ALL)[0]))
        wait(2)
    duelQueue[0].resurrect()
    wait(0.5)
    if ruleCondition:
        loop()


rule "Duels - queue dead player":
    @Event playerDied
    @Condition duelMode == true
    
    duelQueue = duelQueue.concat(eventPlayer)


rule "Duels - remove living player from queue":
    @Event eachPlayer
    @Condition eventPlayer.isAlive() == true
    @Condition duelMode == true
    
    duelQueue = duelQueue.exclude(eventPlayer)


rule "Duels - remove leaving player from queue":
    @Event playerLeft
    @Condition duelMode == true
    
    duelQueue = duelQueue.exclude(eventPlayer)


rule "Collision - ball reaches player":
    @Condition HasCollision == false
    @Condition ballIsOut == true
    @Condition distance(ballPosition, Target.getEyePosition()) <= 1.9
    
    HasCollision = true
    collisionTarget()
    HasCollision = false


rule "Collision - collision check":
    @Condition ballIsOut == true
    @Condition ballSpeed > 150
    
    waitUntil(not HasCollision, 99999)
    HasCollision = true
    if ballHitPosition != null:
        #-o--x--------o->Between last ballPosition & middlePosition
        phasePosition1 = ballHitPosition + phasePosition
        phasePosition1 /= 2
        #-o-----x-----o->Between last & current ballPosition
        phasePosition = ballHitPosition
        ballHitPosition = null
    else:
        #-o--x--------o->Between last ballPosition & middlePosition
        phasePosition1 = phasePosition + ballPosition
        phasePosition1 /= 2
        phasePosition1 += phasePosition
        phasePosition1 /= 2
        #-o-----x-----o->Between last & current ballPosition
        phasePosition += ballPosition
        phasePosition /= 2
    #-o--------x--o->Between phasePosition & current ballPosition & phasePosition
    phasePosition2 = phasePosition + ballPosition
    phasePosition2 /= 2
    #-o-----------x->
    if distance(ballPosition, Target.getEyePosition()) <= 1.9:
        collisionTarget()
    #-o-----x-----o->
    elif distance(phasePosition, Target.getEyePosition()) <= 1.9:
        collisionTarget()
    #-o--x--------o->
    elif distance(phasePosition1, Target.getEyePosition()) <= 1.9:
        collisionTarget()
    #-o--------x--o->
    elif distance(phasePosition2, Target.getEyePosition()) <= 1.9:
        collisionTarget()
    #Save last ballPosition for next loop
    phasePosition = evalOnce(ballPosition)
    HasCollision = false
    wait(0)
    if ruleCondition:
        loop()


def collisionTarget():
    @Name "Collision - collision sub"
    
    if ballSpeedCap == ballSpeed:
        if bozo_Bot and Target.isDummy():
            goto lbl_0
    if bozo_Bot and Target.isDummy():
        Target.forceButtonPress(Button.ABILITY_2)
    if Target.isUsingAbility1():
        goto lbl_1
    #Only when Tracing mode == true
    if tracingPoints == 0:
        goto lbl_2
    if Target.isUsingAbility2():
        goto lbl_3
    lbl_0:
    lbl_2:
    deflectFail()
    return
    lbl_1:
    lbl_3:
    ballDirection = Target.getFacingDirection() * (ballSpeed if ballMotion == 2 else 1)
    prevTarget = Target
    if prevTarget.isUsingAbility1():
        dashBall()
    if prevTarget.Critslash == true:
        #ballSpeed = min(ballSpeedCap, ballSpeed * 1.2)
        prevTarget.Critalert = true
        prevTarget.Critslash = false
    else:
        ballSpeed = min(ballSpeedCap, ballSpeed * 1.05)
    if getCurrentGamemode() == Gamemode.TDM:
        TDMcollision()
    if getCurrentGamemode() == Gamemode.TDM:
        goto lbl_4
    Target = sorted(getLivingPlayers(Team.ALL).exclude(Target).filter(lambda x: x.hasMoved), lambda x: angleBetweenVectors(Target.getFacingDirection(), directionTowards(Target, x.getPosition())))[0]
    lbl_4:
    playEffect(getAllPlayers(), DynamicEffect.EXPLOSION_SOUND, Color.WHITE, evalOnce(prevTarget.getPosition()), 150)
    playEffect(getAllPlayers(), DynamicEffect.BAPTISTE_BIOTIC_LAUNCHER_EXPLOSION_SOUND, Color.WHITE, evalOnce(prevTarget.getPosition()), 20)
    if ballMotion == 0:
        async(ballCurve, AsyncBehavior.RESTART)
    if getCurrentGamemode() == Gamemode.TDM and len(getLivingPlayers(Target.getTeam())) == 1 and Target == prevTarget:
        waitUntil(distance(Target.getEyePosition(), ballPosition) > 1.9, 99999)


def deflectFail():
    @Name "Collision - deflect fail sub"
    
    kill(Target, prevTarget)
    playDeathEffect()
    if getNumberOfLivingPlayers(Team.ALL) == 1:
        alert()
        deleteBall()
        return
    if endlessMode:
        #ballDirection *= -1
        Target = sorted(getLivingPlayers(Team.ALL).exclude(Target).filter(lambda x: x.hasMoved), lambda x: angleBetweenVectors(ballDirection, directionTowards(ballPosition, x.getPosition())))[0]
    else:
        deleteBall()
        randomTarget()


def playDeathEffect():
    @Name "Collision - play death effect sub"
    
    playEffect(getAllPlayers(), DynamicEffect.ASHE_DYNAMITE_EXPLOSION_SOUND, Color.SKY_BLUE, ballPosition.getPosition(), 80)
    if endlessMode:
        playEffect(getAllPlayers(), DynamicEffect.TRACER_RECALL_REAPPEAR, Color.WHITE, ballPosition, 2)
        return
    playEffect(getAllPlayers(), DynamicEffect.ASHE_DYNAMITE_EXPLOSION, Team.1, ballPosition.getPosition(), 40)
    playEffect(getAllPlayers(), DynamicEffect.DVA_SELF_DESTRUCT_EXPLOSION, Team.ALL, ballPosition.getPosition(), 40)
    playEffect(getAllPlayers(), DynamicEffect.DOOMFIST_METEOR_STRIKE_IMPACT, Team.1, ballPosition.getPosition(), 40)


def dashBall():
    @Name "Collision - dash sub"
    
    if prevTarget.stunCooldown <= 0:
        prevTarget.setStatusEffect(null, Status.KNOCKED_DOWN, 1)
        prevTarget.stunCooldown = 0.6


def ballCurve():
    @Name "Collision - ball curve sub"
    
    if ballMotion == 0:
        ballDirectionRate = 6
        #chaseOverTime(ballDirectionRate, ballDirectionRateInit, 0.04, ChaseTimeReeval.NONE)
        wait(0.05)
        ballDirectionRate = ballDirectionRateInit


def deleteBall():
    @Name "Collision - delete ball sub"
    
    async(stopBall, AsyncBehavior.RESTART)
    prevTarget = null
    ballPosition = vect(0, -1, 0)
    ballDirection = vect(0, 0, 0)
    ballSpawnCountdown = 2
    ballHitPosition = null
    phasePosition = vect(0, -1, 0)
    phasePosition1 = vect(0, -1, 0)
    phasePosition2 = vect(0, -1, 0)


def startBall():
    @Name "Ball behaivor - start ball"
    
    ballIsOut = true
    if ballMotion == 0 or ballMotion == 1:
        async(startModernBall, AsyncBehavior.RESTART)
    elif ballMotion == 2:
        async(startAstroBall, AsyncBehavior.RESTART)
    elif ballMotion == 3:
        async(startRetroBall, AsyncBehavior.RESTART)


def stopBall():
    @Name "Ball behaivor - stop ball"
    
    ballIsOut = false
    stopChasing(ballDirection)
    stopChasing(ballPosition)
    stopChasing(ballSpeed)


def startModernBall():
    @Name "Ball behaivor - modern motion"
    
    chaseAtRate(ballPosition, ballPosition + ballDirection * ballSpeed * motionMultiplier, ballSpeed)
    chaseAtRate(ballSpeed, ballSpeedCap, ballAcceleration)
    chaseAtRate(ballDirection, directionTowards(ballPosition, Target.getEyePosition()), updateEveryFrame(ballDirectionRate))


def startRetroBall():
    @Name "Ball Physics - retro motion"
    
    chaseAtRate(ballPosition, Target.getEyePosition(), ballSpeed)
    chaseAtRate(ballSpeed, ballSpeedCap, ballAcceleration)


def startAstroBall():
    @Name "Ball Physics - astro motion"
    
    chaseAtRate(ballPosition, updateEveryFrame(ballPosition + ballDirection), updateEveryFrame(magnitude(ballDirection)))
    #ballDirection is the ball's velocity
    chaseAtRate(ballDirection, updateEveryFrame(ballDirection * 0.93 + Target.getEyePosition() - ballPosition), updateEveryFrame((sqrt((ballSpeed - max(dotProduct(ballDirection, directionTowards(ballPosition, Target.getEyePosition())), 0)) * ballSpeed)) * 3))
    #ballSpeed is the ball's acceleration coefficient
    chaseAtRate(ballSpeed, ballSpeedCap, ballAcceleration)
    wait()
    if ruleCondition:
        loop()


rule "Ball Physics - general collision":
    @Condition ballIsOut == true
    @Condition (updateEveryFrame(isInLoS(ballPosition, ballPosition + ((ballDirection * (ballSpeed if ballMotion != 2 else 1)) * 0.033)))) == false
    @Condition ballPosition.y > 7.5
    @Condition (ballPosition.z > 20 or ballPosition.z < -20 or ballPosition.x > 20 or ballPosition.x < -20 or ballPosition.y > 0) == true
    
    ballNextFramePosition = ballPosition + ballDirection * ballSpeed * 0.066
    #Used for phasingprotection in Ball/Target - collision check
    ballHitPosition = raycastHitPosition(ballPosition, ballNextFramePosition, null, getAllPlayers(), false)
    if __getCurrentMap__() == Map.WORKSHOP_ISLAND or __getCurrentMap__() == Map.WORKSHOP_ISLAND_NIGHT or ballHitPosition.y < -0.5 and ballHitPosition.y > -3.5:
        CollisionSurfaceDistances = [distance(ballHitPosition, vect(20, ballHitPosition.y, ballHitPosition.z)), distance(ballHitPosition, vect(-20, ballHitPosition.y, ballHitPosition.z)), distance(ballHitPosition, vect(ballHitPosition.x, ballHitPosition.y, 20)), distance(ballHitPosition, vect(ballHitPosition.x, ballHitPosition.y, -20))]
        simpleIslandCollision()
    else:
        BallCollisionSurfaceNormal = raycastHitNormal(ballPosition, ballNextFramePosition, null, getAllPlayers(), false)
        #new reflection formula --- new direction = v - 2 * (v ∙ n) * n
        ballDirection -= 2 * dotProduct(ballDirection, BallCollisionSurfaceNormal) * BallCollisionSurfaceNormal
    playEffect(getAllPlayers(), DynamicEffect.PHARAH_BARRAGE_EXPLOSION, Team.ALL, ballHitPosition, 1)
    playEffect(getAllPlayers(), DynamicEffect.ECHO_STICKY_BOMB_EXPLOSION_SOUND, Color.WHITE, ballHitPosition, 30)
    wait(0.02, Wait.ABORT_WHEN_FALSE)
    if ruleCondition:
        loop()


rule "Ball Physics - island collision":
    @Condition ballIsOut == true
    @Condition ballPosition.z < 20.2
    @Condition ballPosition.z > -20.2
    @Condition ballPosition.x < 20.2
    @Condition ballPosition.x > -20.2
    @Condition ballPosition.y < 0
    @Condition (__getCurrentMap__() == Map.WORKSHOP_ISLAND or __getCurrentMap__() == Map.WORKSHOP_ISLAND_NIGHT) == true
    
    CollisionSurfaceDistances = [distance(ballPosition, vect(ballPosition.x, 0, ballPosition.z)), distance(ballPosition, vect(20, ballPosition.y, ballPosition.z)), distance(ballPosition, vect(-20, ballPosition.y, ballPosition.z)), distance(ballPosition, vect(ballPosition.x, ballPosition.y, 20)), distance(ballPosition, vect(ballPosition.x, ballPosition.y, -20))]
    simpleIslandCollision()
    playEffect(getAllPlayers(), DynamicEffect.PHARAH_BARRAGE_EXPLOSION, Team.ALL, ballPosition, 1)
    playEffect(getAllPlayers(), DynamicEffect.ECHO_STICKY_BOMB_EXPLOSION_SOUND, Color.WHITE, ballPosition, 30)
    wait(0.02, Wait.ABORT_WHEN_FALSE)
    if ruleCondition:
        loop()


def simpleIslandCollision():
    @Name "Subroutine - simple island collision"
    
    CollisionSurfaceIndex = CollisionSurfaceDistances.index(sorted(CollisionSurfaceDistances)[0])
    if CollisionSurfaceIndex == 0:
        if ballDirection.y < 0:
            ballDirection *= vect(1, -1, 1)
        else:
            CollisionSurfaceIndex = CollisionSurfaceDistances.index(sorted(CollisionSurfaceDistances)[1])
    if CollisionSurfaceIndex == 1:
        if ballDirection.x < 0:
            ballDirection *= vect(-1, 1, 1)
    elif CollisionSurfaceIndex == 2:
        if ballDirection.x > 0:
            ballDirection *= vect(-1, 1, 1)
    elif CollisionSurfaceIndex == 3:
        if ballDirection.z < 0:
            ballDirection *= vect(1, 1, -1)
    elif CollisionSurfaceIndex == 4:
        if ballDirection.z > 0:
            ballDirection *= vect(1, 1, -1)


rule "Ball Physics - chamber x collision":
    #This collision is the lazy way but its only for chamber so who cares
    @Condition __getCurrentMap__() == Map.WORKSHOP_CHAMBER
    @Condition ballIsOut == true
    @Condition (ballPosition.x + 0 > 20 or ballPosition.x - 0 < -20) == true
    
    if ballPosition.x + 0 > 20 and ballDirection.x > 0 or ballPosition.x - 0 < -20 and ballDirection.x < 0:
        ballDirection = vect(ballDirection.x * -1, ballDirection.y, ballDirection.z)
        playEffect(getAllPlayers(), DynamicEffect.BAD_EXPLOSION, Color.WHITE, ballPosition, 1)
    wait()
    if ruleCondition:
        loop()


rule "Ball Physics - chamber y collision":
    @Condition __getCurrentMap__() == Map.WORKSHOP_CHAMBER
    @Condition ballIsOut == true
    @Condition (ballPosition.y + 0 > 40) - (ballPosition.y - 0 < 0) == true
    
    if ballPosition.y + 0 > 40 and ballDirection.y > 0 or ballPosition.y - 0 < 0 and ballDirection.y < 0:
        ballDirection = vect(ballDirection.x, ballDirection.y * -1, ballDirection.z)
        playEffect(getAllPlayers(), DynamicEffect.BAD_EXPLOSION, Color.WHITE, ballPosition, 1)
    wait()
    if ruleCondition:
        loop()


rule "Ball Physics - chamber z collision":
    @Condition __getCurrentMap__() == Map.WORKSHOP_CHAMBER
    @Condition ballIsOut == true
    @Condition (ballPosition.z + 0 > 20 or ballPosition.z - 0 < -20) == true
    
    if ballPosition.z + 0 > 20 and ballDirection.z > 0 or ballPosition.z - 0 < -20 and ballDirection.z < 0:
        ballDirection = vect(ballDirection.x, ballDirection.y, ballDirection.z * -1)
        playEffect(getAllPlayers(), DynamicEffect.BAD_EXPLOSION, Color.WHITE, ballPosition, 1)
    wait()
    if ruleCondition:
        loop()


rule "Ball Physics - water":
    #(Global.currentMap == Map(Workshop Island) || Global.currentMap == 196) == True;
    @Condition ballIsOut == true
    @Condition (ballPosition.x > 20 or ballPosition.x < -20 or ballPosition.z > 20 or ballPosition.z < -20) == true
    @Condition ballPosition.y < waterLevel
    @Condition ballDirection.y < 0
    @Condition (__getCurrentMap__() == Map.WORKSHOP_ISLAND or __getCurrentMap__() == Map.WORKSHOP_ISLAND_NIGHT) == true
    
    ballDirection *= vect(1, 0, 1)
    playEffect(getAllPlayers(), DynamicEffect.RING_EXPLOSION, Color.WHITE, ballPosition, 2)


rule "Map restrictions - put out center":
    @Event eachPlayer
    @Condition distance(eventPlayer.getPosition(), circleCenter) < CenterOffLimitsSize + 0.5
    
    eventPlayer.applyImpulse(directionTowards(circleCenter, eventPlayer), 10, Relativity.TO_WORLD, Impulse.CANCEL_CONTRARY_MOTION)
    eventPlayer.applyImpulse(Vector.UP, 1.5, Relativity.TO_WORLD, Impulse.INCORPORATE_CONTRARY_MOTION)
    wait(0.25)
    if ruleCondition:
        loop()


rule "Map restrictions - player dashes too far out of bounds":
    @Event eachPlayer
    @Condition distance(eventPlayer.getPosition(), vect(circleCenter.x, eventPlayer.getPosition().y, circleCenter.z)) > SphereSize + 5
    #Workshop Island Fix
    #@Condition (__getCurrentMap__() != Map.WORKSHOP_ISLAND and __getCurrentMap__() != Map.WORKSHOP_ISLAND_NIGHT) == true
    
    eventPlayer.setStatusEffect(null, Status.ROOTED, 3)
    eventPlayer.applyImpulse(vect(directionTowards(eventPlayer.getPosition(), circleCenter).x, 0, directionTowards(eventPlayer.getPosition(), circleCenter).z), 20, Relativity.TO_WORLD, Impulse.CANCEL_CONTRARY_MOTION)
    eventPlayer.applyImpulse(Vector.UP, 3, Relativity.TO_WORLD, Impulse.CANCEL_CONTRARY_MOTION)
    bigMessage(eventPlayer, "Do not dash out of the arena!")


rule "Map restrictions - push to circle":
    @Event eachPlayer
    @Condition distance(eventPlayer.getPosition(), vect(circleCenter.x, eventPlayer.getPosition().y, circleCenter.z)) > SphereSize - 1.5
    #Workshop Island Fix
    @Condition __getCurrentMap__() != Map.WORKSHOP_ISLAND
    @Condition __getCurrentMap__() != Map.WORKSHOP_ISLAND_NIGHT
    
    eventPlayer.applyImpulse(vect(directionTowards(eventPlayer.getPosition(), circleCenter).x, 0, directionTowards(eventPlayer.getPosition(), circleCenter).z), 6, Relativity.TO_WORLD, Impulse.CANCEL_CONTRARY_MOTION)
    eventPlayer.applyImpulse(Vector.UP, 3, Relativity.TO_WORLD, Impulse.INCORPORATE_CONTRARY_MOTION)
    wait(0.25)
    if ruleCondition:
        loop()


rule "Map restrictions - player falls off Workshop Island":
    @Event eachPlayer
    @Condition (__getCurrentMap__() == Map.WORKSHOP_ISLAND or __getCurrentMap__() == Map.WORKSHOP_ISLAND_NIGHT) == true
    @Condition eventPlayer.getPosition().y < -0.5
    
    #A MAN HAS FALLEN INTO THE LAKE IN WORKSHOP ISLAND! START THE NEW RESCUE RULE! HEY! BUILD THE NEW WORSHOP RULE, AND OFF TO THE RESCUE! PREPARE THE CONDITION, TELEPORT THE PLAYER, AND MAKE THE RESCUE! THE NEW 2.3.0 UPDATE FROM OVERWATCH WORKSHOP!
    if not eventPlayer.isAlive():
        eventPlayer.teleport(circleCenter + vect(random.randint(-10, 10), 8, random.randint(-10, 10)))
        if eventPlayer == Target:
            if ballIsOut:
                deleteBall()
    wait(0.5)
    if ruleCondition:
        loop()


rule "Map restrictions - water surface 1":
    @Event eachPlayer
    @Condition updateEveryFrame(eventPlayer.getPosition().y < 0) == true
    @Condition eventPlayer.getPosition().y >= -0.15
    @Condition eventPlayer.getVelocity().y <= 0
    @Condition eventPlayer.isAlive() == true
    @Condition eventPlayer.isUsingAbility1() == false
    #Workshop Island Fix
    @Condition (__getCurrentMap__() == Map.WORKSHOP_ISLAND or __getCurrentMap__() == Map.WORKSHOP_ISLAND_NIGHT) == true
    
    if eventPlayer.getPosition().x < 20.25 and eventPlayer.getPosition().x > -20.25 and eventPlayer.getPosition().z < 20.25 and eventPlayer.getPosition().z > -20.25:
        return
    eventPlayer.currentGravity = 0
    eventPlayer.setGravity(0)
    if eventPlayer.getVelocity().y < 0:
        eventPlayer.applyImpulse(Vector.DOWN, 0.001, Relativity.TO_WORLD, Impulse.CANCEL_CONTRARY_MOTION)
        eventPlayer.applyImpulse(Vector.UP, 0.001, Relativity.TO_WORLD, Impulse.CANCEL_CONTRARY_MOTION)
    wait(0.1)
    if ruleCondition:
        loop()


rule "Map restrictions - water surface 2":
    @Event eachPlayer
    @Condition eventPlayer.getPosition().y < -0.15
    @Condition eventPlayer.getPosition().y >= -1.25
    @Condition eventPlayer.getVelocity().y <= 0
    @Condition eventPlayer.isAlive() == true
    @Condition eventPlayer.isUsingAbility1() == false
    #Workshop Island Fix
    @Condition (__getCurrentMap__() == Map.WORKSHOP_ISLAND or __getCurrentMap__() == Map.WORKSHOP_ISLAND_NIGHT) == true
    
    if eventPlayer.getPosition().x < 20.25 and eventPlayer.getPosition().x > -20.25 and eventPlayer.getPosition().z < 20.25 and eventPlayer.getPosition().z > -20.25:
        return
    eventPlayer.currentGravity = 0
    eventPlayer.setGravity(0)
    eventPlayer.applyImpulse(Vector.UP, 1, Relativity.TO_WORLD, Impulse.CANCEL_CONTRARY_MOTION)
    wait(0.1)
    if ruleCondition:
        loop()


rule "Map restrictions - water resistance":
    @Event eachPlayer
    @Condition (eventPlayer.getPosition().x > 35 or eventPlayer.getPosition().x < -35 or eventPlayer.getPosition().z > 35 or eventPlayer.getPosition().z < -35) == true
    @Condition eventPlayer.getPosition().y <= 0
    @Condition eventPlayer.getPosition().y >= -1.5
    @Condition eventPlayer.isAlive() == true
    @Condition eventPlayer.isUsingAbility1() == false
    @Condition (__getCurrentMap__() == Map.WORKSHOP_ISLAND or __getCurrentMap__() == Map.WORKSHOP_ISLAND_NIGHT) == true
    
    if eventPlayer.getPosition().x > 37 or eventPlayer.getPosition().x < -37 or eventPlayer.getPosition().z > 37 or eventPlayer.getPosition().z < -37:
        eventPlayer.applyImpulse(directionTowards(eventPlayer.getPosition(), circleCenter) * vect(1, 0, 1), 10, Relativity.TO_WORLD, Impulse.CANCEL_CONTRARY_MOTION)
        wait(0.1)
    else:
        eventPlayer.applyImpulse(directionTowards(eventPlayer.getPosition(), circleCenter) * vect(1, 0, 1), 5, Relativity.TO_WORLD, Impulse.INCORPORATE_CONTRARY_MOTION)
        wait(0.05)
    if ruleCondition:
        loop()


rule "Map restrictions - water":
    @Event eachPlayer
    @Condition eventPlayer.getPosition().y < -1.5
    @Condition eventPlayer.isAlive() == true
    #Workshop Island Fix
    @Condition (__getCurrentMap__() == Map.WORKSHOP_ISLAND or __getCurrentMap__() == Map.WORKSHOP_ISLAND_NIGHT) == true
    
    if eventPlayer.getPosition().x < 35 or eventPlayer.getPosition().x > -35 or eventPlayer.getPosition().z < 35 or eventPlayer.getPosition().z > -35:
        #Prevents people from going under the ledge on Workshop Island, which caused ball to go into floor.  Used to be an annoying stunkill
        eventPlayer.applyImpulse(Vector.UP, 2, Relativity.TO_WORLD, Impulse.CANCEL_CONTRARY_MOTION)
        eventPlayer.applyImpulse(directionTowards(eventPlayer, circleCenter), 2, Relativity.TO_WORLD, Impulse.INCORPORATE_CONTRARY_MOTION)
    if eventPlayer.getPosition().x > 35 or eventPlayer.getPosition().x < -35 or eventPlayer.getPosition().z > 35 or eventPlayer.getPosition().z < -35:
        eventPlayer.applyImpulse(directionTowards(eventPlayer, circleCenter), 3, Relativity.TO_WORLD, Impulse.INCORPORATE_CONTRARY_MOTION)
        eventPlayer.applyImpulse(Vector.UP, 0.3, Relativity.TO_WORLD, Impulse.CANCEL_CONTRARY_MOTION)
    wait(0.008)
    if ruleCondition:
        loop()


rule "Map restrictions - water leave":
    @Event eachPlayer
    @Condition eventPlayer.getPosition().y >= 0
    @Condition eventPlayer.isAlive() == true
    #Workshop Island Fix
    @Condition (__getCurrentMap__() == Map.WORKSHOP_ISLAND or __getCurrentMap__() == Map.WORKSHOP_ISLAND_NIGHT) == true
    @Condition eventPlayer.currentGravity != gravity
    
    eventPlayer.setGravity(gravity)
    eventPlayer.currentGravity = gravity


rule "Map restrictions - island enter":
    @Event eachPlayer
    @Condition eventPlayer.getPosition().x < 20.25
    @Condition eventPlayer.getPosition().x > -20.25
    @Condition eventPlayer.getPosition().z < 20.25
    @Condition eventPlayer.getPosition().z > -20.25
    @Condition eventPlayer.isAlive() == true
    #Workshop Island Fix
    @Condition (__getCurrentMap__() == Map.WORKSHOP_ISLAND or __getCurrentMap__() == Map.WORKSHOP_ISLAND_NIGHT) == true
    
    eventPlayer.currentGravity = gravity
    eventPlayer.setGravity(gravity)


def alert():
    @Name "Subroutine - Round end call"
    
    totalRounds = totalRounds - 1
    roundsUntilBreak = roundsUntilBreak - 1


rule "Tournament - game ends after 0 Rounds left":
    @Condition totalRounds <= 0
    @Condition tournamentmode == true
    
    wait(1)
    setMatchTime(0)
    enableGamemodeCompletion()


rule "Tournament - break":
    @Condition roundsUntilBreak <= 0
    @Condition breaksenabled == true
    @Condition tournamentmode == true
    
    setballspawncountdown = breakLength
    bigMessage(getAllPlayers(), "Break time!")
    wait(breakLength + 1)
    setballspawncountdown = setballspawncountdownoriginal
    roundsUntilBreak = roundsUntilBreak + roundsUntilBreakInit


rule "Tournament - forbit dashing into the water":
    @Event eachPlayer
    @Condition tournamentmode == true
    @Condition eventPlayer.getPosition().y < -1
    @Condition eventPlayer.getVelocity().y < 0
    @Condition eventPlayer != Target
    @Condition eventPlayer.isUsingAbility1() == true
    
    eventPlayer.teleport(eventPlayer.getPosition() - normalize(eventPlayer.getVelocity()))
    eventPlayer.startForcingPosition(eventPlayer.getPosition(), false)
    waitUntil(not eventPlayer.isUsingAbility1(), 0.5)
    eventPlayer.stopForcingPosition()


rule "Tournament - no orbit abusing":
    @Event eachPlayer
    @Condition tournamentmode == true
    @Condition eventPlayer == Target
    #@Condition (angleBetweenVectors(ballDirection, directionTowards(ballPosition, eventPlayer.getEyePosition())) < 100 and angleBetweenVectors(ballDirection, directionTowards(ballPosition, eventPlayer.getEyePosition())) > -100) == true
    @Condition ballIsOut == true
    @Condition distance(eventPlayer.getEyePosition(), ballPosition) < 20
    @Condition ballSpeed < 80
    
    #smallMessage(getAllPlayers(), "Orbit start")
    wait(7.5, Wait.ABORT_WHEN_FALSE)
    if not ruleCondition:
        return
    #smallMessage(getAllPlayers(), "...still orbitting...")
    eventPlayer.setStatusEffect(null, Status.ASLEEP, 5)
    eventPlayer.applyImpulse(ballDirection + Vector.UP, 10, Relativity.TO_WORLD)


rule "Tracing mode - gained":
    @Event eachPlayer
    @Condition tracingMode == true
    @Condition eventPlayer == Target
    @Condition angleBetweenVectors(eventPlayer.getFacingDirection(), directionTowards(eventPlayer.getEyePosition(), ballPosition)) <= 45
    #@Condition eventPlayer.isInViewAngle(ballPosition, 70) == true
    
    eventPlayer.clearStatusEffect(Status.BURNING)
    stopChasing(tracingPoints)
    tracingPoints = 0.3


rule "Tracing mode - lost":
    @Event eachPlayer
    @Condition tracingMode == true
    @Condition eventPlayer == Target
    @Condition angleBetweenVectors(eventPlayer.getFacingDirection(), directionTowards(eventPlayer.getEyePosition(), ballPosition)) > 45
    #@Condition eventPlayer.isInViewAngle(ballPosition, 70) == false
    
    chaseAtRate(tracingPoints, 0, 1)


rule "zBozo - spawn":
    #Currently only able to decide between 0 or 1 (false/true) bozo bots
    @Condition bozo_Bot > 0
    
    #if getCurrentGamemode() == Gamemode.TDM:
    #wait(40)
    #__end__()
    while bozo_Bot > 0:
        bozo_Bot--
        createDummy(Hero.GENJI, Team.2, 1 + bozo_Bot, null, hostPlayer)
        wait(0.1)
    bozo_Bot = true
    bozoHasJumped = false
    OrbitTolerance = 0
    BozoTracing = false


rule "zBozo - name":
    @Event eachPlayer
    @Condition bozo_Bot == true
    @Condition eventPlayer.isDummy() == true
    
    eventPlayer.startForcingName("zSh4d0Ws bozo")


rule "zBozo - face when Deflecting":
    @Event eachPlayer
    @Condition bozo_Bot == true
    @Condition distance(eventPlayer.getEyePosition(), ballPosition.getPosition()) <= 2 * (ballSpeed / 20)
    @Condition Target == eventPlayer
    @Condition eventPlayer.isDummy() == true
    @Condition ballIsOut == true
    @Condition eventPlayer.isAlive() == true
    @Condition eventPlayer.isUsingAbility1() == false
    @Condition eventPlayer.isUsingAbility2() == false
    @Condition eventPlayer.hasStatus(Status.STUNNED) == false
    @Condition bozoIsGhostDashing != true
    
    if eventPlayer.canDash == true:
        if random.randint(0, 8) == 0:
            if ballSpeed < 80:
                eventPlayer.startFacing(directionFromAngles(horizontalAngleOfDirection(directionTowards(eventPlayer.getEyePosition(), evalOnce(random.choice(getLivingPlayers(Team.ALL).exclude(eventPlayer))).getEyePosition())) + evalOnce(random.randint(-35, 35)), evalOnce(random.randint(-35, 35))), 10000)
            else:
                eventPlayer.startFacing(directionFromAngles(horizontalAngleOfDirection(directionTowards(eventPlayer.getEyePosition(), evalOnce(random.choice(getLivingPlayers(Team.ALL).exclude(eventPlayer))).getEyePosition())) + evalOnce(random.randint(-10, 10)), evalOnce(random.randint(-10, 10))), 10000)
        else:
            eventPlayer.startFacing(vect(random.randint(-360, 360), random.randint(-360, 360), random.randint(-360, 360)), 10000)
    else:
        if random.randint(0, 1) == 0:
            eventPlayer.startFacing(directionFromAngles(horizontalAngleOfDirection(directionTowards(eventPlayer.getEyePosition(), eventPlayer.getPlayerClosestToReticle(Team.ALL).getEyePosition())) + evalOnce(random.randint(-90, -45)), evalOnce(random.randint(-90, 90))), 10000)
        else:
            eventPlayer.startFacing(directionFromAngles(horizontalAngleOfDirection(directionTowards(eventPlayer.getEyePosition(), eventPlayer.getPlayerClosestToReticle(Team.ALL).getEyePosition())) + evalOnce(random.randint(45, 90)), evalOnce(random.randint(-90, 90))), 10000)
        wait(0)
        if getLivingPlayers(Team.ALL).exclude(eventPlayer).any(lambda x: eventPlayer.isInViewAngle(x.getEyePosition(), 30)):
            loop()
    waitUntil(Target != eventPlayer or eventPlayer.isAlive() != true, 99999)
    if angleBetweenVectors(ballDirection * -1, directionTowards(Target, ballPosition)) < 20:
        #if distance(eventPlayer.getEyePosition(), Target.getEyePosition()) < ballSpeed * 0.3:
        #bozoWillEdash = true
        #bigMessage(getAllPlayers(), "EDASH")
        if distance(eventPlayer.getEyePosition(), ballPosition) < ballSpeed:
            bozoWillGhostDash = true
            #bigMessage(getAllPlayers(), "GDASH")
    wait(0.3)
    if ruleCondition:
        loop()


rule "zBozo - face the Ball":
    @Event eachPlayer
    @Condition bozo_Bot == true
    @Condition eventPlayer.isDummy() == true
    @Condition distance(eventPlayer.getEyePosition(), ballPosition) >= 2 * (ballSpeed / 20)
    @Condition eventPlayer.isAlive() == true
    @Condition bozoIsGhostDashing != true
    @Condition eventPlayer.isUsingAbility1() == false
    @Condition eventPlayer.isUsingAbility2() == false
    @Condition eventPlayer.hasStatus(Status.STUNNED) == false
    
    eventPlayer.startFacing(directionTowards(eventPlayer.getEyePosition(), (ballPosition + Target.getEyePosition()) / 2), 1000)


rule "zBozo - Bahvior changes after round":
    @Condition roundEndCall == true
    
    bozoBehaviorModes = random.choice([2])
    if bozoBehaviorModes == 1:
        bozoAggression = 10
    elif bozoBehaviorModes == 2:
        bozoAggression = 5


rule "zBozo - Movement reworked":
    @Event eachPlayer
    @Condition bozo_Bot == true
    @Condition isGameInProgress() == true
    @Condition eventPlayer.isDummy() == true
    @Condition bozoWillOrbit != true
    @Condition eventPlayer.isAlive() == true
    #@Condition (eventPlayer.getPosition().x < 18 or eventPlayer.getPosition().x > -18 or eventPlayer.getPosition().z < 18 or eventPlayer.getPosition().z > -18) == true
    
    if eventPlayer.getPosition().x > 18 or eventPlayer.getPosition().x < -18 or eventPlayer.getPosition().z > 18 or eventPlayer.getPosition().z < -18:
        eventPlayer.stopThrottleInDirection()
        eventPlayer.startThrottleInDirection(directionTowards(eventPlayer.getPosition(), vect(0, 0, 0)), 1, Relativity.TO_WORLD, Throttle.REPLACE_EXISTING, ThrottleReeval.NONE)
        #bigMessage(getAllPlayers(), "ANTIFLOAT")
        wait(random.uniform(1, 1.5))
        if ruleCondition:
            loop()
    if eventPlayer != Target:
        if distance(eventPlayer.getPosition(), Target.getPosition()) >= bozoAggression:
            eventPlayer.startThrottleInDirection(directionTowards(eventPlayer.getPosition(), Target), 0.8, Relativity.TO_PLAYER, Throttle.REPLACE_EXISTING, ThrottleReeval.NONE)
            wait(random.uniform(0.5, 3))
            if ruleCondition:
                loop()
        else:
            eventPlayer.stopThrottleInDirection()
            eventPlayer.startThrottleInDirection(evalOnce(directionTowards(Target.getEyePosition(), eventPlayer.getEyePosition())), 1, Relativity.TO_WORLD)
            wait(random.uniform(1, 1.5))
            if ruleCondition:
                loop()
    else:
        eventPlayer.startThrottleInDirection(directionTowards(eventPlayer.getPosition(), vect(random.uniform(-15, 15), 0, random.uniform(-15, 15))), 0.8, Relativity.TO_PLAYER, Throttle.REPLACE_EXISTING, ThrottleReeval.NONE)
        wait(random.uniform(0.5, 3))
        if ruleCondition:
            loop()


rule "zBozo - Let him Orbit":
    @Event eachPlayer
    @Condition bozo_Bot == true
    @Condition eventPlayer.isDummy() == true
    @Condition ballIsOut == true
    @Condition distance(eventPlayer.getPosition(), ballPosition) < 5 + ballSpeed / 30
    @Condition bozoWillOrbit == true
    
    IsOrbiting = true
    eventPlayer.startThrottleInDirection((ballDirection * -1 + directionTowards(ballPosition, eventPlayer.getEyePosition()) * 2) / 2, 1, Relativity.TO_WORLD)
    #eventPlayer.startThrottleInDirection(random.choice([vect(180, 0, 0), vect(-180, 0, 0)]), 1, Relativity.TO_PLAYER)
    OrbitTolerance = 999
    #bigMessage(getAllPlayers(), "ORBIT")
    waitUntil(Target != eventPlayer or eventPlayer.isAlive() != true, 99999)
    eventPlayer.stopThrottleInDirection()
    IsOrbiting = false
    bozoWillOrbit = 0


rule "zBozo - bozos move being chosen":
    @Event eachPlayer
    @Condition eventPlayer.isDummy() == true
    @Condition eventPlayer == Target
    
    if bozoBehaviorModes == 1:
        if random.randint(1, 10) == 5:
            bozoWillOrbit = true
    #if bozoWillOrbit != 5:
    #if eventPlayer.getAbilityCooldown(Button.ABILITY_1) == 0:
    #bozoWillGhostDash = random.randint(2, 6)
    #__end__()
    #__end__()
    #if bozoWillGhostDash != 5:
    #if bozoBehaviorModes == 2:
    #if eventPlayer.getAbilityCooldown(Button.ABILITY_1) == 0:
    #bozoWillEdash = random.randint(2, 6)
    #__end__()
    #__end__()
    #__end__()


rule "zBozo - Edash when needed":
    @Event eachPlayer
    @Condition bozo_Bot == true
    @Condition eventPlayer.isDummy() == true
    @Condition ballIsOut == true
    @Condition eventPlayer.isUsingAbility2() == true
    #@Condition (eventPlayer.isUsingAbility2() or bozoWillEdash) == true
    
    waitUntil(eventPlayer != Target and (Target.isUsingAbility1() or Target.isUsingAbility2()), 0.25)
    if eventPlayer == Target:
        if angleBetweenVectors(ballDirection, directionTowards(ballPosition, eventPlayer.getEyePosition())) < 20:
            bozoWillEdash = true
            eventPlayer.setFacing(evalOnce(directionTowards(eventPlayer.getEyePosition(), ballPosition)), Relativity.TO_WORLD)
            eventPlayer.startFacing(evalOnce(directionTowards(eventPlayer.getEyePosition(), ballPosition)), 10000)
            #bigMessage(getAllPlayers(), "EDASHING")
            waitUntil(eventPlayer.isHoldingButton(Button.ABILITY_1) or eventPlayer.isAlive() != true, 1)
            bozoWillEdash = false
    elif eventPlayer == prevTarget:
        if Target.isUsingAbility1() or Target.isUsingAbility2():
            if angleBetweenVectors(ballDirection, directionTowards(ballPosition, Target.getEyePosition())) < 20:
                bozoWillEdash = true
                eventPlayer.setFacing(evalOnce(directionTowards(eventPlayer.getEyePosition(), ballPosition)), Relativity.TO_WORLD)
                eventPlayer.startFacing(evalOnce(directionTowards(eventPlayer.getEyePosition(), ballPosition)), 10000)
                #bigMessage(getAllPlayers(), "EDASHING")
                waitUntil(eventPlayer.isHoldingButton(Button.ABILITY_1) or eventPlayer.isAlive() != true, 1)
                bozoWillEdash = false


rule "zBozo - Jumping":
    @Event eachPlayer
    @Condition bozo_Bot == true
    @Condition eventPlayer.isDummy() == true
    @Condition ballIsOut == true
    
    botJumping = random.choice([1, 2])
    if botJumping == 2:
        eventPlayer.forceButtonPress(Button.JUMP)
        wait(0.35)
        eventPlayer.forceButtonPress(Button.JUMP)
        wait(random.randint(5, 15))
    else:
        eventPlayer.forceButtonPress(Button.JUMP)
        wait(random.randint(3, 7))
    loop()


rule "zBozo - GhostDash":
    @Event eachPlayer
    @Condition bozo_Bot == true
    @Condition eventPlayer.isDummy() == true
    @Condition ballIsOut == true
    @Condition bozoWillGhostDash == true
    
    bozoIsGhostDashing = true
    if Target == eventPlayer:
        if distance(eventPlayer.getEyePosition(), ballPosition) < ballSpeed * 0.3:
            eventPlayer.setFacing(evalOnce(ballDirection.getFacingDirection()), Relativity.TO_WORLD)
            eventPlayer.startFacing(evalOnce(ballDirection.getFacingDirection()), 10000)
    else:
        eventPlayer.setFacing(evalOnce(ballDirection.getFacingDirection()) * -1, Relativity.TO_WORLD)
        eventPlayer.startFacing(evalOnce(ballDirection.getFacingDirection()) * -1, 1000)
        waitUntil(eventPlayer.isHoldingButton(Button.ABILITY_1) or eventPlayer.isAlive() != true, 99999)
    bozoIsGhostDashing = false


rule "zBozo - face when Deflecting":
    @Event eachPlayer
    @Condition bozo_Bot == true
    @Condition distance(eventPlayer.getEyePosition(), ballPosition.getPosition()) <= 2 * (ballSpeed / 20)
    #@Condition Target != eventPlayer
    @Condition eventPlayer.isDummy() == true
    @Condition ballIsOut == true
    @Condition eventPlayer.isAlive() == true
    #@Condition eventPlayer.isUsingAbility2() == false
    @Condition bozoIsGhostDashing != true
    @Condition eventPlayer.getAbilityCooldown(Button.ABILITY_1) != 0
    
    eventPlayer.setFacing(vect(random.uniform(-360, 360), random.uniform(-360, 360), random.uniform(-360, 360)), Relativity.TO_WORLD)
    eventPlayer.startFacing(vect(random.uniform(-360, 360), random.uniform(-360, 360), random.randint(-360, 360)), 10000)
    wait(0.3)
    if ruleCondition:
        loop()


rule "†Tombstone†":
    @Event eachPlayer
    @Condition eventPlayer.isAlive() == true
    @Condition eventPlayer.hasMoved == true
    @Condition isGameInProgress() == true
    @Condition "{0}".format(eventPlayer) in ["boiugayashell", "ren"] == true
    
    eventPlayer.communicate(Comms.EMOTE_UP)
    eventPlayer.communicate(Comms.EMOTE_LEFT)
    eventPlayer.communicate(Comms.EMOTE_RIGHT)
    eventPlayer.communicate(Comms.EMOTE_DOWN)
    bigMessage(getAllPlayers(), "@{0}, is being banhammered!".format(eventPlayer))
    wait(1)
    eventPlayer.setStatusEffect(null, Status.HACKED, 9999)
    eventPlayer.setStatusEffect(null, Status.BURNING, 9999)
    wait(3.5)
    eventPlayer.removeFromGame()


rule "Player rank - Intermediate (rookie)":
    @Event eachPlayer
    @Condition "{0}".format(eventPlayer) in [] == true
    
    eventPlayer.outlineColor = vect(46, 204, 113)


rule "Player rank - Advanced (elo > 900)":
    @Event eachPlayer
    @Condition "{0}".format(eventPlayer) in [] == true
    
    eventPlayer.outlineColor = vect(52, 152, 219)


rule "Player rank - Expert (elo > 1500)":
    @Event eachPlayer
    @Condition "{0}".format(eventPlayer) in [""] == true
    
    eventPlayer.outlineColor = vect(128, 0, 128)


rule "Player rank - Master (elo > 2000)":
    @Event eachPlayer
    @Condition "{0}".format(eventPlayer) in [""] == true
    
    eventPlayer.outlineColor = vect(192, 192, 192)


rule "Player rank - Legendary (elo > 2500)":
    @Event eachPlayer
    @Condition "{0}".format(eventPlayer) in [""] == true
    
    eventPlayer.outlineColor = vect(255, 165, 0)


rule "Player rank - Fade":
    @Event eachPlayer
    @Condition "{0}".format(eventPlayer) in [] == true
    
    eventPlayer.outlineFade = true


rule "Player rank - Apply outline":
    @Event eachPlayer
    @Condition eventPlayer.outlineColor != null
    
    eventPlayer.startForcingOutlineFor(getAllPlayers().exclude(eventPlayer) if eventPlayer == Target else getAllPlayers(), true, updateEveryFrame(rgb(eventPlayer.outlineColor.x, eventPlayer.outlineColor.y, eventPlayer.outlineColor.z)), OutlineVisibility.ALWAYS)
    eventPlayer.startForcingOutlineFor(eventPlayer if eventPlayer == Target else null, true, rgb(255, 0, 0), OutlineVisibility.ALWAYS)
    wait(0)
    loop()


rule "Player rank - Apply fade":
    @Event eachPlayer
    @Condition eventPlayer.outlineFade == true
    
    eventPlayer.outlineFadeBright = eventPlayer.outlineColor + eventPlayer.outlineColor / 2
    eventPlayer.outlineFadeDark = eventPlayer.outlineColor - eventPlayer.outlineColor / 3
    while true:
        chaseOverTime(eventPlayer.outlineColor, eventPlayer.outlineFadeBright, 0.5, ChaseTimeReeval.NONE)
        wait(0.5)
        chaseOverTime(eventPlayer.outlineColor, eventPlayer.outlineFadeDark, 1, ChaseTimeReeval.NONE)
        wait(1.5)
        chaseOverTime(eventPlayer.outlineColor, eventPlayer.outlineFadeBright, 0.5, ChaseTimeReeval.NONE)
        wait(0.5)
        chaseOverTime(eventPlayer.outlineColor, eventPlayer.outlineColor, 0.5, ChaseTimeReeval.NONE)
        wait(0.5)


rule "GENJI BALL ABILITIES :OOOOOO - selection":
    @Event eachPlayer
    @Condition eventPlayer.isHoldingButton(Button.RELOAD) == true
    @Condition eventPlayer.isDummy() != true
    @Condition isGameInProgress() == true
    @Condition ballIsOut == false
    @Condition Abilities == true
    
    waitUntil(not eventPlayer.isHoldingButton(Button.RELOAD), 0.4)
    if eventPlayer.isHoldingButton(Button.RELOAD) == true:
        if eventPlayer.SpecialAbility > 3:
            eventPlayer.SpecialAbility = 1
        else:
            eventPlayer.SpecialAbility = eventPlayer.SpecialAbility + 1
        bigMessage(eventPlayer, "Ability changed")


rule "Gb Abilities - Description":
    @Event eachPlayer
    @Condition Abilities == true
    
    if eventPlayer.Abilitydesc == 1:
        goto lbl_0
    wait(4)
    hudSubheader(eventPlayer.filter(lambda x: x.simpleHUD == 0), "change ability after round: hold [{0}] current: [{1}]".format(inputBindingString(Button.RELOAD), eventPlayer.SpecialAbility), HudPosition.RIGHT, -132, Color.WHITE, HudReeval.VISIBILITY_AND_STRING)
    hudSubheader(eventPlayer.filter(lambda x: x.simpleHUD == 0), "Ability cooldown: [{0}]".format(eventPlayer.Abilitycooldown), HudPosition.RIGHT, -134, Color.WHITE, HudReeval.VISIBILITY_AND_STRING)
    eventPlayer.Abilitydesc = 1
    lbl_0:
    if eventPlayer.SpecialAbility == 1:
        hudSubheader(eventPlayer.filter(lambda x: x.simpleHUD == 0), "Ability: 1. Super Jump: Press [{0}] and [{1}] to jump high".format(inputBindingString(Button.CROUCH), inputBindingString(Button.JUMP)), HudPosition.RIGHT, -133, Color.WHITE, HudReeval.VISIBILITY_AND_STRING)
        waitUntil(eventPlayer.SpecialAbility != 1, 99999)
        destroyHudText(getLastCreatedText())
        loop()
    elif eventPlayer.SpecialAbility == 2:
        hudSubheader(eventPlayer.filter(lambda x: x.simpleHUD == 0), "Ability: 2. Switch Target: Press [{0}] to become the target. Double click to make it not beam you.".format(inputBindingString(Button.ULTIMATE)), HudPosition.RIGHT, -133, Color.WHITE, HudReeval.VISIBILITY_AND_STRING)
        waitUntil(eventPlayer.SpecialAbility != 2, 99999)
        destroyHudText(getLastCreatedText())
        loop()
    elif eventPlayer.SpecialAbility == 3:
        hudSubheader(eventPlayer.filter(lambda x: x.simpleHUD == 0), "Ability: 3. Blink: Press [{0}] to teleport into the direction youre looking at. You will pass through the ball.".format(inputBindingString(Button.ULTIMATE)), HudPosition.RIGHT, -133, Color.WHITE, HudReeval.VISIBILITY_AND_STRING)
        waitUntil(eventPlayer.SpecialAbility != 3, 99999)
        destroyHudText(getLastCreatedText())
        loop()
    elif eventPlayer.SpecialAbility == 4:
        hudSubheader(eventPlayer.filter(lambda x: x.simpleHUD == 0), "Ability: 4. Critical slash: Press [{0}] to make your next hit powerful, speeding up the ball way more.".format(inputBindingString(Button.ULTIMATE)), HudPosition.RIGHT, -133, Color.WHITE, HudReeval.VISIBILITY_AND_STRING)
        waitUntil(eventPlayer.SpecialAbility != 4, 99999)
        destroyHudText(getLastCreatedText())
        loop()
    elif eventPlayer.SpecialAbility == 5:
        hudSubheader(eventPlayer.filter(lambda x: x.simpleHUD == 0), "Ability: 3.", HudPosition.RIGHT, -133, Color.WHITE, HudReeval.VISIBILITY_AND_STRING)
        waitUntil(eventPlayer.SpecialAbility != 5, 99999)
        destroyHudText(getLastCreatedText())
        loop()
    elif eventPlayer.SpecialAbility == 6:
        hudSubheader(eventPlayer.filter(lambda x: x.simpleHUD == 0), "Ability: 3.", HudPosition.RIGHT, -133, Color.WHITE, HudReeval.VISIBILITY_AND_STRING)
        waitUntil(eventPlayer.SpecialAbility != 6, 99999)
        destroyHudText(getLastCreatedText())
        loop()
    else:
        hudSubheader(eventPlayer.filter(lambda x: x.simpleHUD == 0), "Ability: Invalid Ability", HudPosition.RIGHT, -133, Color.WHITE, HudReeval.VISIBILITY_AND_STRING)
        waitUntil(eventPlayer.SpecialAbility <= 6, 99999)
        destroyHudText(getLastCreatedText())
        loop()


rule "Gb Abilities - Cd":
    @Event eachPlayer
    @Condition eventPlayer.Abilitycooldown > 0
    @Condition Abilities == true
    
    chaseAtRate(eventPlayer.Abilitycooldown, 0, 1)
    waitUntil(eventPlayer.Abilitycooldown <= 0, 99999)
    if ruleCondition:
        loop()


rule "Gb Abilities - Reset cd on round end":
    @Event eachPlayer
    @Condition eventPlayer.Abilitycooldown <= 0
    @Condition getAllPlayers().isAlive() == true
    @Condition Abilities == true
    
    eventPlayer.Abilitycooldown = 0
    waitUntil(getAllPlayers().isAlive() == false, 99999)


rule "Gb Abilities - 1. High jump ready":
    @Event eachPlayer
    @Condition eventPlayer.isAlive() == true
    @Condition eventPlayer.Abilitycooldown <= 0
    @Condition eventPlayer.isCrouching() == true
    @Condition eventPlayer.isOnGround() == true
    @Condition isGameInProgress() == true
    @Condition eventPlayer.Abilityready == false
    @Condition eventPlayer.SpecialAbility == 1
    @Condition Abilities == true
    
    eventPlayer.Abilityready = true
    wait()
    if ruleCondition:
        loop()


rule "Gb Abilities - 1. Cancel high jump ready":
    @Event eachPlayer
    @Condition eventPlayer.Abilityready == true
    @Condition (eventPlayer.isOnGround() == false or eventPlayer.isCrouching() == false or false or eventPlayer.isAlive() == false or eventPlayer.Abilitycooldown > 0) == true
    @Condition eventPlayer.SpecialAbility == 1
    @Condition Abilities == true
    
    wait()
    eventPlayer.Abilityready = false
    wait()
    if ruleCondition:
        loop()


rule "Gb Abilities - 1. High jump":
    @Event eachPlayer
    @Condition eventPlayer.isHoldingButton(Button.JUMP) == true
    @Condition eventPlayer.Abilityready == true
    @Condition eventPlayer.SpecialAbility == 1
    @Condition Abilities == true
    
    eventPlayer.applyImpulse(Vector.UP, 25, Relativity.TO_PLAYER, Impulse.CANCEL_CONTRARY_MOTION)
    eventPlayer.Abilitycooldown = 10
    playEffect(getAllPlayers(), DynamicEffect.WINSTON_JUMP_PACK_LANDING_SOUND, Color.WHITE, eventPlayer, 100)


rule "Gb Abilities - 2. Target switch ready":
    @Event eachPlayer
    @Condition Target != eventPlayer
    @Condition eventPlayer.Abilitycooldown <= 0
    @Condition ballIsOut == true
    @Condition eventPlayer.isAlive() == true
    @Condition eventPlayer.SpecialAbility == 2
    @Condition Abilities == true
    
    eventPlayer.Abilityready = true
    wait()
    if ruleCondition:
        loop()


rule "Gb Abilities - 2. Cancel Target switch ready":
    @Event eachPlayer
    @Condition eventPlayer.SpecialAbility == 2
    @Condition (eventPlayer.isAlive() == false or eventPlayer.Abilitycooldown > 0 or ballIsOut != true or Target == eventPlayer) == true
    @Condition Abilities == true
    
    eventPlayer.Abilityready = false
    wait()
    if ruleCondition:
        loop()


rule "Gb Abilities - 2. Target switch":
    @Event eachPlayer
    @Condition eventPlayer.SpecialAbility == 2
    @Condition eventPlayer.isHoldingButton(Button.ULTIMATE) == true
    @Condition eventPlayer.Abilityready == true
    @Condition Abilities == true
    
    waitUntil(eventPlayer.isHoldingButton(Button.ULTIMATE) != true, 99999)
    wait(0.15)
    if eventPlayer.isAlive() == false:
        return
    if eventPlayer.isHoldingButton(Button.ULTIMATE) == true:
        goto lbl_0
    Target = eventPlayer
    ballDirection = directionTowards(ballPosition, eventPlayer.getEyePosition())
    eventPlayer.Abilitycooldown = 20
    playEffect(getAllPlayers(), DynamicEffect.MOIRA_FADE_DISAPPEAR_SOUND, Color.WHITE, eventPlayer, 200)
    return
    lbl_0:
    Target = eventPlayer
    eventPlayer.Abilitycooldown = 15
    playEffect(getAllPlayers(), DynamicEffect.MOIRA_FADE_DISAPPEAR_SOUND, Color.WHITE, eventPlayer, 200)


rule "Gb Abilities - 3. Blink ready":
    @Event eachPlayer
    @Condition eventPlayer.SpecialAbility == 3
    @Condition eventPlayer.isUsingAbility1() == false
    @Condition eventPlayer.Abilitycooldown <= 0
    @Condition eventPlayer.isAlive() == true
    @Condition Abilities == true
    
    eventPlayer.Abilityready = true
    wait()
    if ruleCondition:
        loop()


rule "Gb Abilities - 3. Cancel Blink ready":
    @Event eachPlayer
    @Condition eventPlayer.SpecialAbility == 3
    @Condition (eventPlayer.isAlive() == false or eventPlayer.Abilitycooldown > 0 or eventPlayer.isUsingAbility1() == true) == true
    @Condition Abilities == true
    
    eventPlayer.Abilityready = false
    wait()
    if ruleCondition:
        loop()


rule "Gb Abilities - 3. Blink":
    @Event eachPlayer
    @Condition eventPlayer.SpecialAbility == 3
    @Condition eventPlayer.Abilityready == true
    @Condition eventPlayer.isHoldingButton(Button.ULTIMATE) == true
    @Condition Abilities == true
    
    eventPlayer.teleport(raycastHitPosition(eventPlayer.getEyePosition(), eventPlayer.getEyePosition() + eventPlayer.getFacingDirection() * 20, null, eventPlayer, true))
    eventPlayer.Abilitycooldown = 10
    playEffect(getAllPlayers(), DynamicEffect.SOMBRA_TRANSLOCATING_SOUND, Color.WHITE, eventPlayer, 100)


rule "Gb Abilities - 4. Critslash ready":
    @Event eachPlayer
    @Condition eventPlayer.SpecialAbility == 4
    @Condition eventPlayer.Abilitycooldown <= 0
    @Condition eventPlayer.isAlive() == true
    @Condition ballIsOut == true
    @Condition Abilities == true
    
    eventPlayer.Abilityready = true
    wait()
    if ruleCondition:
        loop()


rule "Gb Abilities - 4. Cancel critslash ready":
    @Event eachPlayer
    @Condition eventPlayer.SpecialAbility == 4
    @Condition (false or eventPlayer.Abilitycooldown > 0 or eventPlayer.isAlive() == false or ballIsOut == false) == true
    @Condition Abilities == true
    
    eventPlayer.Abilityready = false
    eventPlayer.Critslash = false
    wait()
    if ruleCondition:
        loop()


rule "Gb Abilities - 4. Critical slash":
    @Event eachPlayer
    @Condition eventPlayer.SpecialAbility == 4
    @Condition eventPlayer.Abilityready == true
    @Condition eventPlayer.isHoldingButton(Button.ULTIMATE) == true
    @Condition Abilities == true
    
    eventPlayer.Critslash = true
    eventPlayer.startForcingOutlineFor(getAllPlayers(), true, rgb(200, 40, 0))
    waitUntil(eventPlayer.Critslash == false, 99999)
    eventPlayer.Abilitycooldown = 17
    eventPlayer.stopForcingOutlineFor(getAllPlayers())


rule "Teams - Winning Team":
    @Condition (teamScore(Team.1) == Teamsscoretowin or teamScore(Team.2) == Teamsscoretowin or getMatchTime() == 0) == true
    #@Condition RoundInProgress == false
    @Condition TieBreakerActive == false
    @Condition tournamentmode == false
    @Condition getCurrentGamemode() == Gamemode.TDM
    
    waitUntil(ballIsOut == false and getAllPlayers().isAlive(), 9999)
    enableAnnouncer()
    if teamScore(Team.1) == Teamsscoretowin:
        declareTeamVictory(Team.1)
    elif teamScore(Team.2) == Teamsscoretowin:
        declareTeamVictory(Team.2)
    elif teamScore(Team.1) > teamScore(Team.2):
        declareTeamVictory(Team.1)
    elif teamScore(Team.2) == teamScore(Team.1):
        declareTeamVictory(Team.2)
    else:
        declareDraw()


rule "Teams - Passing aura":
    @Event eachPlayer
    @Condition enablepassing == true
    @Condition getCurrentGamemode() == Gamemode.TDM
    @Condition eventPlayer.isHoldingButton(Button.SECONDARY_FIRE) == true
    
    createEffect(getPlayers(eventPlayer.getTeam()).filter(lambda player: player != eventPlayer and player.isAlive()), Effect.BAD_AURA, Color.SKY_BLUE, eventPlayer.getEyePosition(), 1.5, EffectReeval.POSITION_AND_RADIUS)
    waitUntil(eventPlayer.isHoldingButton(Button.SECONDARY_FIRE) != true or eventPlayer.isAlive() == false, 60)
    destroyEffect(getLastCreatedEntity())


rule "Teams - check for <2 players":
    @Condition getCurrentGamemode() == Gamemode.TDM
    @Condition isGameInProgress() == true
    @Condition (getNumberOfPlayers(Team.1) or getNumberOfPlayers(Team.2)) == 0
    
    IsInFinalDuel = false
    IsEnoughPlayersToStart = false
    stopChasing(ballSpawnCountdown)
    deleteBall()
    if RoundInProgress == false:
        goto lbl_0
    RoundInProgress = false
    lbl_0:
    bigMessage(getAllPlayers(), "Waiting for players")
    pauseMatchTime()


rule "Teams - wait for more players":
    @Condition getCurrentGamemode() == Gamemode.TDM
    @Condition getNumberOfPlayers(Team.1) != 0
    @Condition getNumberOfPlayers(Team.2) != 0
    @Condition IsEnoughPlayersToStart == false
    
    if getNumberOfPlayers(Team.ALL) < 2:
        return
    bigMessage(getAllPlayers(), "Lets begin!")
    IsEnoughPlayersToStart = true
    waitUntil(isGameInProgress() == true, 10)
    startRound()


def TDMcollision():
    @Name "Teams - TDM collision"
    
    if prevTarget.isHoldingButton(Button.SECONDARY_FIRE) == true and prevTarget.isUsingAbility2() == true and enablepassing == true:
        playEffect(getAllPlayers(), DynamicEffect.RING_EXPLOSION, Color.SKY_BLUE, prevTarget.getPosition(), 10)
        playEffect(getAllPlayers(), DynamicEffect.MOIRA_FADE_DISAPPEAR_SOUND, Color.WHITE, prevTarget.getPosition(), 100)
        prevTarget.setHealth(prevTarget.getHealth() - 100)
        if prevTarget.getHealth() < 99:
            deflectFail()
        stopAssist(passingassistid)
        if getNumberOfLivingPlayers(prevTarget.getTeam()) == 1:
            if presetMode != 1:
                if ballSpeed > 140:
                    Target = getLivingPlayers(getOppositeTeam(prevTarget.getTeam()))[0]
                    wait()
                Target = prevTarget
            else:
                deflectFail()
        else:
            passingplayer = prevTarget
            passingplayer.startGrantingAssistFor(getAllPlayers(), AssistReeval.NONE)
            passingassistid = getLastAssistId()
            Target = sorted(getLivingPlayers(prevTarget.getTeam()).exclude(prevTarget).filter(lambda x: x.hasMoved), lambda x: angleBetweenVectors(Target.getFacingDirection(), directionTowards(Target, x.getPosition())))[0]
    else:
        if prevTarget.getTeam() == Team.1 == false or prevTarget.getTeam() == Team.2 == false:
            stopAssist(passingassistid)
        heal(prevTarget, null, 100)
        Target = sorted(getLivingPlayers(getOppositeTeam(prevTarget.getTeam())).exclude(prevTarget).filter(lambda x: x.hasMoved), lambda x: angleBetweenVectors(Target.getFacingDirection(), directionTowards(Target, x.getPosition())))[0]


rule "Teams - end assist after 1s":
    @Condition getCurrentGamemode() == Gamemode.TDM
    @Condition passingplayer != null
    
    waitUntil(prevTarget != passingplayer, 10)
    wait(1)
    stopAssist(passingassistid)
    passingplayer = null


rule "Teams - Final duel":
    @Condition getCurrentGamemode() == Gamemode.TDM
    @Condition isGameInProgress() == true
    @Condition RoundInProgress != false
    @Condition len(getLivingPlayers(Team.1).filter(lambda player: player.hasMoved)) == 1
    @Condition len(getLivingPlayers(Team.2).filter(lambda player: player.hasMoved)) == 1
    @Condition IsInFinalDuel == false
    @Condition IsEnoughPlayersToStart == true
    @Condition endlessMode == false
    
    wait(0.016, Wait.ABORT_WHEN_FALSE)
    if not ruleCondition:
        return
    setupFinal()


rule "Teams - Last surviving":
    @Condition getCurrentGamemode() == Gamemode.TDM
    @Condition isGameInProgress() == true
    @Condition IsEnoughPlayersToStart == true
    @Condition (getNumberOfLivingPlayers(Team.1) == 0 or getNumberOfLivingPlayers(Team.2) == 0) == true
    
    IsInFinalDuel = false
    if getNumberOfLivingPlayers(Team.1) == 0:
        addToTeamScore(Team.2, 1)
    else:
        addToTeamScore(Team.1, 1)
    wait(0.25)
    if (getMatchTime() == 0 or TieBreakerActive) and not tournamentmode:
        HighestScore = sorted(getAllPlayers(), lambda player: player.getScore()).last().getScore()
        #Check if there is more then 1 person with the highest score
        if teamScore(Team.1) == teamScore(Team.2):
            #There is more then 1, activate tie breaker
            TieBreakerActive = true
        else:
            TieBreakerActive = false
            if getMatchTime() == 0:
                enableMusic()
                enableGamemodeCompletion()
    stopChasing(ballSpawnCountdown)
    stopChasing(getAllPlayers().bouncePadCooldown)
    bigMessage(getAllPlayers(), "{0} has won the round".format(getLivingPlayers(Team.ALL)[0]))
    wait(2)
    if duelMode:
        goto lbl_0
    if not TieBreakerActive:
        getDeadPlayers(Team.ALL).resurrect()
    else:
        #Kill anyone alive who doesn't have the highest score.
        kill(getLivingPlayers(Team.ALL).filter(lambda player: player.getScore() != HighestScore))
        #During tiebreaker, only revive the people who have the same score as the highest score.
        (getDeadPlayers(Team.ALL).filter(lambda player: player.getScore() == HighestScore)).resurrect()
        wait(0.25)
        bigMessage(getAllPlayers(), "tiebreaker!")
    lbl_0:
    startRound()


rule "Sandbox - Set Ball spawnpoint":
    @Event eachPlayer
    @Condition Sandbox == true
    @Condition eventPlayer.isDummy() != true
    @Condition isGameInProgress() == true
    @Condition ballIsOut == false
    @Condition eventPlayer.isHoldingButton(Button.INTERACT) == true
    @Condition Sandboxselected == 1
    
    if Sandboxxyz == 1:
        if eventPlayer.isHoldingButton(Button.ULTIMATE) == true:
            if Sandboxplusminus == 1:
                Sandboxballpos = Sandboxballpos + vect(1, 0, 0)
            else:
                Sandboxballpos = Sandboxballpos + vect(-1, 0, 0)
        else:
            if Sandboxplusminus == 1:
                Sandboxballpos = Sandboxballpos + vect(0.25, 0, 0)
            else:
                Sandboxballpos = Sandboxballpos + vect(-0.25, 0, 0)
    elif Sandboxxyz == 2:
        if eventPlayer.isHoldingButton(Button.ULTIMATE) == true:
            if Sandboxplusminus == 1:
                Sandboxballpos = Sandboxballpos + vect(0, 1, 0)
            else:
                Sandboxballpos = Sandboxballpos + vect(0, -1, 0)
        else:
            if Sandboxplusminus == 1:
                Sandboxballpos = Sandboxballpos + vect(0, 0.25, 0)
            else:
                Sandboxballpos = Sandboxballpos + vect(0, -0.25, 0)
    elif Sandboxxyz == 3:
        if eventPlayer.isHoldingButton(Button.ULTIMATE) == true:
            if Sandboxplusminus == 1:
                Sandboxballpos = Sandboxballpos + vect(0, 0, 1)
            else:
                Sandboxballpos = Sandboxballpos + vect(0, 0, -1)
        else:
            if Sandboxplusminus == 1:
                Sandboxballpos = Sandboxballpos + vect(0, 0, 0.25)
            else:
                Sandboxballpos = Sandboxballpos + vect(0, 0, -0.25)


rule "Sandbox - Set Ball direction":
    @Event eachPlayer
    @Condition Sandbox == true
    @Condition eventPlayer.isDummy() != true
    @Condition isGameInProgress() == true
    @Condition ballIsOut == false
    @Condition eventPlayer.isHoldingButton(Button.INTERACT) == true
    @Condition Sandboxselected == 2
    
    if Sandboxxyz == 1:
        if eventPlayer.isHoldingButton(Button.ULTIMATE) == true:
            if Sandboxplusminus == 1:
                Sandboxballdir = Sandboxballdir + vect(1, 0, 0)
            else:
                Sandboxballdir = Sandboxballdir + vect(-1, 0, 0)
        else:
            if Sandboxplusminus == 1:
                Sandboxballdir = Sandboxballdir + vect(0.25, 0, 0)
            else:
                Sandboxballdir = Sandboxballdir + vect(-0.25, 0, 0)
    elif Sandboxxyz == 2:
        if eventPlayer.isHoldingButton(Button.ULTIMATE) == true:
            if Sandboxplusminus == 1:
                Sandboxballdir = Sandboxballdir + vect(0, 1, 0)
            else:
                Sandboxballdir = Sandboxballdir + vect(0, -1, 0)
        else:
            if Sandboxplusminus == 1:
                Sandboxballdir = Sandboxballdir + vect(0, 0.25, 0)
            else:
                Sandboxballdir = Sandboxballdir + vect(0, -0.25, 0)
    elif Sandboxxyz == 3:
        if eventPlayer.isHoldingButton(Button.ULTIMATE) == true:
            if Sandboxplusminus == 1:
                Sandboxballdir = Sandboxballdir + vect(0, 0, 1)
            else:
                Sandboxballdir = Sandboxballdir + vect(0, 0, -1)
        else:
            if Sandboxplusminus == 1:
                Sandboxballdir = Sandboxballdir + vect(0, 0, 0.25)
            else:
                Sandboxballdir = Sandboxballdir + vect(0, 0, -0.25)


rule "Sandbox - Set Ball speed":
    @Event eachPlayer
    @Condition Sandbox == true
    @Condition eventPlayer.isDummy() != true
    @Condition isGameInProgress() == true
    @Condition ballIsOut == false
    @Condition eventPlayer.isHoldingButton(Button.INTERACT) == true
    @Condition Sandboxselected == 3
    @Condition isGameInProgress() == true
    
    if eventPlayer.isHoldingButton(Button.ULTIMATE) == true:
        if Sandboxplusminus == 1:
            Sandboxballspd = Sandboxballspd + 10
        else:
            Sandboxballspd = Sandboxballspd + -10
    else:
        if Sandboxplusminus == 1:
            Sandboxballspd = Sandboxballspd + 1
        else:
            Sandboxballspd = Sandboxballspd + -1


rule "Sandbox - Change xyz and +/-":
    @Event eachPlayer
    @Condition Sandbox == true
    @Condition eventPlayer.isDummy() != true
    @Condition isGameInProgress() == true
    @Condition ballIsOut == false
    @Condition (eventPlayer.isHoldingButton(Button.JUMP) == true or eventPlayer.isHoldingButton(Button.CROUCH) == true) == true
    
    if not ruleCondition:
        return
    wait(0.25)
    if eventPlayer.isHoldingButton(Button.JUMP) == true and eventPlayer.isHoldingButton(Button.CROUCH) == true:
        Sandboxplusminus = Sandboxplusminus * -1
        bigMessage(getAllPlayers(), "+/- switched")
    elif eventPlayer.isHoldingButton(Button.JUMP) == true:
        if Sandboxxyz == 3:
            bigMessage(getAllPlayers(), "Invalid input")
        else:
            Sandboxxyz = Sandboxxyz + 1
            bigMessage(getAllPlayers(), "axis +1")
    elif eventPlayer.isHoldingButton(Button.CROUCH) == true:
        if Sandboxxyz == 1:
            bigMessage(getAllPlayers(), "Invalid input")
        else:
            Sandboxxyz = Sandboxxyz - 1
            bigMessage(getAllPlayers(), "axis -1")


rule "Sandbox - Switch between pos/dir/spd":
    @Event eachPlayer
    @Condition eventPlayer.isHoldingButton(Button.RELOAD) == true
    @Condition eventPlayer.isDummy() != true
    @Condition isGameInProgress() == true
    @Condition ballIsOut == false
    @Condition Sandbox == true
    
    waitUntil(not eventPlayer.isHoldingButton(Button.RELOAD), 0.4)
    if eventPlayer.isHoldingButton(Button.RELOAD) == true:
        if Sandboxselected > 2:
            Sandboxselected = 1
        else:
            Sandboxselected = Sandboxselected + 1
        bigMessage(eventPlayer, "Switched pos/dir/spd to {0}".format(Sandboxselected))


rule "Sandbox - Show ball spawnpoint and direction":
    @Condition Sandbox == true
    @Condition isGameInProgress() == true
    @Condition ballIsOut == false
    
    createEffect(getAllPlayers(), Effect.ORB, Color.GREEN, Sandboxballpos, 0.2, EffectReeval.POSITION_AND_RADIUS)
    createEffect(getAllPlayers(), Effect.ORB, Color.YELLOW, Sandboxballpos + Sandboxballdir, 0.1, EffectReeval.POSITION_AND_RADIUS)


rule "Sandbox - Controls desc":
    @Condition Sandbox == true
    
    hudSubheader(getAllPlayers().filter(lambda player: player.simpleHUD == 0), "Press [{0}] / [{1}] to switch the axis youre editing. press both to switch between negative and positive.".format(inputBindingString(Button.JUMP), inputBindingString(Button.CROUCH)), HudPosition.LEFT, 999, Color.WHITE, HudReeval.VISIBILITY_AND_STRING)
    hudSubheader(getAllPlayers().filter(lambda player: player.simpleHUD == 0), "Hold [{0}] to switch between position/direction/speed".format(inputBindingString(Button.RELOAD)), HudPosition.LEFT, 999, Color.WHITE, HudReeval.VISIBILITY_AND_STRING)
    hudSubheader(getAllPlayers().filter(lambda player: player.simpleHUD == 0), "Press [{0}] to add/substract, hold [{1}] while doing so to add/substract more. (dont hold long, because itll deactivate sandbox)".format(inputBindingString(Button.INTERACT), inputBindingString(Button.ULTIMATE)), HudPosition.LEFT, 999, Color.WHITE, HudReeval.VISIBILITY_AND_STRING)
    hudSubheader(getAllPlayers().filter(lambda player: player.simpleHUD == 0), "Current settings: Ballpos: [{0}] Balldirection: [{1}] Ballspeed: [{2}]".format(Sandboxballpos, Sandboxballdir, Sandboxballspd), HudPosition.LEFT, 999, Color.WHITE, HudReeval.VISIBILITY_AND_STRING)
    hudSubheader(getAllPlayers().filter(lambda player: player.simpleHUD == 0), "Start the round by pressing [{0}] and [{1}]".format(inputBindingString(Button.ULTIMATE), inputBindingString(Button.RELOAD)), HudPosition.LEFT, 999, Color.WHITE, HudReeval.VISIBILITY_AND_STRING)


rule "Gb Abilities - stack crit slashes":
    @Event eachPlayer
    @Condition eventPlayer.Critalert == true
    @Condition Abilities == true
    @Condition eventPlayer.isDummy() != true
    @Disabled
    
    eventPlayer.Critalert = false
    wait(0.032, Wait.RESTART_WHEN_TRUE)
    ballSpeed = ballSpeed * 1.75
    wait(5)
    ballSpeed = ballSpeed / 1.75
    ballSpeed = ballSpeed * 1.25


