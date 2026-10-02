#Ranked log: match and player events for the ranked server, written with Log To Inspector.
#The format is docs/ranked-log.md: change it there first. Event-only, never per tick.
#With "70 - Ranked > ranked logging" off, none of these rules fire.

#A player in rankedPlayers who isn't in a slot any more and has no LEAVE yet
#!define rankedLeaver (rankedPlayers.filter(lambda player: player != -1 and player not in getAllPlayers())[0])


#Gives every spawned player without an id the next id, and logs their JOIN.
#Called at MATCH_START for the players already there, then for each player who joins.
#Only once spawned: an AI bot logged the moment it took a slot had no name yet ("Entity 84").
def logRankedJoins():
    @Name "Ranked log - JOIN"

    while any([player not in rankedPlayers and player.hasSpawned() for player in getAllPlayers()]):
        rankedPlayers.append(getAllPlayers().filter(lambda player: player not in rankedPlayers and player.hasSpawned())[0])
        logToInspector("JOIN|{0}|{1}|{2}".format(getTotalTimeElapsed(), len(rankedPlayers) - 1, rankedPlayers.last()))


rule "Ranked log - MATCH_START":
    @Condition rankedState[RankedField.LOGGING] == true
    @Condition isGameInProgress() == true

    #Ids start at 1: index 0 is never a player.
    rankedPlayers = [-1]
    rankedRound = []
    rankedState[RankedField.ROUND] = 0
    rankedState[RankedField.IN_ROUND] = false
    #matchKey: 12 random digits, so the server can tell repeated copies of this match apart from other matches
    logToInspector("GBR|{0}|1|1.3.3R|{1}{2}".format(getTotalTimeElapsed(), random.randint(100000, 999999), random.randint(100000, 999999)))
    #feel: any setting that changes how the ball or a player moves, controls or deflects (docs/ranked-log.md)
    #addOns: the gameplay add-ons that are on, comma-separated
    logToInspector("MATCH_START|{0}|{1}|{2}|{3}|{4}".format(
        getTotalTimeElapsed(),
        "workshop-island-night" if __getCurrentMap__() == Map.WORKSHOP_ISLAND_NIGHT else "other",
        ["Default", "Tournament", "Tournament+", "Rapid", "v1", "v7", "Experimental", "Custom"][presetMode],
        1 if ballFeel[BallFeel.CUSTOM] or addOnSettings[AddOnSetting.WATER_LEDGE_FIX] or addOnSettings[AddOnSetting.TRACING_MODE] or antiGhostMode != AntiGhost.OFF or antiOrbitMode else 0,
        "{0}{1}{2}{3}".format(
            "duels" if addOnSettings[AddOnSetting.DUELS] else "",
            "{0}endless".format("," if addOnSettings[AddOnSetting.DUELS] else "") if addOnSettings[AddOnSetting.ENDLESS] else "",
            "{0}sandbox".format("," if addOnSettings[AddOnSetting.DUELS] or addOnSettings[AddOnSetting.ENDLESS] else "") if addOnSettings[AddOnSetting.SANDBOX] else "",
            "{0}abilities".format("," if addOnSettings[AddOnSetting.DUELS] or addOnSettings[AddOnSetting.ENDLESS] or addOnSettings[AddOnSetting.SANDBOX] else "") if addOnSettings[AddOnSetting.ABILITIES] else ""
        )
    ))
    logRankedJoins()
    rankedState[RankedField.STARTED] = true


rule "Ranked log - player joins":
    @Event eachPlayer
    @Condition rankedState[RankedField.STARTED] == true
    @Condition (eventPlayer in rankedPlayers) == false
    @Condition eventPlayer.hasSpawned() == true

    logRankedJoins()


rule "Ranked log - LEAVE":
    @Event playerLeft
    @Condition rankedState[RankedField.STARTED] == true

    #Everyone who left since the last LEAVE, in case two leave in the same tick.
    #A player's index in rankedPlayers is their id.
    while any([player != -1 and player not in getAllPlayers() for player in rankedPlayers]):
        logToInspector("LEAVE|{0}|{1}".format(getTotalTimeElapsed(), rankedPlayers.index(rankedLeaver)))
        #Out of the round, without an ELIM: the server drops them from it
        rankedRound.remove(rankedLeaver)
        rankedPlayers[rankedPlayers.index(rankedLeaver)] = -1


#Rounds. A round is open from ROUND_START to ROUND_END (rankedState[IN_ROUND]).
#These rules only watch the round flow's variables (core/round-flow.opy, core/lobby.opy), they never change them.
#They come after those rules, so in a shared tick they see what the round flow has just done
#(docs/architecture.md, "Rule order").

