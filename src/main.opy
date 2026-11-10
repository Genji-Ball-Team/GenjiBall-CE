#Genji Ball Community Edition - OverPy entry point.
#Build with `npm run build`; output goes to workshop/genjiball.txt.
#Files are included in order, and include order is rule order. The Workshop runs
#rules top to bottom, so some of this order is behaviour. Comments marked ORDER
#say which; docs/architecture.md ("Rule order") explains each one. Unmarked files
#can be moved freely.
#
#Folders: config/ (settings, variables, named constants), core/ (controls, round flow,
#collision, ball physics; feel-locked, see CONTRIBUTING.md), maps/ (arena
#setup and restrictions), features/ (tournament, ranked log, host sit-out, rank tags, tourney), ui/ (HUD, effects).

#The build id for the GBR log line. tools/build-id.mjs hashes src/ and the build replaces this line, so it never needs bumping by hand.
#!define BUILD_ID "dev"

#!include "config/constants.opy"
#!include "config/lobby.opy"
#!include "config/variables.opy"

#ORDER: must be first. Its settings rule has to run before the startup rules in config/initialization and ui/hud.
#!include "config/workshop-settings.opy"
#ORDER: right after config/workshop-settings. "TOURNEY - generated" and "Tourney - settings" change rankedState,
#tournamentMode and totalRounds in the first tick, before the startup rules below read them.
#!include "features/tourney.opy"
#ORDER: after config/workshop-settings. Before config/initialization ("Initialization - map sphere" reads circleCenter once).
#!include "maps/arenas.opy"
#ORDER: after config/workshop-settings and maps/arenas.
#!include "config/initialization.opy"
#ORDER: after config/workshop-settings ("HUD - controls text" reads settings once).
#!include "ui/hud.opy"
#!include "ui/effects.opy"
#ORDER: before core/round-flow. "Check for <2 players" must run before "check for last player surviving".
#!include "core/lobby.opy"
#ORDER: dash/deflect rule order inside this file is input timing. Before maps/restrictions (gravity).
#!include "core/controls.opy"
#ORDER: before core/collision and core/ball-physics ("spawn ball" sets the ball before collision/physics see it).
#!include "core/round-flow.opy"
#ORDER: before core/ball-physics. A deflect must redirect the ball before bounces.
#!include "core/collision.opy"
#ORDER: after core/collision. Bounce rule order inside this file decides same-tick bounces.
#!include "core/ball-physics.opy"
#ORDER: after core/controls (water rules override dash gravity in a shared tick).
#!include "maps/restrictions.opy"
#!include "features/tournament.opy"
#!include "features/ranked-log.opy"
#!include "features/host-sit-out.opy"
#!include "features/rank-tags.opy"
