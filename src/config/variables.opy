
#Global variables

globalvar target 0
globalvar prevTarget 1
globalvar ballIsOut 2
globalvar RoundInProgress 3
globalvar IsEnoughPlayersToStart 4
globalvar IsInFinalDuel 5
#True while the next round or duel is on its way (a round win pause), so the all-dead rule doesn't start a second one.
globalvar RoundSetupPending 6
globalvar HighestScore 7
globalvar TieBreakerActive 8
globalvar matchTime 9
globalvar tournamentMode 10
globalvar totalRounds 11
globalvar roundsUntilBreak 12
globalvar breakLength 13
globalvar roundsUntilBreakInit 14
globalvar breaksEnabled 15
globalvar roundTimings 16
globalvar presetMode 17
globalvar ballPosition 20
globalvar ballDirection 21
globalvar ballSpeed 22
globalvar ballSpeedCap 23
globalvar ballSpawnSpeed 24
globalvar ballAcceleration 25
globalvar ballSpawnCountdown 26
globalvar setballspawncountdown 27
globalvar setballspawncountdownoriginal 28
globalvar ballFeel 30
globalvar ballDirectionRate 31
globalvar ballDirectionRateInit 32
globalvar ballHitPosition 33
globalvar phasePosition 35
globalvar CollisionSurfaceDistances 39
globalvar CollisionSurfaceIndex 40
globalvar circleCenter 44
globalvar CenterOffLimitsSize 45
globalvar SphereSize 46
globalvar waterLevel 47
globalvar playerSettings 51
globalvar moveSpeed 59
globalvar gravity 60
globalvar jumpVerticalSpeed 61
globalvar addOnSettings 62
#v1.3.3R (Ranked) slots 124-127. Ranked log state (RankedField in config/constants.opy).
globalvar rankedState 124
#Ranked log player ids: rankedPlayers[id] is that player, -1 once they've left. Index 0 is unused.
globalvar rankedPlayers 125
#Ranked log: the players in the current round who aren't eliminated and haven't left. Empty between rounds.
globalvar rankedRound 126
#Rank tags, set only by "RANKS - generated": the list's line, then one row per rank tier, then per top player (RankTagField)
globalvar rankTags 127

#Player variables

playervar hasMoved 0
playervar thirdPerson 1
playervar simpleHUD 2
playervar moveSpeed 4
playervar currentGravity 5
playervar stunCooldown 6
playervar canDash 7
playervar canDeflect 8
playervar dashOnCooldown 9
playervar antiRubberbanding 10
playervar sensHigh 12
#v1.3.3R (Ranked) slots 124-127. The player's entry in rankTags: 0 not checked yet, -1 none.
playervar rankTier 124
#Ranked log: the player's round wins and kills since their JOIN (TourneyStat), for a tourney's final standings
playervar tourneyStats 125

#Subroutine names

subroutine playDeathEffect 0
subroutine deflectFail 1
subroutine dashBall 3
subroutine ballCurve 4
subroutine deleteBall 5
subroutine collisionTarget 6
subroutine alert 8
subroutine setupFinal 9
subroutine randomTarget 10
subroutine startRound 11
subroutine simpleIslandCollision 12
subroutine startBall 13
subroutine stopBall 14
subroutine startModernBall 15
subroutine simpleIslandSideCollision 20
#v1.3.3R (Ranked)
subroutine logRankedJoins 124
subroutine logRankedRoundAbort 125
subroutine logRankedUnranked 126

#Activated extensions. Every one is used; OverPy refuses to compile when they cost more points than the Workshop has.

#D.Va self-destruct and Tracer recall effects (collision)
#!extension energyExplosionEffects
#Ashe dynamite and Doomfist meteor (collision), Pharah barrage (ball physics)
#!extension kineticExplosionEffects
#Ashe, Baptiste (collision), Echo (ball physics), Brigitte armor (controls) explosion sounds
#!extension explosionSounds
#Raises how many effects can play per tick. A compile can't check this; only remove after testing in a full lobby
#!extension playMoreEffects
#The ball's createProjectileEffect (ui/effects.opy)
#!extension projectiles


#Only remove the following directive if the gamemode does not use tricks such as A+0, A*0, A or "", "am" == "**", etc which would otherwise be optimized out.
#!optimizeStrict
