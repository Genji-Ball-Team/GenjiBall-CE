#Arena center and size per map

#True on a map with no row in the map table: the lookup gives no row, so the radius reads 0.
#Every supported row has a radius above 0.
#!define MAP_UNSUPPORTED (mapRow[MapColumn.RADIUS] == 0)

rule "Initialization - Set map":
    #Maps: one row per supported map, one column per value (MapColumn in config/constants.opy).
    #The map list and the row list must stay in the same order.
    #Oasis University, Kings Row and Blizz World are commented out: Overwatch won't enable a
    #non-Workshop map while Workshop extensions are on, and this mode needs them. Uncomment the
    #row and the map together if that changes, and add them to "Initialization - unsupported map".
    #They are smaller than the others: lower the max players there.
    #Rule names can't contain "Blizzard", so the map is written "Blizz World" in rule names.
    #Any other map has no row and no arena, so no round starts there (MAP_UNSUPPORTED).
    mapRow = [
        #center,                        radius
        [vect(0, 1.199, 0),             60],   #Workshop Island
        [vect(0, 1.199, 0),             60],   #Workshop Island (Night)
        [vect(0, 1.199, 0),             29.7], #Workshop Chamber
        [vect(0, 1.199, 0),             50],   #Workshop Expanse
        [vect(0, 1.199, 0),             50],   #Workshop Expanse (Night)
        [vect(0, 1.199, 0),             60],   #Workshop Green Screen
        #[vect(-192.609, 60.349, 2.252), 25],   #Oasis University
        #[vect(-20.504, 40.538, -74.601), 23],  #King's Row
        #[vect(-20.504, 40.538, -74.601), 23],  #King's Row (Winter)
        #[vect(2.554, -4.651, -71.211),  23],   #Blizz World
        #[vect(2.554, -4.651, -71.211),  23],   #Blizz World (Winter)
    ][[
        Map.WORKSHOP_ISLAND,
        Map.WORKSHOP_ISLAND_NIGHT,
        Map.WORKSHOP_CHAMBER,
        Map.WORKSHOP_EXPANSE,
        Map.WORKSHOP_EXPANSE_NIGHT,
        Map.WORKSHOP_GREEN_SCREEN,
        #Map.OASIS_UNIVERSITY,
        #Map.KINGS_ROW,
        #Map.KINGS_ROW_WINTER,
        #Map.BLIZZ_WORLD,
        #Map.BLIZZ_WORLD_WINTER,
    ].index(__getCurrentMap__())]
    circleCenter = mapRow[MapColumn.CENTER]
    SphereSize = mapRow[MapColumn.RADIUS]
    #"20 - Arena > arena radius" overrides the map's radius when it isn't 0.
    #Kept large enough for the final duel spawns: 15 m out on Workshop Island (in bounds needs at
    #least 10) and SphereSize / 1.5 elsewhere (must stay outside the center exclusion's push zone).
    if arenaSettings[ArenaSetting.ARENA_RADIUS] > 0:
        SphereSize = max(arenaSettings[ArenaSetting.ARENA_RADIUS], max(10, 1.5 * (arenaSettings[ArenaSetting.CENTER_SIZE] + 0.5)))
    #Workshop Island has water and a ledge instead of a wall; several rules check this.
    isIsland = __getCurrentMap__() == Map.WORKSHOP_ISLAND or __getCurrentMap__() == Map.WORKSHOP_ISLAND_NIGHT


rule "Initialization - unsupported map":
    @Condition MAP_UNSUPPORTED == true

    hudHeader(getAllPlayers(), "This map isn't supported, so no round will start", HudPosition.TOP, -3, Color.LIGHT_RED, HudReeval.VISIBILITY_AND_STRING)
    hudSubheader(getAllPlayers(), "Pick Workshop Island, Expanse, Green Screen or Chamber", HudPosition.TOP, -2, Color.WHITE, HudReeval.VISIBILITY_AND_STRING)
