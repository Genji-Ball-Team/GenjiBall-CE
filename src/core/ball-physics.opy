#Ball motion modes and map collision

def startBall():
    @Name "Ball behavior - start ball"
    
    ballIsOut = true
    #Spawned balls start already aimed at the target; redirect ramp applies after deflects.
    experimentalState = [999, ballDirectionRate, ballDirection, experimentalTuning[ExperimentalTuning.REBOUND_MIN]]
    if ballPhysicsMode == BallPhysics.LEGACY_PLUS:
        async(startLegacyPlusBall, AsyncBehavior.RESTART)
    elif ballPhysicsMode == BallPhysics.EXPERIMENTAL:
        async(startExperimentalBall, AsyncBehavior.RESTART)
    elif ballMotion == BallMotion.MODERN or ballMotion == BallMotion.RAPID:
        async(startModernBall, AsyncBehavior.RESTART)
    elif ballMotion == BallMotion.ASTRO:
        async(startAstroBall, AsyncBehavior.RESTART)
    elif ballMotion == BallMotion.RETRO:
        async(startRetroBall, AsyncBehavior.RESTART)


def stopBall():
    @Name "Ball behavior - stop ball"
    
    ballIsOut = false
    stopChasing(ballDirection)
    stopChasing(ballPosition)
    stopChasing(ballSpeed)


def startModernBall():
    @Name "Ball behavior - modern motion"
    
    chaseAtRate(ballPosition, ballPosition + ballDirection * ballSpeed * motionMultiplier, ballSpeed)
    chaseAtRate(ballSpeed, ballSpeedCap, ballAcceleration)
    chaseAtRate(ballDirection, directionTowards(ballPosition, target.getEyePosition()), updateEveryFrame(ballDirectionRate))


def startLegacyPlusBall():
    @Name "Ball behavior - Legacy+ motion"
    
    #Legacy+ is a chase-free test path for the modern/rapid motion styles.
    #Astro and retro still use their original engines for now.
    if ballMotion == BallMotion.ASTRO:
        async(startAstroBall, AsyncBehavior.RESTART)
        return
    elif ballMotion == BallMotion.RETRO:
        async(startRetroBall, AsyncBehavior.RESTART)
        return
    while ballIsOut:
        ballSpeed = min(ballSpeedCap, ballSpeed + ballAcceleration * 0.016)
        if target != null:
            ballDirection = directionTowards(vect(0, 0, 0), ballDirection + directionTowards(ballPosition, target.getEyePosition()) * ballDirectionRate * 0.016)
        ballPosition += ballDirection * ballSpeed * motionMultiplier * 0.016
        wait()


def startExperimentalBall():
    @Name "Ball behavior - experimental hybrid motion"
    
    #direction is mostly player aim with a small 3D incoming-momentum influence,
    #then homing returns smoothly. The tuning sliders in 10 - Ball control
    #the incoming-momentum influence and homing handoff so the feel can be
    #adjusted in-game while playtesting.
    if ballMotion == BallMotion.ASTRO:
        async(startAstroBall, AsyncBehavior.RESTART)
        return
    elif ballMotion == BallMotion.RETRO:
        async(startRetroBall, AsyncBehavior.RESTART)
        return
    chaseAtRate(ballPosition, ballPosition + ballDirection * ballSpeed * motionMultiplier, ballSpeed)
    chaseAtRate(ballSpeed, ballSpeedCap, ballAcceleration)
    experimentalState[ExperimentalField.STEERING_RATE] = ballDirectionRate
    chaseAtRate(ballDirection, directionTowards(ballPosition, target.getEyePosition()), updateEveryFrame(experimentalState[ExperimentalField.STEERING_RATE]))
    while ballIsOut:
        experimentalState[ExperimentalField.REDIRECT_AGE] = min(999, experimentalState[ExperimentalField.REDIRECT_AGE] + 0.016)
        if target != null:
            #Dodgeball Hybrid homing handoff: throw/rebound identity first,
            #then a smooth return to normal Modern steering. This uses no
            #close-range magnetic tightening; AntiOrbit handles true orbit abuse.
            if experimentalState[ExperimentalField.REDIRECT_AGE] < experimentalTuning[ExperimentalTuning.HOMING_HOLD]:
                experimentalState[ExperimentalField.STEERING_RATE] = ballDirectionRate * experimentalTuning[ExperimentalTuning.HOMING_START]
            elif experimentalState[ExperimentalField.REDIRECT_AGE] < experimentalTuning[ExperimentalTuning.HOMING_HOLD] + experimentalTuning[ExperimentalTuning.HOMING_RAMP]:
                experimentalState[ExperimentalField.STEERING_RATE] = ballDirectionRate * (experimentalTuning[ExperimentalTuning.HOMING_START] + (((experimentalState[ExperimentalField.REDIRECT_AGE] - experimentalTuning[ExperimentalTuning.HOMING_HOLD]) / experimentalTuning[ExperimentalTuning.HOMING_RAMP]) * (1 - experimentalTuning[ExperimentalTuning.HOMING_START])))
            else:
                experimentalState[ExperimentalField.STEERING_RATE] = ballDirectionRate
        wait()


