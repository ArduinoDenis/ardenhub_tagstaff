ESX = exports["es_extended"]:getSharedObject()
local activeTags = {}

function IsPlayerStaff(source)
    local identifiers = GetPlayerIdentifiers(source)
    
    for _, identifier in ipairs(identifiers) do
        for _, staffId in ipairs(Config.StaffIdentifiers) do
            if identifier == staffId then
                return true
            end
        end
    end
    
    local xPlayer = ESX.GetPlayerFromId(source)
    if xPlayer then
        local group = xPlayer.getGroup()
        if group == 'owner' or group == 'admin' or group == 'mod' or group == 'helper' then
            return true
        end
    end
    return false
end

RegisterServerEvent('ardenhub_staff:toggleTag')
AddEventHandler('ardenhub_staff:toggleTag', function()
    local source = source
    
    if IsPlayerStaff(source) then
        activeTags[source] = not activeTags[source]
        
        TriggerClientEvent('ardenhub_staff:setTag', source, activeTags[source])
        
        TriggerClientEvent('ardenhub_staff:syncTags', -1, activeTags)
        
        local playerName = GetPlayerName(source)
        local state = activeTags[source] and "enabled" or "disabled"
        SendDiscordLog(playerName .. " has " .. state .. " the staff tag")
    else
        TriggerClientEvent('esx:showNotification', source, "You don't have permission to use this command")
    end
end)

AddEventHandler('playerDropped', function()
    local source = source
    if activeTags[source] then
        activeTags[source] = nil
        TriggerClientEvent('ardenhub_staff:syncTags', -1, activeTags)
    end
end)

AddEventHandler('playerConnecting', function()
    local source = source
    TriggerClientEvent('ardenhub_staff:syncTags', source, activeTags)
end)

RegisterServerEvent('ardenhub_staff:changeTagColor')
AddEventHandler('ardenhub_staff:changeTagColor', function(r, g, b)
    local source = source
    
    if IsPlayerStaff(source) then
        Config.TagColor.r = r
        Config.TagColor.g = g
        Config.TagColor.b = b
        
        TriggerClientEvent('ardenhub_staff:setTagColor', -1, r, g, b)
        
        local playerName = GetPlayerName(source)
        SendDiscordLog(playerName .. " has changed the staff tag color to RGB(" .. r .. "," .. g .. "," .. b .. ")")
    else
        TriggerClientEvent('esx:showNotification', source, "You don't have permission to use this command")
    end
end)

RegisterServerEvent('ardenhub_staff:changeTagText')
AddEventHandler('ardenhub_staff:changeTagText', function(newText)
    local source = source
    
    if IsPlayerStaff(source) then
        Config.TagText = newText
        
        TriggerClientEvent('ardenhub_staff:setTagText', -1, newText)
        
        local playerName = GetPlayerName(source)
        SendDiscordLog(playerName .. " has changed the staff tag text to: " .. newText)
    else
        TriggerClientEvent('esx:showNotification', source, "You don't have permission to use this command")
    end
end)

function SendDiscordLog(message)
    if Config.DiscordWebhook == "" then
        return
    end
    
    local embed = {
        {
            ["color"] = 16711680,
            ["title"] = "TagStaff Log",
            ["description"] = message,
            ["footer"] = {
                ["text"] = "ArDenHub TagStaff | " .. os.date("%d/%m/%Y %H:%M:%S")
            }
        }
    }
    
    PerformHttpRequest(Config.DiscordWebhook, function(err, text, headers) end, 'POST', json.encode({embeds = embed}), { ['Content-Type'] = 'application/json' })
end