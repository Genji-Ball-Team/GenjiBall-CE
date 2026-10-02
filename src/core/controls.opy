#Player input: dash, deflect, toggles, bounce pads

rule "Controls - primary fire triggers dash":
    @Event eachPlayer
    @Condition eventPlayer.isHoldingButton(Button.PRIMARY_FIRE) == true
    #Naz: This is remnent code from a dark and lawless time in the development of this game. Leave it be...
    #@Condition "{0}".format(eventPlayer) != "bytestats"
    @Condition eventPlayer.isDummy() == false
    @Condition eventPlayer.isHoldingButton(Button.ABILITY_1) == false
    @Condition eventPlayer.canDash == true
    @Condition eventPlayer.dashOnCooldown == false
    
    if eventPlayer.antiRubberbanding == true:
        eventPlayer.allowButton(Button.ABILITY_1)
        eventPlayer.forceButtonPress(Button.ABILITY_1)
        eventPlayer.disallowButton(Button.ABILITY_1)
    else:
        eventPlayer.forceButtonPress(Button.ABILITY_1)


rule "Controls - secondary fire triggers deflect":
    @Event eachPlayer
    @Condition eventPlayer.isHoldingButton(Button.SECONDARY_FIRE) == true
    #Naz: This is remnent code from a dark and lawless time in the development of this game. Leave it be...
    #@Condition "{0}".format(eventPlayer) != "bytestats"
    @Condition eventPlayer.isDummy() == false
    @Condition eventPlayer.isUsingAbility1() == false
    @Condition eventPlayer.isHoldingButton(Button.ABILITY_2) == false
    @Condition eventPlayer.canDeflect == true
    #Teams passing: secondary fire is held to pass, so deflect with ability 2 (features/teams.opy).
    @Condition (teamSettings[TeamSetting.PASSING] and getCurrentGamemode() == Gamemode.TDM) == false
    
    if eventPlayer.antiRubberbanding == true:
        eventPlayer.allowButton(Button.ABILITY_2)
        eventPlayer.forceButtonPress(Button.ABILITY_2)
        eventPlayer.disallowButton(Button.ABILITY_2)
    else:
        eventPlayer.forceButtonPress(Button.ABILITY_2)


rule "Controls - Dash slow (gravity shift)":
    @Event eachPlayer
    @Condition eventPlayer.isUsingAbility1() == true
    
    eventPlayer.moveSpeed = 0
    chaseAtRate(eventPlayer.moveSpeed, 100, max(eventPlayer.moveSpeed, 16) ** 1.25)
    while eventPlayer.moveSpeed != 100:
        eventPlayer.setMoveSpeed(moveSpeed * (eventPlayer.moveSpeed / 100))
        if eventPlayer.currentGravity == 0:
            goto lbl_0
        eventPlayer.setGravity(gravity * (eventPlayer.moveSpeed / 100))
        lbl_0:
        wait(0.1)
    eventPlayer.setMoveSpeed(moveSpeed)
    if eventPlayer.currentGravity == 0:
        goto lbl_1
    eventPlayer.setGravity(gravity)
    lbl_1:


rule "Controls - Shorten deflect length":
    @Event eachPlayer
    @Condition eventPlayer.isUsingAbility2() == true
    @Condition eventPlayer.isUsingUltimate() == false
    
    wait(ballFeel[BallFeel.DEFLECT_WINDOW])
    if eventPlayer.isDummy():
        if botState[BotField.WILL_EDASH] == true or botState[BotField.WILL_GHOST_DASH] == true:
            eventPlayer.forceButtonPress(Button.ABILITY_1)
            botState[BotField.WILL_GHOST_DASH] = false
            botState[BotField.WILL_EDASH] = false
    eventPlayer.setAbility2Enabled(false)
    eventPlayer.setAbility1Enabled(false)
    eventPlayer.canDeflect = false
    eventPlayer.canDash = false
    wait(ballFeel[BallFeel.DEFLECT_LOCKOUT])
    eventPlayer.setAbility2Enabled(true)
    eventPlayer.setAbility1Enabled(true)
    eventPlayer.canDeflect = true
    eventPlayer.canDash = true


rule "Controls - anti-rubberbanding button lock":
    @Event eachPlayer
    @Condition eventPlayer.isDummy() == false
    @Condition eventPlayer.antiRubberbanding == true
    
    eventPlayer.disallowButton(Button.ABILITY_1)
    eventPlayer.disallowButton(Button.ABILITY_2)


