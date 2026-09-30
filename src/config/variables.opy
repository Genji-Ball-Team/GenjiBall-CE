
#Global variables

globalvar target 0
globalvar prevTarget 1
globalvar ballIsOut 2
globalvar RoundInProgress 3
globalvar IsEnoughPlayersToStart 4
globalvar IsInFinalDuel 5
globalvar roundEndCall 6
globalvar HighestScore 7
globalvar TieBreakerActive 8
globalvar matchTime 9
globalvar tournamentMode 10
globalvar totalRounds 11
globalvar roundsUntilBreak 12
globalvar breakLength 13
globalvar roundsUntilBreakInit 14
globalvar breaksEnabled 15
globalvar breakInProgress 16
globalvar presetMode 17
globalvar duelMode 18
globalvar duelQueue 19
globalvar ballPosition 20
globalvar ballDirection 21
globalvar ballSpeed 22
globalvar ballSpeedCap 23
globalvar ballSpawnSpeed 24
globalvar ballAcceleration 25
globalvar ballSpawnCountdown 26
globalvar setballspawncountdown 27
globalvar setballspawncountdownoriginal 28
globalvar ballMotion 29
globalvar motionMultiplier 30
globalvar ballDirectionRate 31
globalvar ballDirectionRateInit 32
globalvar ballHitPosition 33
globalvar ballNextFramePosition 34
globalvar phasePosition 35
globalvar phasePosition1 36
globalvar phasePosition2 37
globalvar BallCollisionSurfaceNormal 38
globalvar CollisionSurfaceDistances 39
globalvar CollisionSurfaceIndex 40
globalvar antiGhostMode 41
globalvar antiGhostPrevDistance 42
globalvar antiGhostStallTimer 43
globalvar circleCenter 44
globalvar CenterOffLimitsSize 45
globalvar SphereSize 46
globalvar waterLevel 47
globalvar bouncePadToggle 48
globalvar bouncePadRange 49
globalvar bouncePadCooldownLength 50
globalvar bouncePadDistance 51
globalvar bouncePadStrength 52
globalvar bouncePadSuperjumpNerf 53
globalvar bouncePad1 54
globalvar bouncePad2 55
globalvar bouncePad3 56
globalvar bouncePad4 57
globalvar mobilityMode 58
globalvar moveSpeed 59
globalvar gravity 60
globalvar jumpVerticalSpeed 61
globalvar Abilities 62
globalvar endlessMode 63
globalvar Sandbox 64
globalvar xray 65
globalvar tracingMode 66
globalvar tracingPoints 67
globalvar RedGreenColorblindMode 68
globalvar WatermarkEnabled 69
globalvar doubleSensEnabled 70
globalvar Teamsscoretowin 71
globalvar enablepassing 72
globalvar passingassistid 73
globalvar passingplayer 74
globalvar antiOrbitMode 75
globalvar antiOrbitRadius 76
globalvar antiOrbitPressureRate 77
globalvar bozo_Bot 78
globalvar BozoTracing 79
globalvar bozoBehaviorModes 80
globalvar bozoAggression 81
globalvar bozoWillOrbit 82
globalvar bozoWillGhostDash 83
globalvar bozoWillEdash 84
globalvar OrbitTolerance 85
globalvar IsOrbiting 86
globalvar bozoIsGhostDashing 87
globalvar botJumping 88
globalvar bozoHasJumped 89
globalvar Sandboxballpos 90
globalvar Sandboxballdir 91
globalvar Sandboxballspd 92
globalvar Sandboxxyz 93
globalvar Sandboxplusminus 94
globalvar Sandboxselected 95
globalvar Critalert 96
globalvar ballPhysicsMode 97
globalvar ballRedirectAge 98
globalvar experimentalSteeringRate 99
globalvar reboundIncomingDirection 100
globalvar reboundInfluence 101
globalvar experimentalReboundMin 102
globalvar experimentalReboundMax 103
globalvar experimentalHomingStart 104
globalvar experimentalHomingHold 105
globalvar experimentalHomingRamp 106
globalvar experimentalSurfaceHoming 107
globalvar enableDashPassing 108
globalvar killCounterEnabled 109
globalvar debugRules 110
globalvar killLeaderboardPlayers 111
globalvar killLeaderboardSortedPlayers 112

#Player variables

playervar hasMoved 0
playervar thirdPerson 1
playervar simpleHUD 2
playervar bouncePadCooldown 3
playervar moveSpeed 4
playervar currentGravity 5
playervar stunCooldown 6
playervar canDash 7
playervar canDeflect 8
playervar dashOnCooldown 9
playervar antiRubberbanding 10
playervar dashNerf 11
playervar sensHigh 12
playervar SpecialAbility 13
playervar Abilitycooldown 14
playervar Abilityready 15
playervar Abilitydesc 16
playervar Critslash 17
playervar Critalert 18
playervar outlineColor 19
playervar outlineFade 20
playervar outlineFadeDark 21
playervar outlineFadeBright 22
playervar orbitPenalty 23
playervar orbitTimer 24
playervar orbitHeat 25
playervar kills 26

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
subroutine startAstroBall 16
subroutine startRetroBall 17
subroutine TDMcollision 18
subroutine resetOrbitRoundState 19
subroutine simpleIslandSideCollision 20
subroutine startLegacyPlusBall 21
subroutine startExperimentalBall 22

#Activated extensions

#!extension beamSounds
#!extension buffStatusEffects
#!extension debuffStatusEffects
#!extension buffAndDebuffSounds
#!extension energyExplosionEffects
#!extension kineticExplosionEffects
#!extension explosionSounds
#!extension playMoreEffects
#!extension spawnMoreDummyBots
#!extension projectiles


#Only remove the following directive if the gamemode does not use tricks such as A+0, A*0, A or "", "am" == "**", etc which would otherwise be optimized out.
#!optimizeStrict
