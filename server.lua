 -- Copyright (c) 2025 Richfie21
-- Licensed under the MIT License. See LICENSE file for details.


local Framework = nil
local frameworkType = nil

CreateThread(function()
    if GetResourceState('es_extended') == 'started' then
        Framework = exports['es_extended']:getSharedObject()
        frameworkType = 'esx' 
    elseif GetResourceState('qb-core') == 'started' then
        Framework = exports['qb-core']:GetCoreObject()
        frameworkType = 'qbcore' 
    elseif GetResourceState('qbx_core') == 'started' then
        Framework = exports['qbx_core']:GetCoreObject()
        frameworkType = 'qbox'  
    end
end)

local playerStats = {}
local playerZones = {}
local deadPlayers = {}

local function getStats(src)
    if not playerStats[src] then
        playerStats[src] = { kills = 0, deaths = 0, spree = 0 }
    end
    return playerStats[src]
end

AddEventHandler('playerDropped', function()
    playerStats[source] = nil
    playerZones[source] = nil
end)
 
RegisterServerEvent('richfie21:redzone:playerEnteredZone')
AddEventHandler('richfie21:redzone:playerEnteredZone', function(zoneName)
    playerZones[source] = zoneName
end)

RegisterServerEvent('richfie21:redzone:playerExitedZone')
AddEventHandler('richfie21:redzone:playerExitedZone', function()
    playerZones[source] = nil
end)
 
RegisterNetEvent('richfie21:redzone:deleteVehicle', function(netId)
    local veh = NetworkGetEntityFromNetworkId(netId)
    if DoesEntityExist(veh) then
        DeleteEntity(veh)
    end
end)
 
local function respawnPlayer(playerId, forcedZoneName)
    local zoneName = forcedZoneName or playerZones[playerId]

    if not zoneName then
        local randomIndex = math.random(1, #Config.Zones)
        zoneName = Config.Zones[randomIndex].name
    end

    local spawnCoords = nil
    local zoneData = nil
    for _, zone in ipairs(Config.Zones) do
        if zone.name == zoneName then
            zoneData = zone
            break
        end
    end

    if zoneData then
        if zoneData.respawnOuterSideOfZone then
            local angle = math.random() * 2 * math.pi
            local distance = zoneData.radius + 2
            local x = zoneData.coords.x + math.cos(angle) * distance
            local y = zoneData.coords.y + math.sin(angle) * distance
            spawnCoords = vector3(x, y, 0.0)
        else
            local coordsList = zoneData.respawnCoords
            local chosen = coordsList[math.random(1, #coordsList)]
            spawnCoords = vector3(chosen.x, chosen.y, chosen.z)
        end
    end

    if spawnCoords then 
        TriggerClientEvent('richfie21:redzone:respawnPlayer', playerId, spawnCoords) 
    end
end
 
local function handleDeath(victim, killer, killedByPlayer)
    if deadPlayers[victim] then return end
    deadPlayers[victim] = true

    local victimStats = getStats(victim)
    local killerZone = killer and playerZones[killer]
    local victimZone = playerZones[victim]
 
    if killedByPlayer and killer and killerZone and victimZone then
     
	 
        victimStats.deaths = victimStats.deaths + 1
        victimStats.spree = 0
        TriggerClientEvent('richfie21:redzone:updateStats', victim, victimStats)
 
        local killerStats = getStats(killer)
        killerStats.kills = killerStats.kills + 1
        killerStats.spree = killerStats.spree + 1
        TriggerClientEvent('richfie21:redzone:updateStats', killer, killerStats)
 
        if frameworkType == 'esx' then
            local xPlayer = Framework.GetPlayerFromId(killer)
            if xPlayer then
                for _, reward in ipairs(Config.Rewards) do
                    xPlayer.addInventoryItem(reward.item, math.random(reward.min, reward.max))
                end
            end
        elseif frameworkType == 'qbcore' or frameworkType == 'qbox' then
            local Player = Framework.Functions.GetPlayer(killer)
            if Player then
                for _, reward in ipairs(Config.Rewards) do
                    Player.Functions.AddItem(reward.item, math.random(reward.min, reward.max))
                end
            end
        end
 
        local spreeCount = killerStats.spree
        if Config.Sprees[spreeCount] then
            local killerCoords = GetEntityCoords(GetPlayerPed(killer))
            for _, zone in ipairs(Config.Zones) do
                local distToZone = #(killerCoords - zone.coords)
                if distToZone <= zone.radius then
                    TriggerClientEvent('richfie21:redzone:spreePopup', killer, spreeCount)
					if Config.UseSpreeReward then
						GiveSpreeReward(killer, spreeCount)
					end
                    for _, playerId in ipairs(GetPlayers()) do
                        local ped = GetPlayerPed(playerId)
                        if DoesEntityExist(ped) then
                            local coords = GetEntityCoords(ped)
                            local dist = #(coords - zone.coords)
                            if dist <= zone.radius + 10.0 then
                                TriggerClientEvent('ox_lib:notify', playerId, {
                                    title = zone.name,
                                    description = ('%s is on a %s!'):format(GetPlayerName(killer), Config.Sprees[spreeCount].text),
                                    type = 'info',
                                    position = 'middle-right'
                                })
                            end
                        end
                    end
                    break
                end
            end
        end
    end
 
    local respawnZone = killerZone or victimZone
    if respawnZone then
        respawnPlayer(victim, respawnZone)
    end

    SetTimeout(1000, function()
        deadPlayers[victim] = nil
    end)
end

function GiveSpreeReward(killer, spreeCount) 
	 if frameworkType == 'esx' then
            local xPlayer = Framework.GetPlayerFromId(killer)
            if xPlayer then
                for _, reward in ipairs(Config.SpreeRewards[spreeCount]) do 
                    xPlayer.addInventoryItem(reward.item, math.random(reward.min, reward.max))
                end
            end
        elseif frameworkType == 'qbcore' or frameworkType == 'qbox' then
            local Player = Framework.Functions.GetPlayer(killer)
            if Player then
                for _, reward in ipairs(Config.SpreeRewards[spreeCount]) do
                    Player.Functions.AddItem(reward.item, math.random(reward.min, reward.max))
                end
            end
        end 
end
 
RegisterServerEvent('esx:onPlayerDeath')
AddEventHandler('esx:onPlayerDeath', function(data)
	if GetResourceState('es_extended') == 'started' then 
		handleDeath(source, data.killerServerId, data.killedByPlayer)
	end	
end) 
RegisterNetEvent("richfie21:redzone:death:qb", function(killerServerId, weapon)
	local victim = source
	local killer = tonumber(killerServerId) or 0
		
	if killer > 0 and killer ~= victim then
		handleDeath(victim, killer, true)
	else
		handleDeath(victim, killer, false)
	end
		 
end) 

