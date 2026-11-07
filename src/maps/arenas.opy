#The arena: ranked only plays on Workshop Island Night

#True on any other map: there's no arena, so no round starts
#!define MAP_UNSUPPORTED (__getCurrentMap__() != Map.WORKSHOP_ISLAND_NIGHT)

rule "Initialization - Set map":
    circleCenter = ISLAND_CENTER
    SphereSize = ISLAND_RADIUS


rule "Initialization - unsupported map":
    @Condition MAP_UNSUPPORTED == true

    hudHeader(getAllPlayers(), "This map isn't supported, so no round will start", HudPosition.TOP, -3, Color.LIGHT_RED, HudReeval.VISIBILITY_AND_STRING)
    hudSubheader(getAllPlayers(), "Pick Workshop Island Night", HudPosition.TOP, -2, Color.WHITE, HudReeval.VISIBILITY_AND_STRING)
