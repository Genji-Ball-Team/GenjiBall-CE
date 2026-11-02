#Bots: the move library. A bot is a dummy whose botHook[BotHook.PRESET] isn't NONE.
#Everything a bot knows is in its own player variables (botState, botTuning, botShots), so
#the rules below work for any bot on any slot. How the parts fit together: docs/bots.md.
#
#Parts and the values they hand over:
#- brain ("Bots - incoming ball"): once per ball, decides the deflect (botHook DEFLECT), picks a
#  shot table row and aims (botState AIM, INTENT). Owns the facing while it aims.
#- after-shot moves (ghost dash, "Bots - edash"): ask for a dash with botDash (botHook DASH_WANTED
#  and DASH_DIRECTION, pressed by "Controls - Shorten deflect length").
#- camera, movement, jumping: run on their own, from the preset's numbers. The camera only
#  turns the bot while botState FACING is CAMERA.

#The ball counts as near the bot within this distance of its eyes
#!define botNearDistance (eventPlayer.botTuning[BotTuning.NEAR_FACTOR] * ballSpeed + eventPlayer.botTuning[BotTuning.NEAR_OFFSET])

#True for a player whose ball has moved on since the brain started on it
#!define botBallIsStale (eventPlayer.botState[BotField.THIS_BALL] != eventPlayer.botState[BotField.BALL_ID])

#Seconds before the ball reaches the bot, from its distance and speed. An estimate: the ball curves
#!define botTimeToContact ((distance(eventPlayer.getEyePosition(), ballPosition) - ballFeel[BallFeel.HIT_RADIUS]) / ballSpeed)

#firebuss's brad shot geometry: the ball 3-12 m away and flying across the line to the bot (60-120°),
#the enemy within 15 m and in line with the ball seen from the bot (under 15° or over 165°)
#!define botOrbitLine (eventPlayer.botState[BotField.ENEMY].isAlive() and distance(eventPlayer.getEyePosition(), ballPosition) >= 3 and distance(eventPlayer.getEyePosition(), ballPosition) <= 12 and abs(angleBetweenVectors(ballDirection, directionTowards(ballPosition, eventPlayer.getEyePosition())) - 90) < 30 and abs(angleBetweenVectors(directionTowards(eventPlayer.getEyePosition(), ballPosition), directionTowards(eventPlayer.getEyePosition(), eventPlayer.botState[BotField.ENEMY].getEyePosition())) - 90) > 75 and distance(eventPlayer, eventPlayer.botState[BotField.ENEMY]) <= 15)

#The nearest living human to the bot, or null
#!define botNearestHuman (sorted(getLivingPlayers(Team.ALL).filter(lambda x: not x.isDummy()), lambda x: distance(eventPlayer, x))[0])

#How far the bot is from the arena centre on x or z, whichever is more
#!define botFromCentre (max(abs(eventPlayer.getPosition().x - circleCenter.x), abs(eventPlayer.getPosition().z - circleCenter.z)))


rule "Bots - reset":
    #On spawn, revive and whenever the ball is gone: no pending dash, aim or stale ball
    @Event eachPlayer
    @Condition eventPlayer.botHook[BotHook.PRESET] != BotPreset.NONE
    @Condition eventPlayer.isAlive() == true
    @Condition ballIsOut == false

    eventPlayer.botState[BotField.BALL_ID] += 1
    eventPlayer.botState[BotField.FACING] = BotFacing.CAMERA
    eventPlayer.botHook[BotHook.DEFLECT] = BotDeflect.PRESS
    eventPlayer.botHook[BotHook.DASH_WANTED] = false
    eventPlayer.botHook[BotHook.DASH_DIRECTION] = null


