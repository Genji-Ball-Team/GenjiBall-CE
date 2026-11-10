#Named values for enum-like settings and variables.
#OverPy inlines enum members, so these compile to the same numbers as before.
#The order of each enum must match its Workshop setting's option list in
#config/workshop-settings.opy: the setting stores the option's index.

#presetMode ("00 - Preset > preset")
enum Preset:
    DEFAULT
    TOURNAMENT

#The preset names MATCH_START logs (docs/ranked-log.md), in Preset order: a new preset goes in both, at the same place
#!define PRESET_LOG_NAMES ["Default", "Tournament"]

#Fields of ballFeel, the ball's feel numbers: always BALL_FEEL_DEFAULTS ("Settings - Workshop settings").
#CUSTOM and RAPID_RATE aren't read any more (they were "15 - Ball Feel" settings), and stay so the
#other fields keep their indices.
enum BallFeel:
    CUSTOM              #unused: was "custom ball feel"
    DEFLECT_SPEEDUP     #ballSpeed is multiplied by this on a deflect (up to ballSpeedCap)
    HIT_RADIUS          #the ball hits its target within this distance of their eyes
    MODERN_RATE         #ballDirectionRateInit with motion = modern
    RAPID_RATE          #unused: was ballDirectionRateInit with motion = rapid
    CURVE_RATE          #ballDirectionRate right after a deflect
    CURVE_TIME          #seconds CURVE_RATE lasts
    DEFLECT_WINDOW      #seconds a deflect lasts ("Controls - Shorten deflect length")
    DEFLECT_LOCKOUT     #seconds dash and deflect are locked after it
    FAST_BALL_SPEED     #above this ballSpeed, "Collision - collision check" also checks points between frames
    RELIABLE_HITS       #false: "Collision - collision check" only runs above FAST_BALL_SPEED

#ballFeel, in BallFeel order: the v1.3.2 values
#!define BALL_FEEL_DEFAULTS [false, 1.05, 1.9, 1.75, 5, 6, 0.05, 0.3, 0.5, 150, false]

#Fields of phasePosition, points between the ball's last and current position
#that "Collision - collision check" also checks, so a fast ball can't skip the target
enum PhasePoint:
    LAST     #the ball's position at the last check, moved halfway to the current one during the check
    QUARTER  #halfway between LAST before and after that move

#Fields of roundTimings, the round flow's timings ("Settings - Workshop settings")
enum RoundTiming:
    RESPAWN_DELAY   #seconds before the ball respawns after a kill
    WIN_PAUSE       #seconds between a round win and the next round

#Fields of playerSettings, the dash and dash-hit stun timings ("Settings - Workshop settings")
enum PlayerSetting:
    DASH_COOLDOWN   #seconds after a dash ends before the next one ("Controls - Dash cooldown")
    STUN_DURATION   #seconds a dash-hit knocks the dasher down ("Collision - dash sub")
    STUN_COOLDOWN   #seconds before another dash-hit can knock them down again

#"Tournament - no orbit abusing": the target is put to sleep after BASIC_ORBIT_TIMER seconds with a ball
#slower than BASIC_ORBIT_SPEED within BASIC_ORBIT_RADIUS m of their eyes
#!define BASIC_ORBIT_RADIUS 20
#!define BASIC_ORBIT_SPEED 80
#!define BASIC_ORBIT_TIMER 7.5

#Workshop Island Night, the only map ranked plays on: its center and radius (maps/arenas.opy)
#!define ISLAND_CENTER vect(0, 1.199, 0)
#!define ISLAND_RADIUS 60

#Radius of the black sphere at the center that players are pushed out of
#!define CENTER_EXCLUSION_SIZE 3.5

#Fields of addOnSettings, the add-on settings no preset forces
enum AddOnSetting:
    DOUBLE_SENS     #"30 - Player > double sens"
    SENS_MULTIPLIER #"30 - Player > double sens %", the aim speed double sens switches to
    COLORBLIND      #"80 - Visual > red-green colorblind filter", blue/yellow target visuals
    DEBUG_HUD       #"90 - Debug > debug HUD"

