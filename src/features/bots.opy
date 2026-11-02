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
    else:
        eventPlayer.botHook[BotHook.DEFLECT] = BotDeflect.PRESS
    waitUntil(target != eventPlayer or eventPlayer.isDead() or distance(eventPlayer.getEyePosition(), ballPosition) <= botNearDistance, 99999)
    if eventPlayer.botTuning[BotTuning.REACTION_MAX] > 0:
        wait(random.uniform(eventPlayer.botTuning[BotTuning.REACTION_MIN], eventPlayer.botTuning[BotTuning.REACTION_MAX]))
    if target != eventPlayer or eventPlayer.isDead() or botBallIsStale:
        return
    #Shot part: the first row whose condition holds and whose chance passes
    eventPlayer.botState[BotField.ENEMY] = sorted(getLivingPlayers(Team.ALL).filter(lambda x: not x.isDummy()), lambda x: distance(eventPlayer, x))[0]
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
        while target == eventPlayer and eventPlayer.isAlive() and any([eventPlayer.isInViewAngle(x.getEyePosition(), 30) for x in getLivingPlayers(Team.ALL).exclude(eventPlayer)]):
            botAimShot()
            eventPlayer.startFacing(eventPlayer.botState[BotField.AIM], eventPlayer.botTuning[BotTuning.AIM_RATE])
            wait(0)
    #Early deflect: press it when the ball is EARLY_LEAD s away, at most one tick less than a deflect lasts
    if eventPlayer.botTuning[BotTuning.EARLY_LEAD] > 0:
        while target == eventPlayer and eventPlayer.isAlive() and botTimeToContact > min(eventPlayer.botTuning[BotTuning.EARLY_LEAD], ballFeel[BallFeel.DEFLECT_WINDOW] - 0.016):
            wait(0)
        if target == eventPlayer and eventPlayer.canDeflect and eventPlayer.botHook[BotHook.DEFLECT] != BotDeflect.MISS:
            eventPlayer.forceButtonPress(Button.ABILITY_2)
    waitUntil(target != eventPlayer or eventPlayer.isDead() or ballIsOut == false, 99999)
    if eventPlayer.isDead() or ballIsOut == false or botBallIsStale:
        return
    eventPlayer.botState[BotField.FACING] = BotFacing.CAMERA
    #After shot: ghost dash when the ball flies straight at the next player
    if eventPlayer.botTuning[BotTuning.GHOST_DASH] and angleBetweenVectors(ballDirection * -1, directionTowards(target, ballPosition)) < 20 and distance(eventPlayer.getEyePosition(), ballPosition) < ballSpeed:
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
            eventPlayer.botState[BotField.PASSED] = not eventPlayer.isOnGround() and max(abs(eventPlayer.getPosition().x - circleCenter.x), abs(eventPlayer.getPosition().z - circleCenter.z)) > eventPlayer.botTuning[BotTuning.EDGE]
            break
        case BotCondition.ENEMY_FAR:
            eventPlayer.botState[BotField.PASSED] = eventPlayer.botState[BotField.ENEMY] != null and distance(eventPlayer, eventPlayer.botState[BotField.ENEMY]) > eventPlayer.botTuning[BotTuning.ENEMY_FAR]
            break
        case BotCondition.BALL_FAST:
            eventPlayer.botState[BotField.PASSED] = ballSpeed >= eventPlayer.botTuning[BotTuning.BALL_FAST]
            break
        case BotCondition.ORBIT_LINE:
            #firebuss's numbers: ball 3-12 m away and flying across the line to the bot (60-120°), the enemy within 15 m and in line with the ball (under 15° or over 165°)
            eventPlayer.botState[BotField.PASSED] = eventPlayer.botState[BotField.ENEMY] != null and distance(eventPlayer, ballPosition) >= 3 and distance(eventPlayer, ballPosition) <= 12 and abs(angleBetweenVectors(ballDirection, directionTowards(ballPosition, eventPlayer)) - 90) <= 30 and abs(angleBetweenVectors(directionTowards(eventPlayer, ballPosition), directionTowards(eventPlayer, eventPlayer.botState[BotField.ENEMY])) - 90) > 75 and distance(eventPlayer, eventPlayer.botState[BotField.ENEMY]) < 15
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
    if eventPlayer == target:
        if angleBetweenVectors(ballDirection, directionTowards(ballPosition, eventPlayer.getEyePosition())) < 20:
            eventPlayer.botHook[BotHook.DASH_DIRECTION] = directionTowards(eventPlayer.getEyePosition(), ballPosition)
            botDash()
    elif eventPlayer == prevTarget:
        if (target.isUsingAbility1() or target.isUsingAbility2()) and angleBetweenVectors(ballDirection, directionTowards(ballPosition, target.getEyePosition())) < 20:
            eventPlayer.botHook[BotHook.DASH_DIRECTION] = directionTowards(eventPlayer.getEyePosition(), ballPosition)
            botDash()


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


rule "Bots - spin near the ball":
    #While the ball is near and the bot's dash is down, it looks around at random
    @Event eachPlayer
    @Condition eventPlayer.botHook[BotHook.PRESET] != BotPreset.NONE
    @Condition eventPlayer.botTuning[BotTuning.SPIN_NEAR_BALL] == true
    @Condition eventPlayer.botState[BotField.FACING] == BotFacing.CAMERA
    @Condition distance(eventPlayer.getEyePosition(), ballPosition) <= botNearDistance
    @Condition ballIsOut == true
    @Condition eventPlayer.isAlive() == true
    @Condition eventPlayer.getAbilityCooldown(Button.ABILITY_1) != 0

    eventPlayer.setFacing(vect(random.uniform(-360, 360), random.uniform(-360, 360), random.uniform(-360, 360)), Relativity.TO_WORLD)
    eventPlayer.startFacing(vect(random.uniform(-360, 360), random.uniform(-360, 360), random.randint(-360, 360)), 10000)
    wait(0.3)
    if ruleCondition:
        loop()


rule "Bots - movement":
    @Event eachPlayer
    @Condition eventPlayer.botHook[BotHook.PRESET] != BotPreset.NONE
    @Condition eventPlayer.botTuning[BotTuning.MOVEMENT] == BotMovement.ROAM
    @Condition isGameInProgress() == true
    @Condition eventPlayer.isAlive() == true

    #Off the map: walk back to the middle
    if abs(eventPlayer.getPosition().x - circleCenter.x) > eventPlayer.botTuning[BotTuning.OFF_MAP] or abs(eventPlayer.getPosition().z - circleCenter.z) > eventPlayer.botTuning[BotTuning.OFF_MAP]:
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


rule "Bots - jumping":
    @Event eachPlayer
    @Condition eventPlayer.botHook[BotHook.PRESET] != BotPreset.NONE
    @Condition ballIsOut == true

    eventPlayer.forceButtonPress(Button.JUMP)
    if random.randint(0, 99) < eventPlayer.botTuning[BotTuning.JUMP_DOUBLE]:
        wait(0.35)
        eventPlayer.forceButtonPress(Button.JUMP)
        wait(random.uniform(eventPlayer.botTuning[BotTuning.DOUBLE_WAIT_MIN], eventPlayer.botTuning[BotTuning.DOUBLE_WAIT_MAX]))
    else:
        wait(random.uniform(eventPlayer.botTuning[BotTuning.JUMP_WAIT_MIN], eventPlayer.botTuning[BotTuning.JUMP_WAIT_MAX]))
    loop()