rule "Controls - Ability 1 dash queue":
    @Event eachPlayer
    @Condition eventPlayer.isHoldingButton(Button.ABILITY_1) == true
    #Naz: This is remnent code from a dark and lawless time in the development of this game. Leave it be...
    #@Condition "{0}".format(eventPlayer) != "bytestats"
    @Condition eventPlayer.isDummy() == false
    @Condition eventPlayer.isUsingAbility1() == false
    @Condition eventPlayer.canDash == true
    @Condition eventPlayer.dashOnCooldown == false
    
    if eventPlayer.antiRubberbanding == true:
        eventPlayer.allowButton(Button.ABILITY_1)
        eventPlayer.forceButtonPress(Button.ABILITY_1)
        eventPlayer.disallowButton(Button.ABILITY_1)
    else:
        eventPlayer.forceButtonPress(Button.ABILITY_1)


rule "Controls - Ability 2 deflect queue":
    @Event eachPlayer
    @Condition eventPlayer.isHoldingButton(Button.ABILITY_2) == true
    #Naz: This is remnent code from a dark and lawless time in the development of this game. Leave it be...
    #@Condition "{0}".format(eventPlayer) != "bytestats"
    @Condition eventPlayer.isDummy() == false
    @Condition eventPlayer.isUsingAbility1() == false
    @Condition eventPlayer.isUsingAbility2() == false
    @Condition eventPlayer.canDeflect == true
    
    if eventPlayer.antiRubberbanding == true:
        eventPlayer.allowButton(Button.ABILITY_2)
        eventPlayer.forceButtonPress(Button.ABILITY_2)
        eventPlayer.disallowButton(Button.ABILITY_2)
    else:
        eventPlayer.forceButtonPress(Button.ABILITY_2)


rule "Controls - Dash cooldown":
    @Event eachPlayer
    @Condition eventPlayer.isAlive() == true
    @Condition eventPlayer.isUsingAbility1() == true
    
    eventPlayer.dashOnCooldown = true
    waitUntil(not eventPlayer.isUsingAbility1(), 0.5)
    waitUntil(eventPlayer.dashOnCooldown == false, playerSettings[PlayerSetting.DASH_COOLDOWN])
    eventPlayer.dashOnCooldown = false
    #Swift Strike's native cooldown (38% = 3.04s) would still block a shorter custom dash cooldown.
    eventPlayer.setAbilityCooldown(Button.ABILITY_1, 0)


rule "Control - Dash reset":
    @Event playerEarnedElimination
    
    eventPlayer.dashOnCooldown = false


rule "Controls - Switch perspective (reload)":
    @Event eachPlayer
    @Condition eventPlayer.isHoldingButton(Button.RELOAD) == true
    @Condition eventPlayer.isAlive() == true
    
    if not eventPlayer.thirdPerson:
        eventPlayer.thirdPerson = true
        wait(0.01)
        eventPlayer.startCamera(updateEveryFrame(raycastHitPosition(eventPlayer.getEyePosition(), eventPlayer + worldVector(vect(-0.5, 0, 0), eventPlayer, Transform.ROTATION) + vect(0, 1.5, 0) + eventPlayer.getFacingDirection() * -2, null, getAllPlayers(), false)), eventPlayer + eventPlayer.getFacingDirection() * 1000)
        playEffect(eventPlayer, DynamicEffect.BRIGITTE_REPAIR_PACK_ARMOR_SOUND, Color.WHITE, eventPlayer, 10)
    else:
        eventPlayer.stopCamera()
        eventPlayer.thirdPerson = false
        playEffect(eventPlayer, DynamicEffect.BRIGITTE_REPAIR_PACK_ARMOR_SOUND, Color.WHITE, eventPlayer, 10)
    wait(0.1)


rule "Controls - toggle anti rubberbanding (melee)":
    @Event eachPlayer
    @Condition eventPlayer.isHoldingButton(Button.MELEE) == true
    @Condition eventPlayer.isDummy() == false
    
    if eventPlayer.antiRubberbanding == true:
        eventPlayer.antiRubberbanding = false
        eventPlayer.allowButton(Button.ABILITY_1)
        eventPlayer.allowButton(Button.ABILITY_2)
        smallMessage(eventPlayer, "anti-rubberbanding: off")
    elif eventPlayer.antiRubberbanding == false:
        eventPlayer.antiRubberbanding = true
        eventPlayer.disallowButton(Button.ABILITY_1)
        eventPlayer.disallowButton(Button.ABILITY_2)
        smallMessage(eventPlayer, "anti-rubberbanding: on")
    playEffect(eventPlayer, DynamicEffect.BRIGITTE_REPAIR_PACK_ARMOR_SOUND, Color.WHITE, eventPlayer, 10)
    wait(0.1)


