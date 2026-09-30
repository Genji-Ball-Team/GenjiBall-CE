#Optional special abilities

rule "GENJI BALL ABILITIES :OOOOOO - selection":
    @Event eachPlayer
    @Condition eventPlayer.isHoldingButton(Button.RELOAD) == true
    @Condition eventPlayer.isDummy() == false
    @Condition isGameInProgress() == true
    @Condition ballIsOut == false
    @Condition Abilities == true
    
    waitUntil(not eventPlayer.isHoldingButton(Button.RELOAD), 0.4)
    if eventPlayer.isHoldingButton(Button.RELOAD):
        if eventPlayer.SpecialAbility > 3:
            eventPlayer.SpecialAbility = 1
        else:
            eventPlayer.SpecialAbility++
        bigMessage(eventPlayer, "Ability changed")


rule "Gb Abilities - Description":
    @Event eachPlayer
    @Condition Abilities == true
    
    if eventPlayer.Abilitydesc == 1:
        goto lbl_0
    wait(4)
    hudSubheader(eventPlayer.filter(lambda x: x.simpleHUD == 0), "change ability after round: hold [{0}] current: [{1}]".format(inputBindingString(Button.RELOAD), eventPlayer.SpecialAbility), HudPosition.RIGHT, -132, Color.WHITE, HudReeval.VISIBILITY_AND_STRING)
    hudSubheader(eventPlayer.filter(lambda x: x.simpleHUD == 0), "Ability cooldown: [{0}]".format(eventPlayer.Abilitycooldown), HudPosition.RIGHT, -134, Color.WHITE, HudReeval.VISIBILITY_AND_STRING)
    eventPlayer.Abilitydesc = 1
    lbl_0:
    if eventPlayer.SpecialAbility == 1:
        hudSubheader(eventPlayer.filter(lambda x: x.simpleHUD == 0), "Ability: 1. Super Jump: Press [{0}] and [{1}] to jump high".format(inputBindingString(Button.CROUCH), inputBindingString(Button.JUMP)), HudPosition.RIGHT, -133, Color.WHITE, HudReeval.VISIBILITY_AND_STRING)
        waitUntil(eventPlayer.SpecialAbility != 1, 99999)
        destroyHudText(getLastCreatedText())
        loop()
    elif eventPlayer.SpecialAbility == 2:
        hudSubheader(eventPlayer.filter(lambda x: x.simpleHUD == 0), "Ability: 2. Switch Target: Press [{0}] to become the target. Double click to make it not beam you.".format(inputBindingString(Button.ULTIMATE)), HudPosition.RIGHT, -133, Color.WHITE, HudReeval.VISIBILITY_AND_STRING)
        waitUntil(eventPlayer.SpecialAbility != 2, 99999)
        destroyHudText(getLastCreatedText())
        loop()
    elif eventPlayer.SpecialAbility == 3:
        hudSubheader(eventPlayer.filter(lambda x: x.simpleHUD == 0), "Ability: 3. Blink: Press [{0}] to teleport into the direction youre looking at. You will pass through the ball.".format(inputBindingString(Button.ULTIMATE)), HudPosition.RIGHT, -133, Color.WHITE, HudReeval.VISIBILITY_AND_STRING)
        waitUntil(eventPlayer.SpecialAbility != 3, 99999)
        destroyHudText(getLastCreatedText())
        loop()
    elif eventPlayer.SpecialAbility == 4:
        hudSubheader(eventPlayer.filter(lambda x: x.simpleHUD == 0), "Ability: 4. Critical slash: Press [{0}] to make your next hit powerful, speeding up the ball way more.".format(inputBindingString(Button.ULTIMATE)), HudPosition.RIGHT, -133, Color.WHITE, HudReeval.VISIBILITY_AND_STRING)
        waitUntil(eventPlayer.SpecialAbility != 4, 99999)
        destroyHudText(getLastCreatedText())
        loop()
    elif eventPlayer.SpecialAbility == 5:
        hudSubheader(eventPlayer.filter(lambda x: x.simpleHUD == 0), "Ability: 3.", HudPosition.RIGHT, -133, Color.WHITE, HudReeval.VISIBILITY_AND_STRING)
        waitUntil(eventPlayer.SpecialAbility != 5, 99999)
        destroyHudText(getLastCreatedText())
        loop()
    elif eventPlayer.SpecialAbility == 6:
        hudSubheader(eventPlayer.filter(lambda x: x.simpleHUD == 0), "Ability: 3.", HudPosition.RIGHT, -133, Color.WHITE, HudReeval.VISIBILITY_AND_STRING)
        waitUntil(eventPlayer.SpecialAbility != 6, 99999)
        destroyHudText(getLastCreatedText())
        loop()
    else:
        hudSubheader(eventPlayer.filter(lambda x: x.simpleHUD == 0), "Ability: Invalid Ability", HudPosition.RIGHT, -133, Color.WHITE, HudReeval.VISIBILITY_AND_STRING)
        waitUntil(eventPlayer.SpecialAbility <= 6, 99999)
        destroyHudText(getLastCreatedText())
        loop()


