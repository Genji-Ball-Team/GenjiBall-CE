#Anti-orbit detection and penalties

rule "AntiOrbit - no orbit abusing":
    @Event eachPlayer
    @Condition antiOrbitMode == true
    @Condition eventPlayer == target
    @Condition ballIsOut == true
    @Condition eventPlayer.isAlive() == true
    
    #AntiOrbit mirrors the original tournament anti-orbit punishment, but
    #uses pressure/heat to shorten the sleep timer when orbiting persists.
    #Distance and speed checks stay in the body so ballPosition/ballSpeed do
    #not live in @Condition clauses.
    if distance(eventPlayer.getEyePosition(), ballPosition) >= antiOrbitRadius:
        wait(0.1)
        if ruleCondition:
            loop()
        return
    if ballSpeed >= 80:
        wait(0.1)
        if ruleCondition:
            loop()
        return
    wait(max(5.5, 7.5 - ((eventPlayer.orbitPenalty + eventPlayer.orbitHeat) * 5)), Wait.ABORT_WHEN_FALSE)
    if not ruleCondition:
        return
    if not (distance(eventPlayer.getEyePosition(), ballPosition) < antiOrbitRadius and ballSpeed < 80):
        return
    eventPlayer.setStatusEffect(null, Status.ASLEEP, 5)
    eventPlayer.applyImpulse(ballDirection + Vector.UP, 10, Relativity.TO_WORLD)


rule "AntiOrbit - track pressure":
    @Event eachPlayer
    @Condition antiOrbitMode == true
    @Condition eventPlayer.isAlive() == true
    @Condition ballIsOut == true
    @Condition eventPlayer == target
    
    if distance(ballPosition, eventPlayer.getEyePosition()) < antiOrbitRadius:
        eventPlayer.orbitTimer += 0.25
        if eventPlayer.orbitTimer > 2.5:
            eventPlayer.orbitPenalty = min(eventPlayer.orbitPenalty + antiOrbitPressureRate, 0.25)
            eventPlayer.orbitHeat = min(eventPlayer.orbitHeat + antiOrbitPressureRate * 0.2, 0.2)
    else:
        eventPlayer.orbitTimer = max(eventPlayer.orbitTimer - 0.5, 0)
        eventPlayer.orbitPenalty = max(eventPlayer.orbitPenalty - 0.02, 0)
    wait(0.25)
    if ruleCondition:
        loop()


rule "AntiOrbit - reset when disabled":
    @Event eachPlayer
    @Condition antiOrbitMode == false
    
    eventPlayer.orbitTimer = 0
    eventPlayer.orbitPenalty = 0
    eventPlayer.orbitHeat = 0


rule "AntiOrbit - decay heat":
    @Event eachPlayer
    @Condition antiOrbitMode == true
    @Condition isGameInProgress() == true
    @Condition RoundInProgress == true
    @Condition ballIsOut == true
    @Condition eventPlayer != target
    @Condition eventPlayer.orbitHeat > 0
    @Condition eventPlayer.hasStatus(Status.ASLEEP) == false
    
    eventPlayer.orbitHeat = max(eventPlayer.orbitHeat - 0.002, 0)
    eventPlayer.orbitPenalty = max(eventPlayer.orbitPenalty - 0.005, 0)
    eventPlayer.orbitTimer = 0
    wait(0.5)
    if ruleCondition:
        loop()


def resetOrbitRoundState():
    @Name "AntiOrbit - round cleanup"
    
    getAllPlayers().orbitTimer = 0
    getAllPlayers().orbitPenalty = 0
    getAllPlayers().orbitHeat = 0
