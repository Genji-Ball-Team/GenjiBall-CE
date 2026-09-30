#Elo ranks and outlines

rule "Player rank - Expert (elo > 1500)":
    @Event eachPlayer
    @Condition "{0}".format(eventPlayer) == ""
    
    eventPlayer.outlineColor = vect(128, 0, 128)


rule "Player rank - Master (elo > 2000)":
    @Event eachPlayer
    @Condition "{0}".format(eventPlayer) == ""
    
    eventPlayer.outlineColor = vect(192, 192, 192)


rule "Player rank - Legendary (elo > 2500)":
    @Event eachPlayer
    @Condition "{0}".format(eventPlayer) == ""
    
    eventPlayer.outlineColor = vect(255, 165, 0)


rule "Player rank - Apply outline":
    @Event eachPlayer
    @Condition eventPlayer.outlineColor != null
    
    eventPlayer.startForcingOutlineFor(getAllPlayers().exclude(eventPlayer) if eventPlayer == target else getAllPlayers(), true, updateEveryFrame(rgb(eventPlayer.outlineColor.x, eventPlayer.outlineColor.y, eventPlayer.outlineColor.z)), OutlineVisibility.ALWAYS)
    eventPlayer.startForcingOutlineFor(eventPlayer if eventPlayer == target else null, true, rgb(255, 0, 0), OutlineVisibility.ALWAYS)
    wait(0)
    loop()


rule "Player rank - Apply fade":
    @Event eachPlayer
    @Condition eventPlayer.outlineFade == true
    
    eventPlayer.outlineFadeBright = eventPlayer.outlineColor + eventPlayer.outlineColor / 2
    eventPlayer.outlineFadeDark = eventPlayer.outlineColor - eventPlayer.outlineColor / 3
    while true:
        chaseOverTime(eventPlayer.outlineColor, eventPlayer.outlineFadeBright, 0.5, ChaseTimeReeval.NONE)
        wait(0.5)
        chaseOverTime(eventPlayer.outlineColor, eventPlayer.outlineFadeDark, 1, ChaseTimeReeval.NONE)
        wait(1.5)
        chaseOverTime(eventPlayer.outlineColor, eventPlayer.outlineFadeBright, 0.5, ChaseTimeReeval.NONE)
        wait(0.5)
        chaseOverTime(eventPlayer.outlineColor, eventPlayer.outlineColor, 0.5, ChaseTimeReeval.NONE)
        wait(0.5)