rule "Gb Abilities - Cd":
    @Event eachPlayer
    @Condition eventPlayer.Abilitycooldown > 0
    @Condition Abilities == true
    
    chaseAtRate(eventPlayer.Abilitycooldown, 0, 1)
    waitUntil(eventPlayer.Abilitycooldown <= 0, 99999)
    if ruleCondition:
        loop()


rule "Gb Abilities - Reset cd on round end":
    @Event eachPlayer
    @Condition eventPlayer.Abilitycooldown <= 0
    @Condition getAllPlayers().isAlive() == true
    @Condition Abilities == true
    
    eventPlayer.Abilitycooldown = 0
    waitUntil(getAllPlayers().isDead(), 99999)


rule "Gb Abilities - 1. High jump ready":
    @Event eachPlayer
    @Condition eventPlayer.isAlive() == true
    @Condition eventPlayer.Abilitycooldown <= 0
    @Condition eventPlayer.isCrouching() == true
    @Condition eventPlayer.isOnGround() == true
    @Condition isGameInProgress() == true
    @Condition eventPlayer.Abilityready == false
    @Condition eventPlayer.SpecialAbility == 1
    @Condition Abilities == true
    
    eventPlayer.Abilityready = true
    wait()
    if ruleCondition:
        loop()


rule "Gb Abilities - 1. Cancel high jump ready":
    @Event eachPlayer
    @Condition eventPlayer.Abilityready == true
    @Condition (not (eventPlayer.isOnGround() and eventPlayer.isCrouching()) or false or eventPlayer.isDead() or eventPlayer.Abilitycooldown > 0) == true
    @Condition eventPlayer.SpecialAbility == 1
    @Condition Abilities == true
    
    wait()
    eventPlayer.Abilityready = false
    wait()
    if ruleCondition:
        loop()


rule "Gb Abilities - 1. High jump":
    @Event eachPlayer
    @Condition eventPlayer.isHoldingButton(Button.JUMP) == true
    @Condition eventPlayer.Abilityready == true
    @Condition eventPlayer.SpecialAbility == 1
    @Condition Abilities == true
    
    eventPlayer.applyImpulse(Vector.UP, 25, Relativity.TO_PLAYER, Impulse.CANCEL_CONTRARY_MOTION)
    eventPlayer.Abilitycooldown = 10
    playEffect(getAllPlayers(), DynamicEffect.WINSTON_JUMP_PACK_LANDING_SOUND, Color.WHITE, eventPlayer, 100)


rule "Gb Abilities - 2. Target switch ready":
    @Event eachPlayer
    @Condition target != eventPlayer
    @Condition eventPlayer.Abilitycooldown <= 0
    @Condition ballIsOut == true
    @Condition eventPlayer.isAlive() == true
    @Condition eventPlayer.SpecialAbility == 2
    @Condition Abilities == true
    
    eventPlayer.Abilityready = true
    wait()
    if ruleCondition:
        loop()


rule "Gb Abilities - 2. Cancel Target switch ready":
    @Event eachPlayer
    @Condition eventPlayer.SpecialAbility == 2
    @Condition (eventPlayer.isDead() or eventPlayer.Abilitycooldown > 0 or ballIsOut != true or target == eventPlayer) == true
    @Condition Abilities == true
    
    eventPlayer.Abilityready = false
    wait()
    if ruleCondition:
        loop()