rule "Bots - incoming ball":
    #The brain: runs once for each ball sent at the bot
    @Event eachPlayer
    @Condition eventPlayer.botHook[BotHook.PRESET] != BotPreset.NONE
    @Condition target == eventPlayer
    @Condition ballIsOut == true
    @Condition eventPlayer.isAlive() == true

    eventPlayer.botState[BotField.BALL_ID] += 1
    eventPlayer.botState[BotField.THIS_BALL] = eventPlayer.botState[BotField.BALL_ID]
    eventPlayer.botState[BotField.ROLL] = random.randint(0, 99)
    #Deflect part: decided before contact, read by "Collision - collision sub"
    if ballSpeed >= eventPlayer.botTuning[BotTuning.MISS_SPEED] and random.randint(0, 99) < eventPlayer.botTuning[BotTuning.MISS_CHANCE]:
        eventPlayer.botHook[BotHook.DEFLECT] = BotDeflect.MISS
    elif eventPlayer.botTuning[BotTuning.EARLY_LEAD] > 0:
        #Only its own early press counts, so a late one can fail
        eventPlayer.botHook[BotHook.DEFLECT] = BotDeflect.NONE
    else:
        eventPlayer.botHook[BotHook.DEFLECT] = BotDeflect.PRESS
    waitUntil(target != eventPlayer or eventPlayer.isDead() or ballIsOut == false or botBallIsStale or distance(eventPlayer.getEyePosition(), ballPosition) <= botNearDistance, 99999)
    if ballSpeed >= eventPlayer.botTuning[BotTuning.BALL_FAST] and eventPlayer.botTuning[BotTuning.REACTION_FAST_MAX] > 0:
        wait(random.uniform(eventPlayer.botTuning[BotTuning.REACTION_FAST_MIN], eventPlayer.botTuning[BotTuning.REACTION_FAST_MAX]))
    elif eventPlayer.botTuning[BotTuning.REACTION_MAX] > 0:
        wait(random.uniform(eventPlayer.botTuning[BotTuning.REACTION_MIN], eventPlayer.botTuning[BotTuning.REACTION_MAX]))
    #A dash asked for by "Bots - edash" owns the facing until it's pressed
    waitUntil(eventPlayer.botState[BotField.FACING] != BotFacing.DASH, 1)
    if target != eventPlayer or eventPlayer.isDead() or ballIsOut == false or botBallIsStale:
        return
    #Shot part: the first row whose condition holds and whose chance passes
    eventPlayer.botState[BotField.ENEMY] = botNearestHuman
    eventPlayer.botState[BotField.PASSED] = false
    for eventPlayer.botLoop in range(len(eventPlayer.botShots)):
        eventPlayer.botState[BotField.ROW] = eventPlayer.botShots[eventPlayer.botLoop]
        if eventPlayer.botState[BotField.ROLL] < eventPlayer.botState[BotField.ROW][BotShotColumn.CHANCE]:
            botCheckCondition()
            if eventPlayer.botState[BotField.PASSED]:
                break
    if not eventPlayer.botState[BotField.PASSED]:
        return
    eventPlayer.botState[BotField.INTENT] = eventPlayer.botState[BotField.ROW][BotShotColumn.INTENT]
    eventPlayer.botState[BotField.FACING] = BotFacing.AIM
    botAimShot()
    eventPlayer.startFacing(eventPlayer.botState[BotField.AIM], eventPlayer.botTuning[BotTuning.AIM_RATE])
    if eventPlayer.botState[BotField.ROW][BotShotColumn.SHOT] == BotShot.AWAY:
        #Turn first, then re-roll while anyone is in view
        wait(0)
        while target == eventPlayer and eventPlayer.isAlive() and ballIsOut and any([eventPlayer.isInViewAngle(x.getEyePosition(), 30) for x in getLivingPlayers(Team.ALL).exclude(eventPlayer)]):
            botAimShot()
            eventPlayer.startFacing(eventPlayer.botState[BotField.AIM], eventPlayer.botTuning[BotTuning.AIM_RATE])
            wait(0)
    #Early deflect: press it when the ball is EARLY_LEAD s away, at most one tick less than a deflect lasts
    if eventPlayer.botTuning[BotTuning.EARLY_LEAD] > 0:
        #Also waits out a dash (brad shot) or a lockout, so the press isn't lost
        while target == eventPlayer and eventPlayer.isAlive() and ballIsOut and (botTimeToContact > min(eventPlayer.botTuning[BotTuning.EARLY_LEAD], ballFeel[BallFeel.DEFLECT_WINDOW] - 0.016) or eventPlayer.isUsingAbility1() or not eventPlayer.canDeflect):
            wait(0)
        if target == eventPlayer and eventPlayer.isAlive() and ballIsOut and eventPlayer.botHook[BotHook.DEFLECT] != BotDeflect.MISS:
            eventPlayer.forceButtonPress(Button.ABILITY_2)
    waitUntil(target != eventPlayer or eventPlayer.isDead() or ballIsOut == false, 99999)
    if eventPlayer.isDead() or ballIsOut == false or botBallIsStale:
        return
    #After shot: a ball machine sets the speed it sends the ball at
    if eventPlayer.botTuning[BotTuning.MACHINE_SPEED] > 0 and prevTarget == eventPlayer:
        ballSpeed = min(ballSpeedCap, eventPlayer.botTuning[BotTuning.MACHINE_SPEED])
        #Astro moves the ball by ballDirection's length, which the deflect set from the old speed
        if ballMotion == BallMotion.ASTRO:
            ballDirection = normalize(ballDirection) * ballSpeed
    #After shot: safe dash, sideways toward the middle, after a shot at the enemy
    if eventPlayer.botTuning[BotTuning.SAFE_DASH] and eventPlayer.botState[BotField.INTENT] == BotIntent.AT_ENEMY and prevTarget == eventPlayer and eventPlayer.botState[BotField.ENEMY].isAlive() and not eventPlayer.isUsingAbility1() and eventPlayer.canDash and not eventPlayer.dashOnCooldown:
        #Horizontal direction to the enemy, turned 90°, toward the side nearer the middle
        eventPlayer.botState[BotField.AIM] = directionTowards(vect(0, 0, 0), vect(eventPlayer.botState[BotField.ENEMY].getPosition().x - eventPlayer.getPosition().x, 0, eventPlayer.botState[BotField.ENEMY].getPosition().z - eventPlayer.getPosition().z))
        eventPlayer.botState[BotField.AIM] = vect(eventPlayer.botState[BotField.AIM].z, 0, -eventPlayer.botState[BotField.AIM].x)
        if distance(eventPlayer.getPosition() + eventPlayer.botState[BotField.AIM] * 8, vect(circleCenter.x, eventPlayer.getPosition().y, circleCenter.z)) > distance(eventPlayer.getPosition() - eventPlayer.botState[BotField.AIM] * 8, vect(circleCenter.x, eventPlayer.getPosition().y, circleCenter.z)):
            eventPlayer.botState[BotField.AIM] *= -1
        #This dash replaces any edash asked for: drop it and take the facing back
        eventPlayer.botHook[BotHook.DASH_WANTED] = false
        eventPlayer.botHook[BotHook.DASH_DIRECTION] = null
        eventPlayer.botState[BotField.FACING] = BotFacing.AIM
        eventPlayer.setFacing(eventPlayer.botState[BotField.AIM], Relativity.TO_WORLD)
        eventPlayer.startFacing(eventPlayer.botState[BotField.AIM], 10000)
        wait(0.016)
        eventPlayer.forceButtonPress(Button.ABILITY_1)
        waitUntil(eventPlayer.isUsingAbility1() or eventPlayer.isDead(), 0.25)
        eventPlayer.botState[BotField.FACING] = BotFacing.CAMERA
        return
    eventPlayer.botState[BotField.FACING] = BotFacing.CAMERA
    #After shot: dash sideways away from the shot, inside WALK_EDGE (else toward a spot near the middle)
    if eventPlayer.botTuning[BotTuning.DASH_AWAY] > 0 and prevTarget == eventPlayer and (eventPlayer.botState[BotField.INTENT] == BotIntent.AT_ENEMY or random.randint(0, 99) < eventPlayer.botTuning[BotTuning.DASH_AWAY]):
        eventPlayer.botHook[BotHook.DASH_DIRECTION] = directionFromAngles(horizontalAngleOfDirection(eventPlayer.getFacingDirection()) + random.choice([-1, 1]) * random.randint(70, 120), 0)
        if abs(eventPlayer.getPosition().x + eventPlayer.botHook[BotHook.DASH_DIRECTION].x * 12 - circleCenter.x) > eventPlayer.botTuning[BotTuning.WALK_EDGE] or abs(eventPlayer.getPosition().z + eventPlayer.botHook[BotHook.DASH_DIRECTION].z * 12 - circleCenter.z) > eventPlayer.botTuning[BotTuning.WALK_EDGE]:
            eventPlayer.botHook[BotHook.DASH_DIRECTION] = directionTowards(eventPlayer.getPosition(), vect(circleCenter.x + random.uniform(-8, 8), eventPlayer.getPosition().y, circleCenter.z + random.uniform(-8, 8)))
        botDash()
    #After shot: ghost dash when the ball flies straight at the next player
    elif eventPlayer.botTuning[BotTuning.GHOST_DASH] and angleBetweenVectors(ballDirection * -1, directionTowards(target, ballPosition)) < 20 and distance(eventPlayer.getEyePosition(), ballPosition) < ballSpeed:
        #Facing Direction Of a vector, kept as zBozo had it
        eventPlayer.botHook[BotHook.DASH_DIRECTION] = evalOnce(ballDirection.getFacingDirection()) * -1
        botDash()


