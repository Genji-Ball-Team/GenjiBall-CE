#HUD text, debug overlays, kill tracker and visual effects

rule "HUD - community text":
    hudSubheader(getAllPlayers(), "version 1.3.2T", HudPosition.RIGHT, -100, Color.ORANGE, HudReeval.VISIBILITY_AND_STRING)
    hudHeader(getAllPlayers().filter(lambda player: player.simpleHUD == 0), "Discord: discord.gg/genjiball", HudPosition.LEFT, -5, Color.AQUA, HudReeval.VISIBILITY_AND_STRING)


rule "HUD - target player text":
    #white normal
    hudSubtext(getAllPlayers().exclude(target), "{0}{1}{0}".format(iconString(Icon.WARNING), target), HudPosition.LEFT, -3, Color.WHITE, HudReeval.VISIBILITY_AND_STRING)
    #red when you're targeted
    hudSubtext(target, "{0}{1}{0}".format(iconString(Icon.WARNING), target), HudPosition.LEFT, -3, Color.RED, HudReeval.VISIBILITY_AND_STRING)


rule "HUD - ball speed text":
    #Entity creation fail protection
    wait(1)
    #ball speed text color change with speed
    hudSubtext(getAllPlayers() if ballSpeed < 40 else [], "BALL SPEED: {0}".format(ballSpeed), HudPosition.LEFT, -4, Color.BLUE, HudReeval.VISIBILITY_AND_STRING)
    hudSubtext(getAllPlayers() if ballSpeed >= 40 and ballSpeed < 50 else [], "BALL SPEED: {0}".format(ballSpeed), HudPosition.LEFT, -4, Color.SKY_BLUE, HudReeval.VISIBILITY_AND_STRING)
    hudSubtext(getAllPlayers() if ballSpeed >= 50 and ballSpeed < 65 else [], "BALL SPEED: {0}".format(ballSpeed), HudPosition.LEFT, -4, Color.GREEN, HudReeval.VISIBILITY_AND_STRING)
    hudSubtext(getAllPlayers() if ballSpeed >= 65 and ballSpeed < 69 else [], "BALL SPEED: {0}".format(ballSpeed), HudPosition.LEFT, -4, Color.YELLOW, HudReeval.VISIBILITY_AND_STRING)
    hudSubtext(getAllPlayers() if ballSpeed >= 69 and ballSpeed < 70 else [], "BALL SPEED: ;)", HudPosition.LEFT, -4, Color.YELLOW, HudReeval.VISIBILITY_AND_STRING)
    hudSubtext(getAllPlayers() if ballSpeed >= 70 and ballSpeed < 80 else [], "BALL SPEED: {0}".format(ballSpeed), HudPosition.LEFT, -4, Color.YELLOW, HudReeval.VISIBILITY_AND_STRING)
    hudSubtext(getAllPlayers() if ballSpeed >= 80 and ballSpeed < 100 else [], "BALL SPEED: {0}".format(ballSpeed), HudPosition.LEFT, -4, Color.ORANGE, HudReeval.VISIBILITY_AND_STRING)
    hudSubtext(getAllPlayers() if ballSpeed >= 100 and ballSpeed < 150 else [], "BALL SPEED: {0}".format(ballSpeed), HudPosition.LEFT, -4, Color.PURPLE, HudReeval.VISIBILITY_AND_STRING)
    hudSubtext(getAllPlayers() if ballSpeed >= 150 and ballSpeed < 200 else [], "BALL SPEED: {0}".format(ballSpeed), HudPosition.LEFT, -4, Color.VIOLET, HudReeval.VISIBILITY_AND_STRING)
    hudSubtext(getAllPlayers() if ballSpeed >= 200 and ballSpeed < 220 else [], "BALL SPEED: touch grass", HudPosition.LEFT, -4, Color.ROSE, HudReeval.VISIBILITY_AND_STRING)
    hudSubtext(getAllPlayers() if ballSpeed >= 220 and ballSpeed < 350 else [], "BALL SPEED: {0}".format(ballSpeed), HudPosition.LEFT, -4, Color.ROSE, HudReeval.VISIBILITY_AND_STRING)
    hudSubtext(getAllPlayers() if ballSpeed >= 350 and ballSpeed < 400 else [], "BALL SPEED: ???", HudPosition.LEFT, -4, Color.ROSE, HudReeval.VISIBILITY_AND_STRING)
    hudSubtext(getAllPlayers() if ballSpeed >= 400 and ballSpeed < 450 else [], "BALL SPEED: you good??", HudPosition.LEFT, -4, Color.ROSE, HudReeval.VISIBILITY_AND_STRING)
    hudSubtext(getAllPlayers() if ballSpeed >= 450 and ballSpeed < 700 else [], "BALL SPEED: {0}".format(ballSpeed), HudPosition.LEFT, -4, Color.ROSE, HudReeval.VISIBILITY_AND_STRING)
    hudSubtext(getAllPlayers() if ballSpeed >= 700 and ballSpeed < 750 else [], "BALL SPEED: get a life", HudPosition.LEFT, -4, Color.BLACK, HudReeval.VISIBILITY_AND_STRING)
    hudSubtext(getAllPlayers() if ballSpeed >= 750 else [], "BALL SPEED: {0}".format(ballSpeed), HudPosition.LEFT, -4, Color.BLACK, HudReeval.VISIBILITY_AND_STRING)


