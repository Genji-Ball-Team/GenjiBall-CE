#Lobby bot ("[BOT] Genji Bot"): FealthyC's bot, built on gybbus's zBozo bots (CREDITS.md). In a ranked lobby it plays
#whenever one player would be alone (humansPlaying is 1: a host who sits out doesn't count), so they aren't stuck waiting.
#It leaves between rounds once a second player can play ("Lobby bot - leave for a second player", and at the latest
#resurrectForRound() in features/host-sit-out.opy), or at once when no one plays. Never in a tourney.
#
#The ranked log leaves it out (docs/ranked-log.md, "Lobby bot"): no JOIN or id, and no round opens while it's in.
#Rounds with it don't count in the game either: no score for the round win (core/round-flow.opy), and it's never in
#a tiebreaker (tiebreakerPlayers), so it can't win the match. It counts as a player for the lobby (playingPlayers).
#Whether a round is a bot round is latched once, as it starts (botRound, set by startRound()): scoring, the ranked
#log's ROUND_START and the host's first round read the latch, never lobbyBotIn, since the bot can leave mid-round.
#Before the match ends it leaves for good (lobbyBotLeavesForGood()), so it's never on the end screen.
#
#Its deflects are in core/collision.opy (it presses deflect as the ball reaches it, or misses) and its dash at the
#end of a deflect in "Controls - Shorten deflect length" (core/controls.opy). These rules aim and move it.
#The island is at x = 0, z = 0, so the distances from the center below are plain x and z.


rule "Lobby bot - join":
    @Condition isGameInProgress() == true
    @Condition TOURNEY_ON == false
    #No round on an unsupported map (maps/arenas.opy)
    @Condition MAP_UNSUPPORTED == false
    @Condition lobbyBotIn == false
    @Condition humansPlaying == 1
    #Not once the match is ending
    @Condition rankedState[RankedField.BOT_GONE] == false

    createDummy(Hero.GENJI, Team.ALL, -1, null, null)


#No one to play with (the only player left, or the host now sits out), a tourney started, or the match is ending
rule "Lobby bot - leave":
    @Condition lobbyBotIn == true
    @Condition (humansPlaying == 0 or TOURNEY_ON or rankedState[RankedField.BOT_GONE]) == true

    destroyAllDummies()


#A second player can play: the bot leaves once it's dead (killed in its round, or that round ended with everyone
#dead), or at once while the lobby waits for players. Alive, it stays through its round and the round win pause, so
#its round isn't cut short and a round it won isn't left with no one alive ("Active game - all players dead");
#resurrectForRound() (features/host-sit-out.opy) removes it before the next round. A player who joins mid-round waits
#for the next one anyway. Killed first, so it isn't brought back or picked as the target if it's only gone the next tick.
rule "Lobby bot - leave for a second player":
    @Condition lobbyBotIn == true
    @Condition humansPlaying > 1
    @Condition (not IsEnoughPlayersToStart or not any([player.isDummy() for player in getLivingPlayers(Team.ALL)])) == true

    kill(getAllPlayers().filter(lambda player: player.isDummy()), null)
    destroyAllDummies()


#Called right before every match end enables completion (core/round-flow.opy, features/tournament.opy,
#features/tourney.opy): the bot leaves and can't join again, so it's never among the winners on the end screen
#(with everyone on 0 points it would tie for first). Waits until it's gone, at most 1 s; no wait without it.
def lobbyBotLeavesForGood():
    @Name "Lobby bot - leave for the end of the match"

    rankedState[RankedField.BOT_GONE] = true
    if lobbyBotIn:
        destroyAllDummies()
        waitUntil(not lobbyBotIn, 1)


rule "Lobby bot - name":
    @Event eachPlayer
    @Condition eventPlayer.isDummy() == true

    eventPlayer.lobbyBot = []
    eventPlayer.startForcingName("[BOT] Genji Bot")