def botCheckCondition():
    @Name "Bots - check condition"
    #Sets botState PASSED for the condition of botState ROW

    switch eventPlayer.botState[BotField.ROW][BotShotColumn.CONDITION]:
        case BotCondition.ALWAYS:
            eventPlayer.botState[BotField.PASSED] = true
            break
        case BotCondition.I_CAN_DASH:
            eventPlayer.botState[BotField.PASSED] = eventPlayer.canDash and not eventPlayer.dashOnCooldown
            break
        case BotCondition.ENEMY_CANT_DASH:
            eventPlayer.botState[BotField.PASSED] = eventPlayer.botState[BotField.ENEMY] != null and (eventPlayer.botState[BotField.ENEMY].dashOnCooldown or not eventPlayer.botState[BotField.ENEMY].canDash or eventPlayer.botState[BotField.ENEMY].isUsingAbility1()) and eventPlayer.canDash and not eventPlayer.dashOnCooldown
            break
        case BotCondition.NO_ENEMY:
            eventPlayer.botState[BotField.PASSED] = eventPlayer.botState[BotField.ENEMY] == null
            break
        case BotCondition.ME_OFF_MAP:
            eventPlayer.botState[BotField.PASSED] = abs(eventPlayer.getPosition().x - circleCenter.x) > eventPlayer.botTuning[BotTuning.OFF_MAP] or abs(eventPlayer.getPosition().z - circleCenter.z) > eventPlayer.botTuning[BotTuning.OFF_MAP]
            break
        case BotCondition.ENEMY_OFF_MAP:
            eventPlayer.botState[BotField.PASSED] = eventPlayer.botState[BotField.ENEMY] != null and (abs(eventPlayer.botState[BotField.ENEMY].getPosition().x - circleCenter.x) > eventPlayer.botTuning[BotTuning.OFF_MAP] or abs(eventPlayer.botState[BotField.ENEMY].getPosition().z - circleCenter.z) > eventPlayer.botTuning[BotTuning.OFF_MAP])
            break
        case BotCondition.AIR_NEAR_EDGE:
            eventPlayer.botState[BotField.PASSED] = not eventPlayer.isOnGround() and botFromCentre > eventPlayer.botTuning[BotTuning.EDGE]
            break
        case BotCondition.ENEMY_FAR:
            eventPlayer.botState[BotField.PASSED] = eventPlayer.botState[BotField.ENEMY] != null and distance(eventPlayer, eventPlayer.botState[BotField.ENEMY]) > eventPlayer.botTuning[BotTuning.ENEMY_FAR]
            break
        case BotCondition.ALL_FAR:
            eventPlayer.botState[BotField.PASSED] = all([distance(eventPlayer, x) > eventPlayer.botTuning[BotTuning.ENEMY_FAR] for x in getLivingPlayers(Team.ALL).exclude(eventPlayer)])
            break
        case BotCondition.BALL_FAST:
            eventPlayer.botState[BotField.PASSED] = ballSpeed >= eventPlayer.botTuning[BotTuning.BALL_FAST]
            break
        case BotCondition.ORBIT_LINE:
            eventPlayer.botState[BotField.PASSED] = botOrbitLine
            break


