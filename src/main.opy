#Genji Ball Community Edition - OverPy entry point.
#Build with `npm run build`; output goes to workshop/genjiball.txt.
#Files are included in order. Rule order matters in the Workshop, so keep it.

#!include "settings.opy"
#!include "variables.opy"

#!include "rules/01-settings.opy"
#!include "rules/02-initialization.opy"
#!include "rules/03-hud.opy"
#!include "rules/04-lobby.opy"
#!include "rules/05-controls.opy"
#!include "rules/06-round-flow.opy"
#!include "rules/07-duels.opy"
#!include "rules/08-collision.opy"
#!include "rules/09-ball-physics.opy"
#!include "rules/10-map-restrictions.opy"
#!include "rules/11-tournament.opy"
#!include "rules/12-anti-orbit.opy"
#!include "rules/13-tracing-mode.opy"
#!include "rules/14-bot-zbozo.opy"
#!include "rules/15-tombstone.opy"
#!include "rules/16-player-rank.opy"
#!include "rules/17-abilities.opy"
#!include "rules/18-teams.opy"
#!include "rules/19-sandbox.opy"
#!include "rules/20-abilities-experimental.opy"
