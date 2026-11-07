#HUD text and debug overlays

rule "HUD - community text":
    hudSubheader(getAllPlayers(), "version 1.3.3R", HudPosition.RIGHT, -100, Color.ORANGE, HudReeval.VISIBILITY_AND_STRING)
    hudHeader(getAllPlayers().filter(lambda player: player.simpleHUD == SimpleHud.OFF), "Discord: discord.gg/genjiball", HudPosition.LEFT, -5, Color.AQUA, HudReeval.VISIBILITY_AND_STRING)


rule "HUD - target player text":
    #white normal
    hudSubtext(getAllPlayers().exclude(target), "{0}{1}{0}".format(iconString(Icon.WARNING), target), HudPosition.LEFT, -3, Color.WHITE, HudReeval.VISIBILITY_AND_STRING)
    #red when you're targeted
    hudSubtext(target, "{0}{1}{0}".format(iconString(Icon.WARNING), target), HudPosition.LEFT, -3, Color.RED, HudReeval.VISIBILITY_AND_STRING)


#Ball speed band, 0 (below 40) to 15 (750+): how many thresholds the ball has passed.
#!define BALL_SPEED_BAND len([threshold for threshold in [40, 50, 65, 69, 70, 80, 100, 150, 200, 220, 350, 400, 450, 700, 750] if ballSpeed >= threshold])

rule "HUD - ball speed text":
    #Entity creation fail protection
    wait(1)
    #One text for every speed band, so only one HUD text re-evaluates ballSpeed each tick.
    #Bands 4, 9, 11, 12 and 14 show a joke instead of the speed.
    hudSubtext(getAllPlayers(), "BALL SPEED: {0}".format([ballSpeed, ballSpeed, ballSpeed, ballSpeed, ";)", ballSpeed, ballSpeed, ballSpeed, ballSpeed, "touch grass", ballSpeed, "???", "you good??", ballSpeed, "get a life", ballSpeed][BALL_SPEED_BAND]), HudPosition.LEFT, -4, [Color.BLUE, Color.SKY_BLUE, Color.GREEN, Color.YELLOW, Color.YELLOW, Color.YELLOW, Color.ORANGE, Color.PURPLE, Color.VIOLET, Color.ROSE, Color.ROSE, Color.ROSE, Color.ROSE, Color.ROSE, Color.BLACK, Color.BLACK][BALL_SPEED_BAND], HudReeval.VISIBILITY_STRING_AND_COLOR)


rule "HUD - controls text":
    hudSubheader(getAllPlayers().filter(lambda player: player.simpleHUD == SimpleHud.OFF), "change perspective [{0}]".format(inputBindingString(Button.RELOAD)), HudPosition.LEFT, 0, Color.WHITE, HudReeval.VISIBILITY_AND_STRING)
    hudSubheader(getAllPlayers().filter(lambda player: player.simpleHUD == SimpleHud.OFF), "simple HUD [{0}]".format(inputBindingString(Button.INTERACT)), HudPosition.LEFT, 0, Color.WHITE, HudReeval.VISIBILITY_AND_STRING)
    if addOnSettings[AddOnSetting.DOUBLE_SENS]:
        hudSubheader(getAllPlayers().filter(lambda player: player.simpleHUD == SimpleHud.OFF), "double sens [{0}]".format(inputBindingString(Button.ULTIMATE)), HudPosition.LEFT, 0, Color.WHITE, HudReeval.VISIBILITY_AND_STRING)


rule "HUD - tournament text":
    @Condition isGameInProgress() == true

    #A tourney (features/tourney.opy) is always in tournament mode. Its rounds are the ranked log's, restarts included.
    if tournamentMode:
        hudHeader(getAllPlayers(), TOURNEY_TITLE if TOURNEY_ON else "Tournament", HudPosition.RIGHT, 8, Color.BLACK, HudReeval.VISIBILITY_AND_STRING)
        hudSubtext(getAllPlayers(), "ROUND: {0} / {1}".format(max(rankedState[RankedField.ROUND], 1), totalRounds) if TOURNEY_ON else "ROUNDS LEFT: {0}".format(totalRounds), HudPosition.RIGHT, 9, Color.PURPLE, HudReeval.VISIBILITY_AND_STRING)
        hudSubtext(getAllPlayers(), "ROUNDS UNTIL BREAK: {0}".format(roundsUntilBreak), HudPosition.RIGHT, 10, Color.PURPLE, HudReeval.VISIBILITY_AND_STRING)