rule "HUD - controls text":
    hudSubheader(getAllPlayers().filter(lambda player: player.simpleHUD == 0), "change perspective [{0}]".format(inputBindingString(Button.RELOAD)), HudPosition.LEFT, 0, Color.WHITE, HudReeval.VISIBILITY_AND_STRING)
    if Sandbox == false:
        hudSubheader(getAllPlayers().filter(lambda player: player.simpleHUD == 0), "simple hud [{0}]".format(inputBindingString(Button.INTERACT)), HudPosition.LEFT, 0, Color.WHITE, HudReeval.VISIBILITY_AND_STRING)
    if doubleSensEnabled and not Abilities:
        hudSubheader(getAllPlayers().filter(lambda player: player.simpleHUD == 0), "double sens [{0}]".format(inputBindingString(Button.ULTIMATE)), HudPosition.LEFT, 0, Color.WHITE, HudReeval.VISIBILITY_AND_STRING)


rule "HUD - add-ons text":
    @Condition isGameInProgress() == true
    
    #__end__()
    #if endlessMode:
    #hudSubheader(getAllPlayers().filter(lambda player: player.simpleHUD == 0), "•endless", HudPosition.RIGHT, -2, Color.BLUE, HudReeval.VISIBILITY_AND_STRING)
    #__end__()
    if tracingMode:
        hudSubheader(getAllPlayers().filter(lambda player: player.simpleHUD == 0), "tracing: dont lose sight with the ball!", HudPosition.TOP, -1, Color.WHITE, HudReeval.VISIBILITY_AND_STRING)
    if tournamentMode:
        hudHeader(getAllPlayers(), "Tournament", HudPosition.RIGHT, 8, Color.BLACK, HudReeval.VISIBILITY_AND_STRING)
        hudSubtext(getAllPlayers(), "ROUNDS LEFT: {0}".format(totalRounds), HudPosition.RIGHT, 9, Color.PURPLE, HudReeval.VISIBILITY_AND_STRING)
        hudSubtext(getAllPlayers(), "ROUNDS UNTIL BREAK: {0}".format(roundsUntilBreak), HudPosition.RIGHT, 10, Color.PURPLE, HudReeval.VISIBILITY_AND_STRING)


