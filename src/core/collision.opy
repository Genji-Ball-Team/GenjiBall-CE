#Ball-to-player collision, deflects and deaths

rule "Collision - ball reaches player":
    @Condition ballIsOut == true
    @Condition distance(ballPosition, target.getEyePosition()) <= 1.9
    
    collisionTarget()


rule "Collision - collision check":
    @Condition ballIsOut == true
    @Condition ballSpeed > 150
    
    if ballHitPosition != null:
        #-o--x--------o->Between last ballPosition & middlePosition
        phasePosition[PhasePoint.QUARTER] = ballHitPosition + phasePosition[PhasePoint.LAST]
        phasePosition[PhasePoint.QUARTER] /= 2
        #-o-----x-----o->Between last & current ballPosition
        phasePosition[PhasePoint.LAST] = ballHitPosition
        ballHitPosition = null
    else:
        #-o--x--------o->Between last ballPosition & middlePosition
        phasePosition[PhasePoint.QUARTER] = phasePosition[PhasePoint.LAST] + ballPosition
        phasePosition[PhasePoint.QUARTER] /= 2
        phasePosition[PhasePoint.QUARTER] += phasePosition[PhasePoint.LAST]
        phasePosition[PhasePoint.QUARTER] /= 2
        phasePosition[PhasePoint.LAST] += ballPosition
        phasePosition[PhasePoint.LAST] /= 2
    #-o-----------x->
    if distance(ballPosition, target.getEyePosition()) <= 1.9:
        collisionTarget()
    elif distance(phasePosition[PhasePoint.LAST], target.getEyePosition()) <= 1.9:
        collisionTarget()
    elif distance(phasePosition[PhasePoint.QUARTER], target.getEyePosition()) <= 1.9:
        collisionTarget()
    elif distance((phasePosition[PhasePoint.LAST] + ballPosition) / 2, target.getEyePosition()) <= 1.9:
        collisionTarget()
    #Save last ballPosition for next loop
    phasePosition[PhasePoint.LAST] = evalOnce(ballPosition)
    wait(0)
    if ruleCondition:
        loop()


def collisionTarget():
    @Name "Collision - collision sub"
    
    if ballSpeedCap == ballSpeed:
        if bozo_Bot and target.isDummy():
            goto lbl_0
    if bozo_Bot and target.isDummy():
        target.forceButtonPress(Button.ABILITY_2)
    if target.isUsingAbility1():
        goto lbl_1
    #Only when Tracing mode == true
    if tracingPoints == 0:
        goto lbl_2
    if target.isUsingAbility2():
        goto lbl_3
    lbl_0:
    lbl_2:
    deflectFail()
    return
    lbl_1:
    lbl_3:
    if ballPhysicsMode == BallPhysics.EXPERIMENTAL and ballMotion != BallMotion.ASTRO:
        #layered on top of original Modern movement. The deflector's 3D facing
        #direction remains dominant, while incoming ball momentum contributes
        #slightly more on side-angle redirects so geometry matters.
        experimentalState[ExperimentalField.INCOMING_DIRECTION] = directionTowards(vect(0, 0, 0), evalOnce(ballDirection))
        experimentalState[ExperimentalField.REBOUND_INFLUENCE] = experimentalTuning[ExperimentalTuning.REBOUND_MIN] + (((min(angleBetweenVectors(experimentalState[ExperimentalField.INCOMING_DIRECTION], target.getFacingDirection()), 180 - angleBetweenVectors(experimentalState[ExperimentalField.INCOMING_DIRECTION], target.getFacingDirection()))) / 90) * (experimentalTuning[ExperimentalTuning.REBOUND_MAX] - experimentalTuning[ExperimentalTuning.REBOUND_MIN]))
        ballDirection = directionTowards(vect(0, 0, 0), target.getFacingDirection() * (1 - experimentalState[ExperimentalField.REBOUND_INFLUENCE]) + experimentalState[ExperimentalField.INCOMING_DIRECTION] * experimentalState[ExperimentalField.REBOUND_INFLUENCE])
    else:
        ballDirection = target.getFacingDirection() * (ballSpeed if ballMotion == BallMotion.ASTRO else 1)
    prevTarget = target
    if prevTarget.isUsingAbility1():
        dashBall()
    if prevTarget.Critslash == true:
        #ballSpeed = min(ballSpeedCap, ballSpeed * 1.2)
        prevTarget.Critalert = true
        prevTarget.Critslash = false
    else:
        ballSpeed = min(ballSpeedCap, ballSpeed * 1.05)
    target = sorted(getLivingPlayers(Team.ALL).exclude(target).filter(lambda x: x.hasMoved), lambda x: angleBetweenVectors(target.getFacingDirection(), directionTowards(target, x.getPosition())))[0]
    playEffect(getAllPlayers(), DynamicEffect.EXPLOSION_SOUND, Color.WHITE, evalOnce(prevTarget.getPosition()), 150)
    playEffect(getAllPlayers(), DynamicEffect.BAPTISTE_BIOTIC_LAUNCHER_EXPLOSION_SOUND, Color.WHITE, evalOnce(prevTarget.getPosition()), 20)
    #Redirect-sensitive systems should start fresh after the ball changes target.
    experimentalState[ExperimentalField.REDIRECT_AGE] = 0
    experimentalState[ExperimentalField.STEERING_RATE] = ballDirectionRate * experimentalTuning[ExperimentalTuning.HOMING_START]
    antiGhostState = [999, 0]
    if ballMotion == BallMotion.MODERN and ballPhysicsMode != BallPhysics.EXPERIMENTAL:
        async(ballCurve, AsyncBehavior.RESTART)


