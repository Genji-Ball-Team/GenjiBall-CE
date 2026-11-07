#Round lifecycle: start, targeting, win conditions

def startRound():
    @Name "Active game - start round"
    
    RoundSetupPending = true
    randomTarget()
    chaseAtRate(ballSpawnCountdown, 0, 1)
    RoundInProgress = true
    RoundSetupPending = false
    #New rounds should start with dash available again.
    #This only resets the custom dash cooldown flag; it does not alter dash/deflect timing mid-round.
    getAllPlayers().dashOnCooldown = false
    ballSpawnCountdown = setballspawncountdown


rule "Active game - spawn ball":
    @Condition ballSpawnCountdown == 0
    @Condition ballIsOut == false
    @Condition target.isAlive() == true
    
    ballPosition = circleCenter
    ballDirection = directionTowards(ballPosition, target.getEyePosition())
    ballSpeed = min(ballSpawnSpeed, ballSpeed)
    async(startBall, AsyncBehavior.RESTART)


def setupFinal():
    @Name "Subroutine - setup duel"
    
    RoundSetupPending = true
    if ballIsOut == false:
        goto lbl_0
    deleteBall()
    lbl_0:
    randomTarget()
    stopChasing(ballSpawnCountdown)
    IsInFinalDuel = true
    RoundSetupPending = false
    chaseAtRate(ballSpawnCountdown, 0, 1)
    getLivingPlayers(Team.ALL).filter(lambda player: player.hasMoved)[0].startForcingPosition(circleCenter + vect(-15, 0, 0), false)
    getLivingPlayers(Team.ALL).filter(lambda player: player.hasMoved)[1].startForcingPosition(circleCenter + vect(15, 0, 0), false)
    getLivingPlayers(Team.ALL).setStatusEffect(null, Status.ROOTED, 1.5)
    wait(0)
    getLivingPlayers(Team.ALL)[0].setFacing(directionTowards(getLivingPlayers(Team.ALL).filter(lambda player: player.hasMoved)[0].getPosition(), circleCenter), Relativity.TO_WORLD)
    getLivingPlayers(Team.ALL)[1].setFacing(directionTowards(getLivingPlayers(Team.ALL).filter(lambda player: player.hasMoved)[1].getPosition(), circleCenter), Relativity.TO_WORLD)
    bigMessage(getAllPlayers(), "{0} vs. {1}".format(getLivingPlayers(Team.ALL).filter(lambda player: player.hasMoved)[0], getLivingPlayers(Team.ALL).filter(lambda player: player.hasMoved)[1]))
    wait(0.1)
    getLivingPlayers(Team.ALL).filter(lambda player: player.hasMoved)[0].stopForcingPosition()
    getLivingPlayers(Team.ALL).filter(lambda player: player.hasMoved)[1].stopForcingPosition()


rule "Active game - final duel":
    @Condition isGameInProgress() == true
    @Condition len(getLivingPlayers(Team.ALL).filter(lambda player: player.hasMoved)) == 2
    @Condition IsEnoughPlayersToStart == true
    @Condition IsInFinalDuel == false
    @Condition getCurrentGamemode() == Gamemode.FFA
    
    wait(0.016, Wait.ABORT_WHEN_FALSE)
    if not ruleCondition:
        return
    setupFinal()


rule "Active game - check for last player surviving":
    @Condition isGameInProgress() == true
    @Condition getNumberOfLivingPlayers(Team.ALL) == 1
    @Condition IsEnoughPlayersToStart == true
    
    IsInFinalDuel = false
    #Cleared by startRound once the next round is under way.
    RoundSetupPending = true
    getLivingPlayers(Team.ALL).addToScore(1)
    wait(0.25)
    if (getMatchTime() == 0 or TieBreakerActive) and not tournamentMode:
        #If there is alredy a tiebreaker, then the tiebreaker has ended.
        #if TieBreakerActive:
        #break
        #__end__()
        HighestScore = sorted(getAllPlayers(), lambda player: player.getScore()).last().getScore()
        #Check if there is more than 1 person with the highest score
        if len(getAllPlayers().filter(lambda player: player.getScore() == HighestScore)) > 1:
            #There is more than 1, activate tie breaker
            TieBreakerActive = true
        else:
            TieBreakerActive = false
            if getMatchTime() == 0:
                enableMusic()
                enableGamemodeCompletion()
    stopChasing(ballSpawnCountdown)
    bigMessage(getAllPlayers(), "{0} has won the round".format(getLivingPlayers(Team.ALL)[0]))
    wait(roundTimings[RoundTiming.WIN_PAUSE])
    if not TieBreakerActive:
        getDeadPlayers(Team.ALL).resurrect()
    else:
        #Kill anyone alive who doesn't have the highest score.
        kill(getLivingPlayers(Team.ALL).filter(lambda player: player.getScore() != HighestScore))
        #During tiebreaker, only revive the people who have the same score as the highest score.
        (getDeadPlayers(Team.ALL).filter(lambda player: player.getScore() == HighestScore)).resurrect()
        wait(0.25)
        bigMessage(getAllPlayers(), "tiebreaker!")
    startRound()


rule "Active game - all players dead":
    @Condition getNumberOfLivingPlayers(Team.ALL) == 0
    @Condition isGameInProgress() == true
    @Condition TieBreakerActive == false
    
    IsInFinalDuel = false
    if ballIsOut == false:
        goto lbl_0
    deleteBall()
    lbl_0:
    RoundInProgress = false
    stopChasing(ballSpawnCountdown)
    getDeadPlayers(Team.ALL).resurrect()
    ballSpawnCountdown = setballspawncountdown
    wait(1)
    if ruleCondition:
        loop()
    wait(2)
    #Skip if the round has already restarted, or is about to: by the lobby (not enough players), the final duel (two players)
    #or a round win (including its win pause).
    if not IsEnoughPlayersToStart or IsInFinalDuel or RoundInProgress or RoundSetupPending:
        return
    stopChasing(ballSpawnCountdown)
    startRound()


rule "Active game - end game":
    @Condition getMatchTime() == 0
    @Condition RoundInProgress == false
    @Condition TieBreakerActive == false
    @Condition tournamentMode == false
    @Condition getCurrentGamemode() == Gamemode.FFA
    
    enableMusic()
    enableGamemodeCompletion()


def randomTarget():
    @Name "Active game - target random player"
    
    target = random.choice(getLivingPlayers(Team.ALL).filter(lambda player: player.hasMoved and prevTarget != player))
    wait(0.1)


rule "Active game - target not existing fail safe":
    @Condition target == null
    
    randomTarget()
    wait(1)
    if ruleCondition:
        loop()
