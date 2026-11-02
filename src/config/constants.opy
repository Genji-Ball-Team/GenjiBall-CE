#Named values for enum-like settings and variables.
#OverPy inlines enum members, so these compile to the same numbers as before.
#The order of each enum must match its Workshop setting's option list in
#config/workshop-settings.opy: the setting stores the option's index.

#presetMode ("00 - Preset > preset")
enum Preset:
    STANDARD    #"Default" before v1.3.4
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

#Fields of the player variable botState, a bot's working values (features/bots.opy)
enum BotField:
    BALL_ID         #counts up for every ball coming at the bot, and on a reset
    THIS_BALL       #BALL_ID when the brain started on this ball; a different BALL_ID means the ball is stale
    ROLL            #0-99, rolled once per ball, shared by every chance in the shot table
    ENEMY           #the nearest living human, set once per ball (null when there is none)
    ROW             #the shot table row being checked, then the one that won
    PASSED          #true when ROW's condition holds
    AIM             #world direction the shot goes to
    INTENT          #BotIntent of the shot, for the after-shot part
    FACING          #BotFacing: which part may write the bot's facing
    MOVE_ENEMY      #CIRCLE movement: the nearest living human, picked again on every step
    MOVE_DIR        #movement: CIRCLE's horizontal direction to MOVE_ENEMY, STRAFE's roll

#Which part owns a bot's facing (botState[BotField.FACING]), so no two rules turn the bot at once
enum BotFacing:
    CAMERA          #the camera part: looking around, between balls
    AIM             #the brain, from the moment it aims at a ball until the ball leaves
    DASH            #a dash is planned: facing its direction until the dash is pressed
    PUNISH          #"Bots - punish" looks at the nearest player; the brain may take over
    ACE             #"Bots - ace dash" faces where the ball's target looks, until its dash ends

#Columns of a shot table row (botShots): the first row whose condition holds and whose chance passes wins
enum BotShotColumn:
    CONDITION       #BotCondition
    SHOT            #BotShot
    CHANCE          #the row passes when botState[BotField.ROLL] is under this (100 = always)
    INTENT          #BotIntent

#Conditions a shot table row can ask for (botCheckCondition in features/bots.opy)
enum BotCondition:
    ALWAYS
    I_CAN_DASH          #the bot's dash is ready
    ENEMY_CANT_DASH     #the enemy's dash isn't ready and the bot's is: a shot at them can be dodged after
    NO_ENEMY            #no living human
    ME_OFF_MAP          #the bot is past OFF_MAP on x or z
    ENEMY_OFF_MAP
    AIR_NEAR_EDGE       #the bot is in the air and past EDGE on x or z
    ENEMY_FAR           #the enemy is more than ENEMY_FAR away
    BALL_FAST           #ballSpeed is at least BALL_FAST
    ALL_FAR             #every other living player, bots too, is more than ENEMY_FAR away (also true when there's nobody)
    ORBIT_LINE          #the ball is coming round the bot in an orbit, with the enemy close and in line (firebuss's brad shot)

#Where a shot table row sends the ball (botAimShot in features/bots.opy)
enum BotShot:
    DOWN
    UP
    AT_ENEMY            #the enemy's eyes, within the aim error
    AT_ANYONE           #a random other living player's eyes, within the aim error (down when there's nobody)
    FLOOR_BEHIND_ENEMY  #the floor 6 m behind the enemy, seen from the bot
    CORNER_NEAR_ENEMY   #the arena corner (OFF_MAP) nearest the enemy
    WALL_NEAR_ENEMY     #the arena side (OFF_MAP) nearest the enemy
    UNDER_MAP           #outwards from the middle and under the map
    RANDOM              #any direction
    AWAY                #away from everyone: turned 45-90° from the player closest to the crosshair, re-rolled while anyone is within 30°
    RANDOM_DOWN         #up to 60° off the bot's facing, 25-55° below the horizon (as azertybuss writes it)
    SHALLOW_BOUNCE      #up to 110° off the bot's facing, 15-40° below the horizon (as azertybuss writes it)
    STEEP_BOUNCE        #up to 110° off the bot's facing, 45-85° below the horizon (as azertybuss writes it)

#What a shot was meant to do, read by after-shot moves
enum BotIntent:
    SAFE
    AT_ENEMY
    RISKY

