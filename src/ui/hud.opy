#HUD text, debug overlays and kill tracker

rule "HUD - community text":
    hudSubheader(getAllPlayers(), "version 1.3.2", HudPosition.RIGHT, -100, Color.ORANGE, HudReeval.VISIBILITY_AND_STRING)
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
    if addOnSettings[AddOnSetting.SANDBOX] == false:
        hudSubheader(getAllPlayers().filter(lambda player: player.simpleHUD == SimpleHud.OFF), "simple hud [{0}]".format(inputBindingString(Button.INTERACT)), HudPosition.LEFT, 0, Color.WHITE, HudReeval.VISIBILITY_AND_STRING)
    if addOnSettings[AddOnSetting.DOUBLE_SENS] and not addOnSettings[AddOnSetting.ABILITIES]:
        hudSubheader(getAllPlayers().filter(lambda player: player.simpleHUD == SimpleHud.OFF), "double sens [{0}]".format(inputBindingString(Button.ULTIMATE)), HudPosition.LEFT, 0, Color.WHITE, HudReeval.VISIBILITY_AND_STRING)


rule "HUD - add-ons text":
    @Condition isGameInProgress() == true
    
    #__end__()
    #if addOnSettings[AddOnSetting.ENDLESS]:
    #hudSubheader(getAllPlayers().filter(lambda player: player.simpleHUD == 0), "•endless", HudPosition.RIGHT, -2, Color.BLUE, HudReeval.VISIBILITY_AND_STRING)
    #__end__()
    if addOnSettings[AddOnSetting.TRACING_MODE]:
        hudSubheader(getAllPlayers().filter(lambda player: player.simpleHUD == SimpleHud.OFF), "tracing: dont lose sight with the ball!", HudPosition.TOP, -1, Color.WHITE, HudReeval.VISIBILITY_AND_STRING)
    if tournamentMode:
        hudHeader(getAllPlayers(), "Tournament", HudPosition.RIGHT, 8, Color.BLACK, HudReeval.VISIBILITY_AND_STRING)
        hudSubtext(getAllPlayers(), "ROUNDS LEFT: {0}".format(totalRounds), HudPosition.RIGHT, 9, Color.PURPLE, HudReeval.VISIBILITY_AND_STRING)
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
    hudSubtext(hostPlayer, "BALL DEBUG\nSpeed: {0} / {1}\nPhysics: {2}".format(ballSpeed, ballSpeedCap, "{0}  Motion: {1}\nDistance: {2}".format(ballPhysicsMode, ballMotion, "{0}\nDirection rate: {1}".format(distance(ballPosition, target.getEyePosition()), ballDirectionRate))), HudPosition.RIGHT, 3, Color.WHITE, HudReeval.VISIBILITY_AND_STRING)


rule "Debug - anti-orbit values":
    @Condition addOnSettings[AddOnSetting.DEBUG_HUD] == true
    @Condition target != null
    
    #Host-only AntiOrbit diagnostics. Useful even when AntiOrbit is disabled, because it confirms state reset/decay.
    hudSubtext(hostPlayer, "ORBIT DEBUG\nTarget: {0}\nTimer: {1}\nPenalty: {2}".format(target, target.orbitTimer, "{0}\nHeat: {1}".format(target.orbitPenalty, target.orbitHeat)), HudPosition.RIGHT, 4, Color.WHITE, HudReeval.VISIBILITY_AND_STRING)


rule "Kill Tracker - cache players":
    @Condition addOnSettings[AddOnSetting.KILL_TRACKER] == true
    
    #Cache once per tick instead of sorting once per HUD row. Host-only display, real players only.
    killLeaderboardSortedPlayers = sorted(getAllPlayers().filter(lambda player: not player.isDummy()), lambda x: x.kills)
    wait(0.25)
    if ruleCondition:
        loop()


rule "Kill Tracker - header":
    @Condition addOnSettings[AddOnSetting.KILL_TRACKER] == true
    @Condition len(killLeaderboardSortedPlayers) > 0
    
    hudHeader(hostPlayer, "KILLS", HudPosition.LEFT, 8, Color.ORANGE, HudReeval.VISIBILITY_AND_STRING)


rule "Kill Tracker - display":
    @Event eachPlayer
    @Condition addOnSettings[AddOnSetting.KILL_TRACKER] == true
    @Condition eventPlayer.hasSpawned() == true
    @Condition eventPlayer.isDummy() == false
    @Condition len(killLeaderboardSortedPlayers) > 0
    @Condition killLeaderboardSortedPlayers.index(eventPlayer) >= 0
    
    hudSubtext(hostPlayer, "{0}. {1} — {2} KO".format(len(killLeaderboardSortedPlayers) - killLeaderboardSortedPlayers.index(eventPlayer), eventPlayer, eventPlayer.kills), HudPosition.LEFT, 8 + len(killLeaderboardSortedPlayers) - killLeaderboardSortedPlayers.index(eventPlayer), Color.WHITE, HudReeval.VISIBILITY_SORT_ORDER_AND_STRING)


rule "HUD - anti rubberbanding hud text":
    @Event eachPlayer
    
    hudSubheader(eventPlayer, "anti-rubberbanding [{0}]: {1}".format(inputBindingString(Button.MELEE), "On" if eventPlayer.antiRubberbanding else "Off"), HudPosition.LEFT, 0, Color.WHITE, HudReeval.VISIBILITY_AND_STRING)


rule "HUD - zen mode cooldown":
    @Event eachPlayer
    
    hudSubtext(eventPlayer if eventPlayer.simpleHUD == SimpleHud.ZEN else null, "\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n", HudPosition.TOP, 10, Color.WHITE, HudReeval.VISIBILITY_AND_STRING)
    hudHeader(eventPlayer if eventPlayer.simpleHUD == SimpleHud.ZEN else null, "{0}\nDeflect".format(abilityIconString(Hero.GENJI, Button.ABILITY_2)), HudPosition.TOP, 12, Color.BLUE if eventPlayer.canDeflect and not eventPlayer.hasStatus(Status.KNOCKED_DOWN) and not eventPlayer.hasStatus(Status.ASLEEP) and eventPlayer.isAlive() and not eventPlayer.isUsingAbility2() and not eventPlayer.isUsingAbility1() else Color.GREEN if eventPlayer.isUsingAbility2() else Color.GRAY, HudReeval.VISIBILITY_AND_COLOR)
    hudHeader(eventPlayer if eventPlayer.simpleHUD == SimpleHud.ZEN else null, "{0}\nDash".format(abilityIconString(Hero.GENJI, Button.ABILITY_1)), HudPosition.TOP, 11, Color.BLUE if eventPlayer.canDash and not eventPlayer.dashOnCooldown and not eventPlayer.hasStatus(Status.KNOCKED_DOWN) and not eventPlayer.hasStatus(Status.ASLEEP) and eventPlayer.isAlive() and not eventPlayer.isUsingAbility1() else Color.GREEN if eventPlayer.isUsingAbility1() else Color.GRAY, HudReeval.VISIBILITY_AND_COLOR)


rule "HUD - Watermark":
    #Please don't be a child and try to take credit for this game. If you actually have contributed something you are free to add here. But if not, don't touch this. You are free to disable it.
    if WatermarkEnabled:
        hudSubheader(getAllPlayers(), "원작자 u/Mazawrath. v1.0.0N", HudPosition.LEFT, -1000, Color.AQUA, HudReeval.VISIBILITY_AND_STRING, SpecVisibility.ALWAYS)