rule "Lobby bot - EMP death effect":
    @Event playerDied
    @Condition eventPlayer.isDummy() == true

    playEffect(getAllPlayers(), DynamicEffect.SOMBRA_EMP_EXPLOSION_EFFECT, Color.PURPLE, eventPlayer.getPosition(), 15)
    playEffect(getAllPlayers(), DynamicEffect.SOMBRA_EMP_EXPLOSION_SOUND, Color.WHITE, eventPlayer.getPosition(), 200)
    playEffect(getAllPlayers(), DynamicEffect.RING_EXPLOSION, Color.PURPLE, eventPlayer.getPosition(), 30)
    playEffect(getAllPlayers(), DynamicEffect.RING_EXPLOSION, Color.VIOLET, eventPlayer.getPosition() + vect(0, 1, 0), 20)
    wait(0.15)
    playEffect(getAllPlayers(), DynamicEffect.RING_EXPLOSION, Color.PURPLE, eventPlayer.getPosition(), 45)


#Far from the ball: look between the ball and the target
rule "Lobby bot - face the ball":
    @Event eachPlayer
    @Condition eventPlayer.isDummy() == true
    @Condition distance(eventPlayer.getEyePosition(), ballPosition) >= 2 * (ballSpeed / 20)
    @Condition eventPlayer.isAlive() == true
    @Condition eventPlayer.lobbyBot[LobbyBot.ACE_DASH] != true
    @Condition eventPlayer.isUsingAbility1() == false
    @Condition eventPlayer.isUsingAbility2() == false
    @Condition eventPlayer.hasStatus(Status.STUNNED) == false

    eventPlayer.startFacing(directionTowards(eventPlayer.getEyePosition(), (ballPosition + target.getEyePosition()) / 2), 1000)


#Edash: right after its deflect, if the ball comes back at it (it's the target again) or the next deflect sends
#it straight back, it faces the ball. The dash itself comes at the end of the deflect (LobbyBot.EDASH).
rule "Lobby bot - edash when needed":
    @Event eachPlayer
    @Condition eventPlayer.isDummy() == true
    @Condition ballIsOut == true
    @Condition eventPlayer.isUsingAbility2() == true

    waitUntil(eventPlayer != target and (target.isUsingAbility1() or target.isUsingAbility2()), 0.25)
    if eventPlayer == target:
        if angleBetweenVectors(ballDirection, directionTowards(ballPosition, eventPlayer.getEyePosition())) < 20:
            eventPlayer.lobbyBot[LobbyBot.EDASH] = true
            eventPlayer.setFacing(evalOnce(directionTowards(eventPlayer.getEyePosition(), ballPosition)), Relativity.TO_WORLD)
            eventPlayer.startFacing(evalOnce(directionTowards(eventPlayer.getEyePosition(), ballPosition)), 10000)
            waitUntil(eventPlayer.isHoldingButton(Button.ABILITY_1) or eventPlayer.isDead(), 1)
            eventPlayer.lobbyBot[LobbyBot.EDASH] = false
    elif eventPlayer == prevTarget:
        if target.isUsingAbility1() or target.isUsingAbility2():
            if angleBetweenVectors(ballDirection, directionTowards(ballPosition, target.getEyePosition())) < 20:
                eventPlayer.lobbyBot[LobbyBot.EDASH] = true
                eventPlayer.setFacing(evalOnce(directionTowards(eventPlayer.getEyePosition(), ballPosition)), Relativity.TO_WORLD)
                eventPlayer.startFacing(evalOnce(directionTowards(eventPlayer.getEyePosition(), ballPosition)), 10000)
                waitUntil(eventPlayer.isHoldingButton(Button.ABILITY_1) or eventPlayer.isDead(), 1)
                eventPlayer.lobbyBot[LobbyBot.EDASH] = false


#A jump or a double jump every 1 or 2 s while the ball is out
rule "Lobby bot - jumping":
    @Event eachPlayer
    @Condition eventPlayer.isDummy() == true
    @Condition ballIsOut == true

    if random.choice([1, 2]) == 2:
        eventPlayer.forceButtonPress(Button.JUMP)
        wait(0.35)
        eventPlayer.forceButtonPress(Button.JUMP)
        wait(random.randint(1, 2))
    else:
        eventPlayer.forceButtonPress(Button.JUMP)
        wait(random.randint(1, 2))
    loop()


