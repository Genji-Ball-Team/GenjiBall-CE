#Tournament mode: round limits and breaks

rule "Tournament - game ends after 0 Rounds left":
    @Condition totalRounds <= 0
    @Condition tournamentMode == true
    
    wait(1)
    setMatchTime(0)
    enableGamemodeCompletion()


rule "Tournament - break":
    @Condition roundsUntilBreak <= 0
    @Condition breaksEnabled == true
    @Condition tournamentMode == true
    
    setballspawncountdown = breakLength
    bigMessage(getAllPlayers(), "Break time!")
    wait(breakLength + 1)
    setballspawncountdown = setballspawncountdownoriginal
    roundsUntilBreak += roundsUntilBreakInit


rule "Tournament - forbid dashing into the water":
    @Event eachPlayer
    @Condition tournamentMode == true
    @Condition eventPlayer.getPosition().y < -1
    @Condition eventPlayer.getVelocity().y < 0
    @Condition eventPlayer != target
    @Condition eventPlayer.isUsingAbility1() == true
    
    eventPlayer.teleport(eventPlayer.getPosition() - normalize(eventPlayer.getVelocity()))
    eventPlayer.startForcingPosition(eventPlayer.getPosition(), false)
    waitUntil(not eventPlayer.isUsingAbility1(), 0.5)
    eventPlayer.stopForcingPosition()


rule "Tournament - no orbit abusing":
    @Event eachPlayer
    @Condition tournamentMode == true
    @Condition antiOrbitMode == false
    @Condition eventPlayer == target
    #@Condition (angleBetweenVectors(ballDirection, directionTowards(ballPosition, eventPlayer.getEyePosition())) < 100 and angleBetweenVectors(ballDirection, directionTowards(ballPosition, eventPlayer.getEyePosition())) > -100) == true
    @Condition ballIsOut == true
    @Condition distance(eventPlayer.getEyePosition(), ballPosition) < competitiveSettings[CompetitiveSetting.BASIC_ORBIT_RADIUS]
    @Condition ballSpeed < competitiveSettings[CompetitiveSetting.BASIC_ORBIT_SPEED]
    
    #smallMessage(getAllPlayers(), "Orbit start")
    wait(competitiveSettings[CompetitiveSetting.BASIC_ORBIT_TIMER], Wait.ABORT_WHEN_FALSE)
    if not ruleCondition:
        return
    #smallMessage(getAllPlayers(), "...still orbiting...")
    eventPlayer.setStatusEffect(null, Status.ASLEEP, 5)
    eventPlayer.applyImpulse(ballDirection + Vector.UP, 10, Relativity.TO_WORLD)
