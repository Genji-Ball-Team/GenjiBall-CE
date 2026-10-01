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
    SPAWN_COUNTDOWN
    RESPAWN_DELAY
    WIN_PAUSE
    CENTER_SIZE     #CENTER_SIZE to PAD_COOLDOWN must stay last and in ArenaSetting order
    ARENA_RADIUS
    PAD_STRENGTH
    PAD_DISTANCE
    PAD_RANGE
    PAD_COOLDOWN

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

#How far the modern, Legacy+ and Experimental engines move the ball per unit of
#ballSpeed. Only modern and rapid motion reach those engines (astro and retro
#have their own), and rapid moves at half the distance.
#!define motionMultiplier (0.5 if ballMotion == BallMotion.RAPID else 1)

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

#Fields of experimentalState, the Experimental engine's state while the ball is out
enum ExperimentalField:
    REDIRECT_AGE        #seconds since the last deflect, for the homing handoff
    STEERING_RATE       #the rate ballDirection chases the target at
    INCOMING_DIRECTION  #the ball's direction just before a deflect
    REBOUND_INFLUENCE   #share of INCOMING_DIRECTION kept in the deflect

#Fields of antiGhostState ("Ball Physics - anti ghost correction")
enum AntiGhostField:
    PREV_DISTANCE   #distance to the target at the last check, 999 when not tracking
    STALL_TIMER     #seconds the ball hasn't got closer to the target

#Fields of phasePosition, points between the ball's last and current position
#that "Collision - collision check" also checks, so a fast ball can't skip the target
enum PhasePoint:
    LAST     #the ball's position at the last check, moved halfway to the current one during the check
    QUARTER  #halfway between LAST before and after that move

#Fields of bouncePadConfig ("Initialization - global variables")
enum BouncePadField:
    STRENGTH        #upward impulse of a bounce
    DISTANCE        #distance of each pad from circleCenter
    RANGE           #how close a player has to be to a pad to bounce
    SUPERJUMP_NERF  #taken off STRENGTH while the player has dashNerf
    COOLDOWN        #seconds before a player can bounce again

#Fields of roundTimings ("40 - Match" settings that time the round flow)
enum RoundTiming:
    RESPAWN_DELAY   #seconds before the ball respawns after a kill
    WIN_PAUSE       #seconds between a round win and the next round

#Fields of arenaSettings ("20 - Arena" size and bounce pad settings)
enum ArenaSetting:
    CENTER_SIZE     #radius of the black sphere players are pushed out of
    ARENA_RADIUS    #0 = use the map's radius from the map table; otherwise at least 10 (more with a big center exclusion)
    PAD_STRENGTH    #copied into bouncePadConfig by "Initialization - global variables"
    PAD_DISTANCE
    PAD_RANGE
    PAD_COOLDOWN

#Fields of addOnSettings, the add-on settings no preset forces
enum AddOnSetting:
    DOUBLE_SENS     #"30 - Player > double sens"
    ABILITIES       #"50 - Features > custom abilities"
    XRAY            #"80 - Visual > x-ray"
    TRACING_MODE    #"80 - Visual > tracing mode"
    DEBUG_HUD       #"90 - Debug > debug HUD"
    DUELS           #"50 - Features > duels"
    ENDLESS         #"50 - Features > endless mode"
    SANDBOX         #"50 - Features > Sandbox mode"
    KILL_TRACKER    #"80 - Visual > kill tracker"

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
