#Sandbox / practice tools

rule "Sandbox - Set Ball spawnpoint":
    @Event eachPlayer
    @Condition addOnSettings[AddOnSetting.SANDBOX] == true
    @Condition eventPlayer.isDummy() == false
    @Condition isGameInProgress() == true
    @Condition ballIsOut == false
    @Condition eventPlayer.isHoldingButton(Button.INTERACT) == true
    @Condition sandboxState[SandboxField.EDITING] == 1
    
    if sandboxState[SandboxField.AXIS] == 1:
        if eventPlayer.isHoldingButton(Button.ULTIMATE):
            if sandboxState[SandboxField.SIGN] == 1:
                sandboxState[SandboxField.BALL_POSITION] += Vector.LEFT
            else:
                sandboxState[SandboxField.BALL_POSITION] += Vector.RIGHT
        else:
            if sandboxState[SandboxField.SIGN] == 1:
                sandboxState[SandboxField.BALL_POSITION] += vect(0.25, 0, 0)
            else:
                sandboxState[SandboxField.BALL_POSITION] += vect(-0.25, 0, 0)
    elif sandboxState[SandboxField.AXIS] == 2:
        if eventPlayer.isHoldingButton(Button.ULTIMATE):
            if sandboxState[SandboxField.SIGN] == 1:
                sandboxState[SandboxField.BALL_POSITION] += Vector.UP
            else:
                sandboxState[SandboxField.BALL_POSITION] += Vector.DOWN
        else:
            if sandboxState[SandboxField.SIGN] == 1:
                sandboxState[SandboxField.BALL_POSITION] += vect(0, 0.25, 0)
            else:
                sandboxState[SandboxField.BALL_POSITION] += vect(0, -0.25, 0)
    elif sandboxState[SandboxField.AXIS] == 3:
        if eventPlayer.isHoldingButton(Button.ULTIMATE):
            if sandboxState[SandboxField.SIGN] == 1:
                sandboxState[SandboxField.BALL_POSITION] += Vector.FORWARD
            else:
                sandboxState[SandboxField.BALL_POSITION] += Vector.BACKWARD
        else:
            if sandboxState[SandboxField.SIGN] == 1:
                sandboxState[SandboxField.BALL_POSITION] += vect(0, 0, 0.25)
            else:
                sandboxState[SandboxField.BALL_POSITION] += vect(0, 0, -0.25)


rule "Sandbox - Set Ball direction":
    @Event eachPlayer
    @Condition addOnSettings[AddOnSetting.SANDBOX] == true
    @Condition eventPlayer.isDummy() == false
    @Condition isGameInProgress() == true
    @Condition ballIsOut == false
    @Condition eventPlayer.isHoldingButton(Button.INTERACT) == true
    @Condition sandboxState[SandboxField.EDITING] == 2
    
    if sandboxState[SandboxField.AXIS] == 1:
        if eventPlayer.isHoldingButton(Button.ULTIMATE):
            if sandboxState[SandboxField.SIGN] == 1:
                sandboxState[SandboxField.BALL_DIRECTION] += Vector.LEFT
            else:
                sandboxState[SandboxField.BALL_DIRECTION] += Vector.RIGHT
        else:
            if sandboxState[SandboxField.SIGN] == 1:
                sandboxState[SandboxField.BALL_DIRECTION] += vect(0.25, 0, 0)
            else:
                sandboxState[SandboxField.BALL_DIRECTION] += vect(-0.25, 0, 0)
    elif sandboxState[SandboxField.AXIS] == 2:
        if eventPlayer.isHoldingButton(Button.ULTIMATE):
            if sandboxState[SandboxField.SIGN] == 1:
                sandboxState[SandboxField.BALL_DIRECTION] += Vector.UP
            else:
                sandboxState[SandboxField.BALL_DIRECTION] += Vector.DOWN
        else:
            if sandboxState[SandboxField.SIGN] == 1:
                sandboxState[SandboxField.BALL_DIRECTION] += vect(0, 0.25, 0)
            else:
                sandboxState[SandboxField.BALL_DIRECTION] += vect(0, -0.25, 0)
    elif sandboxState[SandboxField.AXIS] == 3:
        if eventPlayer.isHoldingButton(Button.ULTIMATE):
            if sandboxState[SandboxField.SIGN] == 1:
                sandboxState[SandboxField.BALL_DIRECTION] += Vector.FORWARD
            else:
                sandboxState[SandboxField.BALL_DIRECTION] += Vector.BACKWARD
        else:
            if sandboxState[SandboxField.SIGN] == 1:
                sandboxState[SandboxField.BALL_DIRECTION] += vect(0, 0, 0.25)
            else:
                sandboxState[SandboxField.BALL_DIRECTION] += vect(0, 0, -0.25)


rule "Sandbox - Set Ball speed":
    @Event eachPlayer
    @Condition addOnSettings[AddOnSetting.SANDBOX] == true
    @Condition eventPlayer.isDummy() == false
    @Condition isGameInProgress() == true
    @Condition ballIsOut == false
    @Condition eventPlayer.isHoldingButton(Button.INTERACT) == true
    @Condition sandboxState[SandboxField.EDITING] == 3
    @Condition isGameInProgress() == true
    
    if eventPlayer.isHoldingButton(Button.ULTIMATE):
        if sandboxState[SandboxField.SIGN] == 1:
            sandboxState[SandboxField.BALL_SPEED] += 10
        else:
            sandboxState[SandboxField.BALL_SPEED] += -10
    else:
        if sandboxState[SandboxField.SIGN] == 1:
            sandboxState[SandboxField.BALL_SPEED]++
        else:
            sandboxState[SandboxField.BALL_SPEED] += -1


