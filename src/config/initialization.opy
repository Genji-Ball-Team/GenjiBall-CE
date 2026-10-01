#Initial variable values, bounce pads, mobility, match length

rule "Initialization - player variables":
    @Event eachPlayer
    
    eventPlayer.Critalert = false
    eventPlayer.sensHigh = false
    eventPlayer.orbitPenalty = 0
    eventPlayer.orbitTimer = 0
    eventPlayer.orbitHeat = 0
    eventPlayer.setAimSpeed(100)
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
    eventPlayer.startCamera(updateEveryFrame(raycastHitPosition(eventPlayer.getEyePosition(), eventPlayer + worldVector(vect(-0.5, 0, 0), eventPlayer, Transform.ROTATION) + vect(0, 1.5, 0) + eventPlayer.getFacingDirection() * -2, null, getAllPlayers(), false)), eventPlayer + eventPlayer.getFacingDirection() * 1000)
    eventPlayer.simpleHUD = SimpleHud.OFF
    eventPlayer.disableGamemodeHud()
    eventPlayer.canDash = true
    eventPlayer.dashOnCooldown = false
    eventPlayer.canDeflect = true
    eventPlayer.antiRubberbanding = false
    eventPlayer.SpecialAbility = AbilityId.SUPER_JUMP
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
    ballSpeed = ballSpawnSpeed
    CenterOffLimitsSize = 3.5
    IsInFinalDuel = false
    bouncePadCooldownLength = 3
    ballPosition = Vector.DOWN
    roundsUntilBreakInit = roundsUntilBreak
    ballHitPosition = null
    phasePosition = Vector.DOWN
    phasePosition1 = Vector.DOWN
    phasePosition2 = Vector.DOWN
    if ballDirectionRate == 4:
        ballDirectionRate = ballDirectionRateInit
    tracingPoints = 1
    if ballMotion == BallMotion.MODERN:
        ballDirectionRateInit = 1.75
        ballDirectionRate = ballDirectionRateInit
    elif ballMotion == BallMotion.RAPID:
        ballDirectionRateInit = 5
        ballDirectionRate = ballDirectionRateInit
    else:
        ballDirectionRate = 6
    experimentalSteeringRate = ballDirectionRate
    reboundInfluence = experimentalTuning[ExperimentalTuning.REBOUND_MIN]
    duelQueue = []
    #zBozo pending moves (BotField in config/constants.opy)
    botState = []
    killLeaderboardSortedPlayers = []
    #Sandbox spawn point, aim point and speed, plus the editor state (SandboxField in config/constants.opy)
    sandboxState = [ballPosition, ballPosition + Vector.UP, ballSpeed, 1, 1, 1]
    antiGhostPrevDistance = 999
    antiGhostStallTimer = 0
    ballRedirectAge = 999


rule "Initialization - map sphere":
    createEffect(getAllPlayers(), Effect.SPHERE, Color.BLACK, vect(circleCenter.x, circleCenter.y, circleCenter.z), CenterOffLimitsSize, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
    #Workshop Island doesn't need a circle.
    if not isIsland:
        createEffect(getAllPlayers(), Effect.LIGHT_SHAFT, Color.BLACK, vect(circleCenter.x, circleCenter.y - 15, circleCenter.z), SphereSize, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
    else:
        createEffect(getAllPlayers().filter(lambda player: distance(player.getPosition(), circleCenter) >= SphereSize - 10), Effect.LIGHT_SHAFT, Color.BLACK, vect(circleCenter.x, circleCenter.y - 15, circleCenter.z), SphereSize, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)


rule "Initialization - bounce pads":
    @Condition bouncePadToggle == true
    
    #One entry per BouncePadField (config/constants.opy), in that order
    bouncePadConfig = [30, 12, 2.75, 3]
    bouncePads = [
        vect(circleCenter.x + bouncePadConfig[BouncePadField.DISTANCE], circleCenter.y, circleCenter.z),
        vect(circleCenter.x + bouncePadConfig[BouncePadField.DISTANCE] * -1, circleCenter.y, circleCenter.z),
        vect(circleCenter.x, circleCenter.y, circleCenter.z + bouncePadConfig[BouncePadField.DISTANCE]),
        vect(circleCenter.x, circleCenter.y, circleCenter.z + bouncePadConfig[BouncePadField.DISTANCE] * -1)
    ]
    createEffect(getAllPlayers().filter(lambda player: player.bouncePadCooldown == 0), Effect.RING, Color.SKY_BLUE, bouncePads[0], 2, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
    createEffect(getAllPlayers().filter(lambda player: player.bouncePadCooldown == 0), Effect.RING, Color.SKY_BLUE, bouncePads[1], 2, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
    createEffect(getAllPlayers().filter(lambda player: player.bouncePadCooldown == 0), Effect.RING, Color.SKY_BLUE, bouncePads[2], 2, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
    createEffect(getAllPlayers().filter(lambda player: player.bouncePadCooldown == 0), Effect.RING, Color.SKY_BLUE, bouncePads[3], 2, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
    if RedGreenColorblindMode:
        createEffect(getAllPlayers().filter(lambda player: player.bouncePadCooldown > 0), Effect.RING, Color.YELLOW, bouncePads[0], 2, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
        createEffect(getAllPlayers().filter(lambda player: player.bouncePadCooldown > 0), Effect.RING, Color.YELLOW, bouncePads[1], 2, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
        createEffect(getAllPlayers().filter(lambda player: player.bouncePadCooldown > 0), Effect.RING, Color.YELLOW, bouncePads[2], 2, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
        createEffect(getAllPlayers().filter(lambda player: player.bouncePadCooldown > 0), Effect.RING, Color.YELLOW, bouncePads[3], 2, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
    else:
        createEffect(getAllPlayers().filter(lambda player: player.bouncePadCooldown > 0), Effect.RING, Color.WHITE, bouncePads[0], 2, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
        createEffect(getAllPlayers().filter(lambda player: player.bouncePadCooldown > 0), Effect.RING, Color.WHITE, bouncePads[1], 2, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
        createEffect(getAllPlayers().filter(lambda player: player.bouncePadCooldown > 0), Effect.RING, Color.WHITE, bouncePads[2], 2, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
        createEffect(getAllPlayers().filter(lambda player: player.bouncePadCooldown > 0), Effect.RING, Color.WHITE, bouncePads[3], 2, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)


rule "Initialization - Apply high mobility mode":
    @Event eachPlayer
    @Condition isGameInProgress() == true
    
    eventPlayer.setJumpVerticalSpeed(jumpVerticalSpeed)
    eventPlayer.setGravity(gravity)
    eventPlayer.setMoveSpeed(moveSpeed)
    eventPlayer.currentGravity = gravity


rule "Initialization - Match length":
    @Condition isGameInProgress() == true
    @Condition tournamentMode == false
    
    setMatchTime(matchTime)


rule "Initialization - Disable inspector":
    disableInspector()