#A round starts when startRound() (or setupFinal() after a restart with two players) has cleared
#RoundSetupPending and at least two players are alive. Not at the final duel: that's the same round, still open.
rule "Ranked log - ROUND_START":
    @Condition rankedState[RankedField.STARTED] == true
    @Condition rankedState[RankedField.IN_ROUND] == false
    @Condition isGameInProgress() == true
    @Condition IsEnoughPlayersToStart == true
    @Condition RoundSetupPending == false
    @Condition (RoundInProgress or IsInFinalDuel) == true
    @Condition getNumberOfLivingPlayers(Team.ALL) > 1

    #Everyone alive needs an id before it's listed
    logRankedJoins()
    rankedState[RankedField.ROUND] += 1
    rankedState[RankedField.IN_ROUND] = true
    #In the round: everyone alive now. Players who join later are killed by "Player joins game" and play from the next round.
    rankedRound = sorted(getLivingPlayers(Team.ALL), lambda player: rankedPlayers.index(player))
    #ids, comma-separated
    rankedState[RankedField.TEXT] = rankedPlayers.index(rankedRound[0])
    rankedState[RankedField.COUNT] = 1
    while rankedState[RankedField.COUNT] < len(rankedRound):
        rankedState[RankedField.TEXT] = "{0},{1}".format(rankedState[RankedField.TEXT], rankedPlayers.index(rankedRound[rankedState[RankedField.COUNT]]))
        rankedState[RankedField.COUNT] += 1
    logToInspector("ROUND_START|{0}|{1}|{2}".format(getTotalTimeElapsed(), rankedState[RankedField.ROUND], rankedState[RankedField.TEXT]))


#Any death of a player still in the round: the ball, or anything else.
#killer: the attacker, which deflectFail() sets to the last deflector (prevTarget). Empty for none or the player themself.
#place: the players in the round still alive after them, plus 1. Two deaths in one tick share a place.
rule "Ranked log - ELIM":
    @Event playerDied
    @Condition rankedState[RankedField.IN_ROUND] == true
    @Condition (eventPlayer in rankedRound) == true

    rankedRound.remove(eventPlayer)
    logToInspector("ELIM|{0}|{1}|{2}|{3}|{4}".format(
        getTotalTimeElapsed(),
        rankedState[RankedField.ROUND],
        rankedPlayers.index(eventPlayer),
        rankedPlayers.index(attacker) if attacker != eventPlayer and attacker in rankedPlayers else "",
        len([player for player in rankedRound if player.isAlive()]) + 1
    ))


#Stopped before anyone won: "Check for <2 players" (core/lobby.opy) ended it.
#When a player leaves a two-player round, that rule clears IsEnoughPlayersToStart earlier in the same tick,
#so the WIN rule below doesn't give the round to the one left behind.
rule "Ranked log - ROUND_END ABORT":
    @Condition rankedState[RankedField.IN_ROUND] == true
    @Condition IsEnoughPlayersToStart == false

    logRankedRoundAbort()


#One player in the round is left and alive, once every other one has an ELIM or a LEAVE.
#The same win as "Active game - check for last player surviving".
rule "Ranked log - ROUND_END WIN":
    @Condition rankedState[RankedField.IN_ROUND] == true
    @Condition IsEnoughPlayersToStart == true
    @Condition len(rankedRound) == 1
    @Condition rankedRound[0].isAlive() == true
    @Condition getNumberOfLivingPlayers(Team.ALL) == 1

    logToInspector("ROUND_END|{0}|{1}|{2}|WIN".format(getTotalTimeElapsed(), rankedState[RankedField.ROUND], rankedPlayers.index(rankedRound[0])))
    rankedRound = []
    rankedState[RankedField.IN_ROUND] = false


#Everyone in the round is out. "Active game - all players dead" restarts it, which is a new round.
#Not on the number of living players: that rule resurrects everyone in the same tick.
rule "Ranked log - ROUND_END NONE":
    @Condition rankedState[RankedField.IN_ROUND] == true
    @Condition len(rankedRound) == 0

    logToInspector("ROUND_END|{0}|{1}||NONE".format(getTotalTimeElapsed(), rankedState[RankedField.ROUND]))
    rankedState[RankedField.IN_ROUND] = false


def logRankedRoundAbort():
    @Name "Ranked log - abort the open round"

    logToInspector("ROUND_END|{0}|{1}||ABORT".format(getTotalTimeElapsed(), rankedState[RankedField.ROUND]))
    rankedRound = []
    rankedState[RankedField.IN_ROUND] = false


rule "Ranked log - MATCH_END":
    @Condition rankedState[RankedField.STARTED] == true
    @Condition isMatchComplete() == true

    #A round still open when the match ends (Tournament's round limit) never got a winner
    if rankedState[RankedField.IN_ROUND]:
        logRankedRoundAbort()
    logToInspector("MATCH_END|{0}|TIME".format(getTotalTimeElapsed()))