def botAimShot():
    @Name "Bots - aim shot"
    #Sets botState AIM, a world direction, for the shot of botState ROW. Shots that need the enemy
    #only appear after a row that catches NO_ENEMY

    switch eventPlayer.botState[BotField.ROW][BotShotColumn.SHOT]:
        case BotShot.DOWN:
            eventPlayer.botState[BotField.AIM] = Vector.DOWN
            break
        case BotShot.UP:
            eventPlayer.botState[BotField.AIM] = Vector.UP
            break
        case BotShot.AT_ENEMY:
            eventPlayer.botState[BotField.AIM] = directionTowards(eventPlayer.getEyePosition(), eventPlayer.botState[BotField.ENEMY].getEyePosition())
            botAimError()
            break
        case BotShot.AT_ANYONE:
            #Nobody else alive: down
            if len(getLivingPlayers(Team.ALL).exclude(eventPlayer)) == 0:
                eventPlayer.botState[BotField.AIM] = Vector.DOWN
                break
            eventPlayer.botState[BotField.AIM] = directionTowards(eventPlayer.getEyePosition(), random.choice(getLivingPlayers(Team.ALL).exclude(eventPlayer)).getEyePosition())
            botAimError()
            break
        case BotShot.FLOOR_BEHIND_ENEMY:
            eventPlayer.botState[BotField.AIM] = directionTowards(eventPlayer.getEyePosition(), eventPlayer.botState[BotField.ENEMY].getPosition() + directionTowards(vect(0, 0, 0), vect(eventPlayer.botState[BotField.ENEMY].getPosition().x - eventPlayer.getPosition().x, 0, eventPlayer.botState[BotField.ENEMY].getPosition().z - eventPlayer.getPosition().z)) * 6 + vect(0, -1, 0))
            break
        case BotShot.CORNER_NEAR_ENEMY:
            eventPlayer.botState[BotField.AIM] = directionTowards(eventPlayer.getEyePosition(), vect(circleCenter.x + (eventPlayer.botTuning[BotTuning.OFF_MAP] if eventPlayer.botState[BotField.ENEMY].getPosition().x > circleCenter.x else -eventPlayer.botTuning[BotTuning.OFF_MAP]), 1.5, circleCenter.z + (eventPlayer.botTuning[BotTuning.OFF_MAP] if eventPlayer.botState[BotField.ENEMY].getPosition().z > circleCenter.z else -eventPlayer.botTuning[BotTuning.OFF_MAP])))
            break
        case BotShot.WALL_NEAR_ENEMY:
            if abs(eventPlayer.botState[BotField.ENEMY].getPosition().x - circleCenter.x) > abs(eventPlayer.botState[BotField.ENEMY].getPosition().z - circleCenter.z):
                eventPlayer.botState[BotField.AIM] = directionTowards(eventPlayer.getEyePosition(), vect(circleCenter.x + (eventPlayer.botTuning[BotTuning.OFF_MAP] if eventPlayer.botState[BotField.ENEMY].getPosition().x > circleCenter.x else -eventPlayer.botTuning[BotTuning.OFF_MAP]), 1.5, eventPlayer.botState[BotField.ENEMY].getPosition().z))
            else:
                eventPlayer.botState[BotField.AIM] = directionTowards(eventPlayer.getEyePosition(), vect(eventPlayer.botState[BotField.ENEMY].getPosition().x, 1.5, circleCenter.z + (eventPlayer.botTuning[BotTuning.OFF_MAP] if eventPlayer.botState[BotField.ENEMY].getPosition().z > circleCenter.z else -eventPlayer.botTuning[BotTuning.OFF_MAP])))
            break
        case BotShot.UNDER_MAP:
            eventPlayer.botState[BotField.AIM] = directionTowards(eventPlayer.getEyePosition(), vect(circleCenter.x + (eventPlayer.getPosition().x - circleCenter.x) * 3, -20, circleCenter.z + (eventPlayer.getPosition().z - circleCenter.z) * 3))
            break
        case BotShot.RANDOM:
            eventPlayer.botState[BotField.AIM] = vect(random.randint(-360, 360), random.randint(-360, 360), random.randint(-360, 360))
            break
        case BotShot.AWAY:
            eventPlayer.botState[BotField.AIM] = directionFromAngles(horizontalAngleOfDirection(directionTowards(eventPlayer.getEyePosition(), eventPlayer.getRealPlayerClosestToReticle(Team.ALL).getEyePosition())) + random.choice([-1, 1]) * random.randint(45, 90), random.randint(-90, 90))
            break
        case BotShot.RANDOM_DOWN:
            eventPlayer.botState[BotField.AIM] = directionFromAngles(horizontalAngleOfDirection(eventPlayer.getFacingDirection()) + random.randint(-60, 60), random.randint(-55, -25))
            break
        case BotShot.SHALLOW_BOUNCE:
            eventPlayer.botState[BotField.AIM] = directionFromAngles(horizontalAngleOfDirection(eventPlayer.getFacingDirection()) + random.randint(-110, 110), random.randint(-40, -15))
            break
        case BotShot.STEEP_BOUNCE:
            eventPlayer.botState[BotField.AIM] = directionFromAngles(horizontalAngleOfDirection(eventPlayer.getFacingDirection()) + random.randint(-110, 110), random.randint(-85, -45))
            break
        case BotShot.FLOOR_TO_MIDDLE:
            eventPlayer.botState[BotField.AIM] = directionFromAngles(horizontalAngleOfDirection(directionTowards(eventPlayer.getPosition(), vect(circleCenter.x, eventPlayer.getPosition().y, circleCenter.z))) + random.uniform(-45, 45), random.uniform(-90, -45))
            break
        case BotShot.LONG_TO_MIDDLE:
            eventPlayer.botState[BotField.AIM] = directionFromAngles(horizontalAngleOfDirection(directionTowards(eventPlayer.getPosition(), vect(circleCenter.x, eventPlayer.getPosition().y, circleCenter.z))) + random.uniform(-20, 20), random.uniform(-25, -10))
            break


def botAimError():
    @Name "Bots - aim error"
    #Turns botState AIM by up to the preset's aim error, sideways and up or down

    eventPlayer.botLoop = eventPlayer.botTuning[BotTuning.AIM_ERROR_SLOW] if ballSpeed < eventPlayer.botTuning[BotTuning.AIM_FAST_SPEED] else eventPlayer.botTuning[BotTuning.AIM_ERROR_FAST]
    eventPlayer.botState[BotField.AIM] = directionFromAngles(horizontalAngleOfDirection(eventPlayer.botState[BotField.AIM]) + random.uniform(-eventPlayer.botLoop, eventPlayer.botLoop), verticalAngleOfDirection(eventPlayer.botState[BotField.AIM]) + random.uniform(-eventPlayer.botLoop, eventPlayer.botLoop))


def botDash():
    @Name "Bots - dash"
    #Shared move "dash toward X": set botHook DASH_DIRECTION first. Faces it now, and
    #"Controls - Shorten deflect length" presses the dash at the end of this deflect

    eventPlayer.botHook[BotHook.DASH_WANTED] = true
    eventPlayer.botState[BotField.FACING] = BotFacing.DASH
    eventPlayer.setFacing(eventPlayer.botHook[BotHook.DASH_DIRECTION], Relativity.TO_WORLD)
    eventPlayer.startFacing(eventPlayer.botHook[BotHook.DASH_DIRECTION], 10000)