#Back to the center when more than 30 m out, toward the target when it isn't the target, else to a random spot
rule "Lobby bot - movement":
    @Event eachPlayer
    @Condition isGameInProgress() == true
    @Condition eventPlayer.isDummy() == true
    @Condition eventPlayer.isAlive() == true

    if eventPlayer.getPosition().x > 30 or eventPlayer.getPosition().x < -30 or eventPlayer.getPosition().z > 30 or eventPlayer.getPosition().z < -30:
        eventPlayer.stopThrottleInDirection()
        eventPlayer.startThrottleInDirection(directionTowards(eventPlayer.getPosition(), vect(0, 0, 0)), 1, Relativity.TO_WORLD, Throttle.REPLACE_EXISTING, ThrottleReeval.NONE)
        wait(random.uniform(1, 1.5))
        if ruleCondition:
            loop()
    if eventPlayer != target:
        eventPlayer.startThrottleInDirection(directionTowards(eventPlayer.getPosition(), target), 0.8, Relativity.TO_PLAYER, Throttle.REPLACE_EXISTING, ThrottleReeval.NONE)
        wait(random.uniform(0.5, 3))
        if ruleCondition:
            loop()
    else:
        eventPlayer.startThrottleInDirection(directionTowards(eventPlayer.getPosition(), vect(random.uniform(-15, 15), 0, random.uniform(-15, 15))), 0.8, Relativity.TO_PLAYER, Throttle.REPLACE_EXISTING, ThrottleReeval.NONE)
        wait(random.uniform(0.5, 3))
        if ruleCondition:
            loop()


#Where it sends the ball, as the ball comes at it:
#- more than 18 m out from the center: down (from ballSpeed 90, 9 times in 10)
#- else 60%: up if every other player is more than 30 m away (half the time), else down
#- else with its dash ready: 1 time in 9 at a random player (±35° below ballSpeed 80, ±10° from it), else anywhere
#- else 45-90° to the side of the player nearest its aim, until no one is within 30° of it
#Then, once the ball has gone, it dashes back at the end of its next deflect if the ball comes straight back (DASH_BACK).
rule "Lobby bot - aim the deflect":
    @Event eachPlayer
    @Condition distance(eventPlayer.getEyePosition(), ballPosition) <= 2 * (ballSpeed / 20)
    @Condition target == eventPlayer
    @Condition eventPlayer.isDummy() == true
    @Condition ballIsOut == true
    @Condition eventPlayer.isAlive() == true
    @Condition eventPlayer.isUsingAbility1() == false
    @Condition eventPlayer.isUsingAbility2() == false
    @Condition eventPlayer.hasStatus(Status.STUNNED) == false
    @Condition eventPlayer.lobbyBot[LobbyBot.ACE_DASH] != true

    if (eventPlayer.getPosition().x > 18 or eventPlayer.getPosition().x < -18 or eventPlayer.getPosition().z > 18 or eventPlayer.getPosition().z < -18) and (ballSpeed <= 90 or random.randint(0, 99) < 90):
        eventPlayer.startFacing(vect(0, -1, 0), 10000)
    elif random.randint(0, 99) < 60:
        if random.randint(0, 1) == 0 and getLivingPlayers(Team.ALL).exclude(eventPlayer).all(lambda x: distance(eventPlayer.getPosition(), x.getPosition()) > 30):
            eventPlayer.startFacing(vect(0, 1, 0), 10000)
        else:
            eventPlayer.startFacing(vect(0, -1, 0), 10000)
    else:
        if eventPlayer.canDash == true:
            if random.randint(0, 8) == 0:
                if ballSpeed < 80:
                    eventPlayer.startFacing(directionFromAngles(horizontalAngleOfDirection(directionTowards(eventPlayer.getEyePosition(), evalOnce(random.choice(getLivingPlayers(Team.ALL).exclude(eventPlayer))).getEyePosition())) + evalOnce(random.randint(-35, 35)), evalOnce(random.randint(-35, 35))), 10000)
                else:
                    eventPlayer.startFacing(directionFromAngles(horizontalAngleOfDirection(directionTowards(eventPlayer.getEyePosition(), evalOnce(random.choice(getLivingPlayers(Team.ALL).exclude(eventPlayer))).getEyePosition())) + evalOnce(random.randint(-10, 10)), evalOnce(random.randint(-10, 10))), 10000)
            else:
                eventPlayer.startFacing(vect(random.randint(-360, 360), random.randint(-360, 360), random.randint(-360, 360)), 10000)
        else:
            if random.randint(0, 1) == 0:
                eventPlayer.startFacing(directionFromAngles(horizontalAngleOfDirection(directionTowards(eventPlayer.getEyePosition(), eventPlayer.getRealPlayerClosestToReticle(Team.ALL).getEyePosition())) + evalOnce(random.randint(-90, -45)), evalOnce(random.randint(-90, 90))), 10000)
            else:
                eventPlayer.startFacing(directionFromAngles(horizontalAngleOfDirection(directionTowards(eventPlayer.getEyePosition(), eventPlayer.getRealPlayerClosestToReticle(Team.ALL).getEyePosition())) + evalOnce(random.randint(45, 90)), evalOnce(random.randint(-90, 90))), 10000)
            wait(0)
            if getLivingPlayers(Team.ALL).exclude(eventPlayer).any(lambda x: eventPlayer.isInViewAngle(x.getEyePosition(), 30)):
                loop()
    waitUntil(target != eventPlayer or eventPlayer.isDead(), 99999)
    if angleBetweenVectors(ballDirection * -1, directionTowards(target, ballPosition)) < 20:
        if distance(eventPlayer.getEyePosition(), ballPosition) < ballSpeed:
            eventPlayer.lobbyBot[LobbyBot.DASH_BACK] = true
    wait(0.3)
    if ruleCondition:
        loop()


