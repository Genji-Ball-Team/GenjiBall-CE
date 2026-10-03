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
    
    if RoundInProgress and isGameInProgress():
        kill(eventPlayer)
    eventPlayer.teleport(circleCenter + vect(random.randint(-customTuning[CustomTuning.SPAWN_SPREAD], customTuning[CustomTuning.SPAWN_SPREAD]), customTuning[CustomTuning.SPAWN_HEIGHT], random.randint(-customTuning[CustomTuning.SPAWN_SPREAD], customTuning[CustomTuning.SPAWN_SPREAD])))
    eventPlayer.hasMoved = true