rule "Bots - dash pressed":
    #"Controls - Shorten deflect length" cleared DASH_WANTED: the camera turns the bot again
    @Event eachPlayer
    @Condition eventPlayer.botHook[BotHook.PRESET] != BotPreset.NONE
    @Condition eventPlayer.botHook[BotHook.DASH_WANTED] == false
    @Condition eventPlayer.botState[BotField.FACING] == BotFacing.DASH

    eventPlayer.botState[BotField.FACING] = BotFacing.CAMERA


rule "Bots - drop a late dash":
    #A dash asked for after the deflect ended would fire on the next deflect: drop it
    @Event eachPlayer
    @Condition eventPlayer.botHook[BotHook.PRESET] != BotPreset.NONE
    @Condition eventPlayer.botHook[BotHook.DASH_WANTED] == true
    @Condition eventPlayer.isUsingAbility2() == false

    eventPlayer.botHook[BotHook.DASH_WANTED] = false
    eventPlayer.botHook[BotHook.DASH_DIRECTION] = null


rule "Bots - edash":
    #After shot: dash toward the ball when it comes straight back at the bot, or at the next player while they deflect or dash
    @Event eachPlayer
    @Condition eventPlayer.botHook[BotHook.PRESET] != BotPreset.NONE
    @Condition eventPlayer.botTuning[BotTuning.EDASH] == true
    @Condition ballIsOut == true
    @Condition eventPlayer.isUsingAbility2() == true

    waitUntil(eventPlayer != target and (target.isUsingAbility1() or target.isUsingAbility2()), 0.25)
    if ballIsOut == false or eventPlayer.isDead() or not eventPlayer.isUsingAbility2():
        return
    if eventPlayer == target:
        if angleBetweenVectors(ballDirection, directionTowards(ballPosition, eventPlayer.getEyePosition())) < 20:
            eventPlayer.botHook[BotHook.DASH_DIRECTION] = directionTowards(eventPlayer.getEyePosition(), ballPosition)
            botDash()
    elif eventPlayer == prevTarget:
        if (target.isUsingAbility1() or target.isUsingAbility2()) and angleBetweenVectors(ballDirection, directionTowards(ballPosition, target.getEyePosition())) < 20:
            eventPlayer.botHook[BotHook.DASH_DIRECTION] = directionTowards(eventPlayer.getEyePosition(), ballPosition)
            botDash()


rule "Bots - dash guard":
    #Drops the end-of-deflect dash while another player within DASH_GUARD m has their dash ready
    @Event eachPlayer
    @Condition eventPlayer.botHook[BotHook.PRESET] != BotPreset.NONE
    @Condition eventPlayer.botTuning[BotTuning.DASH_GUARD] > 0
    @Condition eventPlayer.isUsingAbility2() == true

    #One tick before "Controls - Shorten deflect length" presses it
    wait(ballFeel[BallFeel.DEFLECT_WINDOW] - 0.016)
    if eventPlayer.botHook[BotHook.DASH_WANTED] and any([distance(eventPlayer, x) < eventPlayer.botTuning[BotTuning.DASH_GUARD] and x.canDash and not x.dashOnCooldown for x in getLivingPlayers(Team.ALL).exclude(eventPlayer)]):
        eventPlayer.botHook[BotHook.DASH_WANTED] = false
        eventPlayer.botHook[BotHook.DASH_DIRECTION] = null


rule "Bots - brad shot":
    #At high speed, with the ball coming round and the enemy close and in line: dash at the enemy, so the ball goes into their face
    @Event eachPlayer
    @Condition eventPlayer.botHook[BotHook.PRESET] != BotPreset.NONE
    @Condition eventPlayer.botTuning[BotTuning.BRAD_SPEED] > 0
    @Condition eventPlayer.botState[BotField.FACING] == BotFacing.AIM
    @Condition target == eventPlayer
    @Condition ballIsOut == true
    @Condition ballSpeed >= eventPlayer.botTuning[BotTuning.BRAD_SPEED]
    @Condition eventPlayer.isAlive() == true
    @Condition eventPlayer.isUsingAbility1() == false
    @Condition eventPlayer.isUsingAbility2() == false
    @Condition eventPlayer.hasStatus(Status.STUNNED) == false
    @Condition eventPlayer.canDash == true
    @Condition eventPlayer.dashOnCooldown == false
    @Condition botOrbitLine == true

    #The brain's aim follows botState AIM, so this also becomes the shot
    eventPlayer.botState[BotField.AIM] = directionTowards(eventPlayer.getEyePosition(), eventPlayer.botState[BotField.ENEMY].getEyePosition())
    eventPlayer.setFacing(eventPlayer.botState[BotField.AIM], Relativity.TO_WORLD)
    eventPlayer.startFacing(eventPlayer.botState[BotField.AIM], 10000)
    wait(0.05)
    eventPlayer.forceButtonPress(Button.ABILITY_1)


