#Team deathmatch variant (mostly disabled)

rule "Teams - Winning Team":
    @Condition (getMatchTime() == 0 and Teamsscoretowin == 0 or (Teamsscoretowin > 0 and teamScore(Team.1) == Teamsscoretowin or Teamsscoretowin > 0 and teamScore(Team.2) == Teamsscoretowin)) == true
    @Condition RoundInProgress == false
    @Condition TieBreakerActive == false
    @Condition tournamentMode == false
    @Condition getCurrentGamemode() == Gamemode.TDM
    @Disabled
    
    enableAnnouncer()
    if Teamsscoretowin == 0:
        if teamScore(Team.1) > teamScore(Team.2):
            declareTeamVictory(Team.1)
        else:
            declareTeamVictory(Team.2)
    elif teamScore(Team.1) == Teamsscoretowin:
        declareTeamVictory(Team.1)
    else:
        declareTeamVictory(Team.2)


rule "Teams - Passing aura":
    @Event eachPlayer
    @Condition enablepassing == true
    @Condition getCurrentGamemode() == Gamemode.TDM
    @Condition eventPlayer.isHoldingButton(Button.SECONDARY_FIRE) == true
    @Disabled
    
    createEffect(getPlayers(eventPlayer.getTeam()).filter(lambda player: player != eventPlayer and player.isAlive()), Effect.BAD_AURA, Color.SKY_BLUE, eventPlayer.getEyePosition(), 1.5, EffectReeval.POSITION_AND_RADIUS)
    waitUntil(not eventPlayer.isHoldingButton(Button.SECONDARY_FIRE) or eventPlayer.isDead(), 60)
    destroyEffect(getLastCreatedEntity())


rule "Teams - check for <2 players":
    @Condition getCurrentGamemode() == Gamemode.TDM
    @Condition isGameInProgress() == true
    @Condition (getNumberOfPlayers(Team.1) and getNumberOfPlayers(Team.2)) == false
    @Disabled
    
    IsInFinalDuel = false
    IsEnoughPlayersToStart = false
    stopChasing(ballSpawnCountdown)
    deleteBall()
    if RoundInProgress == false:
        goto lbl_0
    RoundInProgress = false
    lbl_0:
    bigMessage(getAllPlayers(), "Waiting for players")
    pauseMatchTime()


rule "Teams - wait for more players":
    @Condition getCurrentGamemode() == Gamemode.TDM
    @Condition getNumberOfPlayers(Team.1) != false
    @Condition getNumberOfPlayers(Team.2) != false
    @Condition IsEnoughPlayersToStart == false
    @Disabled
    
    if getNumberOfPlayers(Team.ALL) < 2:
        return
    bigMessage(getAllPlayers(), "Lets begin!")
    IsEnoughPlayersToStart = true
    startRound()


def TDMcollision():
    @Name "Teams - TDM collision"
    
    #TDM passing is intentionally native-TDM only. FFA behavior is unaffected.
    #A pass can be triggered with Secondary Fire / Ability 2, and optionally Dash.
    if enablepassing == true and (prevTarget.isHoldingButton(Button.SECONDARY_FIRE) or prevTarget.isUsingAbility2() or enableDashPassing == true and prevTarget.isUsingAbility1()):
        playEffect(getAllPlayers(), DynamicEffect.RING_EXPLOSION, Color.SKY_BLUE, prevTarget.getPosition(), 10)
        playEffect(getAllPlayers(), DynamicEffect.MOIRA_FADE_DISAPPEAR_SOUND, Color.WHITE, prevTarget.getPosition(), 100)
        prevTarget.setHealth(100)
        stopAssist(passingassistid)
        if getNumberOfLivingPlayers(prevTarget.getTeam()) == 1:
            if presetMode != 0:
                target = prevTarget
            else:
                deflectFail()
        else:
            passingplayer = prevTarget
            passingplayer.startGrantingAssistFor(getAllPlayers(), AssistReeval.NONE)
            passingassistid = getLastAssistId()
            target = sorted(getLivingPlayers(prevTarget.getTeam()).exclude(prevTarget).filter(lambda x: x.hasMoved), lambda x: angleBetweenVectors(prevTarget.getFacingDirection(), directionTowards(prevTarget, x.getPosition())))[0]
    else:
        if prevTarget.getTeam() != Team.1 or prevTarget.getTeam() != Team.2:
            stopAssist(passingassistid)
        heal(prevTarget, null, 100)
        target = sorted(getLivingPlayers(getOppositeTeam(prevTarget.getTeam())).exclude(prevTarget).filter(lambda x: x.hasMoved), lambda x: angleBetweenVectors(prevTarget.getFacingDirection(), directionTowards(prevTarget, x.getPosition())))[0]


rule "Teams - end assist after 1s":
    @Condition getCurrentGamemode() == Gamemode.TDM
    @Condition passingplayer != null
    @Disabled
    
    waitUntil(prevTarget != passingplayer, 10)
    wait(1)
    stopAssist(passingassistid)
    passingplayer = null


rule "Teams - Final duel":
    @Condition getCurrentGamemode() == Gamemode.TDM
    @Condition isGameInProgress() == true
    @Condition RoundInProgress != false
    @Condition len(getLivingPlayers(Team.1).filter(lambda player: player.hasMoved)) == 1
    @Condition len(getLivingPlayers(Team.2).filter(lambda player: player.hasMoved)) == 1
    @Condition IsInFinalDuel == false
    @Condition IsEnoughPlayersToStart == true
    @Condition endlessMode == false
    @Disabled
    
    wait(0.016, Wait.ABORT_WHEN_FALSE)
    if not ruleCondition:
        return
    setupFinal()


rule "Teams - Last surviving":
    @Condition getCurrentGamemode() == Gamemode.TDM
    @Condition isGameInProgress() == true
    @Condition IsEnoughPlayersToStart == true
    @Condition (getNumberOfLivingPlayers(Team.1) == 0 or getNumberOfLivingPlayers(Team.2) == 0) == true
    @Disabled
    
    IsInFinalDuel = false
    if getNumberOfLivingPlayers(Team.1) == 0:
        addToTeamScore(Team.2, 1)
    else:
        addToTeamScore(Team.1, 1)
    wait(0.25)
    if (getMatchTime() == 0 or TieBreakerActive) and not tournamentMode:
        HighestScore = sorted(getAllPlayers(), lambda player: player.getScore()).last().getScore()
        #Check if there is more than 1 person with the highest score
        if teamScore(Team.1) == teamScore(Team.2):
            #There is more than 1, activate tie breaker
            TieBreakerActive = true
        else:
            TieBreakerActive = false
            if getMatchTime() == 0:
                enableMusic()
                enableGamemodeCompletion()
    stopChasing(ballSpawnCountdown)
    stopChasing(getAllPlayers().bouncePadCooldown)
    bigMessage(getAllPlayers(), "{0} has won the round".format(getLivingPlayers(Team.ALL)[0]))
    wait(2)
    if duelMode:
        goto lbl_0
    if not TieBreakerActive:
        getDeadPlayers(Team.ALL).resurrect()
    else:
        #Kill anyone alive who doesn't have the highest score.
        kill(getLivingPlayers(Team.ALL).filter(lambda player: player.getScore() != HighestScore))
        #During tiebreaker, only revive the people who have the same score as the highest score.
        (getDeadPlayers(Team.ALL).filter(lambda player: player.getScore() == HighestScore)).resurrect()
        wait(0.25)
        bigMessage(getAllPlayers(), "tiebreaker!")
    lbl_0:
    startRound()
