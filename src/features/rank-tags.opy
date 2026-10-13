#Rank tags: ranked players get their rank tier's name over their head (the top 10 too, with
#host tool codes that list them with no names; older codes tag them with their place and rating), and the top 10 are listed
#on the right. Grandmaster, Ascendant and Champion players also glow. They come from "RANKS - generated",
#which the host tool replaces (docs/rank-tags.md).


#The host tool replaces this whole rule with one built from the ranked server. Keep it the only thing
#that sets rankTags, and keep its name: the host tool finds it by name in workshop/genjiball.txt.
#rankTags[0] is the line under the list's header. rankTags[1] onward are the rank tiers, lowest first, with
#an empty list line, then the top players, the best last: [label, colour, list line, name, ...].
#Without the host tool there are none.
rule "RANKS - generated":
    rankTags = ["Top 10 comes with the host tool's code"]


#Rank glow: players in these tiers get the Baptiste immortality look, the same as the bot's "bot effect".
#Visual only. Matched by the tier's label, as the ranked server names it (docs/rank-tags.md).
#Checked once, in "Rank tags - find tier" (rankGlow).
#!define RANK_GLOW_TIERS ["Grandmaster", "Ascendant", "Champion"]

#The best entry that lists the player's name, or -1 for none. Once, when they first spawn.
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
    eventPlayer.rankGlow = eventPlayer.rankTier > 0 and rankTags[eventPlayer.rankTier][RankTagField.LABEL] in RANK_GLOW_TIERS
    if eventPlayer.rankTier == 0:
        eventPlayer.rankTier = -1


#One tag per FFA slot, following whoever is in it. Nothing to destroy when a player leaves (the slot's tag
#just has no one to show), and the number of texts never grows. Height and size: "70 - Ranked".
rule "Rank tags - floating tags":
    @Condition rankedState[RankedField.TAGS] == true

    #Entity creation fail protection
    wait(1)
    rankedState[RankedField.TAG_LOOP] = 0
    while rankedState[RankedField.TAG_LOOP] < FFA_SLOTS:
        createInWorldText(
            getAllPlayers() if getPlayersInSlot(evalOnce(rankedState[RankedField.TAG_LOOP]), Team.ALL).rankTier > 0 and getPlayersInSlot(evalOnce(rankedState[RankedField.TAG_LOOP]), Team.ALL).isAlive() else null,
            rankTags[max(getPlayersInSlot(evalOnce(rankedState[RankedField.TAG_LOOP]), Team.ALL).rankTier, 0)][RankTagField.LABEL],
            getPlayersInSlot(evalOnce(rankedState[RankedField.TAG_LOOP]), Team.ALL) + vect(0, evalOnce(rankedState[RankedField.TAG_HEIGHT]), 0),
            rankedState[RankedField.TAG_SIZE],
            Clip.NONE,
            WorldTextReeval.VISIBILITY_POSITION_STRING_AND_COLOR,
            rankTags[max(getPlayersInSlot(evalOnce(rankedState[RankedField.TAG_LOOP]), Team.ALL).rankTier, 0)][RankTagField.COLOR]
        )
        rankedState[RankedField.TAG_LOOP] += 1


#One glow per FFA slot, following whoever is in it, like the tags: hidden while they're dead, nothing to
#destroy when a player leaves, and the number of effects never grows. Off with "70 - Ranked > rank tags".
#Its visibility is re-checked every tick, so it reads the rankGlow flag instead of matching tier names.
#It shares rankedState[TAG_LOOP] with the other loops here, and none of them waits inside its loop.
rule "Rank tags - glow":
    @Condition rankedState[RankedField.TAGS] == true

    #Entity creation fail protection
    wait(1)
    rankedState[RankedField.TAG_LOOP] = 0
    while rankedState[RankedField.TAG_LOOP] < FFA_SLOTS:
        createEffect(
            getAllPlayers() if getPlayersInSlot(evalOnce(rankedState[RankedField.TAG_LOOP]), Team.ALL).rankGlow and getPlayersInSlot(evalOnce(rankedState[RankedField.TAG_LOOP]), Team.ALL).isAlive() else null,
            Effect.BAPTISTE_IMMORTALITY_FIELD_PROTECTED,
            Color.WHITE,
            getPlayersInSlot(evalOnce(rankedState[RankedField.TAG_LOOP]), Team.ALL),
            1,
            EffectReeval.VISIBILITY_POSITION_AND_RADIUS
        )
        rankedState[RankedField.TAG_LOOP] += 1


#The top 10 list on the right, the best first, hidden by simple HUD. Entries with an empty list line aren't listed. Its two header lines sort above
#every entry's line (-30 minus the entry's index), however many entries there are.
#Both loops use rankedState[TAG_LOOP] and have no wait inside, so they can't run into each other.
rule "Rank tags - top 10 list":
    @Condition rankedState[RankedField.GUIDE] == true

    #Entity creation fail protection
    wait(1)
    hudSubtext(getAllPlayers().filter(lambda player: player.simpleHUD == SimpleHud.OFF), "Live leaderboard: genjiball.us", HudPosition.RIGHT, -100, Color.AQUA, HudReeval.VISIBILITY)
    hudSubtext(getAllPlayers().filter(lambda player: player.simpleHUD == SimpleHud.OFF), evalOnce(rankTags[0]), HudPosition.RIGHT, -99, Color.WHITE, HudReeval.VISIBILITY)
    rankedState[RankedField.TAG_LOOP] = len(rankTags) - 1
    while rankedState[RankedField.TAG_LOOP] > 0:
        #A rank tier's entry has no list line: only the top 10 are listed
        if rankTags[rankedState[RankedField.TAG_LOOP]][RankTagField.GUIDE] != "":
            hudSubtext(getAllPlayers().filter(lambda player: player.simpleHUD == SimpleHud.OFF), evalOnce(rankTags[rankedState[RankedField.TAG_LOOP]][RankTagField.GUIDE]), HudPosition.RIGHT, -30 - rankedState[RankedField.TAG_LOOP], evalOnce(rankTags[rankedState[RankedField.TAG_LOOP]][RankTagField.COLOR]), HudReeval.VISIBILITY)
        rankedState[RankedField.TAG_LOOP] -= 1
    #Interact toggles simple HUD, except in Sandbox
    if addOnSettings[AddOnSetting.SANDBOX] == false:
        hudSubtext(getAllPlayers().filter(lambda player: player.simpleHUD == SimpleHud.OFF), "Press [{0}] to hide".format(inputBindingString(Button.INTERACT)), HudPosition.RIGHT, -20, Color.WHITE, HudReeval.VISIBILITY)
