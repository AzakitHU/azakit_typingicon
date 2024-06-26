local typingPlayers = {}

-- When a player starts typing
RegisterServerEvent('azakit_typingicon:typingStart')
AddEventHandler('azakit_typingicon:typingStart', function()
    local sourcePlayer = source
    local playerPed = GetPlayerPed(sourcePlayer)
    local coords = GetEntityCoords(playerPed)
    typingPlayers[sourcePlayer] = { coords = coords }
    TriggerClientEvent('azakit_typingicon:showTypingIcon', -1, sourcePlayer, true, coords)
    UpdateTypingPlayers()
end)

-- If a player stops typing
RegisterServerEvent('azakit_typingicon:typingStop')
AddEventHandler('azakit_typingicon:typingStop', function()
    local sourcePlayer = source
    typingPlayers[sourcePlayer] = nil
    TriggerClientEvent('azakit_typingicon:showTypingIcon', -1, sourcePlayer, false)
    UpdateTypingPlayers()
end)

-- If a player leaves the server, remove them from the list
AddEventHandler('playerDropped', function()
    local sourcePlayer = source
    typingPlayers[sourcePlayer] = nil
    TriggerClientEvent('azakit_typingicon:showTypingIcon', -1, sourcePlayer, false)
    UpdateTypingPlayers()
end)

-- Updating players' environment
function UpdateTypingPlayers()
    local players = GetPlayers()
    local updatedPlayers = {}

    -- Gather typing players
    for _, playerId in ipairs(players) do
        local sourcePlayer = tonumber(playerId)
        if typingPlayers[sourcePlayer] then
            updatedPlayers[sourcePlayer] = GetEntityCoords(GetPlayerPed(sourcePlayer))
        end
    end

    -- Send the data to the clients
    for targetPlayer, coords in pairs(updatedPlayers) do
        local targetPed = GetPlayerPed(targetPlayer)
        local targetCoords = GetEntityCoords(targetPed)
        local distance = #(targetCoords - coords)

        -- Only send the data if the player is close enough to the typist
        if distance < Config.Distance then
            TriggerClientEvent('azakit_typingicon:displayTypingIcon', targetPlayer, true, coords)
        else
            TriggerClientEvent('azakit_typingicon:displayTypingIcon', targetPlayer, false)
        end
    end
end
