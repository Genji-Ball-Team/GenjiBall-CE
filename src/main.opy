#Genji Ball Community Edition - OverPy entry point.
#Build with `npm run build`; output goes to workshop/genjiball.txt.
#Files are included in order. Rule order matters in the Workshop, so keep it.
#
#Folders: config/ (settings, presets, variables), core/ (controls, round flow,
#collision, ball physics), maps/ (per-map setup and restrictions), features/
#(optional modes and tools), ui/ (HUD, effects).

#!include "config/lobby.opy"
#!include "config/variables.opy"

#!include "config/workshop-settings.opy"
#!include "maps/arenas.opy"
#!include "config/initialization.opy"
#!include "ui/hud.opy"
#!include "ui/effects.opy"
#!include "core/lobby.opy"
#!include "core/controls.opy"
#!include "core/round-flow.opy"
#!include "features/duels.opy"
#!include "core/collision.opy"
#!include "core/ball-physics.opy"
#!include "maps/restrictions.opy"
#!include "features/tournament.opy"
#!include "features/anti-orbit.opy"
#!include "features/tracing.opy"
#!include "features/bot-zbozo.opy"
#!include "features/tombstone.opy"
#!include "features/player-rank.opy"
#!include "features/abilities.opy"
#!include "features/teams.opy"
#!include "features/sandbox.opy"
#!include "features/abilities-experimental.opy"
