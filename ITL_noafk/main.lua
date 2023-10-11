pluginName = "ITL_noafk"
pluginVersion = "0.0.1"
playersCache = {}

CFG = require("cfg")

function table.removekey(table, key)
    local element = table[key]
    table[key] = nil
    return element
end

function IsFloatEqual(first, second)
    if first == nil and second == nil then
        return true
    end
    if first ~= nil and second ~= nil and math.abs(first - second) < 0.01 then
        return true
    end
    return false
end

function RenewPlayersCache()
    local playersCount = 0
    local players = MP.GetPlayers()

    if players ~= nil then
        for playerId, playerName in pairs(players) do
            playersCount = playersCount + 1
            local playerVehicles = MP.GetPlayerVehicles(playerId)

            if playersCache[playerName] == nil then
                playersCache[playerName] = {}
            end
            if playersCache[playerName]["count"] == nil then
                playersCache[playerName]["count"] = 0
            end
            if playersCache[playerName]["vehicles"] == nil then
                playersCache[playerName]["vehicles"] = {}
            end
            playersCache[playerName]["atleastOnePlayerVehicleMove"] = false

            if playerVehicles ~= nil then
                for playerVehicleIdValue, playerVehicle in pairs(playerVehicles) do
                    local playerVehicleId = tonumber(playerVehicleIdValue)
                    local playerVihiclePosition = MP.GetPositionRaw(playerId, playerVehicleId)

                    if playersCache[playerName]["vehicles"][playerVehicleId] == nil then
                        playersCache[playerName]["vehicles"][playerVehicleId] = {}
                    end
                    if playersCache[playerName]["vehicles"][playerVehicleId]["positions"] == nil then
                        playersCache[playerName]["vehicles"][playerVehicleId]["positions"] = {}
                    end

                    if
                        IsFloatEqual(playersCache[playerName]["vehicles"][playerVehicleId]["positions"][1], playerVihiclePosition.pos[1])
                        and IsFloatEqual(playersCache[playerName]["vehicles"][playerVehicleId]["positions"][2], playerVihiclePosition.pos[2])
                        and IsFloatEqual(playersCache[playerName]["vehicles"][playerVehicleId]["positions"][3], playerVihiclePosition.pos[3])
                    then
                        playersCache[playerName]["vehicles"][playerVehicleId]["count"] = playersCache[playerName]["vehicles"][playerVehicleId]["count"] + 1
                    else
                        playersCache[playerName]["vehicles"][playerVehicleId]["count"] = 0
                        playersCache[playerName]["atleastOnePlayerVehicleMove"] = true
                    end

                    playersCache[playerName]["vehicles"][playerVehicleId]["positions"][1] = playerVihiclePosition.pos[1]
                    playersCache[playerName]["vehicles"][playerVehicleId]["positions"][2] = playerVihiclePosition.pos[2]
                    playersCache[playerName]["vehicles"][playerVehicleId]["positions"][3] = playerVihiclePosition.pos[3]
                    if playersCache[playerName]["vehicles"][playerVehicleId]["count"] == nil then
                        playersCache[playerName]["vehicles"][playerVehicleId]["count"] = 0
                    end
                end
            end

            if playersCache[playerName]["atleastOnePlayerVehicleMove"] then
                playersCache[playerName]["count"] = 0
            else
                playersCache[playerName]["count"] = playersCache[playerName]["count"] + 1
            end
        end

        if playersCount > 0 and pluginConfig.debug == true then
            print("-- ANTI AFK DEBUG CACHE --")
            print(playersCache)
        end
    else
        playersCache = {}
    end
end

