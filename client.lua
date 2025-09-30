-- Copyright (c) 2025 Richfie21
-- Licensed under the MIT License. See LICENSE file for details.

local activeZone = nil
local stats = { kills = 0, deaths = 0, spree = 0 }
local zones = {}
 
for i, zoneData in ipairs(Config.Zones) do
    zones[i] = lib.zones.sphere({
        coords = zoneData.coords,
        radius = zoneData.radius,
        debug = false,
        inside = function(self)
            if activeZone ~= zoneData.name then
                activeZone = zoneData.name
                SendNUIMessage({ action = 'show', stats = stats, zone = activeZone })
				SendNUIMessage({ action = 'hideSpree' })
            end

            if Config.DeleteVehicles then
                local ped = PlayerPedId()
                local veh = GetVehiclePedIsIn(ped, false)
                if veh ~= 0 then
                    local netId = NetworkGetNetworkIdFromEntity(veh)
                    TriggerServerEvent('richfie21:redzone:deleteVehicle', netId)
                end
            end
        end,
        onEnter = function(self)
            activeZone = zoneData.name
            SendNUIMessage({ action = 'show', stats = stats, zone = activeZone })
            TriggerServerEvent('richfie21:redzone:playerEnteredZone', zoneData.name)
			SendNUIMessage({ action = 'hideSpree' })
        end,
        onExit = function(self)
            if activeZone == zoneData.name then
                activeZone = nil
                SendNUIMessage({ action = 'hide' })
                TriggerServerEvent('richfie21:redzone:playerExitedZone')
                SendNUIMessage({ action = 'hideSpree' }) -- hide spree 
				
            end
        end
    })
end 
 
CreateThread(function()
    while true do
		local sleep = 5000
		if zones then
			sleep = 1000
			local ped = PlayerPedId()
			local pCoords = GetEntityCoords(ped)

			for i, zoneData in pairs(Config.Zones) do
				local dist = #(pCoords - vec3(zoneData.coords.x, zoneData.coords.y, zoneData.coords.z))
				if dist <= zoneData.radius + 20 then
					if not zones[i].debug then
						zones[i]:setDebug(true) -- enable sphere
					end
				else
					if zones[i].debug then
						zones[i]:setDebug(false) -- disable sphere
					end
				end
			end
		end
        Wait(sleep) -- check every second
    end
end)
 
RegisterNetEvent('richfie21:redzone:updateStats', function(newStats)
    stats = newStats
    if activeZone then
        SendNUIMessage({ action = 'update', stats = stats, zone = activeZone })
    end
end)
  
CreateThread(function()
    for _, zone in ipairs(Config.Zones) do
        local blip = AddBlipForRadius(zone.coords.x, zone.coords.y, zone.coords.z, zone.radius)
        SetBlipColour(blip, 1)
        SetBlipAlpha(blip, 128)

        local marker = AddBlipForCoord(zone.coords.x, zone.coords.y, zone.coords.z)
        SetBlipSprite(marker, 310)
        SetBlipScale(marker, 1.0)
        SetBlipColour(marker, 1)
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentString(zone.name)
        EndTextCommandSetBlipName(marker)
    end
end)

RegisterNetEvent('richfie21:redzone:respawnPlayer', function(coords)
    local ped = PlayerPedId()

    if coords.z == 0.0 then
        local success, groundZ = GetGroundZFor_3dCoord(coords.x, coords.y, 1000.0, false)
        if success then
            coords = vector3(coords.x, coords.y, groundZ)
        else
            coords = vector3(coords.x, coords.y, coords.z + 1.0)
        end
    end
	DoScreenFadeOut(1000)
	Wait(1000)
    SetEntityCoords(ped, coords.x, coords.y, coords.z, false, false, false, true)
 
    SendNUIMessage({ action = 'hideSpree' }) 
    if GetResourceState('es_extended') == 'started' then
	
		SetEntityHealth(ped, 200)   
		ClearPedBloodDamage(ped) 
        TriggerEvent('esx_ambulancejob:revive') 
		DoScreenFadeIn(1000)
    elseif GetResourceState('qbx_core') == 'started' or GetResourceState('qb-core') == 'started' then
		  
		Wait(3000) 
		SetEntityHealth(ped, 200)   
		ClearPedBloodDamage(ped) 
        TriggerEvent('hospital:client:Revive')
		 
    DoScreenFadeIn(1000)
    end

end)
 
RegisterNetEvent('richfie21:redzone:spreePopup', function(spreeCount)
    SendNUIMessage({
        action = 'showSpree',
        spree = Config.Sprees[spreeCount].soundfile,
        text = Config.Sprees[spreeCount].text,
        color = Config.Sprees[spreeCount].color,
        shadow = Config.Sprees[spreeCount].shadow,
    })
end)
 
AddEventHandler('gameEventTriggered', function(event, data)

	if GetResourceState('qbx_core') == 'started' or GetResourceState('qb-core') == 'started' then
		if event ~= "CEventNetworkEntityDamage" then return end
	 
		local victim, attacker, victimDied, weapon = data[1], data[2], data[4], data[7]
		if not IsEntityAPed(victim) then return end
  
		
		local killerId = NetworkGetPlayerIndexFromPed(attacker) 
		
		if victimDied and NetworkGetPlayerIndexFromPed(victim) == PlayerId() and IsEntityDead(PlayerPedId()) then
			local killerId = NetworkGetPlayerIndexFromPed(attacker)
			local killerServerId = killerId and GetPlayerServerId(killerId) or 0
  
			TriggerServerEvent("richfie21:redzone:death:qb", killerServerId, weapon)
		end
		
	end	
end)