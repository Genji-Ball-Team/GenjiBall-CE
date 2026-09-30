#Lobby, mode, hero and extension settings for the custom game.

settings {
    "main": {
        "description": "Welcome to Genji Ball v1.3.2!\nDeflect the ball when targeted. Last player\nstanding wins the round. Join tournaments,\nevents, and community discussion at\ndiscord.gg/genjiball. More info:\nworkshop.codes/genjiball.\n\nv1.3.2 rebuild and continued development\nby Frozonovic. Originally developed by\nMazawrath, with major updates by zSh4d0W,\nØøØøØzZØøØøØ, and the official Genji\nDodgeball community.",
        "modeName": "Genji Ball v1.3.2"
    },
    "lobby": {
        "allowPlayersInQueue": true,
        "mapRotation": "afterGame",
        "enableMatchVoiceChat": true,
        "ffaSlots": 10,
        "spectatorSlots": 12,
        "returnToLobby": "never"
    },
    "gamemodes": {
        "ffa": {
            "enabledMaps": [
                "workshopIslandNight"
            ]
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
