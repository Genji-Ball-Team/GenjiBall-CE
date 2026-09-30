#Sandbox / practice tools

rule "Sandbox - Set Ball spawnpoint":
    @Event eachPlayer
    @Condition Sandbox == true
    @Condition eventPlayer.isDummy() == false
    @Condition isGameInProgress() == true
    @Condition ballIsOut == false
    @Condition eventPlayer.isHoldingButton(Button.INTERACT) == true
    @Condition Sandboxselected == 1
    
    if Sandboxxyz == 1:
        if eventPlayer.isHoldingButton(Button.ULTIMATE):
            if Sandboxplusminus == 1:
                Sandboxballpos += Vector.LEFT
            else:
                Sandboxballpos += Vector.RIGHT
        else:
            if Sandboxplusminus == 1:
                Sandboxballpos += vect(0.25, 0, 0)
            else:
                Sandboxballpos += vect(-0.25, 0, 0)
    elif Sandboxxyz == 2:
        if eventPlayer.isHoldingButton(Button.ULTIMATE):
            if Sandboxplusminus == 1:
                Sandboxballpos += Vector.UP
            else:
                Sandboxballpos += Vector.DOWN
        else:
            if Sandboxplusminus == 1:
                Sandboxballpos += vect(0, 0.25, 0)
            else:
                Sandboxballpos += vect(0, -0.25, 0)
    elif Sandboxxyz == 3:
        if eventPlayer.isHoldingButton(Button.ULTIMATE):
            if Sandboxplusminus == 1:
                Sandboxballpos += Vector.FORWARD
            else:
                Sandboxballpos += Vector.BACKWARD
        else:
            if Sandboxplusminus == 1:
                Sandboxballpos += vect(0, 0, 0.25)
            else:
                Sandboxballpos += vect(0, 0, -0.25)


rule "Sandbox - Set Ball direction":
    @Event eachPlayer
    @Condition Sandbox == true
    @Condition eventPlayer.isDummy() == false
    @Condition isGameInProgress() == true
    @Condition ballIsOut == false
    @Condition eventPlayer.isHoldingButton(Button.INTERACT) == true
    @Condition Sandboxselected == 2
    
    if Sandboxxyz == 1:
        if eventPlayer.isHoldingButton(Button.ULTIMATE):
            if Sandboxplusminus == 1:
                Sandboxballdir += Vector.LEFT
            else:
                Sandboxballdir += Vector.RIGHT
        else:
            if Sandboxplusminus == 1:
                Sandboxballdir += vect(0.25, 0, 0)
            else:
                Sandboxballdir += vect(-0.25, 0, 0)
    elif Sandboxxyz == 2:
        if eventPlayer.isHoldingButton(Button.ULTIMATE):
            if Sandboxplusminus == 1:
                Sandboxballdir += Vector.UP
            else:
                Sandboxballdir += Vector.DOWN
        else:
            if Sandboxplusminus == 1:
                Sandboxballdir += vect(0, 0.25, 0)
            else:
                Sandboxballdir += vect(0, -0.25, 0)
    elif Sandboxxyz == 3:
        if eventPlayer.isHoldingButton(Button.ULTIMATE):
            if Sandboxplusminus == 1:
                Sandboxballdir += Vector.FORWARD
            else:
                Sandboxballdir += Vector.BACKWARD
        else:
            if Sandboxplusminus == 1:
                Sandboxballdir += vect(0, 0, 0.25)
            else:
                Sandboxballdir += vect(0, 0, -0.25)


rule "Sandbox - Set Ball speed":
    @Event eachPlayer
    @Condition Sandbox == true
    @Condition eventPlayer.isDummy() == false
    @Condition isGameInProgress() == true
    @Condition ballIsOut == false
    @Condition eventPlayer.isHoldingButton(Button.INTERACT) == true
    @Condition Sandboxselected == 3
    @Condition isGameInProgress() == true
    
    if eventPlayer.isHoldingButton(Button.ULTIMATE):
        if Sandboxplusminus == 1:
            Sandboxballspd += 10
        else:
            Sandboxballspd += -10
    else:
        if Sandboxplusminus == 1:
            Sandboxballspd++
        else:
            Sandboxballspd += -1


