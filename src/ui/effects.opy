#Ball and target visual effects, spawn countdown text

rule "Appearance - target effects":
    @Condition isGameInProgress() == true
    
    createEffect(getAllPlayers().exclude(target), Effect.ORB, Color.WHITE, updateEveryFrame(ballPosition), 1, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
    createProjectileEffect(getAllPlayers(), Projectile.SIGMA_HYPERSPHERE, null, updateEveryFrame(ballPosition), ballDirection, 0.01, ProjectileEffectReeval.VISIBILITY_POSITION_DIRECTION_AND_SIZE)
    if not RedGreenColorblindMode:
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
