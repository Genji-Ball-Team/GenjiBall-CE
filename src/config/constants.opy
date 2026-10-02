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
    BALL_FEEL       #forces "15 - Ball Feel > custom ball feel" (BallFeel.CUSTOM)
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
    ORBIT_SPEED     #ORBIT_SPEED to BASIC_ORBIT_TIMER in CompetitiveSetting order
    ORBIT_TIMER
    ORBIT_MIN_TIMER
    ORBIT_SLEEP
    BASIC_ORBIT_RADIUS
    BASIC_ORBIT_SPEED
    BASIC_ORBIT_TIMER
    DASH_COOLDOWN   #DASH_COOLDOWN to STUN_COOLDOWN in PlayerSetting order
    STUN_DURATION
    STUN_COOLDOWN
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

#Fields of ballFeel, the "15 - Ball Feel" settings. CUSTOM off means today's
#values (BALL_FEEL_DEFAULTS), whatever the sliders say.
enum BallFeel:
    CUSTOM              #"custom ball feel": use the sliders below
    DEFLECT_SPEEDUP     #ballSpeed is multiplied by this on a deflect (up to ballSpeedCap)
    HIT_RADIUS          #the ball hits its target within this distance of their eyes
    MODERN_RATE         #ballDirectionRateInit with motion = modern
    RAPID_RATE          #ballDirectionRateInit with motion = rapid
    CURVE_RATE          #ballDirectionRate right after a deflect (modern motion, not Experimental)
    CURVE_TIME          #seconds CURVE_RATE lasts
    DEFLECT_WINDOW      #seconds a deflect lasts ("Controls - Shorten deflect length")
    DEFLECT_LOCKOUT     #seconds dash and deflect are locked after it
    FAST_BALL_SPEED     #above this ballSpeed, "Collision - collision check" also checks points between frames
    RELIABLE_HITS       #"reliable hit detection": "Collision - collision check" runs at every ballSpeed

#ballFeel with "custom ball feel" off, in BallFeel order: the v1.3.2 values
#!define BALL_FEEL_DEFAULTS [false, 1.05, 1.9, 1.75, 5, 6, 0.05, 0.3, 0.5, 150, false]

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

#Fields of playerSettings ("30 - Player" dash and dash-hit stun settings)
enum PlayerSetting:
    DASH_COOLDOWN   #seconds after a dash ends before the next one ("Controls - Dash cooldown")
    STUN_DURATION   #seconds a dash-hit knocks the dasher down ("Collision - dash sub")
    STUN_COOLDOWN   #seconds before another dash-hit can knock them down again

#Fields of competitiveSettings ("60 - Competitive" anti-orbit tuning).
#A preset forces all of them or none (MANUAL in the ORBIT_SPEED column).
enum CompetitiveSetting:
    ORBIT_SPEED         #AntiOrbit: the ball counts as orbiting below this speed
    ORBIT_TIMER         #AntiOrbit: seconds of orbiting before the sleep, with no pressure or heat
    ORBIT_MIN_TIMER     #AntiOrbit: pressure and heat never shorten the timer below this
    ORBIT_SLEEP         #AntiOrbit: seconds the orbiting player sleeps
    BASIC_ORBIT_RADIUS  #"Tournament - no orbit abusing" (tournament mode with AntiOrbit off)
    BASIC_ORBIT_SPEED
    BASIC_ORBIT_TIMER

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
    SENS_MULTIPLIER #"30 - Player > double sens %", the aim speed double sens switches to
    TRACING_ANGLE   #"80 - Visual > tracing view angle", how far from the crosshair the ball may be
    COLORBLIND      #"80 - Visual > red-green colorblind filter", blue/yellow target and bounce pad visuals
    WATERMARK       #"80 - Visual > watermark", the original-author credit
    WATER_LEDGE_FIX #"20 - Arena > water ledge fix", limits the under-ledge push to near the island

#Fields of rankedState, the ranked log's state (features/ranked-log.opy)
enum RankedField:
    LOGGING     #"70 - Ranked > ranked logging"
    STARTED     #MATCH_START is logged, so JOIN and LEAVE can be
    ROUND       #the current round's number, from 1 in each match
    IN_ROUND    #a ROUND_START is logged and its ROUND_END isn't yet
    TEXT        #the id list being built for ROUND_START
    COUNT       #how many ids are in TEXT so far
    DEFLECTOR   #the prevTarget "Ranked log - DEFLECT" last saw
    TAG_LOOP    #loop counter for the rank tag and tier guide rules (features/rank-tags.opy)
    UNRANKED    #the UnrankedReasons logged in this match
    UNRANKED_TEXT   #the unranked warning's reasons, comma-separated
    REASON      #the UnrankedReason for logRankedUnranked()

#Why a match won't count: UNRANKED's reason codes (docs/ranked-log.md, "Unranked matches").
#The code and warning text of each are UNRANKED_CODES and UNRANKED_TEXTS (features/ranked-log.opy).
enum UnrankedReason:
    MAP
    MODE
    PRESET
    FEEL
    ADD_ON
    BOT

#Fields of a tier in rankTags ("RANKS - generated", docs/rank-tags.md)
enum RankTagField:
    LABEL       #the tag over the player
    COLOR       #the tag's and the guide line's colour
    GUIDE       #the tier's line in the guide
    NAMES       #the player names in this tier start here

#FFA slots a lobby can have: one rank tag each
#!define FFA_SLOTS 12

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
    CUSTOM      #uses the "custom move speed %", "custom gravity %" and "custom jump %" settings

#eventPlayer.simpleHUD, toggled with Interact
enum SimpleHud:
    OFF
    ON
    ZEN

#eventPlayer.SpecialAbility ("50 - Features > custom abilities").
#Selection cycles SUPER_JUMP to CRIT_SLASH ("> BLINK" wraps back to 1).
enum AbilityId:
    SUPER_JUMP = 1
    TARGET_SWITCH
    BLINK
    CRIT_SLASH
