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
    bouncePadStrength = 30
    bouncePadDistance = 12
    bouncePadSuperjumpNerf = 3
    ballSpeed = ballSpawnSpeed
    CenterOffLimitsSize = 3.5
    IsInFinalDuel = false
    bouncePadCooldownLength = 3
    ballPosition = Vector.DOWN
    roundsUntilBreakInit = roundsUntilBreak
    roundEndCall = false
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
    reboundInfluence = experimentalReboundMin
    duelQueue = []
    killLeaderboardPlayers = []
    killLeaderboardSortedPlayers = []
    Sandboxxyz = 1
    Sandboxselected = 1
    Sandboxballpos = ballPosition
    Sandboxballdir = ballPosition + Vector.UP
    Sandboxballspd = ballSpeed
    Sandboxplusminus = 1
    antiGhostPrevDistance = 999
    antiGhostStallTimer = 0
    ballRedirectAge = 999
    Critalert = false


rule "Initialization - map sphere":
    createEffect(getAllPlayers(), Effect.SPHERE, Color.BLACK, vect(circleCenter.x, circleCenter.y, circleCenter.z), CenterOffLimitsSize, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
    #Workshop Island doesn't need a circle.
    if not isIsland:
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
    @Condition tournamentMode == false
    
    setMatchTime(matchTime)


rule "Initialization - Disable inspector":
    disableInspector()