def startRetroBall():
    @Name "Ball Physics - retro motion"
    
    chaseAtRate(ballPosition, target.getEyePosition(), ballSpeed)
    chaseAtRate(ballSpeed, ballSpeedCap, ballAcceleration)


def startAstroBall():
    @Name "Ball Physics - astro motion"
    
    chaseAtRate(ballPosition, updateEveryFrame(ballPosition + ballDirection), updateEveryFrame(magnitude(ballDirection)))
    #ballDirection is the ball's velocity
    chaseAtRate(ballDirection, updateEveryFrame(ballDirection * 0.93 + target.getEyePosition() - ballPosition), updateEveryFrame((sqrt((ballSpeed - max(dotProduct(ballDirection, directionTowards(ballPosition, target.getEyePosition())), 0)) * ballSpeed)) * 3))
    #ballSpeed is the ball's acceleration coefficient
    chaseAtRate(ballSpeed, ballSpeedCap, ballAcceleration)
    wait()
    if ruleCondition:
        loop()


rule "Ball Physics - anti ghost correction":
    @Condition antiGhostMode != AntiGhost.OFF
    @Condition ballIsOut == true
    @Condition ballMotion == BallMotion.MODERN
    @Condition target != null
    @Condition target.isAlive() == true
    
    #Mode 2 = steer. If the ball is close to the target and its current
    #direction is far off from the ideal target direction, temporarily raise
    #steering strength. antiGhostRaised marks a raise to undo, so a deflect
    #curve rate of 4 isn't mistaken for one. Experimental leaves AntiGhost off by default;
    #Tournament+ uses Steer.
    if distance(ballPosition, target.getEyePosition()) <= 7:
        if antiGhostMode == AntiGhost.TRACK:
            if antiGhostState[AntiGhostField.PREV_DISTANCE] == 999:
                antiGhostState[AntiGhostField.PREV_DISTANCE] = distance(ballPosition, target.getEyePosition())
            if distance(ballPosition, target.getEyePosition()) >= antiGhostState[AntiGhostField.PREV_DISTANCE] - 0.05:
                antiGhostState[AntiGhostField.STALL_TIMER] += 0.05
            else:
                antiGhostState[AntiGhostField.STALL_TIMER] = 0
            antiGhostState[AntiGhostField.PREV_DISTANCE] = distance(ballPosition, target.getEyePosition())
            if antiGhostState[AntiGhostField.STALL_TIMER] >= 0.15:
                if ballDirectionRate < 4:
                    ballDirectionRate = 4
                    antiGhostRaised = true
            elif antiGhostRaised:
                ballDirectionRate = ballDirectionRateInit
                antiGhostRaised = false
        elif antiGhostMode == AntiGhost.STEER:
            if angleBetweenVectors(ballDirection, directionTowards(ballPosition, target.getEyePosition())) >= 35:
                antiGhostState = [distance(ballPosition, target.getEyePosition()), 0]
                if ballDirectionRate < 4:
                    ballDirectionRate = 4
                    antiGhostRaised = true
            elif antiGhostRaised:
                ballDirectionRate = ballDirectionRateInit
                antiGhostRaised = false
    else:
        antiGhostState = [999, 0]
        if antiGhostRaised:
            ballDirectionRate = ballDirectionRateInit
            antiGhostRaised = false
    wait(0.05, Wait.ABORT_WHEN_FALSE)
    if ruleCondition:
        loop()