rule "Debug - server load HUD":
    @Condition debugRules == true
    
    #Host-only server-load diagnostics for test builds. Presets never force this on/off.
    hudText(hostPlayer, null, "Server Load", getServerLoad(), HudPosition.RIGHT, 0, Color.WHITE, Color.WHITE, Color.WHITE, HudReeval.VISIBILITY_AND_STRING)
    hudText(hostPlayer, null, "Server Load Average", getAverageServerLoad(), HudPosition.RIGHT, 1, Color.WHITE, Color.WHITE, Color.WHITE, HudReeval.VISIBILITY_AND_STRING)
    hudText(hostPlayer, null, "Server Load Peak", getPeakServerLoad(), HudPosition.RIGHT, 2, Color.WHITE, Color.WHITE, Color.WHITE, HudReeval.VISIBILITY_AND_STRING)


rule "Debug - ball state HUD":
    @Condition debugRules == true
    @Condition ballIsOut == true
    @Condition target != null
    
    #Host-only ball/target diagnostics for physics and collision testing.
    hudSubtext(hostPlayer, "BALL DEBUG\nSpeed: {0} / {1}\nPhysics: {2}".format(ballSpeed, ballSpeedCap, "{0}  Motion: {1}\nDistance: {2}".format(ballPhysicsMode, ballMotion, "{0}\nDirection rate: {1}".format(distance(ballPosition, target.getEyePosition()), ballDirectionRate))), HudPosition.RIGHT, 3, Color.WHITE, HudReeval.VISIBILITY_AND_STRING)


rule "Debug - anti-orbit values":
    @Condition debugRules == true
    @Condition target != null
    
    #Host-only AntiOrbit diagnostics. Useful even when AntiOrbit is disabled, because it confirms state reset/decay.
    hudSubtext(hostPlayer, "ORBIT DEBUG\nTarget: {0}\nTimer: {1}\nPenalty: {2}".format(target, target.orbitTimer, "{0}\nHeat: {1}".format(target.orbitPenalty, target.orbitHeat)), HudPosition.RIGHT, 4, Color.WHITE, HudReeval.VISIBILITY_AND_STRING)


rule "Kill Tracker - cache players":
    @Condition killCounterEnabled == true
    
    #Cache once per tick instead of sorting once per HUD row. Host-only display, real players only.
    killLeaderboardPlayers = getAllPlayers().filter(lambda player: not player.isDummy())
    killLeaderboardSortedPlayers = sorted(killLeaderboardPlayers, lambda x: x.kills)
    wait(0.25)
    if ruleCondition:
        loop()


rule "Kill Tracker - header":
    @Condition killCounterEnabled == true
    @Condition len(killLeaderboardSortedPlayers) > 0
    
    hudHeader(hostPlayer, "KILLS", HudPosition.LEFT, 8, Color.ORANGE, HudReeval.VISIBILITY_AND_STRING)


rule "Kill Tracker - display":
    @Event eachPlayer
    @Condition killCounterEnabled == true
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
    
    hudSubtext(eventPlayer if eventPlayer.simpleHUD == 2 else null, "\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n", HudPosition.TOP, 10, Color.WHITE, HudReeval.VISIBILITY_AND_STRING)
    hudHeader(eventPlayer if eventPlayer.simpleHUD == 2 else null, "{0}\nDeflect".format(abilityIconString(Hero.GENJI, Button.ABILITY_2)), HudPosition.TOP, 12, Color.BLUE if eventPlayer.canDeflect and not eventPlayer.hasStatus(Status.KNOCKED_DOWN) and not eventPlayer.hasStatus(Status.ASLEEP) and eventPlayer.isAlive() and not eventPlayer.isUsingAbility2() and not eventPlayer.isUsingAbility1() else Color.GREEN if eventPlayer.isUsingAbility2() else Color.GRAY, HudReeval.VISIBILITY_AND_COLOR)
    hudHeader(eventPlayer if eventPlayer.simpleHUD == 2 else null, "{0}\nDash".format(abilityIconString(Hero.GENJI, Button.ABILITY_1)), HudPosition.TOP, 11, Color.BLUE if eventPlayer.canDash and not eventPlayer.dashOnCooldown and not eventPlayer.hasStatus(Status.KNOCKED_DOWN) and not eventPlayer.hasStatus(Status.ASLEEP) and eventPlayer.isAlive() and not eventPlayer.isUsingAbility1() else Color.GREEN if eventPlayer.isUsingAbility1() else Color.GRAY, HudReeval.VISIBILITY_AND_COLOR)