rule "Debug - server load HUD":
    @Condition addOnSettings[AddOnSetting.DEBUG_HUD] == true
    
    #Host-only server-load diagnostics for test builds. Presets never force this on/off.
    hudText(hostPlayer, null, "Server Load", getServerLoad(), HudPosition.RIGHT, 0, Color.WHITE, Color.WHITE, Color.WHITE, HudReeval.VISIBILITY_AND_STRING)
    hudText(hostPlayer, null, "Server Load Average", getAverageServerLoad(), HudPosition.RIGHT, 1, Color.WHITE, Color.WHITE, Color.WHITE, HudReeval.VISIBILITY_AND_STRING)
    hudText(hostPlayer, null, "Server Load Peak", getPeakServerLoad(), HudPosition.RIGHT, 2, Color.WHITE, Color.WHITE, Color.WHITE, HudReeval.VISIBILITY_AND_STRING)


rule "Debug - ball state HUD":
    @Condition addOnSettings[AddOnSetting.DEBUG_HUD] == true
    @Condition ballIsOut == true
    @Condition target != null
    
    #Host-only ball/target diagnostics for physics and collision testing.
    hudSubtext(hostPlayer, "BALL DEBUG\nSpeed: {0} / {1}\nDistance: {2}".format(ballSpeed, ballSpeedCap, "{0}\nDirection rate: {1}".format(distance(ballPosition, target.getEyePosition()), ballDirectionRate)), HudPosition.RIGHT, 3, Color.WHITE, HudReeval.VISIBILITY_AND_STRING)


rule "HUD - anti rubberbanding hud text":
    @Event eachPlayer
    
    hudSubheader(eventPlayer, "anti-rubberbanding [{0}]: {1}".format(inputBindingString(Button.MELEE), "On" if eventPlayer.antiRubberbanding else "Off"), HudPosition.LEFT, 0, Color.WHITE, HudReeval.VISIBILITY_AND_STRING)


rule "HUD - zen mode cooldown":
    @Event eachPlayer
    
    hudSubtext(eventPlayer if eventPlayer.simpleHUD == SimpleHud.ZEN else null, "\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n", HudPosition.TOP, 10, Color.WHITE, HudReeval.VISIBILITY_AND_STRING)
    hudHeader(eventPlayer if eventPlayer.simpleHUD == SimpleHud.ZEN else null, "{0}\nDeflect".format(abilityIconString(Hero.GENJI, Button.ABILITY_2)), HudPosition.TOP, 12, Color.BLUE if eventPlayer.canDeflect and not eventPlayer.hasStatus(Status.KNOCKED_DOWN) and not eventPlayer.hasStatus(Status.ASLEEP) and eventPlayer.isAlive() and not eventPlayer.isUsingAbility2() and not eventPlayer.isUsingAbility1() else Color.GREEN if eventPlayer.isUsingAbility2() else Color.GRAY, HudReeval.VISIBILITY_AND_COLOR)
    hudHeader(eventPlayer if eventPlayer.simpleHUD == SimpleHud.ZEN else null, "{0}\nDash".format(abilityIconString(Hero.GENJI, Button.ABILITY_1)), HudPosition.TOP, 11, Color.BLUE if eventPlayer.canDash and not eventPlayer.dashOnCooldown and not eventPlayer.hasStatus(Status.KNOCKED_DOWN) and not eventPlayer.hasStatus(Status.ASLEEP) and eventPlayer.isAlive() and not eventPlayer.isUsingAbility1() else Color.GREEN if eventPlayer.isUsingAbility1() else Color.GRAY, HudReeval.VISIBILITY_AND_COLOR)
