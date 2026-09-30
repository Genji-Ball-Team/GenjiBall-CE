#Named values for enum-like settings and variables.
#OverPy inlines enum members, so these compile to the same numbers as before.
#The order of each enum must match its Workshop setting's option list in
#config/workshop-settings.opy: the setting stores the option's index.

#presetMode ("00 - Preset > preset")
enum Preset:
    DEFAULT
    TOURNAMENT
    TOURNAMENT_PLUS
    RAPID
    V1
    V7
    EXPERIMENTAL
    CUSTOM

#Columns of the preset table in config/workshop-settings.opy
enum PresetColumn:
    MATCH_TIME
    TOURNAMENT_MODE
    TOTAL_ROUNDS
    BREAKS_ENABLED
    ROUNDS_UNTIL_BREAK
    BREAK_LENGTH
    BALL_SPAWN_SPEED
    BALL_SPEED_CAP
    BALL_ACCELERATION
    BALL_MOTION
    BALL_PHYSICS
    WATER
    BOUNCE_PADS
    MOBILITY
    ANTI_GHOST
    ANTI_ORBIT
    ANTI_ORBIT_RADIUS
    ANTI_ORBIT_PRESSURE

#A preset table cell that leaves the host's setting as is
#!define MANUAL -1

#Columns of the map table in maps/arenas.opy
enum MapColumn:
    CENTER
    RADIUS

#Fields of sandboxState (features/sandbox.opy)
enum SandboxField:
    BALL_POSITION   #where the ball spawns
    BALL_DIRECTION  #the point the ball flies towards
    BALL_SPEED
    AXIS            #axis being edited: 1 = x, 2 = y, 3 = z
    SIGN            #1 = add, -1 = subtract
    EDITING         #value being edited: 1 = position, 2 = direction, 3 = speed

#Fields of botState (features/bot-zbozo.opy)
enum BotField:
    WILL_GHOST_DASH
    WILL_EDASH
    GHOST_DASHING

#ballMotion ("10 - Ball > motion")
enum BallMotion:
    MODERN
    RAPID
    ASTRO
    RETRO

#ballPhysicsMode ("10 - Ball > physics engine")
enum BallPhysics:
    ORIGINAL
    LEGACY_PLUS
    EXPERIMENTAL

#Fields of experimentalTuning, the "10 - Ball > exp ..." settings (Experimental physics engine only)
enum ExperimentalTuning:
    REBOUND_MIN     #share of the incoming direction kept on a straight-on deflect
    REBOUND_MAX     #same, for a side-on deflect
    HOMING_START    #homing strength right after a deflect
    HOMING_HOLD     #seconds homing stays at HOMING_START
    HOMING_RAMP     #seconds to ramp back to full homing
    SURFACE_HOMING  #homing strength right after a wall or floor bounce

#antiGhostMode ("10 - Ball > anti-ghost correction")
enum AntiGhost:
    OFF
    TRACK
    STEER

#waterLevel ("20 - Arena > water"). Settings replaces it with a height afterwards.
enum Water:
    MODERATE
    NONE
    MINIMAL
    FLOOD

#mobilityMode ("30 - Player > mobility")
enum Mobility:
    AGILE
    BALANCED
    SLUGGISH

#eventPlayer.simpleHUD, toggled with Interact
enum SimpleHud:
    OFF
    ON
    ZEN

#eventPlayer.SpecialAbility ("50 - Features > custom abilities").
#Selection cycles SUPER_JUMP to CRIT_SLASH ("> BLINK" wraps back to 1).
#5 and 6 only have placeholder text.
enum AbilityId:
    SUPER_JUMP = 1
    TARGET_SWITCH
    BLINK
    CRIT_SLASH
    UNUSED_5
    UNUSED_6
