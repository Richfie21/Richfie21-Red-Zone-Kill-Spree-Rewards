-- Copyright (c) 2025 Richfie21
-- Licensed under the MIT License. See LICENSE file for details.

Config = {}
 
Config.Zones = {
    {
        name = "Red Zone",
        coords = vector3(1918.6541, 3406.9272, 42.4614),
        radius = 30.0,
        respawnOuterSideOfZone = true,
        respawnCoords = {
            vector3(2100.0, 3100.0, 45.0),
            vector3(2102.0, 3105.0, 45.0),
            vector3(2098.0, 3098.0, 45.0)
        }
    },
    {
        name = "Airport Zone",
        coords = vector3(-1037.0, -2738.0, 20.0),
        radius = 150.0,
        respawnOuterSideOfZone = false,
        respawnCoords = {
            vector3(-980.0, -2700.0, 20.0)
        }
    }
}

-- Vehicle deletion inside zones
Config.DeleteVehicles = true

-- Kill rewards
Config.Rewards = {
    { item = 'ammo-9', min = 15, max = 20 },
    { item = 'money', min = 1000, max = 2000 },
    { item = 'black_money', min = 1000, max = 2000 } 
}
  
 -- Spree Count and Sound Effects
Config.Sprees = {
    [1] = { soundfile = 'killing_spree', text = "KILLING SPREE", color = "#007bff", shadow = "0 0 10px #007bff, 0 0 20px #3399ff" } ,
    [2] = { soundfile = 'mega_kill', text = "MEGA KILL", color = "#00ff00", shadow = "0 0 10px #00ff00, 0 0 20px #33ff33" },
    [3] = { soundfile = 'dominating', text = "DOMINATING", color = "#ff8800", shadow = "0 0 10px #ff8800, 0 0 20px #ffaa33" },
    [4] = { soundfile = 'godlike', text = "GODLIKE", color = "#cc00ff", shadow = "0 0 10px #cc00ff, 0 0 20px #e066ff" },
}
 
Config.UseSpreeReward = true
-- make sure spree number are same
Config.SpreeRewards = {
    [1] = { { item = 'ammo-9', min = 25, max = 35 }, { item = 'money', min = 1500, max = 2000 } },
    [2] = { { item = 'ammo-9', min = 35, max = 45 }, { item = 'money', min = 2500, max = 3000 } },
    [3] = { { item = 'ammo-9', min = 45, max = 55 }, { item = 'money', min = 3500, max = 4000 } },
    [4] = { { item = 'ammo-9', min = 55, max = 65 }, { item = 'money', min = 4500, max = 5000 } },
}