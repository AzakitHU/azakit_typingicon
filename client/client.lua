local typing = false
local typingPlayers = {}

-- Show or hide the icon above the player's head
RegisterNetEvent('azakit_typingicon:showTypingIcon')
AddEventHandler('azakit_typingicon:showTypingIcon', function(playerId, show, coords)
    local player = GetPlayerFromServerId(playerId)
    if player and NetworkIsPlayerActive(player) then
        local playerPed = GetPlayerPed(player)
        local playerCoords = GetEntityCoords(playerPed)
        local distance = #(playerCoords - coords)

        if show and distance < Config.Distance then
            typingPlayers[playerId] = { show = true, coords = coords }
            Citizen.CreateThread(function()
                Citizen.Wait(Config.Time)
                typingPlayers[playerId] = nil
            end)
        else
            typingPlayers[playerId] = nil
        end
    end
end)

-- Monitoring chat status
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        if IsControlJustPressed(0, 245) then --  press 'T'
            typing = true
            TriggerServerEvent('azakit_typingicon:typingStart')
      --[[  elseif typing and not IsControlPressed(0, 245) then
            if IsControlJustPressed(0, 322) or IsControlJustPressed(0, 18) then -- press ESC or ENTER
                typing = false
                TriggerServerEvent('azakit_typingicon:typingStop')
            end]]
        end
    end
end)

-- Monitoring chat events
RegisterNUICallback('chatResult', function(data, cb)
    if typing then
        typing = false
        TriggerServerEvent('azakit_typingicon:typingStop')
    end
    cb('ok')
end)

-- Show players icon
Citizen.CreateThread(function()
    while true do
        local playerPed = PlayerPedId()
        local playerCoords = GetEntityCoords(playerPed)

        for playerId, data in pairs(typingPlayers) do
            local player = GetPlayerFromServerId(playerId)
            if player and NetworkIsPlayerActive(player) then
                local ped = GetPlayerPed(player)
                local pedCoords = GetEntityCoords(ped)
                local distance = #(playerCoords - pedCoords)

                if data.show and distance < Config.Distance then
                    DrawText3D(pedCoords.x, pedCoords.y, pedCoords.z + Config.Height, Config.Text, Config.MarkerScale)
                end
            end
        end

        Citizen.Wait(0)
    end
end)

-- Function for your 3D text image
function DrawText3D(x, y, z, text, scale)
    local onScreen, _x, _y = World3dToScreen2d(x, y, z)
    local px, py, pz = table.unpack(GetGameplayCamCoords())
    local dist = GetDistanceBetweenCoords(px, py, pz, x, y, z, 1)

    local scale = scale / dist

    if onScreen then
        SetTextScale(0.0, scale)
        SetTextFont(Config.TextFont)
        SetTextProportional(1)
        SetTextColour(Config.Colour.r, Config.Colour.g, Config.Colour.b, Config.Colour.a)
        SetTextDropshadow(0, 0, 0, 0, 255)
        SetTextEdge(2, 0, 0, 0, 150)
        SetTextDropShadow()
        SetTextOutline()
        SetTextEntry("STRING")
        SetTextCentre(1)
        AddTextComponentString(text)
        DrawText(_x, _y)
    end
end
