local QBCore = exports['qb-core']:GetCoreObject()
-- Include configuration for zones, models, and spawning rules
local coca_config = {
    zones = {
        ['MTCHIL'] = 30, -- Mount Chiliad area
        ['MTGORDO'] = 30, -- Mount Gordo
        ['CCREAK'] = 30, -- Cassidy Creek
        ['GALFISH'] = 30
    },
    special_coca_roll = function()
        return math.random(1, 100) <= 5 -- 5% chance for special coca plant
    end,
    models = { `prop_plant_01a` },
    models_special = { `prop_coca_plant_special` },
    cleanup_time = 30, -- minutes
    test_mode = true  -- Toggle this to true for testing
}

GlobalState.coca_config = coca_config

local spawned_coca = {}

-- Event to spawn a coca plant
RegisterNetEvent('cocaine:server:requestCocaSpawn')
AddEventHandler('cocaine:server:requestCocaSpawn', function(zone)
    print("Debug: Received request to spawn in zone:", zone)
    
    local src = source
    local ped = GetPlayerPed(src)
    local playerCoords = GetEntityCoords(ped)

    if coca_config.zones[zone] and (not spawned_coca[zone] or #spawned_coca[zone] < coca_config.zones[zone]) then
        local isSpecial = coca_config.special_coca_roll()
        local plant_model = isSpecial and coca_config.models_special[1] or coca_config.models[math.random(#coca_config.models)]
        
        local spawnCoords = {
            x = playerCoords.x + math.random(-5, 5),
            y = playerCoords.y + math.random(-5, 5),
            z = playerCoords.z
        }

        if not spawned_coca[zone] then
            spawned_coca[zone] = {}
        end

        table.insert(spawned_coca[zone], { model = plant_model, coords = spawnCoords, isSpecial = isSpecial })
        print(string.format("Debug: Spawning coca plant at coords: x=%.2f, y=%.2f, z=%.2f", spawnCoords.x, spawnCoords.y, spawnCoords.z))
        
        TriggerClientEvent('cocaine:client:spawnCocaPlant', -1, plant_model, spawnCoords, isSpecial)
    else
        print("Debug: Zone limit reached or invalid zone.")
    end
end)
-- Cleanup thread to clear old coca plants
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(coca_config.cleanup_time * 60000)
        print("Debug: Starting coca plant cleanup.")
        for zone, plants in pairs(spawned_coca) do
            for _, plant in ipairs(plants) do
                TriggerClientEvent('cocaine:client:removeCocaPlant', -1, plant.coords)
                print("Debug: Removing coca plant at coords:", plant.coords)
            end
            spawned_coca[zone] = {}
        end
        print("Debug: Coca plant cleanup completed.")
    end
end)

function CaneCooldown(loc)
    CreateThread(function()
        Wait(Config.respawnTime * 1)
        cokeplants[loc].taken = false
        GlobalState.CocaPlant = cokeplants
        Wait(1000)
        TriggerClientEvent('coke:respawnCane', -1, loc)
		Log('Coca Plant Respawned At ' .. cokeplants[loc].location, 'coke')
    end)
end

RegisterNetEvent("coke:pickupCoca")
AddEventHandler("coke:pickupCoca", function(loc)
	local src = source
	--if CheckDist(src, Config.CocaPlant[loc].location) then return end
    if not cokeplants[loc].taken then
        cokeplants[loc].taken = true
        GlobalState.CocaPlant = cokeplants
        TriggerClientEvent("coke:removeCocaPlant", -1, loc)
        CaneCooldown(loc)
        AddItem(src, 'coca_leaf', 1)
		--Log(GetName(src) .. ' Picked A Coca Leaf With a distance of ' .. dist(src, Config.CocaPlant[loc].location) .. ' vectors', 'coke')
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