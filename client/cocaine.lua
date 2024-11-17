local QBCore = exports['qb-core']:GetCoreObject()
local CocaPlant = {}
local cuttingcoke = nil
local baggingcoke = nil
local CocaPlant = {}
local currentZone = nil

-- Check player’s zone and request prop spawn
Citizen.CreateThread(function()
    while true do
        local playerPed = PlayerPedId()
        local playerCoords = GetEntityCoords(playerPed)
        local zoneName = GetNameOfZone(playerCoords.x, playerCoords.y, playerCoords.z)

        -- If player enters a new zone that matches the config, request spawn
        if zoneName ~= currentZone and GlobalState.coca_config.zones[zoneName] then
            currentZone = zoneName
            TriggerServerEvent('cocaine:server:requestCocaSpawn', currentZone)
        elseif not GlobalState.coca_config.zones[zoneName] then
            currentZone = nil
        end

        Wait(5000)  -- Check every 5 seconds to reduce processing load
    end
end)

-- Spawning a Coca plant at a given location
RegisterNetEvent('cocaine:client:spawnCocaPlant')
AddEventHandler('cocaine:client:spawnCocaPlant', function(model, coords, isSpecial)
    print(string.format("Debug: Received spawn request for coca plant at: x=%.2f, y=%.2f, z=%.2f", coords.x, coords.y, coords.z))
    
    local model = "prop_plant_01a"
    local hash = GetHashKey(model)
    RequestModel(hash)
    while not HasModelLoaded(hash) do
        Wait(10)
    end

    local plant = CreateObject(hash, coords.x, coords.y, coords.z, false, true, true)
    if DoesEntityExist(plant) then
        FreezeEntityPosition(plant, true)
        CocaPlant[coords] = plant
        print("Debug: Coca plant spawned successfully at:", coords)
        print(string.format("Debug: Creating object at: x=%.2f, y=%.2f, z=%.2f", coords.x, coords.y, coords.z))

        exports['ox_target']:addLocalEntity(plant, {
            {
                name = "coca_plant",
                event = "cocaine:client:pickCocaPlant",
                icon = "fas fa-seedling",
                label = "Pick Coca Plant",
                loc = coords,
                distance = 2.5
            }
        })
    else
        print("Debug: Failed to create coca plant entity.")
    end
end)

-- Event to pick the plant
RegisterNetEvent('cocaine:client:pickCocaPlant')
AddEventHandler('cocaine:client:pickCocaPlant', function(data)
    local loc = data.loc
    QBCore.Functions.Progressbar("pick_coca", "Picking Coca Plant...", 4000, false, true, {}, {}, {}, {}, function()
        TriggerServerEvent('md-drugs:server:pickupCoca', loc)
    end)
end)

-- Remove a specific Coca plant
RegisterNetEvent('cocaine:client:removeCocaPlant')
AddEventHandler('cocaine:client:removeCocaPlant', function(coords)
    local plant = CocaPlant[coords]
    if plant then
        DeleteEntity(plant)
        CocaPlant[coords] = nil
        exports['ox_target']:removeEntity(plant)  -- Remove the target interaction for this plant
    end
end)

RegisterNetEvent("coke:init", function()
    for k, v in pairs (GlobalState.CocaPlant) do
        local hash = GetHashKey(v.model)
        LoadModel(hash) 
        if not v.taken then
            CocaPlant[k] = CreateObject(hash, v.location.x, v.location.y, v.location.z, false, true, true)
            Freeze(CocaPlant[k], true, v.heading)
            AddSingleModel(CocaPlant[k], {icon = "fa-solid fa-seedling", label = Lang.targets.coke.pick, action = function() if not pick(k) then return end end}, k)
        end
    end
end)

AddEventHandler('onResourceStop', function(resourceName)
    if GetCurrentResourceName() == resourceName then
        SetModelAsNoLongerNeeded(GetHashKey('prop_plant_01a'))
        for k, v in pairs(CocaPlant) do
            if DoesEntityExist(v) then
                DeleteEntity(v) SetEntityAsNoLongerNeeded(v)
            end
        end
    end
end)

RegisterNetEvent("md-drugs:client:makepowder", function(data)
    if not ItemCheck('coca_leaf') then return end
    if not progressbar(Lang.Coke.makepow, 4000, 'uncuff') then return end
	TriggerServerEvent("md-drugs:server:makepowder", data.data)
end)

RegisterNetEvent("md-drugs:client:cutcokeone", function(data)
    if not ItemCheck('bakingsoda') then return end
	cuttingcoke = true
    if Config.FancyCokeAnims then
	    CutCoke()
    else
         if not progressbar(Lang.Coke.cutting, 5000, 'uncuff') then cuttingcoke = nil return end
    end
	TriggerServerEvent("md-drugs:server:cutcokeone", data.data)
	cuttingcoke = nil
end)

RegisterNetEvent("md-drugs:client:bagcoke", function(data) 
    if not ItemCheck('empty_weed_bag') then return end
	baggingcoke = true
    if Config.FancyCokeAnims then
	    BagCoke()
    else
        if not progressbar(Lang.Coke.bagging, 5000, 'uncuff') then baggingcoke = nil return end
    end
	TriggerServerEvent("md-drugs:server:bagcoke", data.data)
	baggingcoke = nil
end)

CreateThread(function()
    local config = lib.callback.await('md-drugs:server:getLocs', false)
    if not config then return end
    if Config.FancyCokeAnims == false then 
        AddBoxZoneMulti('cuttcoke', config.CuttingCoke,  {	type = "client",event = "md-drugs:client:cutcokeone",	icon = "fa-solid fa-mortar-pestle",  label = Lang.targets.coke.cut}) 
        AddBoxZoneMulti('baggcoke', config.BaggingCoke,  {	type = "client",event = "md-drugs:client:bagcoke",	    icon = "fa-solid fa-sack-xmark",  label = Lang.targets.coke.bag})
    else
        AddBoxZoneSingle('cutcoke', config.singleSpot.cutcoke,
		    { data = config.singleSpot.cutcoke,  type = "client", event = "md-drugs:client:cutcokeone", icon = "fa-solid fa-mortar-pestle", label = Lang.targets.coke.cut, canInteract = function() if cuttingcoke == nil and baggingcoke == nil then return true end end })
        AddBoxZoneSingle('bagcokepowder', config.singleSpot.bagcokepowder,
		    { data = config.singleSpot.bagcokepowder, type = "client", event = "md-drugs:client:bagcoke",    icon = "fa-solid fa-sack-xmark", label = Lang.targets.coke.bag, canInteract = function() if baggingcoke == nil and cuttingcoke == nil then return true end end })
    end
end)
