#zBozo, the practice bot

rule "zBozo - spawn":
    #Currently only able to decide between 0 or 1 (false/true) bozo bots
    @Condition bozo_Bot > 0
    
    while bozo_Bot > 0:
        bozo_Bot--
        createDummy(Hero.GENJI, Team.ALL, 12 + bozo_Bot, null, hostPlayer)
        wait(0.1)
    bozo_Bot = true
    bozoHasJumped = false
    OrbitTolerance = 0
    BozoTracing = false


rule "zBozo - name":
    @Event eachPlayer
    @Condition bozo_Bot == true
    @Condition eventPlayer.isDummy() == true
    
    eventPlayer.startForcingName("zSh4d0Ws bozo")


rule "zBozo - face target while deflecting":
    @Event eachPlayer
    @Condition bozo_Bot == true
    @Condition distance(eventPlayer.getEyePosition(), ballPosition.getPosition()) <= 2 * (ballSpeed / 20)
    @Condition target == eventPlayer
    @Condition eventPlayer.isDummy() == true
    @Condition ballIsOut == true
    @Condition eventPlayer.isAlive() == true
    @Condition eventPlayer.isUsingAbility1() == false
    @Condition eventPlayer.isUsingAbility2() == false
    @Condition eventPlayer.hasStatus(Status.STUNNED) == false
    @Condition bozoIsGhostDashing != true
    
    if eventPlayer.canDash == true:
        if random.randint(0, 8) == 0:
            if ballSpeed < 80:
                eventPlayer.startFacing(directionFromAngles(horizontalAngleOfDirection(directionTowards(eventPlayer.getEyePosition(), evalOnce(random.choice(getLivingPlayers(Team.ALL).exclude(eventPlayer))).getEyePosition())) + evalOnce(random.randint(-35, 35)), evalOnce(random.randint(-35, 35))), 10000)
            else:
                eventPlayer.startFacing(directionFromAngles(horizontalAngleOfDirection(directionTowards(eventPlayer.getEyePosition(), evalOnce(random.choice(getLivingPlayers(Team.ALL).exclude(eventPlayer))).getEyePosition())) + evalOnce(random.randint(-10, 10)), evalOnce(random.randint(-10, 10))), 10000)
        else:
            eventPlayer.startFacing(vect(random.randint(-360, 360), random.randint(-360, 360), random.randint(-360, 360)), 10000)
    else:
        if random.randint(0, 1) == 0:
            eventPlayer.startFacing(directionFromAngles(horizontalAngleOfDirection(directionTowards(eventPlayer.getEyePosition(), eventPlayer.getPlayerClosestToReticle(Team.ALL).getEyePosition())) + evalOnce(random.randint(-90, -45)), evalOnce(random.randint(-90, 90))), 10000)
        else:
            eventPlayer.startFacing(directionFromAngles(horizontalAngleOfDirection(directionTowards(eventPlayer.getEyePosition(), eventPlayer.getPlayerClosestToReticle(Team.ALL).getEyePosition())) + evalOnce(random.randint(45, 90)), evalOnce(random.randint(-90, 90))), 10000)
        wait(0)
        if getLivingPlayers(Team.ALL).exclude(eventPlayer).any(lambda x: eventPlayer.isInViewAngle(x.getEyePosition(), 30)):
            loop()
    waitUntil(target != eventPlayer or eventPlayer.isDead(), 99999)
    if angleBetweenVectors(ballDirection * -1, directionTowards(target, ballPosition)) < 20:
        #if distance(eventPlayer.getEyePosition(), target.getEyePosition()) < ballSpeed * 0.3:
        #bozoWillEdash = true
        #bigMessage(getAllPlayers(), "EDASH")
        if distance(eventPlayer.getEyePosition(), ballPosition) < ballSpeed:
            bozoWillGhostDash = true
    wait(0.3)
    if ruleCondition:
        loop()


rule "zBozo - face the Ball":
    @Event eachPlayer
    @Condition bozo_Bot == true
    @Condition eventPlayer.isDummy() == true
    @Condition distance(eventPlayer.getEyePosition(), ballPosition) >= 2 * (ballSpeed / 20)
    @Condition eventPlayer.isAlive() == true
    @Condition bozoIsGhostDashing != true
    @Condition eventPlayer.isUsingAbility1() == false
    @Condition eventPlayer.isUsingAbility2() == false
    @Condition eventPlayer.hasStatus(Status.STUNNED) == false
    
    eventPlayer.startFacing(directionTowards(eventPlayer.getEyePosition(), (ballPosition + target.getEyePosition()) / 2), 1000)


