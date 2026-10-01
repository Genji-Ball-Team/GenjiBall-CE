#1v1 duel mode and queue

rule "Duels - Global HUD":
    @Condition addOnSettings[AddOnSetting.DUELS] == true
    
    hudSubtext(getAllPlayers(), "current duel: {0} vs. {1}".format(getLivingPlayers(Team.ALL)[0], getLivingPlayers(Team.ALL)[1]), HudPosition.TOP, -1, Color.PURPLE, HudReeval.VISIBILITY_AND_STRING)


rule "Duels - Queue HUD":
    @Event eachPlayer
    @Condition addOnSettings[AddOnSetting.DUELS] == true
    
    hudSubheader(eventPlayer if eventPlayer.isDead() else null, "You fight in {0} rounds.".format(duelQueue.index(eventPlayer) + 1), HudPosition.TOP, -1, Color.PURPLE, HudReeval.VISIBILITY_AND_STRING)


rule "Duels - kill players when more than two alive":
    @Condition addOnSettings[AddOnSetting.DUELS] == true
    @Condition isGameInProgress() == false
    @Condition getNumberOfLivingPlayers(Team.ALL) > 2
    
    kill(getLivingPlayers(Team.ALL).exclude(target)[0])
    wait(0.5)
    if ruleCondition:
        loop()


rule "Duels - start game":
    @Condition addOnSettings[AddOnSetting.DUELS] == true
    @Condition isGameInProgress() == true
    @Condition len(getLivingPlayers(Team.ALL).filter(lambda player: player.hasMoved)) == 2
    
    wait(0.016, Wait.ABORT_WHEN_FALSE)
    if not ruleCondition:
        return
    setupFinal()


rule "Duels - not enough players alive":
    @Condition addOnSettings[AddOnSetting.DUELS] == true
    @Condition isGameInProgress() == true
    @Condition getNumberOfLivingPlayers(Team.ALL) < 2
    @Condition len(duelQueue) > 0
    
    deleteBall()
    stopChasing(ballSpawnCountdown)
    if getLivingPlayers(Team.ALL)[0].isAlive():
        getLivingPlayers(Team.ALL).addToScore(1)
        bigMessage(getAllPlayers(), "{0} wins, congrats!".format(getLivingPlayers(Team.ALL)[0]))
        wait(roundTimings[RoundTiming.WIN_PAUSE])
    duelQueue[0].resurrect()
    wait(0.5)
    if ruleCondition:
        loop()


rule "Duels - queue dead player":
    @Event playerDied
    @Condition addOnSettings[AddOnSetting.DUELS] == true
    
    duelQueue.append(eventPlayer)


rule "Duels - remove living player from queue":
    @Event eachPlayer
    @Condition eventPlayer.isAlive() == true
    @Condition addOnSettings[AddOnSetting.DUELS] == true
    
    duelQueue.remove(eventPlayer)


rule "Duels - remove leaving player from queue":
    @Event playerLeft
    @Condition addOnSettings[AddOnSetting.DUELS] == true
    
    duelQueue.remove(eventPlayer)
