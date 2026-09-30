#Arena center and size per map

rule "Initialization - Set Workshop Island":
    @Condition (__getCurrentMap__() == Map.WORKSHOP_ISLAND or __getCurrentMap__() == Map.WORKSHOP_ISLAND_NIGHT) == true
    
    circleCenter = vect(0, 1.199, 0)
    SphereSize = 60


rule "Initialization - Set Workshop Chamber":
    @Condition __getCurrentMap__() == Map.WORKSHOP_CHAMBER
    
    circleCenter = vect(0, 1.199, 0)
    SphereSize = 29.7


rule "Initialization - Set Workshop Expanse Center":
    @Condition (__getCurrentMap__() == Map.WORKSHOP_EXPANSE or __getCurrentMap__() == Map.WORKSHOP_EXPANSE_NIGHT) == true
    
    circleCenter = vect(0, 1.199, 0)
    SphereSize = 50


rule "Initialization - Set Workshop Green Screen":
    @Condition __getCurrentMap__() == Map.WORKSHOP_GREEN_SCREEN
    
    circleCenter = vect(0, 1.199, 0)
    SphereSize = 60


rule "Initialization - Set Oasis University Center":
    @Condition __getCurrentMap__() == Map.OASIS_UNIVERSITY
    
    circleCenter = vect(-192.609, 60.349, 2.252)
    SphereSize = 25


rule "Initialization - Set Kings Row center (NOTE: Lower the max players! This arena is smaller then the others!)":
    @Condition (__getCurrentMap__() == Map.KINGS_ROW or __getCurrentMap__() == Map.KINGS_ROW_WINTER) == true
    
    circleCenter = vect(-20.504, 40.538, -74.601)
    SphereSize = 23


rule "Initialization - Set Blizz World center (fun fact: you can't use the name of the company who made this game in rule names)":
    @Condition (__getCurrentMap__() == Map.BLIZZ_WORLD or __getCurrentMap__() == Map.BLIZZ_WORLD_WINTER) == true
    
    circleCenter = vect(2.554, -4.651, -71.211)
    SphereSize = 23