rule "Bots - punish":
    #After a human deflects a fast ball, the bot turns to the nearest player until its own ball comes
    @Event eachPlayer
    @Condition eventPlayer.botHook[BotHook.PRESET] != BotPreset.NONE
    @Condition eventPlayer.botTuning[BotTuning.PUNISH_SPEED] > 0
    @Condition ballIsOut == true
    @Condition ballSpeed >= eventPlayer.botTuning[BotTuning.PUNISH_SPEED]
    @Condition any([x.isUsingAbility2() and not x.isDummy() for x in getAllPlayers()]) == true
    @Condition eventPlayer.isAlive() == true
    @Condition eventPlayer.hasStatus(Status.STUNNED) == false

    wait(random.uniform(0.2, 0.8))
    if eventPlayer.botState[BotField.FACING] != BotFacing.CAMERA or eventPlayer.isDead() or len(getLivingPlayers(Team.ALL).exclude(eventPlayer)) == 0:
        return
    eventPlayer.botState[BotField.FACING] = BotFacing.PUNISH
    eventPlayer.startFacing(directionTowards(eventPlayer.getEyePosition(), sorted(getLivingPlayers(Team.ALL).exclude(eventPlayer), lambda x: distance(eventPlayer, x))[0].getEyePosition()), 10000)
    waitUntil(target == eventPlayer or eventPlayer.botState[BotField.FACING] != BotFacing.PUNISH, 1)
    waitUntil(target != eventPlayer or eventPlayer.isDead() or eventPlayer.botState[BotField.FACING] != BotFacing.PUNISH, 4)
    if eventPlayer.botState[BotField.FACING] == BotFacing.PUNISH:
        eventPlayer.botState[BotField.FACING] = BotFacing.CAMERA


rule "Bots - ace dash":
    #As the ball reaches a player close by, ACE_CHANCE % of the time: dash along where that player looks
    @Event eachPlayer
    @Condition eventPlayer.botHook[BotHook.PRESET] != BotPreset.NONE
    @Condition eventPlayer.botTuning[BotTuning.ACE_CHANCE] > 0
    @Condition eventPlayer.botState[BotField.FACING] == BotFacing.CAMERA
    @Condition ballIsOut == true
    @Condition target != eventPlayer
    @Condition eventPlayer.isAlive() == true
    @Condition eventPlayer.isUsingAbility1() == false
    @Condition eventPlayer.isUsingAbility2() == false
    @Condition eventPlayer.hasStatus(Status.STUNNED) == false
    @Condition eventPlayer.canDash == true
    @Condition eventPlayer.dashOnCooldown == false
    @Condition distance(eventPlayer, target) <= 10
    @Condition distance(target.getEyePosition(), ballPosition) <= ballSpeed * 0.3

    if random.randint(0, 99) >= eventPlayer.botTuning[BotTuning.ACE_CHANCE]:
        #No ace dash for this ball
        waitUntil(target == eventPlayer or eventPlayer.isDead(), 5)
        return
    eventPlayer.botState[BotField.FACING] = BotFacing.ACE
    eventPlayer.setFacing(evalOnce(target.getFacingDirection()), Relativity.TO_WORLD)
    eventPlayer.startFacing(evalOnce(target.getFacingDirection()), 10000)
    wait(0.05)
    #The brain took over: the ball came to the bot meanwhile
    if eventPlayer.botState[BotField.FACING] != BotFacing.ACE or target == eventPlayer or eventPlayer.isDead():
        return
    eventPlayer.forceButtonPress(Button.ABILITY_1)
    wait(0.05)
    waitUntil(not eventPlayer.isUsingAbility1() or eventPlayer.isDead(), 1)
    if eventPlayer.botState[BotField.FACING] == BotFacing.ACE:
        eventPlayer.botState[BotField.FACING] = BotFacing.CAMERA


rule "Bots - camera":
    #Looks between the ball and its target while the ball is far
    @Event eachPlayer
    @Condition eventPlayer.botHook[BotHook.PRESET] != BotPreset.NONE
    @Condition eventPlayer.botState[BotField.FACING] == BotFacing.CAMERA
    @Condition eventPlayer.botTuning[BotTuning.CAMERA] == BotCamera.BETWEEN
    @Condition distance(eventPlayer.getEyePosition(), ballPosition) >= botNearDistance
    @Condition eventPlayer.isAlive() == true
    @Condition eventPlayer.isUsingAbility1() == false
    @Condition eventPlayer.isUsingAbility2() == false
    @Condition eventPlayer.hasStatus(Status.STUNNED) == false

    eventPlayer.startFacing(directionTowards(eventPlayer.getEyePosition(), (ballPosition + target.getEyePosition()) / 2), eventPlayer.botTuning[BotTuning.CAMERA_RATE])


rule "Bots - human camera":
    #Looks at the ball, or the nearest human between balls, a little off and at a varying speed
    @Event eachPlayer
    @Condition eventPlayer.botHook[BotHook.PRESET] != BotPreset.NONE
    @Condition eventPlayer.botState[BotField.FACING] == BotFacing.CAMERA
    @Condition eventPlayer.botTuning[BotTuning.CAMERA] == BotCamera.HUMAN
    @Condition eventPlayer.isAlive() == true
    @Condition eventPlayer.isUsingAbility1() == false
    @Condition eventPlayer.isUsingAbility2() == false
    @Condition eventPlayer.hasStatus(Status.STUNNED) == false

    eventPlayer.startFacing(directionTowards(eventPlayer.getEyePosition(), (ballPosition if ballIsOut else botNearestHuman.getEyePosition()) + evalOnce(vect(random.uniform(-1.5, 1.5), random.uniform(-1, 1), random.uniform(-1.5, 1.5)))), evalOnce(random.uniform(eventPlayer.botTuning[BotTuning.CAMERA_RATE] / 2, eventPlayer.botTuning[BotTuning.CAMERA_RATE])))
    wait(random.uniform(0.2, 0.5))
    if ruleCondition:
        loop()


