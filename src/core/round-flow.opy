#Round lifecycle: start, targeting, win conditions

def startRound():
    @Name "Active game - start round"
    
    RoundSetupPending = true
    randomTarget()
    #A tiebreaker: a tied player may have left during the wait. Decided again; with no tie left the match ends
    #(time is up) and no round starts. RoundSetupPending stays set, so nothing else starts one.
    if TieBreakerActive:
        decideTiebreaker()
        if not TieBreakerActive:
            return
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
    #The host's sit-out takes effect between rounds, after the ranked log's ROUND_END. With too few players
    #left, "Check for <2 players" stops the lobby during the win pause
    applyHostSitOut()
    #The tie is decided after the win pause. Until then, a tie with the host playing or sitting out stops "all players
    #dead" and "end game" from ending the match during the pause (the winner leaves). Never ends a match or tiebreaker
    if (getMatchTime() == 0 or TieBreakerActive) and not tournamentMode:
        HighestScore = sorted(getAllPlayers(), lambda player: player.getScore()).last().getScore()
        if len(getAllPlayers().filter(lambda player: player.getScore() == HighestScore)) > 1:
            TieBreakerActive = true
        HighestScore = sorted(tiebreakerPlayers, lambda player: player.getScore()).last().getScore()
        if len(tiebreakerPlayers.filter(lambda player: player.getScore() == HighestScore)) > 1:
            TieBreakerActive = true
    stopChasing(ballSpawnCountdown)
    bigMessage(getAllPlayers(), "{0} has won the round".format(getLivingPlayers(Team.ALL)[0]))
    wait(roundTimings[RoundTiming.WIN_PAUSE])
    #RoundSetupPending stays set through the whole pause, even if the lobby stops ("Check for <2 players" leaves it):
    #"Wait for more players" and "end game" wait for this rule, so the next round and the end of the match are decided
    #only here, once.
    #A press of the sit-out button during the win pause counts for the next round. If the host now sits out and
    #too few players are left, no round: "Check for <2 players" stops the lobby (it may only see it next tick)
    applyHostSitOut()
    #Tiebreaker or end of match, once per round end, among the players of the next round. If there is already a
    #tiebreaker, it has ended. A match that ends here starts no round and brings nobody back.
    if (getMatchTime() == 0 or TieBreakerActive) and not tournamentMode:
        decideTiebreaker()
        if getMatchTime() == 0 and not TieBreakerActive:
            return
    #No round from here: too few players. The lobby stopped during the win pause, or is about to. Bring back the
    #players while it waits; "Wait for more players" starts the next round. No tie is possible with one player.
    if playingPlayers <= 1:
        RoundSetupPending = false
        resurrectForRound()
        return
    #The lobby stopped during the win pause and enough players are back: start it again here, as "Wait for more
    #players" would. In the same tick as bringing players back, so the lobby is never "enough players" with one alive.
    if not IsEnoughPlayersToStart:
        bigMessage(getAllPlayers(), "Let's begin!")
        IsEnoughPlayersToStart = true
    if not TieBreakerActive:
        resurrectForRound()
    else:
        #Kill anyone alive who doesn't have the highest score, and a host who sits out.
        kill(getLivingPlayers(Team.ALL).filter(lambda player: player.getScore() != HighestScore or sitsOut(player)))
        #During tiebreaker, only revive the people who have the same score as the highest score, but a host who sits out.
        (getDeadPlayers(Team.ALL).filter(lambda player: player.getScore() == HighestScore and not sitsOut(player))).resurrect()
        wait(0.25)
        #A tied player may have left during the wait: decided again. With no tie left the match ends (time is up)
        #and no round starts; RoundSetupPending stays set, so nothing else starts one.
        decideTiebreaker()
        if not TieBreakerActive:
            return
        bigMessage(getAllPlayers(), "tiebreaker!")
    startRound()


#Tiebreaker or end of match, once time is up (not in tournament mode), after the round win pause. Decided among
#tiebreakerPlayers: a host who sits out never plays a tiebreaker, so a tie with them alone isn't one, and their score
#doesn't set HighestScore. With nobody left to decide among, there's no tie.
def decideTiebreaker():
    @Name "Active game - decide tiebreaker"

    HighestScore = sorted(tiebreakerPlayers, lambda player: player.getScore()).last().getScore()
    #Check if there is more than 1 person with the highest score
    if len(tiebreakerPlayers.filter(lambda player: player.getScore() == HighestScore)) > 1:
        #There is more than 1, activate tie breaker
        TieBreakerActive = true
    else:
        TieBreakerActive = false
        if getMatchTime() == 0:
            enableMusic()
            enableGamemodeCompletion()


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
    resurrectForRound()
    ballSpawnCountdown = setballspawncountdown
    wait(1)
    if ruleCondition:
        loop()
    wait(2)
    #Skip if the round has already restarted, or is about to: by the lobby (not enough players), the final duel (two players)
    #or a round win (including its win pause).
    if not IsEnoughPlayersToStart or IsInFinalDuel or RoundInProgress or RoundSetupPending:
        return
    #The host's sit-out takes effect here, after the ranked log's ROUND_END NONE, so a press during the pause counts.
    #If the host now sits out and too few players are left, no round: "Check for <2 players" stops the lobby
    applyHostSitOut()
    resurrectForRound()
    if playingPlayers <= 1:
        return
    stopChasing(ballSpawnCountdown)
    startRound()


rule "Active game - end game":
    @Condition getMatchTime() == 0
    @Condition RoundInProgress == false
    @Condition TieBreakerActive == false
    @Condition tournamentMode == false
    @Condition getCurrentGamemode() == Gamemode.FFA
    #Not during a round win pause, even with the lobby stopped: the round win decides the end of the match after it
    @Condition RoundSetupPending == false

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
