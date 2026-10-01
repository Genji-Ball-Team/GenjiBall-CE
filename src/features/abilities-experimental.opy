#Experimental / disabled ability rules

rule "Gb Abilities - stack crit slashes":
    @Event eachPlayer
    @Condition eventPlayer.Critalert == true
    @Condition addOnSettings[AddOnSetting.ABILITIES] == true
    @Condition eventPlayer.isDummy() == false
    @Disabled
    
    eventPlayer.Critalert = false
    wait(0.032, Wait.RESTART_WHEN_TRUE)
    ballSpeed *= 1.75
    wait(5)
    ballSpeed /= 1.75
    ballSpeed *= 1.25