rule "Ball Physics - general collision":
    @Condition ballIsOut == true
    @Condition (updateEveryFrame(isInLoS(ballPosition, ballPosition + ((ballDirection * (ballSpeed if ballMotion != BallMotion.ASTRO else 1)) * 0.033)))) == false
    @Condition ballPosition.y > 7.5
    @Condition (ballPosition.z > 20 or ballPosition.z < -20 or ballPosition.x > 20 or ballPosition.x < -20 or ballPosition.y > 0) == true
    
    #Used for phasingprotection in Ball/Target - collision check
    ballHitPosition = raycastHitPosition(ballPosition, ballPosition + ballDirection * ballSpeed * 0.066, null, getAllPlayers(), false)
    if isIsland or ballHitPosition.y < -0.5 and ballHitPosition.y > -3.5:
        CollisionSurfaceDistances = [distance(ballHitPosition, vect(20, ballHitPosition.y, ballHitPosition.z)), distance(ballHitPosition, vect(-20, ballHitPosition.y, ballHitPosition.z)), distance(ballHitPosition, vect(ballHitPosition.x, ballHitPosition.y, 20)), distance(ballHitPosition, vect(ballHitPosition.x, ballHitPosition.y, -20))]
        simpleIslandSideCollision()
    else:
        #Reflect around the normal of the surface hit above
        ballDirection -= 2 * dotProduct(ballDirection, raycastHitNormal(ballPosition, ballPosition + ballDirection * ballSpeed * 0.066, null, getAllPlayers(), false)) * raycastHitNormal(ballPosition, ballPosition + ballDirection * ballSpeed * 0.066, null, getAllPlayers(), false)
    if ballPhysicsMode == BallPhysics.EXPERIMENTAL:
        #Surface rebounds use their own tuning slider so wall/platform bounces
        #can read physically without resetting to the full player-deflect window.
        experimentalState[ExperimentalField.STEERING_RATE] = ballDirectionRate * experimentalTuning[ExperimentalTuning.SURFACE_HOMING]
        experimentalState[ExperimentalField.REDIRECT_AGE] = experimentalTuning[ExperimentalTuning.HOMING_HOLD] + (experimentalTuning[ExperimentalTuning.HOMING_RAMP] * (max(0, min(1, (experimentalTuning[ExperimentalTuning.SURFACE_HOMING] - experimentalTuning[ExperimentalTuning.HOMING_START]) / (max(0.01, 1 - experimentalTuning[ExperimentalTuning.HOMING_START]))))))
        antiGhostState = [999, 0]
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
    @Condition isIsland == true
    
    CollisionSurfaceDistances = [distance(ballPosition, vect(ballPosition.x, 0, ballPosition.z)), distance(ballPosition, vect(20, ballPosition.y, ballPosition.z)), distance(ballPosition, vect(-20, ballPosition.y, ballPosition.z)), distance(ballPosition, vect(ballPosition.x, ballPosition.y, 20)), distance(ballPosition, vect(ballPosition.x, ballPosition.y, -20))]
    simpleIslandCollision()
    if ballPhysicsMode == BallPhysics.EXPERIMENTAL:
        #Floor/platform rebounds use the same surface tuning slider as walls.
        experimentalState[ExperimentalField.STEERING_RATE] = ballDirectionRate * experimentalTuning[ExperimentalTuning.SURFACE_HOMING]
        experimentalState[ExperimentalField.REDIRECT_AGE] = experimentalTuning[ExperimentalTuning.HOMING_HOLD] + (experimentalTuning[ExperimentalTuning.HOMING_RAMP] * (max(0, min(1, (experimentalTuning[ExperimentalTuning.SURFACE_HOMING] - experimentalTuning[ExperimentalTuning.HOMING_START]) / (max(0.01, 1 - experimentalTuning[ExperimentalTuning.HOMING_START]))))))
        antiGhostState = [999, 0]
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


