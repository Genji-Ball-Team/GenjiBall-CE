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
    #RoundSetupPending is left as it is: during a round win pause the round win still decides the tiebreaker or the
    #end of the match after the pause, and starts the next round if enough players are back (core/round-flow.opy)
    bigMessage(getAllPlayers(), "Waiting for players")


#A tiebreaker player left during a tiebreaker round and the lobby stopped: the tie is decided again at once, so the
#match ends (time is up) and TieBreakerActive is never left set while the lobby waits. A tie needs two tiebreaker
#players, who both count as playing, so it can't survive a stopped lobby. Only outside a round win pause and the
#tiebreaker's setup (RoundSetupPending): there the round win decides, after the host's latest sit-out press, and
#rechecks after each of its waits (core/round-flow.opy). Right after "Check for <2 players", in the same tick.
rule "Tiebreaker ends when the lobby stops":
    @Condition isGameInProgress() == true
    @Condition TieBreakerActive == true
    @Condition IsEnoughPlayersToStart == false
    @Condition RoundSetupPending == false

    decideTiebreaker()


rule "Wait for more players":
    @Condition isGameInProgress() == true
    @Condition playingPlayers > 1
    @Condition IsEnoughPlayersToStart == false
    @Condition getCurrentGamemode() == Gamemode.FFA
    #No arena on an unsupported map (maps/arenas.opy)
    @Condition MAP_UNSUPPORTED == false
    #Not during a round win pause: the round win starts the next round itself after it, or clears this when
    #too few players are left
    @Condition RoundSetupPending == false
    
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
