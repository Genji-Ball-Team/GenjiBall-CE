#Waiting for players / joining

rule "Check for <2 players":
    @Condition isGameInProgress() == true
    #A host who sits out doesn't count (features/host-sit-out.opy): with one other player, the lobby waits
    @Condition playingPlayers <= 1
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
    @Condition playingPlayers > 1
    @Condition IsEnoughPlayersToStart == false
    @Condition getCurrentGamemode() == Gamemode.FFA
    #No arena on an unsupported map (maps/arenas.opy)
    @Condition MAP_UNSUPPORTED == false
    
    #The host's latest sit-out choice counts from this round. If it leaves too few players, keep waiting
    applyHostSitOut()
    if playingPlayers <= 1:
        return
    bigMessage(getAllPlayers(), "Let's begin!")
    IsEnoughPlayersToStart = true
    #Players who lost the round before the lobby stopped can still be dead (the host sat out during the win pause)
    resurrectForRound()
    startRound()


rule "Player joins game":
    @Event eachPlayer
    @Condition eventPlayer.hasMoved == false
    @Condition eventPlayer.hasSpawned() == true
    
    if RoundInProgress and isGameInProgress():
        kill(eventPlayer)
    eventPlayer.teleport(circleCenter + vect(random.randint(-10, 10), 8, random.randint(-10, 10)))
    eventPlayer.hasMoved = true
