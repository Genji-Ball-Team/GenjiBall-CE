#Out-of-bounds, water and island boundaries

rule "Map restrictions - put out center":
    @Event eachPlayer
    #No arena on an unsupported map (circleCenter and SphereSize are unset)
    @Condition MAP_UNSUPPORTED == false
    @Condition distance(eventPlayer.getPosition(), circleCenter) < CenterOffLimitsSize + 0.5
    
    eventPlayer.applyImpulse(directionTowards(circleCenter, eventPlayer), customTuning[CustomTuning.CENTER_PUSH], Relativity.TO_WORLD, Impulse.CANCEL_CONTRARY_MOTION)
    eventPlayer.applyImpulse(Vector.UP, 1.5, Relativity.TO_WORLD, Impulse.INCORPORATE_CONTRARY_MOTION)
    wait(0.25)
    if ruleCondition:
        loop()


rule "Map restrictions - player dashes too far out of bounds":
    @Event eachPlayer
    #No arena on an unsupported map (circleCenter and SphereSize are unset)
    @Condition MAP_UNSUPPORTED == false
    @Condition distance(eventPlayer.getPosition(), vect(circleCenter.x, eventPlayer.getPosition().y, circleCenter.z)) > SphereSize + customTuning[CustomTuning.OUT_MARGIN]
    
    #Workshop Island Fix
    #@Condition isIsland == false
    eventPlayer.setStatusEffect(null, Status.ROOTED, customTuning[CustomTuning.OUT_ROOT])
    eventPlayer.applyImpulse(vect(directionTowards(eventPlayer.getPosition(), circleCenter).x, 0, directionTowards(eventPlayer.getPosition(), circleCenter).z), customTuning[CustomTuning.OUT_PUSH], Relativity.TO_WORLD, Impulse.CANCEL_CONTRARY_MOTION)
    eventPlayer.applyImpulse(Vector.UP, 3, Relativity.TO_WORLD, Impulse.CANCEL_CONTRARY_MOTION)
    bigMessage(eventPlayer, "Do not dash out of the arena!")


rule "Map restrictions - push to circle":
    @Event eachPlayer
    #No arena on an unsupported map (circleCenter and SphereSize are unset)
    @Condition MAP_UNSUPPORTED == false
    @Condition distance(eventPlayer.getPosition(), vect(circleCenter.x, eventPlayer.getPosition().y, circleCenter.z)) > SphereSize - customTuning[CustomTuning.EDGE_MARGIN]
    #Workshop Island Fix
    @Condition isIsland == false
    
    eventPlayer.applyImpulse(vect(directionTowards(eventPlayer.getPosition(), circleCenter).x, 0, directionTowards(eventPlayer.getPosition(), circleCenter).z), customTuning[CustomTuning.EDGE_PUSH], Relativity.TO_WORLD, Impulse.CANCEL_CONTRARY_MOTION)
    eventPlayer.applyImpulse(Vector.UP, 3, Relativity.TO_WORLD, Impulse.INCORPORATE_CONTRARY_MOTION)
    wait(0.25)
    if ruleCondition:
        loop()


rule "Map restrictions - player falls off Workshop Island":
    @Event eachPlayer
    @Condition isIsland == true
    @Condition eventPlayer.getPosition().y < -0.5
    
    #A MAN HAS FALLEN INTO THE LAKE IN WORKSHOP ISLAND! START THE NEW RESCUE RULE! HEY! BUILD THE NEW WORSHOP RULE, AND OFF TO THE RESCUE! PREPARE THE CONDITION, TELEPORT THE PLAYER, AND MAKE THE RESCUE! THE NEW 2.3.0 UPDATE FROM OVERWATCH WORKSHOP!
    if eventPlayer.isDead():
        eventPlayer.teleport(circleCenter + vect(random.randint(-customTuning[CustomTuning.SPAWN_SPREAD], customTuning[CustomTuning.SPAWN_SPREAD]), customTuning[CustomTuning.SPAWN_HEIGHT], random.randint(-customTuning[CustomTuning.SPAWN_SPREAD], customTuning[CustomTuning.SPAWN_SPREAD])))
        if eventPlayer == target:
            if ballIsOut:
                deleteBall()
    wait(0.5)
    if ruleCondition:
        loop()


rule "Map restrictions - water surface 1":
    @Event eachPlayer
    @Condition updateEveryFrame(eventPlayer.getPosition().y < 0) == true
    @Condition eventPlayer.getPosition().y >= -0.15
    @Condition eventPlayer.getVelocity().y <= 0
    @Condition eventPlayer.isAlive() == true
    @Condition eventPlayer.isUsingAbility1() == false
    #Workshop Island Fix
    @Condition isIsland == true
    
    if eventPlayer.getPosition().x < 20.25 and eventPlayer.getPosition().x > -20.25 and eventPlayer.getPosition().z < 20.25 and eventPlayer.getPosition().z > -20.25:
        return
    eventPlayer.currentGravity = 0
    eventPlayer.setGravity(0)
    if eventPlayer.getVelocity().y < 0:
        eventPlayer.applyImpulse(Vector.DOWN, 0.001, Relativity.TO_WORLD, Impulse.CANCEL_CONTRARY_MOTION)
        eventPlayer.applyImpulse(Vector.UP, 0.001, Relativity.TO_WORLD, Impulse.CANCEL_CONTRARY_MOTION)
    wait(0.1)
    if ruleCondition:
        loop()


