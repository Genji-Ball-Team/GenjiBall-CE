#Rank tags: the top tiers get a tag over their head, and a guide on the right lists the tiers.
#The tiers and names come from "RANKS - generated", which the host tool replaces (docs/rank-tags.md).


#The host tool replaces this whole rule with one built from the ranked server. Keep it the only thing
#that sets rankTags, and keep its name: the host tool finds it by name in workshop/genjiball.txt.
#rankTags[0] is the line under the guide's header. rankTags[1] onward are the tiers, lowest first:
#[label, colour, guide line, name, name, ...]. Without the host tool, the tiers have no names.
rule "RANKS - generated":
    rankTags = [
        "Ranks update daily",
        ["Master", rgba(255, 215, 0, 255), "Master"],
        ["Grandmaster", rgba(255, 140, 0, 255), "Grandmaster"],
        ["Ascendant", rgba(60, 160, 255, 255), "Ascendant"],
        ["Champion", rgba(150, 0, 0, 255), "Champion"],
        ["God", rgba(160, 160, 160, 255), "God"]
    ]


#The highest tier that lists the player's name, or -1 for none. Once, when they first spawn.
#Only the names are searched (from RankTagField.NAMES), so a player named like a label isn't matched.
rule "Rank tags - find tier":
    @Event eachPlayer
    @Condition eventPlayer.hasSpawned() == true
    @Condition eventPlayer.rankTier == 0

    #As in v1.3.2 RANKED: the name isn't known the moment a bot takes a slot
    wait(0.25)
    eventPlayer.rankTier = len(rankTags) - 1
    while eventPlayer.rankTier > 0 and "{0}".format(eventPlayer) not in rankTags[eventPlayer.rankTier].slice(RankTagField.NAMES, len(rankTags[eventPlayer.rankTier]) - RankTagField.NAMES):
        eventPlayer.rankTier -= 1
    if eventPlayer.rankTier == 0:
        eventPlayer.rankTier = -1


#One tag per FFA slot, following whoever is in it. Nothing to destroy when a player leaves (the slot's tag
#just has no one to show), and the number of texts never grows.
rule "Rank tags - floating tags":
    #Entity creation fail protection
    wait(1)
    rankedState[RankedField.TAG_LOOP] = 0
    while rankedState[RankedField.TAG_LOOP] < FFA_SLOTS:
        createInWorldText(
            getAllPlayers() if getPlayersInSlot(evalOnce(rankedState[RankedField.TAG_LOOP]), Team.ALL).rankTier > 0 and getPlayersInSlot(evalOnce(rankedState[RankedField.TAG_LOOP]), Team.ALL).isAlive() else null,
            rankTags[max(getPlayersInSlot(evalOnce(rankedState[RankedField.TAG_LOOP]), Team.ALL).rankTier, 0)][RankTagField.LABEL],
            getPlayersInSlot(evalOnce(rankedState[RankedField.TAG_LOOP]), Team.ALL) + vect(0, 1.5, 0),
            1,
            Clip.NONE,
            WorldTextReeval.VISIBILITY_POSITION_STRING_AND_COLOR,
            rankTags[max(getPlayersInSlot(evalOnce(rankedState[RankedField.TAG_LOOP]), Team.ALL).rankTier, 0)][RankTagField.COLOR]
        )
        rankedState[RankedField.TAG_LOOP] += 1


#The tier guide on the right, highest tier first, hidden by simple HUD.
#Both loops use rankedState[TAG_LOOP] and have no wait inside, so they can't run into each other.
rule "Rank tags - tier guide":
    #Entity creation fail protection
    wait(1)
    hudSubtext(getAllPlayers().filter(lambda player: player.simpleHUD == SimpleHud.OFF), "Live leaderboard: genjiball.us", HudPosition.RIGHT, -40, Color.AQUA, HudReeval.VISIBILITY)
    hudSubtext(getAllPlayers().filter(lambda player: player.simpleHUD == SimpleHud.OFF), evalOnce(rankTags[0]), HudPosition.RIGHT, -39, Color.WHITE, HudReeval.VISIBILITY)
    rankedState[RankedField.TAG_LOOP] = len(rankTags) - 1
    while rankedState[RankedField.TAG_LOOP] > 0:
        hudSubtext(getAllPlayers().filter(lambda player: player.simpleHUD == SimpleHud.OFF), evalOnce(rankTags[rankedState[RankedField.TAG_LOOP]][RankTagField.GUIDE]), HudPosition.RIGHT, -30 - rankedState[RankedField.TAG_LOOP], evalOnce(rankTags[rankedState[RankedField.TAG_LOOP]][RankTagField.COLOR]), HudReeval.VISIBILITY)
        rankedState[RankedField.TAG_LOOP] -= 1
    #Interact toggles simple HUD, except in Sandbox
    if addOnSettings[AddOnSetting.SANDBOX] == false:
        hudSubtext(getAllPlayers().filter(lambda player: player.simpleHUD == SimpleHud.OFF), "Press [{0}] to hide".format(inputBindingString(Button.INTERACT)), HudPosition.RIGHT, -20, Color.WHITE, HudReeval.VISIBILITY)
