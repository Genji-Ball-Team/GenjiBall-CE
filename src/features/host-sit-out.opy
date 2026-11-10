#Host sit-out (docs/ranked-log.md, "Host sit-out"): in a ranked lobby the host plays the first round, then
#stays in their slot, dead, so the lobby keeps going without them. Crouch + Interact switches it, from the next round.
#The round flow calls applyHostSitOut() between rounds and brings players back with resurrectForRound()
#(core/round-flow.opy). A host who sits out doesn't count toward the players a round needs (playingPlayers).
#
#rankedState holds the state: SIT_OUT_WISH is what the host chose, SITTING_OUT what is in effect now.


#Brings back the players for the next round: everyone dead but a host who sits out. A host who starts
#sitting out right after winning is still alive, and is killed so the round starts without them.
#The lobby bot (features/lobby-bot.opy) leaves here at the latest once two players can play without it, so no
#round starts with it then. No wait: it's killed first, so even if it's only gone next tick it isn't brought back
#here or picked as the target (randomTarget() picks a living player).
def resurrectForRound():
    @Name "Host sit-out - bring back players"

    if lobbyBotIn and humansPlaying > 1:
        kill(getAllPlayers().filter(lambda player: player.isDummy()), null)
        destroyAllDummies()
        getDeadPlayers(Team.ALL).filter(lambda player: not sitsOut(player) and not player.isDummy()).resurrect()
    else:
        getDeadPlayers(Team.ALL).filter(lambda player: not sitsOut(player)).resurrect()
    if rankedState[RankedField.SITTING_OUT] and hostPlayer.isAlive():
        kill(hostPlayer, null)


#Puts the host's choice into effect, between rounds or while the lobby waits for players. Logs SIT_OUT when it changes.
def applyHostSitOut():
    @Name "Host sit-out - take effect"

    if rankedState[RankedField.SITTING_OUT] == rankedState[RankedField.SIT_OUT_WISH]:
        return
    rankedState[RankedField.SITTING_OUT] = rankedState[RankedField.SIT_OUT_WISH]
    if rankedState[RankedField.STARTED] and hostPlayer in rankedPlayers:
        logToInspector("SIT_OUT|{0}|{1}|{2}".format(getTotalTimeElapsed(), rankedPlayers.index(hostPlayer), 1 if rankedState[RankedField.SITTING_OUT] else 0))


#A ranked match: the host sits out from round 2. Set as the first round without the lobby bot starts, so the host plays it.
#A tourney's host plays until they press the button.
rule "Host sit-out - from round 2":
    @Condition rankedState[RankedField.SIT_OUT_READY] == false
    @Condition isGameInProgress() == true
    @Condition IsEnoughPlayersToStart == true
    @Condition RoundInProgress == true
    #A lobby bot round isn't the first round: a host alone with it keeps playing. From the latch (botRound), so a
    #bot round stays one after the bot leaves during it; startRound() sets it before it clears RoundSetupPending
    @Condition botRound == false
    @Condition RoundSetupPending == false

    rankedState[RankedField.SIT_OUT_READY] = true
    rankedState[RankedField.SIT_OUT_HOST] = hostPlayer
    if not TOURNEY_ON:
        rankedState[RankedField.SIT_OUT_WISH] = true


#A new host (the old one left) plays until they press the button
rule "Host sit-out - new host":
    @Condition rankedState[RankedField.SIT_OUT_READY] == true
    @Condition hostPlayer != rankedState[RankedField.SIT_OUT_HOST]

    rankedState[RankedField.SIT_OUT_HOST] = hostPlayer
    rankedState[RankedField.SIT_OUT_WISH] = false
    rankedState[RankedField.SITTING_OUT] = false


#Crouch + Interact: the host switches between sitting out and playing, from the next round.
#While the lobby waits for players there's no round to wait for, so it takes effect at once.
rule "Host sit-out - button":
    @Event eachPlayer
    @Condition eventPlayer == hostPlayer
    @Condition eventPlayer.isHoldingButton(Button.CROUCH) == true
    @Condition eventPlayer.isHoldingButton(Button.INTERACT) == true

    rankedState[RankedField.SIT_OUT_WISH] = not rankedState[RankedField.SIT_OUT_WISH]
    rankedState[RankedField.SIT_OUT_HOST] = hostPlayer
    #Pressed before the first round: their choice, not the default
    rankedState[RankedField.SIT_OUT_READY] = true
    smallMessage(eventPlayer, "sitting out from the next round" if rankedState[RankedField.SIT_OUT_WISH] else "playing from the next round")
    playEffect(eventPlayer, DynamicEffect.BRIGITTE_REPAIR_PACK_ARMOR_SOUND, Color.WHITE, eventPlayer, 10)
    if isGameInProgress() and not IsEnoughPlayersToStart:
        applyHostSitOut()
        if not rankedState[RankedField.SITTING_OUT] and eventPlayer.isDead():
            eventPlayer.resurrect()
    waitUntil(not eventPlayer.isHoldingButton(Button.INTERACT), 99999)


#Keeps a host who sits out out of the lobby while it waits for players: they sat out while alone, or came
#back from spectator. The next round can't start with them alive.
rule "Host sit-out - stay out while waiting":
    @Condition rankedState[RankedField.SITTING_OUT] == true
    @Condition isGameInProgress() == true
    @Condition IsEnoughPlayersToStart == false
    @Condition hostPlayer.isAlive() == true

    kill(hostPlayer, null)


#The host's line, with the other controls on the left: what the button does now
rule "Host sit-out - HUD":
    #Entity creation fail protection
    wait(1)
    hudSubheader(hostPlayer if hostPlayer.simpleHUD == SimpleHud.OFF or rankedState[RankedField.SITTING_OUT] or rankedState[RankedField.SIT_OUT_WISH] else null, "{0} [{1}]".format(
        "sitting out: play" if rankedState[RankedField.SITTING_OUT] and rankedState[RankedField.SIT_OUT_WISH] else "sitting out from the next round: keep playing" if rankedState[RankedField.SIT_OUT_WISH] else "playing from the next round: keep sitting out" if rankedState[RankedField.SITTING_OUT] else "sit out",
        "{0} + {1}".format(inputBindingString(Button.CROUCH), inputBindingString(Button.INTERACT))
    ), HudPosition.LEFT, 0, Color.WHITE if not rankedState[RankedField.SITTING_OUT] else Color.ORANGE, HudReeval.VISIBILITY_STRING_AND_COLOR)