rule "Bots - spin near the ball":
    #While the ball is near and the bot's dash is down, it looks around at random, or down (or up)
    @Event eachPlayer
    @Condition eventPlayer.botHook[BotHook.PRESET] != BotPreset.NONE
    @Condition eventPlayer.botTuning[BotTuning.SPIN_NEAR_BALL] != BotSpin.NONE
    @Condition eventPlayer.botState[BotField.FACING] == BotFacing.CAMERA
    @Condition distance(eventPlayer.getEyePosition(), ballPosition) <= botNearDistance
    @Condition ballIsOut == true
    @Condition eventPlayer.isAlive() == true
    @Condition eventPlayer.getAbilityCooldown(Button.ABILITY_1) != 0

    if eventPlayer.botTuning[BotTuning.SPIN_NEAR_BALL] == BotSpin.RANDOM:
        eventPlayer.setFacing(vect(random.uniform(-360, 360), random.uniform(-360, 360), random.uniform(-360, 360)), Relativity.TO_WORLD)
        eventPlayer.startFacing(vect(random.uniform(-360, 360), random.uniform(-360, 360), random.randint(-360, 360)), 10000)
    elif random.randint(0, 1) == 0 and all([distance(eventPlayer, x) > eventPlayer.botTuning[BotTuning.ENEMY_FAR] for x in getLivingPlayers(Team.ALL).exclude(eventPlayer)]):
        eventPlayer.startFacing(Vector.UP, 10000)
    else:
        eventPlayer.startFacing(Vector.DOWN, 10000)
    wait(0.3)
    if ruleCondition:
        loop()


rule "Bots - movement":
    @Event eachPlayer
    @Condition eventPlayer.botHook[BotHook.PRESET] != BotPreset.NONE
    @Condition eventPlayer.botTuning[BotTuning.MOVEMENT] == BotMovement.ROAM
    @Condition isGameInProgress() == true
    @Condition eventPlayer.isAlive() == true

    #Past WALK_EDGE: walk back to the middle
    if botFromCentre > eventPlayer.botTuning[BotTuning.WALK_EDGE]:
        eventPlayer.stopThrottleInDirection()
        eventPlayer.startThrottleInDirection(directionTowards(eventPlayer.getPosition(), circleCenter), 1, Relativity.TO_WORLD, Throttle.REPLACE_EXISTING, ThrottleReeval.NONE)
        wait(random.uniform(1, 1.5))
    #ROAM's odd walking: a world direction on a throttle relative to the bot's facing
    elif eventPlayer != target:
        eventPlayer.startThrottleInDirection(directionTowards(eventPlayer.getPosition(), target), 0.8, Relativity.TO_PLAYER, Throttle.REPLACE_EXISTING, ThrottleReeval.NONE)
        wait(random.uniform(0.5, 3))
    else:
        eventPlayer.startThrottleInDirection(directionTowards(eventPlayer.getPosition(), circleCenter + vect(random.uniform(-15, 15), 0, random.uniform(-15, 15))), 0.8, Relativity.TO_PLAYER, Throttle.REPLACE_EXISTING, ThrottleReeval.NONE)
        wait(random.uniform(0.5, 3))
    if ruleCondition:
        loop()


rule "Bots - circling":
    #Strafes round the nearest human, keeping CIRCLE_NEAR to CIRCLE_FAR m, with short pauses like a player
    @Event eachPlayer
    @Condition eventPlayer.botHook[BotHook.PRESET] != BotPreset.NONE
    @Condition eventPlayer.botTuning[BotTuning.MOVEMENT] == BotMovement.CIRCLE
    @Condition isGameInProgress() == true
    @Condition eventPlayer.isAlive() == true

    if botFromCentre > eventPlayer.botTuning[BotTuning.WALK_EDGE]:
        eventPlayer.startThrottleInDirection(directionTowards(eventPlayer.getPosition(), vect(circleCenter.x, eventPlayer.getPosition().y, circleCenter.z)), 1, Relativity.TO_WORLD, Throttle.REPLACE_EXISTING, ThrottleReeval.NONE)
        wait(random.uniform(0.5, 1))
    elif random.randint(0, 99) < 15:
        eventPlayer.stopThrottleInDirection()
        wait(random.uniform(0.2, 0.6))
    else:
        eventPlayer.botState[BotField.MOVE_ENEMY] = botNearestHuman
        if not eventPlayer.botState[BotField.MOVE_ENEMY].isAlive():
            #Nobody to circle: wander
            eventPlayer.startThrottleInDirection(vect(random.uniform(-1, 1), 0, random.uniform(-1, 1)), random.uniform(0.5, 1), Relativity.TO_WORLD, Throttle.REPLACE_EXISTING, ThrottleReeval.NONE)
            wait(random.uniform(0.5, 1.5))
        else:
            eventPlayer.botState[BotField.MOVE_DIR] = directionTowards(vect(0, 0, 0), vect(eventPlayer.botState[BotField.MOVE_ENEMY].getPosition().x - eventPlayer.getPosition().x, 0, eventPlayer.botState[BotField.MOVE_ENEMY].getPosition().z - eventPlayer.getPosition().z))
            #Sideways is MOVE_DIR turned 90°, to a random side; it also closes in or backs off when out of the band
            if distance(vect(eventPlayer.getPosition().x, 0, eventPlayer.getPosition().z), vect(eventPlayer.botState[BotField.MOVE_ENEMY].getPosition().x, 0, eventPlayer.botState[BotField.MOVE_ENEMY].getPosition().z)) > eventPlayer.botTuning[BotTuning.CIRCLE_FAR]:
                eventPlayer.botState[BotField.MOVE_DIR] = eventPlayer.botState[BotField.MOVE_DIR] * 0.7 + vect(eventPlayer.botState[BotField.MOVE_DIR].z, 0, -eventPlayer.botState[BotField.MOVE_DIR].x) * random.choice([-1, 1]) * 0.7
            elif distance(vect(eventPlayer.getPosition().x, 0, eventPlayer.getPosition().z), vect(eventPlayer.botState[BotField.MOVE_ENEMY].getPosition().x, 0, eventPlayer.botState[BotField.MOVE_ENEMY].getPosition().z)) < eventPlayer.botTuning[BotTuning.CIRCLE_NEAR]:
                eventPlayer.botState[BotField.MOVE_DIR] = eventPlayer.botState[BotField.MOVE_DIR] * -0.7 + vect(eventPlayer.botState[BotField.MOVE_DIR].z, 0, -eventPlayer.botState[BotField.MOVE_DIR].x) * random.choice([-1, 1]) * 0.7
            else:
                eventPlayer.botState[BotField.MOVE_DIR] = vect(eventPlayer.botState[BotField.MOVE_DIR].z, 0, -eventPlayer.botState[BotField.MOVE_DIR].x) * random.choice([-1, 1])
            eventPlayer.startThrottleInDirection(directionTowards(vect(0, 0, 0), eventPlayer.botState[BotField.MOVE_DIR]), random.uniform(0.6, 1), Relativity.TO_WORLD, Throttle.REPLACE_EXISTING, ThrottleReeval.NONE)
            wait(random.uniform(0.4, 1.6))
    if ruleCondition:
        loop()


