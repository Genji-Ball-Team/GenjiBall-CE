#Ball-to-player collision, deflects and deaths

rule "Collision - ball reaches player":
    @Condition ballIsOut == true
    @Condition distance(ballPosition, target.getEyePosition()) <= ballFeel[BallFeel.HIT_RADIUS]
    
    collisionTarget()


rule "Collision - collision check":
    @Condition ballIsOut == true
    #RELIABLE_HITS is always false: this runs above FAST_BALL_SPEED only, as a backup for
    #"Collision - ball reaches player", whose condition reads the chased ballPosition.
    @Condition (ballSpeed > ballFeel[BallFeel.FAST_BALL_SPEED] or ballFeel[BallFeel.RELIABLE_HITS]) == true
    
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
    if distance(ballPosition, target.getEyePosition()) <= ballFeel[BallFeel.HIT_RADIUS]:
        collisionTarget()
    elif distance(phasePosition[PhasePoint.LAST], target.getEyePosition()) <= ballFeel[BallFeel.HIT_RADIUS]:
        collisionTarget()
    elif distance(phasePosition[PhasePoint.QUARTER], target.getEyePosition()) <= ballFeel[BallFeel.HIT_RADIUS]:
        collisionTarget()
    elif distance((phasePosition[PhasePoint.LAST] + ballPosition) / 2, target.getEyePosition()) <= ballFeel[BallFeel.HIT_RADIUS]:
        collisionTarget()
    #Save last ballPosition for next loop
    phasePosition[PhasePoint.LAST] = evalOnce(ballPosition)
    wait(0)
    if ruleCondition:
        loop()


def collisionTarget():
    @Name "Collision - collision sub"
    
    #Only a dash or deflect sends the ball back
    if not (target.isUsingAbility1() or target.isUsingAbility2()):
        deflectFail()
        return
    ballDirection = target.getFacingDirection()
    prevTarget = target
    if prevTarget.isUsingAbility1():
        dashBall()
    ballSpeed = min(ballSpeedCap, ballSpeed * ballFeel[BallFeel.DEFLECT_SPEEDUP])
    target = sorted(getLivingPlayers(Team.ALL).exclude(target).filter(lambda x: x.hasMoved), lambda x: angleBetweenVectors(target.getFacingDirection(), directionTowards(target, x.getPosition())))[0]
    playEffect(getAllPlayers(), DynamicEffect.EXPLOSION_SOUND, Color.WHITE, evalOnce(prevTarget.getPosition()), 150)
    playEffect(getAllPlayers(), DynamicEffect.BAPTISTE_BIOTIC_LAUNCHER_EXPLOSION_SOUND, Color.WHITE, evalOnce(prevTarget.getPosition()), 20)
    async(ballCurve, AsyncBehavior.RESTART)


def deflectFail():
    @Name "Collision - deflect fail sub"
    
    kill(target, prevTarget)
    playDeathEffect()
    if getNumberOfLivingPlayers(Team.ALL) == 1:
        alert()
        deleteBall()
        return
    deleteBall()
    randomTarget()


def playDeathEffect():
    @Name "Collision - play death effect sub"
    
    playEffect(getAllPlayers(), DynamicEffect.ASHE_DYNAMITE_EXPLOSION_SOUND, Color.SKY_BLUE, ballPosition.getPosition(), 80)
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
    
    ballDirectionRate = ballFeel[BallFeel.CURVE_RATE]
    #chaseOverTime(ballDirectionRate, ballDirectionRateInit, 0.04, ChaseTimeReeval.NONE)
    wait(ballFeel[BallFeel.CURVE_TIME])
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
    ballDirectionRate = ballDirectionRateInit