function CheckAfkRules()
    local players = MP.GetPlayers()

    if players ~= nil then
        for playerId, playerName in pairs(players) do
            local playerVehicleKey = 0
            for playerVehicleId, playerVehicleData in pairs(playersCache[playerName]["vehicles"]) do
                playerVehicleKey = playerVehicleKey + 1
                if
                playersCache[playerName]["vehicles"][playerVehicleId] ~= nil
                and pluginConfig.destroyAbandonedVehicle == true
                and playersCache[playerName]["vehicles"][playerVehicleId]["count"] >= pluginConfig.destroyAbandonedVehicleChecksCount
                then
                    if pluginConfig.debug == true then
                        print("-- ANTI AFK DEBUG REMOVE --")
                        print("TEST PLAYER VEHICLE REMOVE ID: " .. playerVehicleId)
                    end
                    playersCache[playerName]["vehicles"][playerVehicleId] = nil
                    MP.RemoveVehicle(playerId, playerVehicleId)
                else
                    if
                        pluginConfig.destroyAbandonedVehicleNotifyPlayer == true
                        and playersCache[playerName]["vehicles"][playerVehicleId]["count"] >= pluginConfig.destroyAbandonedVehicleNotifyPlayerAfterCount
                    then
                        local secondsToDestroy = (pluginConfig.destroyAbandonedVehicleChecksCount - playersCache[playerName]["vehicles"][playerVehicleId]["count"]) * pluginConfig.vehiclePositionsCheckDelay
                        MP.SendChatMessage(playerId, string.format("Your vehicle #%s will be destroyed after %s seconds because not move", playerVehicleId, secondsToDestroy))
                    end
                end
            end

            if playerVehicleKey > 0 then
                if pluginConfig.kickAfkPlayers == true and playersCache[playerName]["count"] >= pluginConfig.kickAfkPlayersChecksCount then
                    if pluginConfig.debug == true then
                        print("-- ANTI AFK DEBUG KICK --")
                        print("TEST KICK PLAYER: " .. playerName)
                    end
                    MP.DropPlayer(playerId, "You are kicked because so long AFK!")
                else
                    if
                        pluginConfig.kickAfkPlayersNotifyPlayer == true
                        and playersCache[playerName]["count"] >= pluginConfig.kickAfkPlayersNotifyPlayerAfterCount
                    then
                        local secondsToKick = (pluginConfig.kickAfkPlayersChecksCount - playersCache[playerName]["count"]) * pluginConfig.vehiclePositionsCheckDelay
                        MP.SendChatMessage(playerId, string.format("You will be kicked for AFK after %s seconds", secondsToKick))
                    end
                end
            else
                if pluginConfig.kickAfkPlayersWoVehicles == true and playersCache[playerName]["count"] >= pluginConfig.kickAfkPlayersWoVehiclesChecksCount then
                    if pluginConfig.debug == true then
                        print("-- ANTI AFK DEBUG KICK WO VEHICLE --")
                        print("TEST KICK PLAYER: " .. playerName)
                    end
                    MP.DropPlayer(playerId, "You are kicked because so long AFK!")
                else
                    if
                        pluginConfig.kickAfkPlayersWoVehiclesNotifyPlayer == true
                        and playersCache[playerName]["count"] >= pluginConfig.kickAfkPlayersWoVehiclesNotifyPlayerAfterCount
                    then
                        local secondsToKick = (pluginConfig.kickAfkPlayersWoVehiclesChecksCount - playersCache[playerName]["count"]) * pluginConfig.vehiclePositionsCheckDelay
                        MP.SendChatMessage(playerId, string.format("You will be kicked for AFK after %s seconds, you need to spawn vehicle", secondsToKick))
                    end
                end
            end
        end
    end
end

function FindPlayerFreshestCar(playerId)
    local playerName = MP.GetPlayerName(playerId)
    local playerVehicles = MP.GetPlayerVehicles(playerId)
    local freshestPlayerVehicleId = nil
    local freshestPlayerVehicleCount = nil

    if playerVehicles ~= nil then
        for playerVehicleIdValue, playerVehicle in pairs(playerVehicles) do
            local playerVehicleId = tonumber(playerVehicleIdValue)
            if freshestPlayerVehicleId == nil and freshestPlayerVehicleCount == nil then
                freshestPlayerVehicleId = playerVehicleId
                freshestPlayerVehicleCount = playersCache[playerName]["vehicles"][playerVehicleId]["count"]
            else
                if playersCache[playerName]["vehicles"][playerVehicleId]["count"] < freshestPlayerVehicleCount then
                    freshestPlayerVehicleId = playerVehicleId
                    freshestPlayerVehicleCount = playersCache[playerName]["vehicles"][playerVehicleId]["count"]
                end
            end
        end
    end

    return freshestPlayerVehicleId
end

function ResetCounter(playerId, playerVehicleId)
    if playerId ~= nil then
        local playerName = MP.GetPlayerName(playerId)
        playersCache[playerName]["count"] = 0

        if playerVehicleId == nil then
            -- nothing
        elseif playerVehicleId == -1 then
            freshestPlayerVehicleId = FindPlayerFreshestCar(playerId)
            if freshestPlayerVehicleId ~= nil then
                playersCache[playerName]["vehicles"][freshestPlayerVehicleId]["count"] = 0
            end
        else
            playersCache[playerName]["vehicles"][playerVehicleId]["count"] = 0
        end
    end
end

function onInit()

    pluginConfig = CFG.get("main.config.json")

    function PlayersCheckTimerHandler()
        RenewPlayersCache()
        CheckAfkRules()
    end
    MP.RegisterEvent("PlayersCheckTimer", "PlayersCheckTimerHandler")
    MP.CreateEventTimer("PlayersCheckTimer", pluginConfig.vehiclePositionsCheckDelay * 1000)

    function OnChatMessageHandler(playerId, playerName, message)
        ResetCounter(playerId, -1)
    end
    MP.RegisterEvent("onChatMessage", "OnChatMessageHandler")

    function OnVehicleEditedHandler(playerId, vehicleId, data)
        ResetCounter(playerId, vehicleId)
    end
    MP.RegisterEvent("onVehicleEdited", "OnVehicleEditedHandler")

    function OnVehicleResetHandler(playerId, vehicleId, data)
        ResetCounter(playerId, vehicleId)
    end
    MP.RegisterEvent("onVehicleReset", "OnVehicleResetHandler")

    function OnVehicleDeletedHandler(playerId, vehicleId)
        ResetCounter(playerId, nil)
    end
    MP.RegisterEvent("onVehicleDeleted", "OnVehicleDeletedHandler")

    function OnPlayerDisconnectHandler(playerId)
        local playerName = MP.GetPlayerName(playerId)
        playersCache[playerName] = nil
        -- ToDo MAKE REAL DELETE!!!
    end
    MP.RegisterEvent("onPlayerDisconnect", "OnPlayerDisconnectHandler")

end
