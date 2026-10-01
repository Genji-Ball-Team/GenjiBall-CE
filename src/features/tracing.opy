#Tracing mode

rule "Tracing mode - gained":
    @Event eachPlayer
    @Condition addOnSettings[AddOnSetting.TRACING_MODE] == true
    @Condition eventPlayer == target
    @Condition angleBetweenVectors(eventPlayer.getFacingDirection(), directionTowards(eventPlayer.getEyePosition(), ballPosition)) <= 45
    
    #@Condition eventPlayer.isInViewAngle(ballPosition, 70) == true
    eventPlayer.clearStatusEffect(Status.BURNING)
    stopChasing(tracingPoints)
    tracingPoints = 0.3


rule "Tracing mode - lost":
    @Event eachPlayer
    @Condition addOnSettings[AddOnSetting.TRACING_MODE] == true
    @Condition eventPlayer == target
    @Condition angleBetweenVectors(eventPlayer.getFacingDirection(), directionTowards(eventPlayer.getEyePosition(), ballPosition)) > 45
    
    #@Condition eventPlayer.isInViewAngle(ballPosition, 70) == false
    chaseAtRate(tracingPoints, 0, 1)
