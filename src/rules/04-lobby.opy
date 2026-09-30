#Waiting for players / joining

rule "Check for <2 players":
    @Condition isGameInProgress() == true
    @Condition getNumberOfPlayers(Team.ALL) == 1
    @Condition getCurrentGamemode() == Gamemode.FFA
    
    IsInFinalDuel = false
    IsEnoughPlayersToStart = false
    stopChasing(ballSpawnCountdown)
    deleteBall()
    if RoundInProgress == false:
        goto lbl_0
    RoundInProgress = false
    lbl_0:
    bigMessage(getAllPlayers(), "Waiting for players")


rule "Wait for more players":
    @Condition isGameInProgress() == true
    @Condition (getNumberOfPlayers(Team.ALL) > 1 or Sandbox == true) == true
    @Condition IsEnoughPlayersToStart == false
    @Condition getCurrentGamemode() == Gamemode.FFA
    
    if Sandbox == true:
        goto lbl_0
    if getNumberOfPlayers(Team.ALL) < 2:
        return
    lbl_0:
    bigMessage(getAllPlayers(), "Lets begin!")
    IsEnoughPlayersToStart = true
    startRound()


rule "Player joins game":
    @Event eachPlayer
    @Condition eventPlayer.hasMoved == false
    @Condition eventPlayer.hasSpawned() == true
    
    if not (RoundInProgress and isGameInProgress()):
        goto lbl_0
    kill(eventPlayer)
    lbl_0:
    eventPlayer.teleport(circleCenter + vect(random.randint(-10, 10), 8, random.randint(-10, 10)))
    eventPlayer.hasMoved = true