#Fields of rankedState, the ranked log's state (features/ranked-log.opy)
#The settings come first: "Settings - Workshop settings" builds rankedState with them in this order.
enum RankedField:
    LOGGING     #"70 - Ranked > ranked logging"
    TAGS        #"70 - Ranked > rank tags", the floating tags over players
    TAG_HEIGHT  #"70 - Ranked > rank tag height", metres above the player's position
    TAG_SIZE    #"70 - Ranked > rank tag size", the tag's in-world text size
    GUIDE       #"70 - Ranked > top 10 list", the top 10 list and "Live leaderboard" line on the right
    DEBUG_HUD   #"70 - Ranked > ranked debug HUD", the host-only ranked log state
    STARTED     #MATCH_START is logged, so JOIN and LEAVE can be
    ROUND       #the current round's number, from 1 in each match
    IN_ROUND    #a ROUND_START is logged and its ROUND_END isn't yet
    TEXT        #the id list being built for ROUND_START
    COUNT       #how many ids are in TEXT so far
    DEFLECTOR   #the prevTarget "Ranked log - DEFLECT" last saw
    TAG_LOOP    #loop counter for the rank tag and top 10 list rules (features/rank-tags.opy)
    UNRANKED    #the UnrankedReasons logged in this match
    UNRANKED_TEXT   #the unranked warning's reasons, comma-separated
    REASON      #the UnrankedReason for logRankedUnranked()
    TOURNEY     #the tourney settings (TourneyField), set only by "TOURNEY - generated". Its index (16) is
                #part of the rule's contract (docs/tourney-rule.md): add new fields after it, never before
    MATCH_KEY   #this match's matchKey from GBR, 12 digits as text
    ENDED       #tourney: MATCH_END ROUNDS is logged, the final standings are up
    STANDINGS   #tourney: the players on the final standings, best first
    SIT_OUT_WISH    #the host's choice, switched with Crouch + Interact: sit out from the next round (features/host-sit-out.opy)
    SITTING_OUT     #the host sits out now: not brought back for rounds, not counted as a player (playingPlayers)
    SIT_OUT_HOST    #the hostPlayer the two above belong to. A new host starts playing
    SIT_OUT_READY   #the first round has started, so the default (sit out from round 2) is set

#Fields of rankedState[TOURNEY], the tourney rule's values (docs/tourney-rule.md), in the rule's order
enum TourneyField:
    ON          #true in a tourney code: round-based match, TOURNEY line, final standings
    LOBBY_KEY   #the server's id for the tourney lobby, digits as text (may start with 0)
    ROUND_LIMIT #rounds the match lasts. Replaces "40 - Match > tournament rounds"
    NAME        #the tourney's name on the HUD and final standings ("October Cup")
    LOBBY_LABEL #the lobby's label next to it ("Lobby 1/2")

#A tourney code: the tourney rule is on (features/tourney.opy)
#!define TOURNEY_ON (rankedState[RankedField.TOURNEY][TourneyField.ON] == true)

#The tourney's name and lobby label, on the HUD (ui/hud.opy) and the final standings (features/tourney.opy)
#!define TOURNEY_TITLE "{0}   {1}".format(rankedState[RankedField.TOURNEY][TourneyField.NAME], rankedState[RankedField.TOURNEY][TourneyField.LOBBY_LABEL])

#Rounds a tourney lasts when the rule's round limit is below 1
#!define TOURNEY_DEFAULT_ROUNDS 30

#Seconds between the last round's ROUND_END and MATCH_END ROUNDS, so that round's last KILL and LEAVE lines come first
#!define TOURNEY_MATCH_END_DELAY 1

#Seconds the final standings stay up before the match ends and the lobby resets: time for the host's screenshot
#!define TOURNEY_STANDINGS_TIME 30

#Final standings: wins count this much more than kills, so sorting on wins * weight + kills puts most wins
#first and breaks ties on kills. More kills than one match can have.
#!define TOURNEY_WIN_WEIGHT 10000

#Final standings: the sort order of their header line, at the top of the screen above the unranked warning
#!define TOURNEY_STANDINGS_SORT -40

#Fields of a player's tourneyStats, counted from their JOIN as the server counts the log (docs/ranked-log.md)
enum TourneyStat:
    WINS        #ROUND_END WIN rounds they won, rated or not
    KILLS       #KILL lines with them as the attacker (not themselves)

#Why a match won't count: UNRANKED's reason codes (docs/ranked-log.md, "Unranked matches").
#The code and warning text of each are UNRANKED_CODES and UNRANKED_TEXTS (features/ranked-log.opy).
enum UnrankedReason:
    MAP
    MODE
    PRESET
    FEEL
    ADD_ON
    BOT

#Fields of an entry in rankTags ("RANKS - generated", docs/rank-tags.md)
enum RankTagField:
    LABEL       #the tag over the player
    COLOR       #the tag's and the list line's colour
    GUIDE       #the entry's line in the top 10 list, empty for a rank tier
    NAMES       #the player names in this entry start here

#Players a round can use (core/lobby.opy): everyone in a slot but a host who sits out (features/host-sit-out.opy)
#!define playingPlayers (getNumberOfPlayers(Team.ALL) - (1 if rankedState[RankedField.SITTING_OUT] and hostPlayer in getAllPlayers() else 0))
#True for the host while they sit out: not brought back for a round, never in a tiebreaker
#!define sitsOut(player) (player == hostPlayer and rankedState[RankedField.SITTING_OUT])
#The players a tiebreaker is decided among and played by: everyone in a slot but a host who sits out
#!define tiebreakerPlayers getAllPlayers().filter(lambda player: not sitsOut(player))

#FFA slots a lobby can have: one rank tag each
#!define FFA_SLOTS 12

#eventPlayer.simpleHUD, toggled with Interact
enum SimpleHud:
    OFF
    ON
    ZEN