def deflectFail():
    @Name "Collision - deflect fail sub"
    
    if addOnSettings[AddOnSetting.KILL_TRACKER] == true and prevTarget != null and not prevTarget.isDummy():
        prevTarget.kills++
    kill(target, prevTarget)
    playDeathEffect()
    if getNumberOfLivingPlayers(Team.ALL) == 1:
        alert()
        deleteBall()
        return
    if addOnSettings[AddOnSetting.ENDLESS]:
        #ballDirection *= -1
        target = sorted(getLivingPlayers(Team.ALL).exclude(target).filter(lambda x: x.hasMoved), lambda x: angleBetweenVectors(ballDirection, directionTowards(ballPosition, x.getPosition())))[0]
    else:
        deleteBall()
        randomTarget()


def playDeathEffect():
    @Name "Collision - play death effect sub"
    
    playEffect(getAllPlayers(), DynamicEffect.ASHE_DYNAMITE_EXPLOSION_SOUND, Color.SKY_BLUE, ballPosition.getPosition(), 80)
    if addOnSettings[AddOnSetting.ENDLESS]:
        playEffect(getAllPlayers(), DynamicEffect.TRACER_RECALL_REAPPEAR, Color.WHITE, ballPosition, 2)
        return
    playEffect(getAllPlayers(), DynamicEffect.ASHE_DYNAMITE_EXPLOSION, Team.1, ballPosition.getPosition(), 40)
    playEffect(getAllPlayers(), DynamicEffect.DVA_SELF_DESTRUCT_EXPLOSION, Team.ALL, ballPosition.getPosition(), 40)
    playEffect(getAllPlayers(), DynamicEffect.DOOMFIST_METEOR_STRIKE_IMPACT, Team.1, ballPosition.getPosition(), 40)


def dashBall():
    @Name "Collision - dash sub"
    
    if prevTarget.stunCooldown <= 0:
        prevTarget.setStatusEffect(null, Status.KNOCKED_DOWN, playerSettings[PlayerSetting.STUN_DURATION])
        prevTarget.stunCooldown = playerSettings[PlayerSetting.STUN_COOLDOWN]


def ballCurve():
    @Name "Collision - ball curve sub"
    
    if ballMotion == BallMotion.MODERN:
        ballDirectionRate = 6
        #chaseOverTime(ballDirectionRate, ballDirectionRateInit, 0.04, ChaseTimeReeval.NONE)
        wait(0.05)
        ballDirectionRate = ballDirectionRateInit


def deleteBall():
    @Name "Collision - delete ball sub"
    
    async(stopBall, AsyncBehavior.RESTART)
    prevTarget = null
    ballPosition = Vector.DOWN
    ballDirection = vect(0, 0, 0)
    ballSpawnCountdown = roundTimings[RoundTiming.RESPAWN_DELAY]
    ballHitPosition = null
    phasePosition = [Vector.DOWN, Vector.DOWN]
    antiGhostState = [999, 0]
    ballDirectionRate = ballDirectionRateInit
    experimentalState = [999, ballDirectionRateInit, vect(0, 0, 0), experimentalTuning[ExperimentalTuning.REBOUND_MIN]]
