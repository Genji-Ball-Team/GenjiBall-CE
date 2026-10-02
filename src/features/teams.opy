#Team Deathmatch (v1.3.3T). The rules follow zSh4d0W's 1.3T (archived on the v1.3T branch).
#Every rule here only runs when the custom game mode is Team Deathmatch. A team scores
#when the other team has no one left alive.

rule "Teams - Winning Team":
    @Condition (teamSettings[TeamSetting.SCORE_TO_WIN] > 0 and (teamScore(Team.1) >= teamSettings[TeamSetting.SCORE_TO_WIN] or teamScore(Team.2) >= teamSettings[TeamSetting.SCORE_TO_WIN]) or getMatchTime() == 0) == true
    @Condition TieBreakerActive == false
    @Condition tournamentMode == false
    @Condition getCurrentGamemode() == Gamemode.TDM

    #Let the current kill finish before the game ends.
    waitUntil(ballIsOut == false and getAllPlayers().isAlive(), 99999)
    enableAnnouncer()
    if teamSettings[TeamSetting.SCORE_TO_WIN] > 0 and teamScore(Team.1) >= teamSettings[TeamSetting.SCORE_TO_WIN]:
        declareTeamVictory(Team.1)
    elif teamSettings[TeamSetting.SCORE_TO_WIN] > 0 and teamScore(Team.2) >= teamSettings[TeamSetting.SCORE_TO_WIN]:
        declareTeamVictory(Team.2)
    elif teamScore(Team.1) > teamScore(Team.2):
        declareTeamVictory(Team.1)
    elif teamScore(Team.2) > teamScore(Team.1):
        declareTeamVictory(Team.2)
    else:
        #Tied when the time ran out: play on until one team leads ("Teams - Last surviving").
        disableAnnouncer()
        TieBreakerActive = true


rule "Teams - Passing aura":
    @Event eachPlayer
    @Condition teamSettings[TeamSetting.PASSING] == true
    @Condition getCurrentGamemode() == Gamemode.TDM
    @Condition eventPlayer.isHoldingButton(Button.SECONDARY_FIRE) == true

    #Shows teammates who is ready to pass.
    createEffect(getPlayers(eventPlayer.getTeam()).filter(lambda player: player != eventPlayer and player.isAlive()), Effect.BAD_AURA, Color.SKY_BLUE, eventPlayer.getEyePosition(), 1.5, EffectReeval.POSITION_AND_RADIUS)
    waitUntil(not eventPlayer.isHoldingButton(Button.SECONDARY_FIRE) or eventPlayer.isDead(), 60)
    destroyEffect(getLastCreatedEntity())


rule "Teams - check for <2 players":
    @Condition getCurrentGamemode() == Gamemode.TDM
    @Condition isGameInProgress() == true
    #A team is empty. (1.3T checked for both teams empty, which never paused a round with one team left.)
    @Condition (getNumberOfPlayers(Team.1) == 0 or getNumberOfPlayers(Team.2) == 0) == true

    IsInFinalDuel = false
    IsEnoughPlayersToStart = false
    stopChasing(ballSpawnCountdown)
    deleteBall()
    RoundInProgress = false
    RoundSetupPending = false
    bigMessage(getAllPlayers(), "Waiting for players")
    pauseMatchTime()


rule "Teams - wait for more players":
    @Condition getCurrentGamemode() == Gamemode.TDM
    @Condition getNumberOfPlayers(Team.1) != 0
    @Condition getNumberOfPlayers(Team.2) != 0
    @Condition IsEnoughPlayersToStart == false
    #No arena on an unsupported map (maps/arenas.opy)
    @Condition MAP_UNSUPPORTED == false

    bigMessage(getAllPlayers(), "Let's begin!")
    IsEnoughPlayersToStart = true
    waitUntil(isGameInProgress(), 10)
    #A team may have emptied during the wait.
    if not isGameInProgress() or getNumberOfPlayers(Team.1) == 0 or getNumberOfPlayers(Team.2) == 0:
        IsEnoughPlayersToStart = false
        return
    #Paused by "Teams - check for <2 players"
    unpauseMatchTime()
    startRound()