rule "Controls - double sens toggle":
    @Event eachPlayer
    @Condition addOnSettings[AddOnSetting.DOUBLE_SENS] == true
    @Condition addOnSettings[AddOnSetting.ABILITIES] == false
    @Condition eventPlayer.isDummy() == false
    @Condition eventPlayer.isAlive() == true
    @Condition eventPlayer.isHoldingButton(Button.ULTIMATE) == true
    
    if eventPlayer.sensHigh == true:
        eventPlayer.sensHigh = false
        eventPlayer.setAimSpeed(100)
        smallMessage(eventPlayer, "double sens: normal")
    else:
        eventPlayer.sensHigh = true
        eventPlayer.setAimSpeed(addOnSettings[AddOnSetting.SENS_MULTIPLIER])
        smallMessage(eventPlayer, "double sens: high")
    playEffect(eventPlayer, DynamicEffect.BRIGITTE_REPAIR_PACK_ARMOR_SOUND, Color.WHITE, eventPlayer, 10)
    waitUntil(not eventPlayer.isHoldingButton(Button.ULTIMATE), 99999)


rule "Controls - double sens reset when disabled":
    @Event eachPlayer
    @Condition eventPlayer.sensHigh == true
    @Condition (addOnSettings[AddOnSetting.DOUBLE_SENS] == false or addOnSettings[AddOnSetting.ABILITIES] == true) == true
    
    eventPlayer.sensHigh = false
    eventPlayer.setAimSpeed(100)


rule "Controls - Simple HUD (Interact)":
    @Event eachPlayer
    @Condition eventPlayer.isHoldingButton(Button.INTERACT) == true
    @Condition eventPlayer.isAlive() == true
    @Condition addOnSettings[AddOnSetting.SANDBOX] == false
    
    if eventPlayer.simpleHUD == SimpleHud.ZEN:
        eventPlayer.simpleHUD = SimpleHud.OFF
        eventPlayer.enableHeroHud()
        playEffect(eventPlayer, DynamicEffect.BRIGITTE_REPAIR_PACK_ARMOR_SOUND, Color.WHITE, eventPlayer, 10)
        smallMessage(eventPlayer, "simple HUD: off")
        return
    waitUntil(not eventPlayer.isHoldingButton(Button.INTERACT), 0.4)
    if eventPlayer.isHoldingButton(Button.INTERACT):
        if eventPlayer.simpleHUD == SimpleHud.ZEN:
            eventPlayer.simpleHUD = SimpleHud.OFF
            eventPlayer.enableHeroHud()
            playEffect(eventPlayer, DynamicEffect.BRIGITTE_REPAIR_PACK_ARMOR_SOUND, Color.WHITE, eventPlayer, 10)
            smallMessage(eventPlayer, "simple HUD: off")
        else:
            eventPlayer.simpleHUD = SimpleHud.ZEN
            eventPlayer.disableHeroHud()
            playEffect(eventPlayer, DynamicEffect.BRIGITTE_REPAIR_PACK_ARMOR_SOUND, Color.WHITE, eventPlayer, 10)
            smallMessage(eventPlayer, "simple HUD: zen mode")
    else:
        if eventPlayer.simpleHUD == SimpleHud.OFF:
            eventPlayer.simpleHUD = SimpleHud.ON
            playEffect(eventPlayer, DynamicEffect.BRIGITTE_REPAIR_PACK_ARMOR_SOUND, Color.WHITE, eventPlayer, 10)
            smallMessage(eventPlayer, "simple HUD: on")
        else:
            eventPlayer.simpleHUD = SimpleHud.OFF
            eventPlayer.enableHeroHud()
            playEffect(eventPlayer, DynamicEffect.BRIGITTE_REPAIR_PACK_ARMOR_SOUND, Color.WHITE, eventPlayer, 10)
            smallMessage(eventPlayer, "simple HUD: off")
    wait(0.1)


rule "Controls - Bounce when near a pad":
    @Event eachPlayer
    @Condition len(bouncePads) > 0
    @Condition any([distance(eventPlayer.getPosition(), pad) <= bouncePadConfig[BouncePadField.RANGE] for pad in bouncePads])
    @Condition eventPlayer.bouncePadCooldown == 0
    @Condition eventPlayer.isAlive() == true
    @Condition eventPlayer.isHoldingButton(Button.JUMP) == true
    @Condition bouncePadToggle == true
    
    eventPlayer.applyImpulse(Vector.UP, bouncePadConfig[BouncePadField.STRENGTH], Relativity.TO_WORLD, Impulse.CANCEL_CONTRARY_MOTION)
    eventPlayer.bouncePadCooldown = bouncePadConfig[BouncePadField.COOLDOWN]
    playEffect(getAllPlayers(), DynamicEffect.RING_EXPLOSION_SOUND, Color.WHITE, sorted(bouncePads, lambda pad: distance(eventPlayer.getPosition(), pad))[0], 25)
