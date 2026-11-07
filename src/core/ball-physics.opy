#Ball motion and map collision

def startBall():
    @Name "Ball behavior - start ball"
    
    ballIsOut = true
    async(startModernBall, AsyncBehavior.RESTART)


def stopBall():
    @Name "Ball behavior - stop ball"
    
    ballIsOut = false
    stopChasing(ballDirection)
    stopChasing(ballPosition)
    stopChasing(ballSpeed)


def startModernBall():
    @Name "Ball behavior - modern motion"
    
    chaseAtRate(ballPosition, ballPosition + ballDirection * ballSpeed, ballSpeed)
    chaseAtRate(ballSpeed, ballSpeedCap, ballAcceleration)
    chaseAtRate(ballDirection, directionTowards(ballPosition, target.getEyePosition()), updateEveryFrame(ballDirectionRate))


rule "Ball Physics - network resync":
    @Condition ballIsOut == true
    
    #Ported from Genji Ball vTec ("Hack: Fix BallPosition network sync"). Restarting the
    #ballDirection chase resends it to every client, so a client's copy of the ball can't
    #drift from the server's (the ball clipping through an orbiting player on their screen).
    chaseAtRate(ballDirection, directionTowards(ballPosition, target.getEyePosition()), updateEveryFrame(ballDirectionRate))
    #20 times a second, as in vTec
    wait(0.05, Wait.ABORT_WHEN_FALSE)
    if ruleCondition:
        loop()


rule "Ball Physics - general collision":
    @Condition ballIsOut == true
    @Condition (updateEveryFrame(isInLoS(ballPosition, ballPosition + ((ballDirection * ballSpeed) * 0.033)))) == false
    @Condition ballPosition.y > 7.5
    @Condition (ballPosition.z > 20 or ballPosition.z < -20 or ballPosition.x > 20 or ballPosition.x < -20 or ballPosition.y > 0) == true
    
    #Used for phasingprotection in Ball/Target - collision check
    ballHitPosition = raycastHitPosition(ballPosition, ballPosition + ballDirection * ballSpeed * 0.066, null, getAllPlayers(), false)
    CollisionSurfaceDistances = [distance(ballHitPosition, vect(20, ballHitPosition.y, ballHitPosition.z)), distance(ballHitPosition, vect(-20, ballHitPosition.y, ballHitPosition.z)), distance(ballHitPosition, vect(ballHitPosition.x, ballHitPosition.y, 20)), distance(ballHitPosition, vect(ballHitPosition.x, ballHitPosition.y, -20))]
    simpleIslandSideCollision()
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


rule "Ball Physics - water":
    #(Global.currentMap == Map(Workshop Island) || Global.currentMap == 196) == True;
    @Condition ballIsOut == true
    @Condition (ballPosition.x > 20 or ballPosition.x < -20 or ballPosition.z > 20 or ballPosition.z < -20) == true
    @Condition ballPosition.y < waterLevel
    @Condition ballDirection.y < 0
    
    ballDirection *= vect(1, 0, 1)
    playEffect(getAllPlayers(), DynamicEffect.RING_EXPLOSION, Color.WHITE, ballPosition, 2)