def simpleIslandSideCollision():
    @Name "Subroutine - simple island side collision"
    
    #Side-only collision helper for low/platform edge raycast hits.
    #Expects four distances: +X, -X, +Z, -Z.
    #Do not route this through simpleIslandCollision(), which expects
    #a five-surface layout with floor/top at index 0.
    CollisionSurfaceIndex = CollisionSurfaceDistances.index(sorted(CollisionSurfaceDistances)[0])
    if CollisionSurfaceIndex == 0:
        if ballDirection.x < 0:
            ballDirection *= vect(-1, 1, 1)
    elif CollisionSurfaceIndex == 1:
        if ballDirection.x > 0:
            ballDirection *= vect(-1, 1, 1)
    elif CollisionSurfaceIndex == 2:
        if ballDirection.z < 0:
            ballDirection *= vect(1, 1, -1)
    elif CollisionSurfaceIndex == 3:
        if ballDirection.z > 0:
            ballDirection *= vect(1, 1, -1)


rule "Ball Physics - chamber x collision":
    #This collision is the lazy way but its only for chamber so who cares
    @Condition __getCurrentMap__() == Map.WORKSHOP_CHAMBER
    @Condition ballIsOut == true
    @Condition (ballPosition.x + 0 > 20 or ballPosition.x < -20) == true
    
    if ballPosition.x + 0 > 20 and ballDirection.x > 0 or ballPosition.x < -20 and ballDirection.x < 0:
        ballDirection = vect(ballDirection.x * -1, ballDirection.y, ballDirection.z)
        playEffect(getAllPlayers(), DynamicEffect.BAD_EXPLOSION, Color.WHITE, ballPosition, 1)
    wait()
    if ruleCondition:
        loop()


rule "Ball Physics - chamber y collision":
    @Condition __getCurrentMap__() == Map.WORKSHOP_CHAMBER
    @Condition ballIsOut == true
    #v1.3.2 subtracted the two checks, "(y > 40) - (y < 0) == true", which is -1 below the floor, so only
    #the ceiling bounced. Fixed without a toggle: an obvious bug on a map nobody played.
    @Condition (ballPosition.y + 0 > 40 or ballPosition.y < 0) == true
    
    if ballPosition.y + 0 > 40 and ballDirection.y > 0 or ballPosition.y < 0 and ballDirection.y < 0:
        ballDirection = vect(ballDirection.x, ballDirection.y * -1, ballDirection.z)
        playEffect(getAllPlayers(), DynamicEffect.BAD_EXPLOSION, Color.WHITE, ballPosition, 1)
    wait()
    if ruleCondition:
        loop()


rule "Ball Physics - chamber z collision":
    @Condition __getCurrentMap__() == Map.WORKSHOP_CHAMBER
    @Condition ballIsOut == true
    @Condition (ballPosition.z + 0 > 20 or ballPosition.z < -20) == true
    
    if ballPosition.z + 0 > 20 and ballDirection.z > 0 or ballPosition.z < -20 and ballDirection.z < 0:
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
    @Condition isIsland == true
    
    ballDirection *= vect(1, 0, 1)
    playEffect(getAllPlayers(), DynamicEffect.RING_EXPLOSION, Color.WHITE, ballPosition, 2)
