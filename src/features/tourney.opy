#Tourney matches (docs/ranked-log.md, "Tourney matches"): a round-based match in a tourney lobby, set up by
#"TOURNEY - generated", which the host tool replaces (docs/tourney-rule.md). With the rule off (the code
#in this repo), nothing here changes the game: the match is a ranked match.
#The ranked log counts the rounds and logs MATCH_END ROUNDS (features/ranked-log.opy).

#Final standings: the sort order of their header line, at the top of the screen above the unranked warning
#!define TOURNEY_STANDINGS_SORT -40

#A player's place key on the final standings: most wins first, then most kills
#!define tourneyScore(player) (player.tourneyStats[TourneyStat.WINS] * TOURNEY_WIN_WEIGHT + player.tourneyStats[TourneyStat.KILLS])


#The host tool replaces this whole rule with one built from the ranked server. Keep it the only thing
#that sets rankedState[TOURNEY], and keep its name: the host tool finds it by name in workshop/genjiball.txt.
#One array in TourneyField order: on, lobbyKey, round limit, tourney name, lobby label.
#Without the host tool it's off. After "Settings - Workshop settings", which builds rankedState.
rule "TOURNEY - generated":
    rankedState[RankedField.TOURNEY] = [false, "", TOURNEY_DEFAULT_ROUNDS, "", ""]


#In the first tick, after the generated rule and before the startup rules that read what it sets:
#"Initialization - Match length", "Initialization - Disable inspector", "HUD - add-ons text" and
#"Ranked log - MATCH_START" (docs/architecture.md, "Rule order").
rule "Tourney - settings":
    @Condition TOURNEY_ON

    #No match timer and no timed tiebreaker, whatever the preset. Anything but Tournament is unranked anyway.
    tournamentMode = true
    #The rule's round limit replaces "tournament rounds" and the preset's value
    totalRounds = floor(rankedState[RankedField.TOURNEY][TourneyField.ROUND_LIMIT]) if rankedState[RankedField.TOURNEY][TourneyField.ROUND_LIMIT] >= 1 else TOURNEY_DEFAULT_ROUNDS
    #The ranked log counts the rounds and ends the match, and the server needs the log
    rankedState[RankedField.LOGGING] = true


#Holds the ball of the round the round flow starts after the last one: the match ends before its countdown
#does. Set as the last round closes, before the round win pause ends. alert() (maps/restrictions.opy) gives
#no break after the last round, so "Tournament - break" doesn't reset it.
rule "Tourney - hold the next round":
    @Condition TOURNEY_ON
    @Condition rankedState[RankedField.ROUND] >= totalRounds
    @Condition rankedState[RankedField.IN_ROUND] == false

    setballspawncountdown = TOURNEY_MATCH_END_DELAY + TOURNEY_STANDINGS_TIME


#The final standings, for everyone, spectators too (the host may be spectating), once MATCH_END ROUNDS is logged.
#The host screenshots them for the server, so they're the log's numbers (docs/ranked-log.md, "Tourney matches"):
#players in a slot with an id, most wins first, ties broken by kills, the same wins and kills share a place (1, 2, 2, 4).
#Strings are evaluated once: nothing changes after MATCH_END.
rule "Tourney - final standings":
    @Condition rankedState[RankedField.ENDED] == true

    rankedState[RankedField.STANDINGS] = sorted(getAllPlayers().filter(lambda player: player in rankedPlayers), lambda player: -tourneyScore(player))
    hudHeader(getAllPlayers(), "FINAL STANDINGS", HudPosition.TOP, TOURNEY_STANDINGS_SORT, Color.ORANGE, HudReeval.VISIBILITY, SpecVisibility.ALWAYS)
    hudSubheader(getAllPlayers(), "{0}   {1}".format(rankedState[RankedField.TOURNEY][TourneyField.NAME], rankedState[RankedField.TOURNEY][TourneyField.LOBBY_LABEL]), HudPosition.TOP, TOURNEY_STANDINGS_SORT + 1, Color.WHITE, HudReeval.VISIBILITY, SpecVisibility.ALWAYS)
    hudSubtext(getAllPlayers(), "Match {0}".format(rankedState[RankedField.MATCH_KEY]), HudPosition.TOP, TOURNEY_STANDINGS_SORT + 2, Color.WHITE, HudReeval.VISIBILITY, SpecVisibility.ALWAYS)
    #One line per player: place, name, wins, kills. The place is 1 + the players with a better score.
    rankedState[RankedField.COUNT] = 0
    while rankedState[RankedField.COUNT] < len(rankedState[RankedField.STANDINGS]):
        hudSubheader(getAllPlayers(), "{0}. {1}   {2}".format(
            len([player for player in rankedState[RankedField.STANDINGS] if tourneyScore(player) > tourneyScore(rankedState[RankedField.STANDINGS][rankedState[RankedField.COUNT]])]) + 1,
            rankedState[RankedField.STANDINGS][rankedState[RankedField.COUNT]],
            "{0} wins   {1} kills".format(
                rankedState[RankedField.STANDINGS][rankedState[RankedField.COUNT]].tourneyStats[TourneyStat.WINS],
                rankedState[RankedField.STANDINGS][rankedState[RankedField.COUNT]].tourneyStats[TourneyStat.KILLS]
            )
        ), HudPosition.TOP, TOURNEY_STANDINGS_SORT + 3 + rankedState[RankedField.COUNT], Color.WHITE, HudReeval.VISIBILITY, SpecVisibility.ALWAYS)
        rankedState[RankedField.COUNT] += 1
    #Time for the screenshot, then the match ends as in "Tournament - game ends after 0 Rounds left"
    wait(TOURNEY_STANDINGS_TIME)
    setMatchTime(0)
    enableGamemodeCompletion()
