#Rank tags: the leaderboard's top players get a tag over their head with their place and rating, and a
#top 10 list on the right. Other ranked players get their rank tier's name. Grandmaster, Ascendant and
#Champion players also glow. They come from "RANKS - generated",
#which the host tool replaces (docs/rank-tags.md).


#The host tool replaces this whole rule with one built from the ranked server. Keep it the only thing
#that sets rankTags, and keep its name: the host tool finds it by name in workshop/genjiball.txt.
#rankTags[0] is the line under the list's header. rankTags[1] onward are the rank tiers, lowest first, with
#an empty list line, then the top players, the best last: [label, colour, list line, name, ...].
#Without the host tool there are none.
rule "RANKS - generated":
    rankTags = ["Top 10 comes with the host tool's code"]


#Rank glow: players in these tiers get the Baptiste immortality look, the same as the bot's "bot effect".
#Visual only. Matched by the tier's label, as the ranked server names it (docs/rank-tags.md), or a top player's
#by their tier's colour, once, in "Rank tags - find tier" (rankGlow).
#!define RANK_GLOW_TIERS ["Grandmaster", "Ascendant", "Champion"]

#Destroys the glow of a player in GLOW_OWNERS and takes them off both lists. No wait in between.
#!define removeRankGlow(owner) destroyEffect(rankedState[RankedField.GLOW_EFFECTS][rankedState[RankedField.GLOW_OWNERS].index(owner)])\
rankedState[RankedField.GLOW_EFFECTS].remove(rankedState[RankedField.GLOW_EFFECTS][rankedState[RankedField.GLOW_OWNERS].index(owner)])\
rankedState[RankedField.GLOW_OWNERS].remove(owner)

#A player in GLOW_OWNERS who left the match, or null
#!define RANK_GLOW_LEAVER (rankedState[RankedField.GLOW_OWNERS].filter(lambda player: player not in getAllPlayers())[0])


#No glows yet. Before any player can have a tier (that waits for them to spawn).
rule "Rank tags - glow list":
    rankedState[RankedField.GLOW_OWNERS] = []
    rankedState[RankedField.GLOW_EFFECTS] = []


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
    #A top player's entry has their place as its label, so it's matched by its colour: the host tool gives it their tier's
    eventPlayer.rankGlow = eventPlayer.rankTier > 0 and (rankTags[eventPlayer.rankTier][RankTagField.LABEL] in RANK_GLOW_TIERS or rankTags[eventPlayer.rankTier][RankTagField.COLOR] in [entry[RankTagField.COLOR] for entry in rankTags if entry[RankTagField.LABEL] in RANK_GLOW_TIERS])
    if eventPlayer.rankTier == 0:
        eventPlayer.rankTier = -1


#The player in the slot of the tag being made, followed by that tag
#!define TAGGED_PLAYER getPlayersInSlot(evalOnce(rankedState[RankedField.TAG_LOOP]), Team.ALL)

#One tag per FFA slot, following whoever is in it. Nothing to destroy when a player leaves (the slot's tag
#just has no one to show), and the number of texts never grows. Height and size: "70 - Ranked".
rule "Rank tags - floating tags":
    @Condition rankedState[RankedField.TAGS] == true

    #Entity creation fail protection
    wait(1)
    rankedState[RankedField.TAG_LOOP] = 0
    while rankedState[RankedField.TAG_LOOP] < FFA_SLOTS:
        createInWorldText(
            getAllPlayers() if TAGGED_PLAYER.rankTier > 0 and TAGGED_PLAYER.isAlive() else null,
            rankTags[max(TAGGED_PLAYER.rankTier, 0)][RankTagField.LABEL],
            TAGGED_PLAYER + vect(0, evalOnce(rankedState[RankedField.TAG_HEIGHT]), 0),
            rankedState[RankedField.TAG_SIZE],
            Clip.NONE,
            WorldTextReeval.VISIBILITY_POSITION_STRING_AND_COLOR,
            rankTags[max(TAGGED_PLAYER.rankTier, 0)][RankTagField.COLOR]
        )
        rankedState[RankedField.TAG_LOOP] += 1


#Rank glow: one effect per glowing player, made when they spawn and destroyed when they die or leave, so
#a lobby with no one who glows has no glow at all. Only its position follows them: who sees it is set
#when it's made (everyone, but not its wearer if they hid it), so a player who joins sees it from the
#wearer's next spawn. Off with "70 - Ranked > rank tags".
rule "Rank tags - glow on":
    @Event eachPlayer
    @Condition rankedState[RankedField.TAGS] == true
    @Condition eventPlayer.rankGlow == true
    @Condition eventPlayer.isAlive() == true
    @Condition (eventPlayer in rankedState[RankedField.GLOW_OWNERS]) == false

    createEffect(getAllPlayers().exclude(eventPlayer if eventPlayer.rankGlowHidden else null), Effect.BAPTISTE_IMMORTALITY_FIELD_PROTECTED, Color.WHITE, eventPlayer, 1, EffectReeval.POSITION_AND_RADIUS)
    rankedState[RankedField.GLOW_EFFECTS].append(getLastCreatedEntity())
    rankedState[RankedField.GLOW_OWNERS].append(eventPlayer)


rule "Rank tags - glow off":
    @Event eachPlayer
    @Condition (eventPlayer in rankedState[RankedField.GLOW_OWNERS]) == true
    @Condition (eventPlayer.isAlive() and rankedState[RankedField.TAGS]) == false

    removeRankGlow(eventPlayer)


#A player who leaves can't run "glow off": their glow goes here. Everyone who left, in case two leave in the same tick.
#The leaver is kept in TAG_LOOP for the pass (no wait, so the tag loops can't be running).
rule "Rank tags - glow of a leaver":
    @Event playerLeft

    while any([player not in getAllPlayers() for player in rankedState[RankedField.GLOW_OWNERS]]):
        rankedState[RankedField.TAG_LOOP] = RANK_GLOW_LEAVER
        removeRankGlow(rankedState[RankedField.TAG_LOOP])


#A tap of Crouch hides a glowing player's own glow from them, and shows it again. Everyone else still sees it.
#Holding Crouch (to crouch) or pressing Jump with it (Super Jump) doesn't count. The glow is made again
#("glow on") with the new choice.
rule "Rank tags - hide own glow":
    @Event eachPlayer
    @Condition eventPlayer.isHoldingButton(Button.CROUCH) == true
    @Condition rankedState[RankedField.TAGS] == true
    @Condition eventPlayer.rankGlow == true
    @Condition addOnSettings[AddOnSetting.SANDBOX] == false

    waitUntil(not eventPlayer.isHoldingButton(Button.CROUCH) or eventPlayer.isHoldingButton(Button.JUMP), 0.3)
    if eventPlayer.isHoldingButton(Button.CROUCH) or eventPlayer.isHoldingButton(Button.JUMP):
        return
    eventPlayer.rankGlowHidden = not eventPlayer.rankGlowHidden
    playEffect(eventPlayer, DynamicEffect.BRIGITTE_REPAIR_PACK_ARMOR_SOUND, Color.WHITE, eventPlayer, 10)
    smallMessage(eventPlayer, "your glow: hidden for you" if eventPlayer.rankGlowHidden else "your glow: shown")
    if eventPlayer in rankedState[RankedField.GLOW_OWNERS]:
        removeRankGlow(eventPlayer)


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
