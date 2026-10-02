#Lobby, mode, hero and extension settings for the custom game.

settings {
    "main": {
        "description": "Welcome to Genji Ball v1.3.3T (Teams)!\nDeflect the ball at the other team. A team\nscores when the other team is wiped out.\nTournaments, events and community:\ndiscord.gg/genjiball. More info:\nworkshop.codes/GenjiBall-CE\nReport bugs as an issue on GitHub:\ngithub.com/Genji-Ball-Team/GenjiBall-CE\n\nTeams (1.3T) by zSh4d0W. v1.3.2 rebuild\nand development by Frozonovic. Originally\nby Mazawrath, with major updates by\nzSh4d0W, ØøØøØzZØøØøØ and the official\nGenji Dodgeball community.",
        "modeName": "Genji Ball v1.3.3T"
    },
    "lobby": {
        "allowPlayersInQueue": true,
        "mapRotation": "afterGame",
        "enableMatchVoiceChat": true,
        "spectatorSlots": 12,
        "team1Slots": 5,
        "team2Slots": 5,
        "returnToLobby": "never",
        "swapTeamsAfterMatch": false,
        "teamBalancing": "afterGame"
    },
    "gamemodes": {
        "ffa": {
            "enabled": false
        },
        "tdm": {
            "enabledMaps": [
                "workshopIslandNight"
            ],
            "gameLengthInMn": 15,
            "needsImbalancedTeamScoreToWin": true,
            "team1ScoreToWin": 10,
            "team2ScoreToWin": 10
        },
        "general": {
            "enableHeroSwitching": false,
            "gamemodeStartTrigger": "immediately",
            "heroLimit": "off",
            "enableRandomHeroes": true,
            "enableSelfInitiatedRespawn": false
        }
    },
    "heroes": {
        "allTeams": {
            "genji": {
                "ability2Cooldown%": 0,
                "jumpVerticalSpeed%": 100,
                "movementGravity%": 100,
                "movementSpeed%": 100,
                "enableInfiniteAmmo": true,
                "enablePrimaryFire": false,
                "projectileSpeed%": 120,
                "enableMelee": false,
                "enableSecondaryFire": false,
                "ability1Cooldown%": 38,
                "combatUltGen%": 0,
                "passiveUltGen%": 0
            },
            "enabledHeroes": [
                "genji"
            ]
        }
    }
}
