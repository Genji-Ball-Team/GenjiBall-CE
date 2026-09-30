#Tombstone

rule "†Tombstone†":
    @Event eachPlayer
    @Condition eventPlayer.isAlive() == true
    @Condition eventPlayer.hasMoved == true
    @Condition isGameInProgress() == true
    @Condition "{0}".format(eventPlayer) in ["ifyoureadthisyouverygayong", "ren"] == true
    
    eventPlayer.communicate(Comms.EMOTE_UP)
    eventPlayer.communicate(Comms.EMOTE_LEFT)
    eventPlayer.communicate(Comms.EMOTE_RIGHT)
    eventPlayer.communicate(Comms.EMOTE_DOWN)
    bigMessage(getAllPlayers(), "@{0}, is being banhammered!".format(eventPlayer))
    wait(1)
    eventPlayer.setStatusEffect(null, Status.HACKED, 9999)
    eventPlayer.setStatusEffect(null, Status.BURNING, 9999)
    wait(3.5)
    eventPlayer.removeFromGame()