#Fields of the player variable botTuning: a preset's numbers (features/bot-presets.opy)
enum BotTuning:
    NEAR_FACTOR         #the ball counts as near within NEAR_FACTOR * ballSpeed + NEAR_OFFSET m of the bot's eyes
    NEAR_OFFSET
    REACTION_MIN        #seconds the bot waits after the ball is near, before it aims
    REACTION_MAX        #0 = no delay
    MISS_AT_CAP         #true: dies when the ball is at the speed cap
    MISS_SPEED          #from this ballSpeed on, the bot misses MISS_CHANCE % of balls (rolled once per ball)
    MISS_CHANCE
    EARLY_LEAD          #seconds before contact the bot presses deflect itself; 0 = pressed on contact
    AIM_RATE            #turn rate while aiming, degrees per second
    AIM_ERROR_SLOW      #degrees of aim error on AT_ENEMY and AT_ANYONE below AIM_FAST_SPEED
    AIM_ERROR_FAST      #the same from AIM_FAST_SPEED on
    AIM_FAST_SPEED
    OFF_MAP             #m from the arena centre on x or z that count as off the map; corner and wall shots aim there
    EDGE                #m from the centre on x or z that count as near the edge (AIR_NEAR_EDGE)
    ENEMY_FAR           #m (ENEMY_FAR)
    BALL_FAST           #ballSpeed (BALL_FAST)
    EDASH               #true: edash when the ball comes straight back (botEdash)
    GHOST_DASH          #true: ghost dash when the shot goes straight at the next player
    CAMERA              #BotCamera
    CAMERA_RATE         #turn rate of the camera, degrees per second
    SPIN_NEAR_BALL      #BotSpin: what the bot does while the ball is near and its dash is down
    MOVEMENT            #BotMovement
    JUMP_DOUBLE         #% of jumps that are double jumps
    JUMP_WAIT_MIN       #seconds between single jumps
    JUMP_WAIT_MAX
    DOUBLE_WAIT_MIN     #seconds after a double jump
    DOUBLE_WAIT_MAX
    DASH_GUARD          #m: drops the end-of-deflect dash while another player this close has their dash ready; 0 = off
    SAFE_DASH           #true: after an AT_ENEMY shot, dashes sideways toward the middle
    BRAD_SPEED          #from this ballSpeed on, the brad shot (ORBIT_LINE: dash at the enemy so the ball goes into their face); 0 = off
    PUNISH_SPEED        #after a human deflects a ball this fast, the bot turns to the nearest player; 0 = off
    IMPACT_JUMP         #% chance to double jump as the ball comes in (always near the EDGE); 0 = off
    IMPACT_FACTOR       #the ball comes in within IMPACT_FACTOR * ballSpeed + IMPACT_OFFSET m of the bot's eyes
    IMPACT_OFFSET
    CIRCLE_NEAR         #CIRCLE movement: backs off from the enemy closer than this (m)
    CIRCLE_FAR          #closes in on the enemy farther than this (m)
    WALK_EDGE           #walks back to the middle past this far from it on x or z (m); DASH_AWAY stays inside it
    REACTION_FAST_MIN   #the reaction delay from ballSpeed BALL_FAST on (REACTION_FAST_MAX 0 = REACTION_MIN to REACTION_MAX)
    REACTION_FAST_MAX
    ACE_CHANCE          #% chance of an ace dash: a dash along where the ball's target looks, as the ball reaches them; 0 = off
    DASH_AWAY           #% chance to dash sideways after a shot, always after an AT_ENEMY one; 0 = off

#botTuning[BotTuning.CAMERA]
enum BotCamera:
    BETWEEN         #looks between the ball and its target
    HUMAN           #looks at the ball (or the nearest human between balls) with a little noise, turning at CAMERA_RATE / 2 to CAMERA_RATE

#botTuning[BotTuning.SPIN_NEAR_BALL]
enum BotSpin:
    NONE
    RANDOM          #zBozo: looks around at random
    DOWN_UP         #lucybuss: looks straight down, or half the time up while every other player is over ENEMY_FAR away

#botTuning[BotTuning.MOVEMENT]
enum BotMovement:
    ROAM            #zBozo: walks to the ball's target, or to a random spot when it is the target. World directions on a throttle relative to the bot's facing, kept on purpose (it makes zBozo orbit now and then)
    CIRCLE          #firebuss: strafes round the nearest human, keeping CIRCLE_NEAR to CIRCLE_FAR m, with short pauses
    STRAFE          #azertybuss: strafes, walks and stops at random like a player, wherever the others are

#Fields of the player variable botHook: the only bot values core rules read.
#Bot code sets them; a human's botHook is null, so every field reads 0.
enum BotHook:
    PRESET          #BotPreset, NONE for humans
    DEFLECT         #BotDeflect, read by "Collision - collision sub" on contact
    MISS_AT_CAP     #true: the bot dies when the ball is at the speed cap, whatever DEFLECT says
    DASH_WANTED     #true: "Controls - Shorten deflect length" presses dash at the end of the deflect, then clears it
    DASH_DIRECTION  #world direction to face for that dash; null keeps the bot's facing. Cleared with DASH_WANTED

#botHook[BotHook.PRESET]
enum BotPreset:
    NONE
    ZBOZO
    FIREBUSS
    LUCYBUSS
    AZERTYBUSS

#botHook[BotHook.DEFLECT]
enum BotDeflect:
    NONE            #no forced press: the bot deflects (or not) with its own presses, like a human
    PRESS           #deflect is pressed for the bot on contact
    MISS            #the bot dies on contact

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
    NETWORK_RESYNC  #"10 - Ball > network resync", resends the ball's direction 20 times a second (on by default)

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
