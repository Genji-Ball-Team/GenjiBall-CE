#Round lifecycle: start, targeting, win conditions

def startRound():
    @Name "Active game - start round"
    
    if Sandbox == true:
        waitUntil(hostPlayer.isHoldingButton(Button.ULTIMATE) and hostPlayer.isHoldingButton(Button.RELOAD), 99999)
    randomTarget()
    chaseAtRate(ballSpawnCountdown, 0, 1)
    RoundInProgress = true
    #New rounds should start with dash available again.
    #This only resets the custom dash cooldown flag; it does not alter dash/deflect timing mid-round.
    getAllPlayers().dashOnCooldown = false
    resetOrbitRoundState()
    chaseAtRate(getAllPlayers().bouncePadCooldown, 0, 1)
    ballSpawnCountdown = setballspawncountdown
    getLivingPlayers(Team.ALL).bouncePadCooldown = bouncePadCooldownLength - 1


rule "Active game - spawn ball":
    @Condition ballSpawnCountdown == 0
    @Condition ballIsOut == false
    @Condition target.isAlive() == true
    
    if Sandbox == true:
        ballPosition = Sandboxballpos
        ballDirection = directionTowards(Sandboxballpos, Sandboxballdir)
        ballSpeed = Sandboxballspd
    else:
        ballPosition = circleCenter
        ballDirection = directionTowards(ballPosition, target.getEyePosition())
        ballSpeed = min(ballSpawnSpeed, ballSpeed)
    async(startBall, AsyncBehavior.RESTART)


def setupFinal():
    @Name "Subroutine - setup duel"
    
    if ballIsOut == false:
        goto lbl_0
    deleteBall()
    lbl_0:
    randomTarget()
    stopChasing(ballSpawnCountdown)
    if Sandbox == true:
        waitUntil(hostPlayer.isHoldingButton(Button.ULTIMATE) and hostPlayer.isHoldingButton(Button.RELOAD), 99999)
    IsInFinalDuel = true
    chaseAtRate(ballSpawnCountdown, 0, 1)
    getLivingPlayers(Team.ALL).bouncePadCooldown = bouncePadCooldownLength - 1
    if isIsland:
        getLivingPlayers(Team.ALL).filter(lambda player: player.hasMoved)[0].startForcingPosition(circleCenter + vect(-15, 0, 0), false)
        getLivingPlayers(Team.ALL).filter(lambda player: player.hasMoved)[1].startForcingPosition(circleCenter + vect(15, 0, 0), false)
    else:
        getLivingPlayers(Team.ALL).filter(lambda player: player.hasMoved)[0].startForcingPosition(circleCenter + Vector.RIGHT * (SphereSize / 1.5), false)
        getLivingPlayers(Team.ALL).filter(lambda player: player.hasMoved)[1].startForcingPosition(circleCenter + Vector.LEFT * (SphereSize / 1.5), false)
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
    @Condition duelMode == false
    @Condition endlessMode == false
    @Condition getCurrentGamemode() == Gamemode.FFA
    
    wait(0.016, Wait.ABORT_WHEN_FALSE)
    if not ruleCondition:
        return
    setupFinal()


rule "Active game - check for last player surviving":
    @Condition isGameInProgress() == true
    @Condition getNumberOfLivingPlayers(Team.ALL) == 1
    @Condition IsEnoughPlayersToStart == true
    @Condition duelMode == false
    
    IsInFinalDuel = false
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


rule "Active game - all players dead":
    @Condition getNumberOfLivingPlayers(Team.ALL) == 0
    @Condition isGameInProgress() == true
    @Condition TieBreakerActive == false
    @Condition duelMode == false
    
    IsInFinalDuel = false
    if ballIsOut == false:
        goto lbl_0
    deleteBall()
    lbl_0:
    RoundInProgress = false
    stopChasing(ballSpawnCountdown)
    getDeadPlayers(Team.ALL).resurrect()
    stopChasing(getAllPlayers().bouncePadCooldown)
    getAllPlayers().bouncePadCooldown = bouncePadCooldownLength
    ballSpawnCountdown = setballspawncountdown
    wait(1)
    if ruleCondition:
        loop()
    wait(2)
    if IsEnoughPlayersToStart:
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
    
    if Sandbox == true:
        target = hostPlayer
        goto lbl_0
    target = random.choice(getLivingPlayers(Team.ALL).filter(lambda player: player.hasMoved and prevTarget != player))
    lbl_0:
    wait(0.1)


rule "Active game - target not existing fail safe":
    @Condition target == null
    
    randomTarget()
    wait(1)
    if ruleCondition:
        loop()
