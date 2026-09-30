#Genji Ball Community Edition - OverPy entry point.
#Build with `npm run build`; output goes to workshop/genjiball.txt.
#Files are included in order. The Workshop runs rules top to bottom, so some of
#this order is behaviour. Comments marked ORDER say which; docs/architecture.md
#("Rule order") explains each one. Unmarked files can be moved freely.

#!include "settings.opy"
#!include "variables.opy"

#ORDER: must be first. Its settings rule has to run before the startup rules in 02 and 03.
#!include "rules/01-settings.opy"
#ORDER: after 01. The map rules must stay before "Initialization - bounce pads".
#!include "rules/02-initialization.opy"
#ORDER: after 01 ("HUD - controls text", "HUD - Watermark" read settings once).
#!include "rules/03-hud.opy"
#ORDER: before 06. "Check for <2 players" must run before "check for last player surviving".
#!include "rules/04-lobby.opy"
#ORDER: dash/deflect rule order inside this file is input timing. Before 10 (gravity).
#!include "rules/05-controls.opy"
#ORDER: before 08 and 09 ("spawn ball" sets the ball before collision/physics see it).
#!include "rules/06-round-flow.opy"
#!include "rules/07-duels.opy"
#ORDER: before 09, 13 and 17. A deflect must redirect the ball before bounces, tracing and target switch.
#!include "rules/08-collision.opy"
#ORDER: after 08. Bounce rule order inside this file decides same-tick bounces.
#!include "rules/09-ball-physics.opy"
#ORDER: after 05 (water rules override dash gravity in a shared tick).
#!include "rules/10-map-restrictions.opy"
#!include "rules/11-tournament.opy"
#ORDER: "no orbit abusing" must stay before "track pressure".
#!include "rules/12-anti-orbit.opy"
#ORDER: after 08 (collision reads last tick's tracingPoints).
#!include "rules/13-tracing-mode.opy"
#!include "rules/14-bot-zbozo.opy"
#ORDER: after 08 ("2. Target switch" overrides a same-tick deflect).
#!include "rules/17-abilities.opy"
#!include "rules/19-sandbox.opy"
#!include "rules/20-abilities-experimental.opy"
