ESX = exports["es_extended"]:getSharedObject()
local staffTags = {}
local showTag = false
local keyMapped = false

-- command /tagstaff
RegisterCommand('tagstaff', function()
    TriggerServerEvent('ardenhub_staff:toggleTag')
end, false)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        if not keyMapped then
            RegisterKeyMapping('tagstaff', 'Enable/Disable Staff Tag', 'keyboard', Config.DefaultKey)
            keyMapped = true
        end
    end
end)

RegisterNetEvent('ardenhub_staff:setTag')
AddEventHandler('ardenhub_staff:setTag', function(state)
    showTag = state
    local message = state and "Staff tag enabled" or "Staff tag disabled"
    ESX.ShowNotification(message)
end)

RegisterNetEvent('ardenhub_staff:syncTags')
AddEventHandler('ardenhub_staff:syncTags', function(tags)
    staffTags = tags
end)

Citizen.CreateThread(function()
    while true do
        local sleep = 1000
        
        if next(staffTags) ~= nil then
            local playerPed = PlayerPedId()
            local playerCoords = GetEntityCoords(playerPed)
            local anyNearbyStaff = false
            
            for serverId, hasTag in pairs(staffTags) do
                if hasTag then
                    local targetPed = GetPlayerPed(GetPlayerFromServerId(serverId))
                    if targetPed ~= 0 and DoesEntityExist(targetPed) then
                        local targetCoords = GetEntityCoords(targetPed)
                        local distance = #(playerCoords - targetCoords)
                        
                        if distance < Config.MaxDistance then
                            anyNearbyStaff = true
                            local x, y, z = table.unpack(targetCoords)
                            z = z + Config.TagHeight
                            
                            if HasEntityClearLosToEntity(playerPed, targetPed, 17) then
                                DrawText3D(x, y, z, Config.TagText, Config.TagColor.r, Config.TagColor.g, Config.TagColor.b)
                            end
                        end
                    end
                end
            end
            
            if anyNearbyStaff then
                sleep = 0
            end
        end
        
        Citizen.Wait(sleep)
    end
end)

local animationOffset = 0.0
local animationDirection = 1

function DrawText3D(x, y, z, text, r, g, b)
    animationOffset = animationOffset + (0.0005 * animationDirection)
    if animationOffset > 0.02 then
        animationDirection = -1
    elseif animationOffset < -0.02 then
        animationDirection = 1
    end
    
    if Config.PulseEffect then
        z = z + animationOffset
    end
    
    local onScreen, _x, _y = World3dToScreen2d(x, y, z)
    local px, py, pz = table.unpack(GetGameplayCamCoords())
    local scale = 0.7
    
    if onScreen then
        local playerPed = PlayerPedId()
        local playerCoords = GetEntityCoords(playerPed)
        local distance = #(playerCoords - vector3(x, y, z))
        local alpha = 255
        
        if distance > Config.FadeDistance then
            local fadeRange = Config.MaxDistance - Config.FadeDistance
            alpha = math.floor(255 * (1.0 - (distance - Config.FadeDistance) / fadeRange))
            if alpha < 40 then alpha = 40 end
        end
        
        SetTextScale(scale, scale)
        SetTextFont(Config.TagFont)
        SetTextProportional(1)
        SetTextColour(r, g, b, alpha)
        SetTextDropshadow(0, 0, 0, 0, alpha)
        SetTextEdge(2, 0, 0, 0, math.floor(alpha * 0.6))
        SetTextDropShadow()
        SetTextOutline()
        SetTextEntry("STRING")
        SetTextCentre(1)
        AddTextComponentString(text)
        DrawText(_x, _y)
        
        if Config.ShowGlowEffect then
            local factor = (string.len(text)) / 370
            DrawRect(_x, _y + 0.0125, 0.015 + factor, 0.001, r, g, b, math.floor(alpha * 0.6))
        end
    end
end

-- command /tagcolor r g b - esample /tagcolor 255 255 255
RegisterCommand('tagcolor', function(source, args)
    if args[1] and args[2] and args[3] then
        local r = tonumber(args[1])
        local g = tonumber(args[2])
        local b = tonumber(args[3])
        
        if r and g and b and r >= 0 and r <= 255 and g >= 0 and g <= 255 and b >= 0 and b <= 255 then
            TriggerServerEvent('ardenhub_staff:changeTagColor', r, g, b)
        else
            ESX.ShowNotification("Use valid RGB values (0-255)")
        end
    else
        ESX.ShowNotification("Usage: /tagcolor [r] [g] [b]")
    end
end, false)

RegisterNetEvent('ardenhub_staff:setTagColor')
AddEventHandler('ardenhub_staff:setTagColor', function(r, g, b)
    Config.TagColor.r = r
    Config.TagColor.g = g
    Config.TagColor.b = b
    ESX.ShowNotification("Tag color changed")
end)

RegisterCommand('tagtext', function(source, args)
    if #args > 0 then
        local newText = table.concat(args, " ")
        if string.len(newText) <= 20 then
            TriggerServerEvent('ardenhub_staff:changeTagText', newText)
        else
            ESX.ShowNotification("Text must be maximum 20 characters")
        end
    else
        ESX.ShowNotification("Usage: /tagtext [new text]")
    end
end, false)

RegisterNetEvent('ardenhub_staff:setTagText')
AddEventHandler('ardenhub_staff:setTagText', function(newText)
    Config.TagText = newText
    ESX.ShowNotification("Tag text changed to: " .. newText)
end)