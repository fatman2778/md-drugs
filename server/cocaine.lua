local QBCore = exports['qb-core']:GetCoreObject()
local SpawnedPlants = {}

-- Configuration for zones
local Zones = {
    ['MTCHIL'] = { label = "Mount Chiliad", radius = 30, maxPlants = 5 },
    ['MTGORDO'] = { label = "Mount Gordo", radius = 30, maxPlants = 5 },
    ['CCREAK'] = { label = "Cassidy Creek", radius = 30, maxPlants = 5 },
    ['GALFISH'] = { label = "Galilee Fishing Area", radius = 30, maxPlants = 5 },
}

-- Initialize the Global State
GlobalState.CocaPlant = {}

-- Spawn plants dynamically within a zone
local function spawnPlantsInZone(zoneName, maxPlants, radius, playerCoords)
    local spawnedCount = 0
    if not SpawnedPlants[zoneName] then
        SpawnedPlants[zoneName] = {}
    end

    while spawnedCount < maxPlants do
        Wait(2000) -- Delay between plant spawns

        -- Generate a random location within the radius
        local xOffset = math.random(-radius, radius)
        local yOffset = math.random(-radius, radius)
        local coords = vector3(playerCoords.x + xOffset, playerCoords.y + yOffset, playerCoords.z)
        
        local foundGround, groundZ = GetGroundZFor_3dCoord(coords.x, coords.y, coords.z + 10.0, true)
        if foundGround then
            coords = vector3(coords.x, coords.y, groundZ)

            -- Plant data
            local plantData = {
                location = coords,
                heading = math.random(0, 360),
                model = "prop_plant_01a", -- Replace with your desired model
                taken = false,
            }
            table.insert(SpawnedPlants[zoneName], plantData)
            spawnedCount = spawnedCount + 1
        end
    end

    GlobalState.CocaPlant = SpawnedPlants
    print("Plants spawned in zone:", zoneName)
end

-- Handle player entering a zone
RegisterNetEvent('coke:enterZone')
AddEventHandler('coke:enterZone', function(zoneName, playerCoords)
    if Zones[zoneName] and not SpawnedPlants[zoneName] then
        spawnPlantsInZone(zoneName, Zones[zoneName].maxPlants, Zones[zoneName].radius, playerCoords)
    end
end)

-- Handle picking up a plant
RegisterNetEvent("coke:pickupCane")
AddEventHandler("coke:pickupCane", function(zoneName, loc)
    local src = source
    local plants = SpawnedPlants[zoneName]
    if plants and plants[loc] and not plants[loc].taken then
        plants[loc].taken = true
        GlobalState.CocaPlant = SpawnedPlants
        TriggerClientEvent("coke:removeCane", -1, zoneName, loc)

        -- Respawn plant after cooldown
        CreateThread(function()
            Wait(Config.respawnTime * 1000)
            plants[loc].taken = false
            GlobalState.CocaPlant = SpawnedPlants
            TriggerClientEvent("coke:respawnCane", -1, zoneName, loc)
        end)

        AddItem(src, 'coca_leaf', 1)
        print("Player picked a coca leaf in zone:", zoneName, "at location:", loc)
    end
end)

RegisterServerEvent('md-drugs:server:makepowder', function(num)
    local src = source
    if not checkLoc(src, 'MakePowder', num) then return end
    local tier = 'tier1'
    local logMessage = ' Made Raw Coke'
    if Config.TierSystem then
        local coke = getRep(src, 'coke')
        if coke > Config.Tier1 and coke <= Config.Tier2 then
            tier = 'tier2'
            logMessage = ' Made Raw Coke tier 2'
        elseif coke > Config.Tier2 then
            tier = 'tier3'
            logMessage = ' Made Raw Coke tier 3'
        end
    end
    if not GetRecipe(src, 'cocaine', 'cokepowder', tier) then return end
    Log(GetName(src) .. logMessage .. dist(src, Config.MakePowder[num]['loc']) .. ' vectors', 'coke')
end)

RegisterServerEvent('md-drugs:server:cutcokeone', function(num)
    local src = source
    local Player = getPlayer(src)
	local count = 0
    if Config.FancyCokeAnims then
        if not checkLoc(src, 'singleSpot', 'cutcoke') then return end
    else
        if not checkLoc(src, 'CuttingCoke', num) then return end
    end
    if Config.TierSystem then
        local tier = ''
        local cokeTiers = {
            {item = 'coke', 		  tier = 'tier1', log = ' Cut Coke'},
            {item = 'cokestagetwo',   tier = 'tier2', log = ' Cut Coke tier 2'},
            {item = 'cokestagethree', tier = 'tier3', log = ' Cut Coke tier 3'}
        }
        for _, v in ipairs(cokeTiers) do
			if count >= 1 then break end
            if Player.Functions.GetItemByName(v.item) then
                tier = v.tier
                count = count + 1
            end
        end
        if not GetRecipe(src, 'cocaine', 'cutcoke', tier) then return end
    else
        if not GetRecipe(src, 'cocaine', 'cutcoke', 'tier1') then return end
        Log(GetName(src) .. ' Cut Coke', 'coke')
    end
end)

RegisterServerEvent('md-drugs:server:bagcoke', function(num)
    local src = source
    local Player = getPlayer(src)
	local count = 0
    local tier = ''
    if Config.FancyCokeAnims then
        if not checkLoc(src, 'singleSpot', 'bagcokepowder') then return end
    else
        if not checkLoc(src, 'BaggingCoke', num) then return end
    end
    if Config.TierSystem then
        local coke = getRep(src, 'coke')
        local cokeTiers = {
            {item = 'loosecoke', 		   tier = 'tier1', log = ' Bagged Coke'},
            {item = 'loosecokestagetwo',   tier = 'tier2', log = ' Bagged Coke tier 2'},
            {item = 'loosecokestagethree', tier = 'tier3', log = ' Bagged Coke tier 3'}
        }
        for _, v in ipairs(cokeTiers) do
            if Player.Functions.GetItemByName(v.item) then
				if count >= 1 then break end
                count = count + 1
                tier = v.tier 
            end
        end
        if not GetRecipe(src, 'cocaine', 'bagcoke', tier) then return end
        AddRep(src, 'coke')
    else
        if not GetRecipe(src, 'cocaine', 'bagcoke', 'tier1') then return end
        Log(GetName(src) .. ' Bagged Coke', 'coke')
    end
end)

local cokecut = {loosecokestagetwo = 2, loosecokestagethree = 3}
for k, v in pairs (cokecut) do
	QBCore.Functions.CreateUseableItem(k, function(source, item)
		local src = source
		   local Player = getPlayer(src)
		if Player.Functions.GetItemByName(item.name) then
			if not Itemcheck(src, 'bakingsoda', 1) then return end
			TriggerClientEvent('md-drugs:client:minusTier', src, {type = 'coke', xt = 'bakingsoda', item = k, amount =  v,recieve = 'loosecoke'})
		end
	end)
end