def TDMcollision():
    @Name "Teams - TDM collision"

    #Called by collisionTarget() after a successful deflect, instead of the free-for-all retarget.
    #Holding secondary fire while deflecting (or dashing, with dash passing) passes to a teammate.
    if teamSettings[TeamSetting.PASSING] == true and prevTarget.isHoldingButton(Button.SECONDARY_FIRE) and (prevTarget.isUsingAbility2() or teamSettings[TeamSetting.DASH_PASSING] == true and prevTarget.isUsingAbility1()):
        playEffect(getAllPlayers(), DynamicEffect.RING_EXPLOSION, Color.SKY_BLUE, prevTarget.getPosition(), 10)
        playEffect(getAllPlayers(), DynamicEffect.MOIRA_FADE_DISAPPEAR_SOUND, Color.WHITE, prevTarget.getPosition(), 100)
        #A pass costs health. A deflect at an opponent heals it back.
        prevTarget.setHealth(prevTarget.getHealth() - PASS_HEALTH_COST)
        if prevTarget.getHealth() < PASS_MIN_HEALTH:
            deflectFail()
            return
        stopAssist(passingAssistId)
        if getNumberOfLivingPlayers(prevTarget.getTeam()) == 1:
            #Nobody left to pass to. On Default the pass fails, otherwise the ball comes back to the passer.
            if presetMode != Preset.DEFAULT:
                if ballSpeed > SELF_PASS_FAST_SPEED:
                    target = getLivingPlayers(getOppositeTeam(prevTarget.getTeam()))[0]
                    wait()
                target = prevTarget
            else:
                deflectFail()
        else:
            passingPlayer = prevTarget
            passingPlayer.startGrantingAssistFor(getAllPlayers(), AssistReeval.NONE)
            passingAssistId = getLastAssistId()
            target = sorted(getLivingPlayers(prevTarget.getTeam()).exclude(prevTarget).filter(lambda x: x.hasMoved), lambda x: angleBetweenVectors(prevTarget.getFacingDirection(), directionTowards(prevTarget, x.getPosition())))[0]
    else:
        stopAssist(passingAssistId)
        heal(prevTarget, null, PASS_HEALTH_COST)
        target = sorted(getLivingPlayers(getOppositeTeam(prevTarget.getTeam())).exclude(prevTarget).filter(lambda x: x.hasMoved), lambda x: angleBetweenVectors(prevTarget.getFacingDirection(), directionTowards(prevTarget, x.getPosition())))[0]


rule "Teams - end assist after 1s":
    @Condition getCurrentGamemode() == Gamemode.TDM
    @Condition passingPlayer != null

    #The passer gets the assist if the teammate's next deflect kills within a second.
    waitUntil(prevTarget != passingPlayer, 10)
    wait(1)
    #A teammate passed again during the second: wait for that pass instead. TDMcollision() already stopped the old assist.
    if prevTarget == passingPlayer:
        loop()
    stopAssist(passingAssistId)
    passingPlayer = null


rule "Teams - Final duel":
    @Condition getCurrentGamemode() == Gamemode.TDM
    @Condition isGameInProgress() == true
    @Condition RoundInProgress != false
    @Condition len(getLivingPlayers(Team.1).filter(lambda player: player.hasMoved)) == 1
    @Condition len(getLivingPlayers(Team.2).filter(lambda player: player.hasMoved)) == 1
    @Condition IsInFinalDuel == false
    @Condition IsEnoughPlayersToStart == true
    @Condition addOnSettings[AddOnSetting.ENDLESS] == false

    wait(0.016, Wait.ABORT_WHEN_FALSE)
    if not ruleCondition:
        return
    setupFinal()


rule "Teams - Last surviving":
    @Condition getCurrentGamemode() == Gamemode.TDM
    @Condition isGameInProgress() == true
    @Condition IsEnoughPlayersToStart == true
    @Condition (getNumberOfLivingPlayers(Team.1) == 0 or getNumberOfLivingPlayers(Team.2) == 0) == true

    IsInFinalDuel = false
    #Cleared by startRound once the next round is under way.
    RoundSetupPending = true
    #deflectFail() already counted the round for tournament mode when one player is left.
    if getNumberOfLivingPlayers(Team.ALL) > 1:
        alert()
    if getNumberOfLivingPlayers(Team.1) == 0:
        addToTeamScore(Team.2, 1)
    else:
        addToTeamScore(Team.1, 1)
    wait(0.25)
    if (getMatchTime() == 0 or TieBreakerActive) and not tournamentMode:
        if teamScore(Team.1) == teamScore(Team.2):
            TieBreakerActive = true
        else:
            #"Teams - Winning Team" ends the game.
            TieBreakerActive = false
    stopChasing(ballSpawnCountdown)
    stopChasing(getAllPlayers().bouncePadCooldown)
    bigMessage(getAllPlayers(), "{0} has won the round".format(getLivingPlayers(Team.ALL)[0]))
    wait(roundTimings[RoundTiming.WIN_PAUSE])
    if addOnSettings[AddOnSetting.DUELS]:
        goto lbl_0
    getDeadPlayers(Team.ALL).resurrect()
    lbl_0:
    startRound()