rule "HUD - Watermark":
    if not WatermarkEnabled:
        goto lbl_0
    #Please don't be a child and try to take credit for this game. If you actually have contributed something you are free to add here. But if not, don't touch this. You are free to disable it.
    hudSubheader(getAllPlayers(), "원작자 u/Mazawrath. v1.0.0N", HudPosition.LEFT, -1000, Color.AQUA, HudReeval.VISIBILITY_AND_STRING, SpecVisibility.ALWAYS)
    lbl_0:


rule "Appearance - target effects":
    @Condition isGameInProgress() == true
    
    createEffect(getAllPlayers().exclude(target), Effect.ORB, Color.WHITE, updateEveryFrame(ballPosition), 1, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
    createProjectileEffect(getAllPlayers(), Projectile.SIGMA_HYPERSPHERE, null, updateEveryFrame(ballPosition), ballDirection, 0.01, ProjectileEffectReeval.VISIBILITY_POSITION_DIRECTION_AND_SIZE)
    if getCurrentGamemode() == Gamemode.TDM:
        if passingplayer == prevTarget and target.getTeam() == prevTarget.getTeam():
            createEffect(target, Effect.ORB, Color.SKY_BLUE, updateEveryFrame(ballPosition), 1, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
            createEffect(getAllPlayers().exclude(target) if target.isAlive() else null, Effect.GOOD_AURA, Color.RED, target, 1, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
            createEffect(localPlayer if localPlayer == target else null, Effect.GOOD_AURA, Color.GRAY if localPlayer.thirdPerson else Color.RED, localPlayer, 0.8)
            createEffect(target, Effect.GOOD_AURA, Color.BLUE, ballPosition, 1, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
    elif not RedGreenColorblindMode:
        createEffect(target, Effect.ORB, Color.RED, updateEveryFrame(ballPosition), 1, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
        createEffect(getAllPlayers().exclude(target) if target.isAlive() else null, Effect.GOOD_AURA, Color.RED, target, 1, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
        createEffect(localPlayer if localPlayer == target else null, Effect.GOOD_AURA, Color.GRAY if localPlayer.thirdPerson else Color.RED, localPlayer, 0.8)
        createEffect(target, Effect.GOOD_AURA, Color.BLUE, ballPosition, 1, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
    else:
        createEffect(target, Effect.ORB, Color.BLUE, updateEveryFrame(ballPosition), 0.4, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
        createEffect(getAllPlayers(), Effect.GOOD_AURA, Color.BLUE, target, 1, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
        createEffect(target, Effect.GOOD_AURA, Color.BLUE, target, 1, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
    if xray:
        createIcon(target if ballIsOut and not isInLoS(target.getEyePosition(), ballPosition, BarrierLos.BLOCKED_BY_ALL_BARRIERS) else null, updateEveryFrame(ballPosition), Icon.HEART, IconReeval.VISIBILITY_AND_POSITION, Color.RED)


rule "Appearance - ball countdown":
    createInWorldText(null if ballIsOut else getAllPlayers().exclude(target), "BALL SPAWNING IN: {0}".format(ceil(ballSpawnCountdown)), vect(circleCenter.x, circleCenter.y + 2.5, circleCenter.z), 2.5, Clip.SURFACES, WorldTextReeval.VISIBILITY_POSITION_AND_STRING, Color.SKY_BLUE)
    createInWorldText(null if ballIsOut else target, "BALL SPAWNING IN: {0}".format(ceil(ballSpawnCountdown)), vect(circleCenter.x, circleCenter.y + 2.5, circleCenter.z), 2.5, Clip.SURFACES, WorldTextReeval.VISIBILITY_POSITION_AND_STRING, Color.RED)
