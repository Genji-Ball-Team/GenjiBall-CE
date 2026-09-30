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
        phasePosition += ballPosition
        phasePosition /= 2
    #-o--------x--o->Between phasePosition & current ballPosition & phasePosition
    phasePosition2 = phasePosition + ballPosition
    phasePosition2 /= 2
    #-o-----------x->
    if distance(ballPosition, target.getEyePosition()) <= 1.9:
        collisionTarget()
    elif distance(phasePosition, target.getEyePosition()) <= 1.9:
        collisionTarget()
    elif distance(phasePosition1, target.getEyePosition()) <= 1.9:
        collisionTarget()
    elif distance(phasePosition2, target.getEyePosition()) <= 1.9:
        collisionTarget()
    #Save last ballPosition for next loop
    phasePosition = evalOnce(ballPosition)
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
    if ballPhysicsMode == 2 and ballMotion != 2:
        #layered on top of original Modern movement. The deflector's 3D facing
        #direction remains dominant, while incoming ball momentum contributes
        #slightly more on side-angle redirects so geometry matters.
        reboundIncomingDirection = directionTowards(vect(0, 0, 0), evalOnce(ballDirection))
        reboundInfluence = experimentalReboundMin + (((min(angleBetweenVectors(reboundIncomingDirection, target.getFacingDirection()), 180 - angleBetweenVectors(reboundIncomingDirection, target.getFacingDirection()))) / 90) * (experimentalReboundMax - experimentalReboundMin))
        ballDirection = directionTowards(vect(0, 0, 0), target.getFacingDirection() * (1 - reboundInfluence) + reboundIncomingDirection * reboundInfluence)
    else:
        ballDirection = target.getFacingDirection() * (ballSpeed if ballMotion == 2 else 1)
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
    ballRedirectAge = 0
    experimentalSteeringRate = ballDirectionRate * experimentalHomingStart
    antiGhostPrevDistance = 999
    antiGhostStallTimer = 0
    if ballMotion == 0 and ballPhysicsMode != 2:
        async(ballCurve, AsyncBehavior.RESTART)


def deflectFail():
    @Name "Collision - deflect fail sub"
    
    if killCounterEnabled == true and prevTarget != null and not prevTarget.isDummy():
        prevTarget.kills++
    kill(target, prevTarget)
    playDeathEffect()
    if getNumberOfLivingPlayers(Team.ALL) == 1:
        alert()
        deleteBall()
        return
    if endlessMode:
        #ballDirection *= -1
        target = sorted(getLivingPlayers(Team.ALL).exclude(target).filter(lambda x: x.hasMoved), lambda x: angleBetweenVectors(ballDirection, directionTowards(ballPosition, x.getPosition())))[0]
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
    ballPosition = Vector.DOWN
    ballDirection = vect(0, 0, 0)
    ballSpawnCountdown = 2
    ballHitPosition = null
    phasePosition = Vector.DOWN
    phasePosition1 = Vector.DOWN
    phasePosition2 = Vector.DOWN
    antiGhostPrevDistance = 999
    antiGhostStallTimer = 0
    ballRedirectAge = 999
    ballDirectionRate = ballDirectionRateInit
    experimentalSteeringRate = ballDirectionRateInit
    reboundIncomingDirection = vect(0, 0, 0)
    reboundInfluence = experimentalReboundMin