rule "Bots - strafing":
    #Moves like a player who isn't watching anyone: 15 % stops, 35 % strafes, 25 % forward or back, 25 % diagonal
    @Event eachPlayer
    @Condition eventPlayer.botHook[BotHook.PRESET] != BotPreset.NONE
    @Condition eventPlayer.botTuning[BotTuning.MOVEMENT] == BotMovement.STRAFE
    @Condition isGameInProgress() == true
    @Condition eventPlayer.isAlive() == true

    if botFromCentre > eventPlayer.botTuning[BotTuning.WALK_EDGE]:
        eventPlayer.startThrottleInDirection(directionTowards(eventPlayer.getPosition(), vect(circleCenter.x + random.uniform(-7, 7), eventPlayer.getPosition().y, circleCenter.z + random.uniform(-7, 7))), random.uniform(0.7, 1), Relativity.TO_WORLD, Throttle.REPLACE_EXISTING, ThrottleReeval.NONE)
        wait(random.uniform(0.5, 1))
    else:
        eventPlayer.botState[BotField.MOVE_DIR] = random.randint(0, 99)
        if eventPlayer.botState[BotField.MOVE_DIR] < 15:
            eventPlayer.stopThrottleInDirection()
            wait(random.uniform(0.2, 0.7))
        elif eventPlayer.botState[BotField.MOVE_DIR] < 50:
            eventPlayer.startThrottleInDirection(vect(random.choice([-1, 1]), 0, 0), random.uniform(0.6, 1), Relativity.TO_PLAYER, Throttle.REPLACE_EXISTING, ThrottleReeval.NONE)
            wait(random.uniform(0.4, 1.6))
        elif eventPlayer.botState[BotField.MOVE_DIR] < 75:
            eventPlayer.startThrottleInDirection(vect(0, 0, random.choice([-1, 1])), random.uniform(0.6, 1), Relativity.TO_PLAYER, Throttle.REPLACE_EXISTING, ThrottleReeval.NONE)
            wait(random.uniform(0.3, 1.2))
        else:
            eventPlayer.startThrottleInDirection(vect(random.choice([-1, 1]), 0, random.choice([-1, 1])), random.uniform(0.6, 1), Relativity.TO_PLAYER, Throttle.REPLACE_EXISTING, ThrottleReeval.NONE)
            wait(random.uniform(0.3, 1.4))
    if ruleCondition:
        loop()


rule "Bots - pinned":
    #Forced to its spot, again every 1.25 s, so a teleport (the final duel) doesn't move it for long
    @Event eachPlayer
    @Condition eventPlayer.botHook[BotHook.PRESET] != BotPreset.NONE
    @Condition eventPlayer.botTuning[BotTuning.MOVEMENT] == BotMovement.PINNED
    @Condition eventPlayer.isAlive() == true

    #25 m, or less in an arena smaller than 27 m so the edge rules leave it alone, and at least
    #1.5 m past the centre's off-limits size so "Map restrictions - put out center" does too
    eventPlayer.startForcingPosition(circleCenter + eventPlayer.botTuning[BotTuning.PIN_SPOT] * max((CenterOffLimitsSize + 1.5) / magnitude(eventPlayer.botTuning[BotTuning.PIN_SPOT]), min(25, SphereSize - 2)), false)
    wait(1.25)
    if ruleCondition:
        loop()


rule "Bots - jump before impact":
    #As the ball comes in: IMPACT_JUMP % of the time, and always near the edge, so a shot can go under the map
    @Event eachPlayer
    @Condition eventPlayer.botHook[BotHook.PRESET] != BotPreset.NONE
    @Condition eventPlayer.botTuning[BotTuning.IMPACT_JUMP] > 0
    @Condition target == eventPlayer
    @Condition ballIsOut == true
    @Condition eventPlayer.isAlive() == true
    @Condition eventPlayer.isOnGround() == true
    @Condition eventPlayer.isUsingAbility1() == false
    @Condition distance(eventPlayer.getEyePosition(), ballPosition) <= eventPlayer.botTuning[BotTuning.IMPACT_FACTOR] * ballSpeed + eventPlayer.botTuning[BotTuning.IMPACT_OFFSET]

    if random.randint(0, 99) < eventPlayer.botTuning[BotTuning.IMPACT_JUMP] or botFromCentre > eventPlayer.botTuning[BotTuning.EDGE]:
        eventPlayer.forceButtonPress(Button.JUMP)
        wait(0.3)
        eventPlayer.forceButtonPress(Button.JUMP)
    wait(1)


rule "Bots - jumping":
    @Event eachPlayer
    @Condition eventPlayer.botHook[BotHook.PRESET] != BotPreset.NONE
    @Condition eventPlayer.botTuning[BotTuning.JUMP_WAIT_MAX] > 0
    @Condition ballIsOut == true

    eventPlayer.forceButtonPress(Button.JUMP)
    if random.randint(0, 99) < eventPlayer.botTuning[BotTuning.JUMP_DOUBLE]:
        wait(0.35)
        eventPlayer.forceButtonPress(Button.JUMP)
        wait(random.uniform(eventPlayer.botTuning[BotTuning.DOUBLE_WAIT_MIN], eventPlayer.botTuning[BotTuning.DOUBLE_WAIT_MAX]))
    else:
        wait(random.uniform(eventPlayer.botTuning[BotTuning.JUMP_WAIT_MIN], eventPlayer.botTuning[BotTuning.JUMP_WAIT_MAX]))
    loop()