rule "Sandbox - Change xyz and +/-":
    @Event eachPlayer
    @Condition Sandbox == true
    @Condition eventPlayer.isDummy() == false
    @Condition isGameInProgress() == true
    @Condition ballIsOut == false
    @Condition (eventPlayer.isHoldingButton(Button.JUMP) or eventPlayer.isHoldingButton(Button.CROUCH)) == true
    
    if not ruleCondition:
        return
    wait(0.25)
    if eventPlayer.isHoldingButton(Button.JUMP) and eventPlayer.isHoldingButton(Button.CROUCH):
        Sandboxplusminus *= -1
        bigMessage(getAllPlayers(), "+/- switched")
    elif eventPlayer.isHoldingButton(Button.JUMP):
        if Sandboxxyz == 3:
            bigMessage(getAllPlayers(), "Invalid input")
        else:
            Sandboxxyz++
            bigMessage(getAllPlayers(), "axis +1")
    elif eventPlayer.isHoldingButton(Button.CROUCH):
        if Sandboxxyz == 1:
            bigMessage(getAllPlayers(), "Invalid input")
        else:
            Sandboxxyz--
            bigMessage(getAllPlayers(), "axis -1")


rule "Sandbox - Switch between pos/dir/spd":
    @Event eachPlayer
    @Condition eventPlayer.isHoldingButton(Button.RELOAD) == true
    @Condition eventPlayer.isDummy() == false
    @Condition isGameInProgress() == true
    @Condition ballIsOut == false
    @Condition Sandbox == true
    
    waitUntil(not eventPlayer.isHoldingButton(Button.RELOAD), 0.4)
    if eventPlayer.isHoldingButton(Button.RELOAD):
        if Sandboxselected > 2:
            Sandboxselected = 1
        else:
            Sandboxselected++
        bigMessage(eventPlayer, "Switched pos/dir/spd to {0}".format(Sandboxselected))


rule "Sandbox - Show ball spawnpoint and direction":
    @Condition Sandbox == true
    @Condition isGameInProgress() == true
    @Condition ballIsOut == false
    
    createEffect(getAllPlayers(), Effect.ORB, Color.GREEN, Sandboxballpos, 0.2, EffectReeval.POSITION_AND_RADIUS)
    createEffect(getAllPlayers(), Effect.ORB, Color.YELLOW, Sandboxballpos + Sandboxballdir, 0.1, EffectReeval.POSITION_AND_RADIUS)


rule "Sandbox - Controls desc":
    @Condition Sandbox == true
    
    hudSubheader(getAllPlayers().filter(lambda player: player.simpleHUD == 0), "Press [{0}] / [{1}] to switch the axis youre editing. press both to switch between negative and positive.".format(inputBindingString(Button.JUMP), inputBindingString(Button.CROUCH)), HudPosition.LEFT, 999, Color.WHITE, HudReeval.VISIBILITY_AND_STRING)
    hudSubheader(getAllPlayers().filter(lambda player: player.simpleHUD == 0), "Hold [{0}] to switch between position/direction/speed".format(inputBindingString(Button.RELOAD)), HudPosition.LEFT, 999, Color.WHITE, HudReeval.VISIBILITY_AND_STRING)
    hudSubheader(getAllPlayers().filter(lambda player: player.simpleHUD == 0), "Press [{0}] to add/substract, hold [{1}] while doing so to add/substract more. (dont hold long, because itll deactivate sandbox)".format(inputBindingString(Button.INTERACT), inputBindingString(Button.ULTIMATE)), HudPosition.LEFT, 999, Color.WHITE, HudReeval.VISIBILITY_AND_STRING)
    hudSubheader(getAllPlayers().filter(lambda player: player.simpleHUD == 0), "Current settings: Ballpos: [{0}] Balldirection: [{1}] Ballspeed: [{2}]".format(Sandboxballpos, Sandboxballdir, Sandboxballspd), HudPosition.LEFT, 999, Color.WHITE, HudReeval.VISIBILITY_AND_STRING)
    hudSubheader(getAllPlayers().filter(lambda player: player.simpleHUD == 0), "Start the round by pressing [{0}] and [{1}]".format(inputBindingString(Button.ULTIMATE), inputBindingString(Button.RELOAD)), HudPosition.LEFT, 999, Color.WHITE, HudReeval.VISIBILITY_AND_STRING)