rule "zBozo - behavior changes after round":
    @Condition roundEndCall == true
    
    bozoBehaviorModes = random.choice([2])
    if bozoBehaviorModes == 1:
        bozoAggression = 10
    elif bozoBehaviorModes == 2:
        bozoAggression = 5


rule "zBozo - Movement reworked":
    @Event eachPlayer
    @Condition bozo_Bot == true
    @Condition isGameInProgress() == true
    @Condition eventPlayer.isDummy() == true
    @Condition bozoWillOrbit != true
    @Condition eventPlayer.isAlive() == true
    
    #@Condition (eventPlayer.getPosition().x < 18 or eventPlayer.getPosition().x > -18 or eventPlayer.getPosition().z < 18 or eventPlayer.getPosition().z > -18) == true
    if eventPlayer.getPosition().x > 18 or eventPlayer.getPosition().x < -18 or eventPlayer.getPosition().z > 18 or eventPlayer.getPosition().z < -18:
        eventPlayer.stopThrottleInDirection()
        eventPlayer.startThrottleInDirection(directionTowards(eventPlayer.getPosition(), vect(0, 0, 0)), 1, Relativity.TO_WORLD, Throttle.REPLACE_EXISTING, ThrottleReeval.NONE)
        #bigMessage(getAllPlayers(), "ANTIFLOAT")
        wait(random.uniform(1, 1.5))
        if ruleCondition:
            loop()
    if eventPlayer != target:
        if distance(eventPlayer.getPosition(), target.getPosition()) >= bozoAggression:
            eventPlayer.startThrottleInDirection(directionTowards(eventPlayer.getPosition(), target), 0.8, Relativity.TO_PLAYER, Throttle.REPLACE_EXISTING, ThrottleReeval.NONE)
            wait(random.uniform(0.5, 3))
            if ruleCondition:
                loop()
        else:
            eventPlayer.stopThrottleInDirection()
            eventPlayer.startThrottleInDirection(evalOnce(directionTowards(target.getEyePosition(), eventPlayer.getEyePosition())), 1, Relativity.TO_WORLD)
            wait(random.uniform(1, 1.5))
            if ruleCondition:
                loop()
    else:
        eventPlayer.startThrottleInDirection(directionTowards(eventPlayer.getPosition(), vect(random.uniform(-15, 15), 0, random.uniform(-15, 15))), 0.8, Relativity.TO_PLAYER, Throttle.REPLACE_EXISTING, ThrottleReeval.NONE)
        wait(random.uniform(0.5, 3))
        if ruleCondition:
            loop()


rule "zBozo - Let him Orbit":
    @Event eachPlayer
    @Condition bozo_Bot == true
    @Condition eventPlayer.isDummy() == true
    @Condition ballIsOut == true
    @Condition distance(eventPlayer.getPosition(), ballPosition) < 5 + ballSpeed / 30
    @Condition bozoWillOrbit == true
    
    IsOrbiting = true
    eventPlayer.startThrottleInDirection((ballDirection * -1 + directionTowards(ballPosition, eventPlayer.getEyePosition()) * 2) / 2, 1, Relativity.TO_WORLD)
    #eventPlayer.startThrottleInDirection(random.choice([vect(180, 0, 0), vect(-180, 0, 0)]), 1, Relativity.TO_PLAYER)
    OrbitTolerance = 999
    #bigMessage(getAllPlayers(), "ORBIT")
    waitUntil(target != eventPlayer or eventPlayer.isDead(), 99999)
    eventPlayer.stopThrottleInDirection()
    IsOrbiting = false
    bozoWillOrbit = 0


rule "zBozo - bozos move being chosen":
    @Event eachPlayer
    @Condition eventPlayer.isDummy() == true
    @Condition eventPlayer == target
    
    if bozoBehaviorModes == 1:
        if random.randint(1, 10) == 5:
            bozoWillOrbit = true