rule "Gb Abilities - 2. Target switch":
    @Event eachPlayer
    @Condition eventPlayer.SpecialAbility == 2
    @Condition eventPlayer.isHoldingButton(Button.ULTIMATE) == true
    @Condition eventPlayer.Abilityready == true
    @Condition Abilities == true
    
    waitUntil(not eventPlayer.isHoldingButton(Button.ULTIMATE), 99999)
    wait(0.15)
    if eventPlayer.isDead():
        return
    if eventPlayer.isHoldingButton(Button.ULTIMATE):
        goto lbl_0
    target = eventPlayer
    ballDirection = directionTowards(ballPosition, eventPlayer.getEyePosition())
    eventPlayer.Abilitycooldown = 20
    playEffect(getAllPlayers(), DynamicEffect.MOIRA_FADE_DISAPPEAR_SOUND, Color.WHITE, eventPlayer, 200)
    return
    lbl_0:
    target = eventPlayer
    eventPlayer.Abilitycooldown = 15
    playEffect(getAllPlayers(), DynamicEffect.MOIRA_FADE_DISAPPEAR_SOUND, Color.WHITE, eventPlayer, 200)


rule "Gb Abilities - 3. Blink ready":
    @Event eachPlayer
    @Condition eventPlayer.SpecialAbility == 3
    @Condition eventPlayer.isUsingAbility1() == false
    @Condition eventPlayer.Abilitycooldown <= 0
    @Condition eventPlayer.isAlive() == true
    @Condition Abilities == true
    
    eventPlayer.Abilityready = true
    wait()
    if ruleCondition:
        loop()


rule "Gb Abilities - 3. Cancel Blink ready":
    @Event eachPlayer
    @Condition eventPlayer.SpecialAbility == 3
    @Condition (eventPlayer.isDead() or eventPlayer.Abilitycooldown > 0 or eventPlayer.isUsingAbility1()) == true
    @Condition Abilities == true
    
    eventPlayer.Abilityready = false
    wait()
    if ruleCondition:
        loop()


rule "Gb Abilities - 3. Blink":
    @Event eachPlayer
    @Condition eventPlayer.SpecialAbility == 3
    @Condition eventPlayer.Abilityready == true
    @Condition eventPlayer.isHoldingButton(Button.ULTIMATE) == true
    @Condition Abilities == true
    
    eventPlayer.teleport(raycastHitPosition(eventPlayer.getEyePosition(), eventPlayer.getEyePosition() + eventPlayer.getFacingDirection() * 20, null, eventPlayer, true))
    eventPlayer.Abilitycooldown = 10
    playEffect(getAllPlayers(), DynamicEffect.SOMBRA_TRANSLOCATING_SOUND, Color.WHITE, eventPlayer, 100)


rule "Gb Abilities - 4. Critslash ready":
    @Event eachPlayer
    @Condition eventPlayer.SpecialAbility == 4
    @Condition eventPlayer.Abilitycooldown <= 0
    @Condition eventPlayer.isAlive() == true
    @Condition ballIsOut == true
    @Condition Abilities == true
    
    eventPlayer.Abilityready = true
    wait()
    if ruleCondition:
        loop()


rule "Gb Abilities - 4. Cancel critslash ready":
    @Event eachPlayer
    @Condition eventPlayer.SpecialAbility == 4
    @Condition (eventPlayer.Abilitycooldown > 0 or eventPlayer.isDead() or ballIsOut == false) == true
    @Condition Abilities == true
    
    eventPlayer.Abilityready = false
    eventPlayer.Critslash = false
    wait()
    if ruleCondition:
        loop()


rule "Gb Abilities - 4. Critical slash":
    @Event eachPlayer
    @Condition eventPlayer.SpecialAbility == 4
    @Condition eventPlayer.Abilityready == true
    @Condition eventPlayer.isHoldingButton(Button.ULTIMATE) == true
    @Condition Abilities == true
    
    eventPlayer.Critslash = true
    eventPlayer.startForcingOutlineFor(getAllPlayers(), true, rgb(200, 40, 0))
    waitUntil(eventPlayer.Critslash == false, 99999)
    eventPlayer.Abilitycooldown = 17
    eventPlayer.stopForcingOutlineFor(getAllPlayers())