rule "Sandbox - Change xyz and +/-":
    @Event eachPlayer
    @Condition addOnSettings[AddOnSetting.SANDBOX] == true
    @Condition eventPlayer.isDummy() == false
    @Condition isGameInProgress() == true
    @Condition ballIsOut == false
    @Condition (eventPlayer.isHoldingButton(Button.JUMP) or eventPlayer.isHoldingButton(Button.CROUCH)) == true
    
    if not ruleCondition:
        return
    wait(0.25)
    if eventPlayer.isHoldingButton(Button.JUMP) and eventPlayer.isHoldingButton(Button.CROUCH):
        sandboxState[SandboxField.SIGN] *= -1
        bigMessage(getAllPlayers(), "+/- switched")
    elif eventPlayer.isHoldingButton(Button.JUMP):
        if sandboxState[SandboxField.AXIS] == 3:
            bigMessage(getAllPlayers(), "Invalid input")
        else:
            sandboxState[SandboxField.AXIS]++
            bigMessage(getAllPlayers(), "axis +1")
    elif eventPlayer.isHoldingButton(Button.CROUCH):
        if sandboxState[SandboxField.AXIS] == 1:
            bigMessage(getAllPlayers(), "Invalid input")
        else:
            sandboxState[SandboxField.AXIS]--
            bigMessage(getAllPlayers(), "axis -1")


rule "Sandbox - Switch between pos/dir/spd":
    @Event eachPlayer
    @Condition eventPlayer.isHoldingButton(Button.RELOAD) == true
    @Condition eventPlayer.isDummy() == false
    @Condition isGameInProgress() == true
    @Condition ballIsOut == false
    @Condition addOnSettings[AddOnSetting.SANDBOX] == true
    
    waitUntil(not eventPlayer.isHoldingButton(Button.RELOAD), 0.4)
    if eventPlayer.isHoldingButton(Button.RELOAD):
        if sandboxState[SandboxField.EDITING] > 2:
            sandboxState[SandboxField.EDITING] = 1
        else:
            sandboxState[SandboxField.EDITING]++
        bigMessage(eventPlayer, "Switched pos/dir/spd to {0}".format(sandboxState[SandboxField.EDITING]))


rule "Sandbox - Show ball spawnpoint and direction":
    @Condition addOnSettings[AddOnSetting.SANDBOX] == true
    @Condition isGameInProgress() == true
    @Condition ballIsOut == false
    
    createEffect(getAllPlayers(), Effect.ORB, Color.GREEN, sandboxState[SandboxField.BALL_POSITION], 0.2, EffectReeval.POSITION_AND_RADIUS)
    createEffect(getAllPlayers(), Effect.ORB, Color.YELLOW, sandboxState[SandboxField.BALL_POSITION] + sandboxState[SandboxField.BALL_DIRECTION], 0.1, EffectReeval.POSITION_AND_RADIUS)


rule "Sandbox - Controls desc":
    @Condition addOnSettings[AddOnSetting.SANDBOX] == true
    
    hudSubheader(getAllPlayers().filter(lambda player: player.simpleHUD == SimpleHud.OFF), "Press [{0}] / [{1}] to switch the axis you're editing. Press both to switch between negative and positive.".format(inputBindingString(Button.JUMP), inputBindingString(Button.CROUCH)), HudPosition.LEFT, 999, Color.WHITE, HudReeval.VISIBILITY_AND_STRING)
    hudSubheader(getAllPlayers().filter(lambda player: player.simpleHUD == SimpleHud.OFF), "Hold [{0}] to switch between position/direction/speed".format(inputBindingString(Button.RELOAD)), HudPosition.LEFT, 999, Color.WHITE, HudReeval.VISIBILITY_AND_STRING)
    hudSubheader(getAllPlayers().filter(lambda player: player.simpleHUD == SimpleHud.OFF), "Press [{0}] to add/subtract, hold [{1}] while doing so to add/subtract more. (Don't hold it too long, or it will turn off sandbox.)".format(inputBindingString(Button.INTERACT), inputBindingString(Button.ULTIMATE)), HudPosition.LEFT, 999, Color.WHITE, HudReeval.VISIBILITY_AND_STRING)
    hudSubheader(getAllPlayers().filter(lambda player: player.simpleHUD == SimpleHud.OFF), "Current settings: Ballpos: [{0}] Balldirection: [{1}] Ballspeed: [{2}]".format(sandboxState[SandboxField.BALL_POSITION], sandboxState[SandboxField.BALL_DIRECTION], sandboxState[SandboxField.BALL_SPEED]), HudPosition.LEFT, 999, Color.WHITE, HudReeval.VISIBILITY_AND_STRING)
    hudSubheader(getAllPlayers().filter(lambda player: player.simpleHUD == SimpleHud.OFF), "Start the round by pressing [{0}] and [{1}]".format(inputBindingString(Button.ULTIMATE), inputBindingString(Button.RELOAD)), HudPosition.LEFT, 999, Color.WHITE, HudReeval.VISIBILITY_AND_STRING)
