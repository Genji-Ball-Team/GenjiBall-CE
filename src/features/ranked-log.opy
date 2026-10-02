#Ranked log: match and player events for the ranked server, written with Log To Inspector.
#The format is docs/ranked-log.md: change it there first. Event-only, never per tick.
#With "70 - Ranked > ranked logging" off, none of these rules fire.

#A player in rankedPlayers who isn't in a slot any more and has no LEAVE yet
#!define rankedLeaver (rankedPlayers.filter(lambda player: player != -1 and player not in getAllPlayers())[0])


#Gives every player in a slot without an id the next id, and logs their JOIN.
#Called at MATCH_START for the players already there, then for each player who joins.
def logRankedJoins():
    @Name "Ranked log - JOIN"

    while any([player not in rankedPlayers for player in getAllPlayers()]):
        rankedPlayers.append(getAllPlayers().filter(lambda player: player not in rankedPlayers)[0])
        logToInspector("JOIN|{0}|{1}|{2}".format(getTotalTimeElapsed(), len(rankedPlayers) - 1, rankedPlayers.last()))


rule "Ranked log - MATCH_START":
    @Condition rankedState[RankedField.LOGGING] == true
    @Condition isGameInProgress() == true

    #Ids start at 1: index 0 is never a player.
    rankedPlayers = [-1]
    logToInspector("GBR|{0}|1|1.3.3R".format(getTotalTimeElapsed()))
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

    logRankedJoins()


rule "Ranked log - LEAVE":
    @Event playerLeft
    @Condition rankedState[RankedField.STARTED] == true

    #Everyone who left since the last LEAVE, in case two leave in the same tick.
    #A player's index in rankedPlayers is their id.
    while any([player != -1 and player not in getAllPlayers() for player in rankedPlayers]):
        logToInspector("LEAVE|{0}|{1}".format(getTotalTimeElapsed(), rankedPlayers.index(rankedLeaver)))
        rankedPlayers[rankedPlayers.index(rankedLeaver)] = -1


rule "Ranked log - MATCH_END":
    @Condition rankedState[RankedField.STARTED] == true
    @Condition isMatchComplete() == true

    logToInspector("MATCH_END|{0}|TIME".format(getTotalTimeElapsed()))
