#Waiting for players / joining

rule "Check for <2 players":
    @Condition isGameInProgress() == true
    @Condition getNumberOfPlayers(Team.ALL) == 1
    @Condition getCurrentGamemode() == Gamemode.FFA
    
    IsInFinalDuel = false
    IsEnoughPlayersToStart = false
    stopChasing(ballSpawnCountdown)
    deleteBall()
    RoundInProgress = false
    RoundSetupPending = false
    bigMessage(getAllPlayers(), "Waiting for players")


rule "Wait for more players":
    @Condition isGameInProgress() == true
    @Condition (getNumberOfPlayers(Team.ALL) > 1 or addOnSettings[AddOnSetting.SANDBOX] == true) == true
    @Condition IsEnoughPlayersToStart == false
    @Condition getCurrentGamemode() == Gamemode.FFA
    #No arena on an unsupported map (maps/arenas.opy)
    @Condition MAP_UNSUPPORTED == false
    
    if addOnSettings[AddOnSetting.SANDBOX] != true and getNumberOfPlayers(Team.ALL) < 2:
        return
    bigMessage(getAllPlayers(), "Let's begin!")
    IsEnoughPlayersToStart = true
    startRound()


rule "Player joins game":
    @Event eachPlayer
    @Condition eventPlayer.hasMoved == false
    @Condition eventPlayer.hasSpawned() == true

    eventPlayer.teleport(circleCenter + vect(random.randint(-10, 10), 8, random.randint(-10, 10)))
    #From vTec: a player who joins mid-round isn't killed the moment they spawn (a group joining at once lagged
    #the lobby). They sit out hidden and frozen, out of the round (hasMoved stays false), until the round ends
    #or JOIN_SIT_OUT_TIME passes, then die if a round is on. Killed during a round win, they're revived with the others.
    if RoundInProgress and isGameInProgress() and not addOnSettings[AddOnSetting.DUELS]:
        eventPlayer.setInvisibility(Invis.ALL)
        eventPlayer.disablePlayerCollision()
        eventPlayer.setAbility1Enabled(false)
        eventPlayer.setAbility2Enabled(false)
        eventPlayer.startForcingPosition(eventPlayer.getPosition(), false)
        waitUntil(RoundSetupPending or not RoundInProgress or not isGameInProgress(), JOIN_SIT_OUT_TIME)
        #They may have left during the wait
        if not entityExists(eventPlayer):
            return
        if RoundInProgress and isGameInProgress():
            kill(eventPlayer)
        eventPlayer.stopForcingPosition()
        eventPlayer.setAbility1Enabled(true)
        eventPlayer.setAbility2Enabled(true)
        eventPlayer.enablePlayerCollision()
        eventPlayer.setInvisibility(Invis.NONE)
    elif RoundInProgress and isGameInProgress():
        kill(eventPlayer)
    eventPlayer.hasMoved = true
