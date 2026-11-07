#1v1: sets of first to "1v1 first to" round wins, the winner stays.
#Uses the duel queue and duel start (features/duels.opy, QUEUE_MODE). The duel-only rules are off while 1v1 is on.

rule "1v1 - queue HUD":
    @Event eachPlayer
    @Condition addOnSettings[AddOnSetting.ONE_V_ONE] == true

    #A player who just lost a point is queued until the next point, but isn't waiting
    hudSubheader(eventPlayer if eventPlayer.isDead() and not eventPlayer in oneVOneState[OneVOneField.PLAYERS] else null, "You fight in {0} sets.".format(duelQueue.index(eventPlayer) + 1), HudPosition.TOP, -1, Color.PURPLE, HudReeval.VISIBILITY_AND_STRING)


rule "1v1 - round end":
    @Condition addOnSettings[AddOnSetting.ONE_V_ONE] == true
    @Condition isGameInProgress() == true
    @Condition getNumberOfLivingPlayers(Team.ALL) < 2
    @Condition len(duelQueue) > 0

    deleteBall()
    stopChasing(ballSpawnCountdown)
    oneVOneRoundEnd()
    wait(0.5)
    if ruleCondition:
        loop()


#Called by setupFinal (both players of the duel are alive and placed)
def oneVOneServe():
    @Name "1v1 - serve"

    #Not the two players of the running set: a new set starts, and randomTarget's pick serves first
    if len(getLivingPlayers(Team.ALL).filter(lambda player: player.hasMoved and player in oneVOneState[OneVOneField.PLAYERS])) < 2:
        oneVOneState[OneVOneField.PLAYERS] = getLivingPlayers(Team.ALL).filter(lambda player: player.hasMoved)
        getAllPlayers().setPoints = 0
    elif oneVOneState[OneVOneField.SERVE] in getLivingPlayers(Team.ALL):
        target = oneVOneState[OneVOneField.SERVE]
    #The other player serves next point
    oneVOneState[OneVOneField.SERVE] = oneVOneState[OneVOneField.PLAYERS].exclude(target)[0]


#Called by "1v1 - round end" and "1v1 - player left", after the ball is deleted
def oneVOneRoundEnd():
    @Name "1v1 - round end"

    if oneVOneState[OneVOneField.OVER]:
        return
    #The survivor is a player of the set: the other one died (a point) or left (the set)
    if getLivingPlayers(Team.ALL)[0] in oneVOneState[OneVOneField.PLAYERS]:
        if len(oneVOneState[OneVOneField.PLAYERS].filter(lambda player: player in getAllPlayers())) == 2:
            getLivingPlayers(Team.ALL)[0].setPoints += 1
            if getLivingPlayers(Team.ALL)[0].setPoints < addOnSettings[AddOnSetting.ONE_V_ONE_FIRST_TO]:
                bigMessage(getAllPlayers(), "{0} {1} - {2} {3}".format(oneVOneState[OneVOneField.PLAYERS][0], oneVOneState[OneVOneField.PLAYERS][0].setPoints, oneVOneState[OneVOneField.PLAYERS][1].setPoints, oneVOneState[OneVOneField.PLAYERS][1]))
                wait(addOnSettings[AddOnSetting.ONE_V_ONE_PAUSE])
                #Next point: the loser comes back ("Duels - start game" sets it up)
                ballSpawnCountdown = addOnSettings[AddOnSetting.ONE_V_ONE_COUNTDOWN]
                oneVOneState[OneVOneField.PLAYERS].filter(lambda player: player.isDead()).resurrect()
                return
        getLivingPlayers(Team.ALL)[0].addToScore(1)
        bigMessage(getAllPlayers(), "{0} wins the set, congrats!".format(getLivingPlayers(Team.ALL)[0]))
        wait(roundTimings[RoundTiming.WIN_PAUSE])
    #Next set: the loser stays in the queue, the queue head comes in
    oneVOneState[OneVOneField.PLAYERS] = []
    oneVOneState[OneVOneField.SERVE] = null
    ballSpawnCountdown = setballspawncountdown
    if oneVOneState[OneVOneField.TIME_UP]:
        HighestScore = sorted(getAllPlayers(), lambda player: player.getScore()).last().getScore()
        if len(getAllPlayers().filter(lambda player: player.getScore() == HighestScore)) == 1:
            oneVOneState[OneVOneField.OVER] = true
            enableMusic()
            enableGamemodeCompletion()
            return
        #Tied on sets won: a tiebreaker set between tied players only
        bigMessage(getAllPlayers(), "tiebreaker set!")
        kill(getLivingPlayers(Team.ALL).filter(lambda player: player.getScore() != HighestScore))
        wait(0.25)
        duelQueue.filter(lambda player: player.getScore() == HighestScore).slice(0, 2 - getNumberOfLivingPlayers(Team.ALL)).resurrect()
        return
    duelQueue[0].resurrect()


rule "1v1 - player left":
    @Event playerLeft
    @Condition addOnSettings[AddOnSetting.ONE_V_ONE] == true
    #With players waiting, "1v1 - round end" ends the set
    @Condition len(duelQueue) == 0

    deleteBall()
    stopChasing(ballSpawnCountdown)
    oneVOneRoundEnd()


rule "1v1 - set HUD":
    @Condition addOnSettings[AddOnSetting.ONE_V_ONE] == true

    hudSubtext(getAllPlayers() if len(oneVOneState[OneVOneField.PLAYERS]) == 2 else null, "{0} {1} - {2} {3} | first to {4}".format(oneVOneState[OneVOneField.PLAYERS][0], oneVOneState[OneVOneField.PLAYERS][0].setPoints, oneVOneState[OneVOneField.PLAYERS][1].setPoints, oneVOneState[OneVOneField.PLAYERS][1], addOnSettings[AddOnSetting.ONE_V_ONE_FIRST_TO]), HudPosition.TOP, -1, Color.PURPLE, HudReeval.VISIBILITY_AND_STRING)
    hudSubtext(getAllPlayers() if len(duelQueue.filter(lambda player: not player in oneVOneState[OneVOneField.PLAYERS])) > 0 else null, "next: {0}".format(duelQueue.filter(lambda player: not player in oneVOneState[OneVOneField.PLAYERS])[0]), HudPosition.TOP, -0.5, Color.PURPLE, HudReeval.VISIBILITY_AND_STRING)


rule "1v1 - no timer":
    @Condition addOnSettings[AddOnSetting.ONE_V_ONE] == true
    @Condition addOnSettings[AddOnSetting.ONE_V_ONE_MATCH_LENGTH] == 0
    @Condition isGameInProgress() == true

    #After "Initialization - Match length" sets the match time
    wait(0.25)
    pauseMatchTime()


rule "1v1 - time up":
    @Condition addOnSettings[AddOnSetting.ONE_V_ONE] == true
    @Condition addOnSettings[AddOnSetting.ONE_V_ONE_MATCH_LENGTH] > 0
    @Condition isGameInProgress() == true
    @Condition getMatchTime() == 0

    oneVOneState[OneVOneField.TIME_UP] = true
    bigMessage(getAllPlayers(), "time's up: last set")