rule "zBozo - Edash when needed":
    @Event eachPlayer
    @Condition bozo_Bot == true
    @Condition eventPlayer.isDummy() == true
    @Condition ballIsOut == true
    @Condition eventPlayer.isUsingAbility2() == true
    
    #@Condition (eventPlayer.isUsingAbility2() or bozoWillEdash) == true
    waitUntil(eventPlayer != target and (target.isUsingAbility1() or target.isUsingAbility2()), 0.25)
    if eventPlayer == target:
        if angleBetweenVectors(ballDirection, directionTowards(ballPosition, eventPlayer.getEyePosition())) < 20:
            bozoWillEdash = true
            eventPlayer.setFacing(evalOnce(directionTowards(eventPlayer.getEyePosition(), ballPosition)), Relativity.TO_WORLD)
            eventPlayer.startFacing(evalOnce(directionTowards(eventPlayer.getEyePosition(), ballPosition)), 10000)
            #bigMessage(getAllPlayers(), "EDASHING")
            waitUntil(eventPlayer.isHoldingButton(Button.ABILITY_1) or eventPlayer.isDead(), 1)
            bozoWillEdash = false
    elif eventPlayer == prevTarget:
        if target.isUsingAbility1() or target.isUsingAbility2():
            if angleBetweenVectors(ballDirection, directionTowards(ballPosition, target.getEyePosition())) < 20:
                bozoWillEdash = true
                eventPlayer.setFacing(evalOnce(directionTowards(eventPlayer.getEyePosition(), ballPosition)), Relativity.TO_WORLD)
                eventPlayer.startFacing(evalOnce(directionTowards(eventPlayer.getEyePosition(), ballPosition)), 10000)
                #bigMessage(getAllPlayers(), "EDASHING")
                waitUntil(eventPlayer.isHoldingButton(Button.ABILITY_1) or eventPlayer.isDead(), 1)
                bozoWillEdash = false


rule "zBozo - Jumping":
    @Event eachPlayer
    @Condition bozo_Bot == true
    @Condition eventPlayer.isDummy() == true
    @Condition ballIsOut == true
    
    botJumping = random.choice([1, 2])
    if botJumping == 2:
        eventPlayer.forceButtonPress(Button.JUMP)
        wait(0.35)
        eventPlayer.forceButtonPress(Button.JUMP)
        wait(random.randint(5, 15))
    else:
        eventPlayer.forceButtonPress(Button.JUMP)
        wait(random.randint(3, 7))
    loop()


rule "zBozo - GhostDash":
    @Event eachPlayer
    @Condition bozo_Bot == true
    @Condition eventPlayer.isDummy() == true
    @Condition ballIsOut == true
    @Condition bozoWillGhostDash == true
    
    bozoIsGhostDashing = true
    if target == eventPlayer:
        if distance(eventPlayer.getEyePosition(), ballPosition) < ballSpeed * 0.3:
            eventPlayer.setFacing(evalOnce(ballDirection.getFacingDirection()), Relativity.TO_WORLD)
            eventPlayer.startFacing(evalOnce(ballDirection.getFacingDirection()), 10000)
    else:
        eventPlayer.setFacing(evalOnce(ballDirection.getFacingDirection()) * -1, Relativity.TO_WORLD)
        eventPlayer.startFacing(evalOnce(ballDirection.getFacingDirection()) * -1, 1000)
        waitUntil(eventPlayer.isHoldingButton(Button.ABILITY_1) or eventPlayer.isDead(), 99999)
    bozoIsGhostDashing = false


rule "zBozo - randomize facing near ball":
    @Event eachPlayer
    @Condition bozo_Bot == true
    @Condition distance(eventPlayer.getEyePosition(), ballPosition.getPosition()) <= 2 * (ballSpeed / 20)
    #@Condition target != eventPlayer
    @Condition eventPlayer.isDummy() == true
    @Condition ballIsOut == true
    @Condition eventPlayer.isAlive() == true
    #@Condition eventPlayer.isUsingAbility2() == false
    @Condition bozoIsGhostDashing != true
    @Condition eventPlayer.getAbilityCooldown(Button.ABILITY_1) != 0
    
    eventPlayer.setFacing(vect(random.uniform(-360, 360), random.uniform(-360, 360), random.uniform(-360, 360)), Relativity.TO_WORLD)
    eventPlayer.startFacing(vect(random.uniform(-360, 360), random.uniform(-360, 360), random.randint(-360, 360)), 10000)
    wait(0.3)
    if ruleCondition:
        loop()