#Near the ball with its dash used: up if every other player is more than 30 m away (half the time), else down
rule "Lobby bot - face up or down near the ball":
    @Event eachPlayer
    @Condition distance(eventPlayer.getEyePosition(), ballPosition) <= 2 * (ballSpeed / 20)
    @Condition eventPlayer.isDummy() == true
    @Condition ballIsOut == true
    @Condition eventPlayer.isAlive() == true
    @Condition eventPlayer.lobbyBot[LobbyBot.ACE_DASH] != true
    @Condition eventPlayer.getAbilityCooldown(Button.ABILITY_1) != 0

    if random.randint(0, 1) == 0 and getLivingPlayers(Team.ALL).exclude(eventPlayer).all(lambda x: distance(eventPlayer.getPosition(), x.getPosition()) > 30):
        eventPlayer.startFacing(vect(0, 1, 0), 10000)
    else:
        eventPlayer.startFacing(vect(0, -1, 0), 10000)
    wait(0.3)
    if ruleCondition:
        loop()


#Ace dash: within 10 m of the target as the ball reaches them, 30% of the time it dashes the way the target faces
rule "Lobby bot - ace dash":
    @Event eachPlayer
    @Condition eventPlayer.isDummy() == true
    @Condition ballIsOut == true
    @Condition target != eventPlayer
    @Condition eventPlayer.isAlive() == true
    @Condition eventPlayer.getAbilityCooldown(Button.ABILITY_1) == 0
    @Condition eventPlayer.isUsingAbility1() == false
    @Condition eventPlayer.isUsingAbility2() == false
    @Condition eventPlayer.hasStatus(Status.STUNNED) == false
    @Condition eventPlayer.lobbyBot[LobbyBot.ACE_DASH] != true
    @Condition distance(eventPlayer.getPosition(), target.getPosition()) <= 10
    @Condition distance(target.getEyePosition(), ballPosition) <= ballSpeed * 0.3

    if random.randint(0, 99) < 30:
        eventPlayer.lobbyBot[LobbyBot.ACE_DASH] = true
        eventPlayer.setFacing(evalOnce(target.getFacingDirection()), Relativity.TO_WORLD)
        eventPlayer.startFacing(evalOnce(target.getFacingDirection()), 10000)
        wait(0.05)
        eventPlayer.forceButtonPress(Button.ABILITY_1)
        wait(0.05)
        waitUntil(eventPlayer.isUsingAbility1() == false or eventPlayer.isDead(), 1)
        eventPlayer.lobbyBot[LobbyBot.ACE_DASH] = false
    else:
        waitUntil(target == eventPlayer or eventPlayer.isDead(), 5)
