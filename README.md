README: [🇺🇸](/README.md) | [🇷🇺](/README.ru.md)

# ITL_noafk

This is a simple serverside plugin for BeamMP that kick afk players or remove abandoned vehicles

## Plugin installation & update

- Simple drag&drop "ITL_noafk" folder in to "Resources/Server" directory of your server

## Configuring

Explanation of config rows:
```
"vehiclePositionsCheckDelay": 5,                            // Check players positions every N seconds
"kickAfkPlayers": true,                                     // Kick players for AFK (the player must have a vehicle! if the player has several cars, then they all must be idle!)
"kickAfkPlayersChecksCount": 60,                            // Count in checks through which the player’s AFK will kick
"kickAfkPlayersNotifyPlayer": true,                         // Notify the player that he will be kicked for AFK (true - yes, false - no)
"kickAfkPlayersNotifyPlayerAfterCount": 50,                 // Number of checks through which the player will be notified that he has been AFK for a long time and that he will be kicked
"kickAfkPlayersWoVehicles": true,                           // Kick AFK players without transport (true - yes, false - no)
"kickAfkPlayersWoVehiclesChecksCount": 120,                 // Number of checks through which an AFK player without a vehicle will kick
"kickAfkPlayersWoVehiclesNotifyPlayer": true,               // Notify the AFK player without transport that he will be kicked (true - yes, false - no)
"kickAfkPlayersWoVehiclesNotifyPlayerAfterCount": 110,      // Number of checks through which the AFK of a player without a vehicle will notify
"destroyAbandonedVehicle": true,                            // Delete unused vehiclesv (true - yes, false - no)
"destroyAbandonedVehicleChecksCount": 120,                  // Number of checks through which unused vehicles will be deleted
"destroyAbandonedVehicleNotifyPlayer": true,                // Notify the player that his unused vehicle will be deleted (true - yes, false - no)
"destroyAbandonedVehicleNotifyPlayerAfterCount": 110,       // Count in checks through which the player will be notified that his unused transport will be deleted
"debug": false                                              // Debugging mode (true - enable, false - disable | false recommended)
```

## Tips:

ToDo...

## Thanks

[csv4211](https://github.com/csv4211) and [STRMBRG](https://github.com/STRMBRG) for helping with docs and testing