rule "Map restrictions - water surface 2":
    @Event eachPlayer
    @Condition eventPlayer.getPosition().y < -0.15
    @Condition eventPlayer.getPosition().y >= -1.25
    @Condition eventPlayer.getVelocity().y <= 0
    @Condition eventPlayer.isAlive() == true
    @Condition eventPlayer.isUsingAbility1() == false
    #Workshop Island Fix
    @Condition isIsland == true
    
    if eventPlayer.getPosition().x < 20.25 and eventPlayer.getPosition().x > -20.25 and eventPlayer.getPosition().z < 20.25 and eventPlayer.getPosition().z > -20.25:
        return
    eventPlayer.currentGravity = 0
    eventPlayer.setGravity(0)
    eventPlayer.applyImpulse(Vector.UP, 1, Relativity.TO_WORLD, Impulse.CANCEL_CONTRARY_MOTION)
    wait(0.1)
    if ruleCondition:
        loop()


rule "Map restrictions - water resistance":
    @Event eachPlayer
    @Condition (eventPlayer.getPosition().x > 35 or eventPlayer.getPosition().x < -35 or eventPlayer.getPosition().z > 35 or eventPlayer.getPosition().z < -35) == true
    @Condition eventPlayer.getPosition().y <= 0
    @Condition eventPlayer.getPosition().y >= -1.5
    @Condition eventPlayer.isAlive() == true
    @Condition eventPlayer.isUsingAbility1() == false
    @Condition isIsland == true
    
    if eventPlayer.getPosition().x > 37 or eventPlayer.getPosition().x < -37 or eventPlayer.getPosition().z > 37 or eventPlayer.getPosition().z < -37:
        eventPlayer.applyImpulse(directionTowards(eventPlayer.getPosition(), circleCenter) * vect(1, 0, 1), 10, Relativity.TO_WORLD, Impulse.CANCEL_CONTRARY_MOTION)
        wait(0.1)
    else:
        eventPlayer.applyImpulse(directionTowards(eventPlayer.getPosition(), circleCenter) * vect(1, 0, 1), 5, Relativity.TO_WORLD, Impulse.INCORPORATE_CONTRARY_MOTION)
        wait(0.05)
    if ruleCondition:
        loop()


rule "Map restrictions - water":
    @Event eachPlayer
    @Condition eventPlayer.getPosition().y < -1.5
    @Condition eventPlayer.isAlive() == true
    #Workshop Island Fix
    @Condition isIsland == true
    
    #"water ledge fix" (off by default, player feel): under the island, push straight out instead, so the push below
    #can't pin players under the ledge. 21 is the 20.25 m edge plus a margin for the player's width.
    if addOnSettings[AddOnSetting.WATER_LEDGE_FIX] and abs(eventPlayer.getPosition().x) < 21 and abs(eventPlayer.getPosition().z) < 21:
        eventPlayer.applyImpulse(directionTowards(circleCenter, eventPlayer) * vect(1, 0, 1), 2, Relativity.TO_WORLD, Impulse.INCORPORATE_CONTRARY_MOTION)
    else:
        #v1.3.2 checked "x < 35 or x > -35 or ..." here, which is always true, so this runs everywhere below -1.5.
        #Prevents people from going under the ledge on Workshop Island, which caused ball to go into floor.  Used to be an annoying stunkill
        eventPlayer.applyImpulse(Vector.UP, 2, Relativity.TO_WORLD, Impulse.CANCEL_CONTRARY_MOTION)
        eventPlayer.applyImpulse(directionTowards(eventPlayer, circleCenter), 2, Relativity.TO_WORLD, Impulse.INCORPORATE_CONTRARY_MOTION)
    if eventPlayer.getPosition().x > 35 or eventPlayer.getPosition().x < -35 or eventPlayer.getPosition().z > 35 or eventPlayer.getPosition().z < -35:
        eventPlayer.applyImpulse(directionTowards(eventPlayer, circleCenter), 3, Relativity.TO_WORLD, Impulse.INCORPORATE_CONTRARY_MOTION)
        eventPlayer.applyImpulse(Vector.UP, 0.3, Relativity.TO_WORLD, Impulse.CANCEL_CONTRARY_MOTION)
    wait()
    if ruleCondition:
        loop()


rule "Map restrictions - water leave":
    @Event eachPlayer
    @Condition eventPlayer.getPosition().y >= 0
    @Condition eventPlayer.isAlive() == true
    #Workshop Island Fix
    @Condition isIsland == true
    @Condition eventPlayer.currentGravity != gravity
    
    eventPlayer.setGravity(gravity)
    eventPlayer.currentGravity = gravity


rule "Map restrictions - island enter":
    @Event eachPlayer
    @Condition eventPlayer.getPosition().x < 20.25
    @Condition eventPlayer.getPosition().x > -20.25
    @Condition eventPlayer.getPosition().z < 20.25
    @Condition eventPlayer.getPosition().z > -20.25
    @Condition eventPlayer.isAlive() == true
    #Workshop Island Fix
    @Condition isIsland == true
    
    eventPlayer.currentGravity = gravity
    eventPlayer.setGravity(gravity)


def alert():
    @Name "Subroutine - Round end call"
    
    totalRounds--
    roundsUntilBreak--
