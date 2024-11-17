local QBCore = exports['qb-core']:GetCoreObject()
local CocaPlant = {}
local cuttingcoke = nil
local baggingcoke = nil
local CurrentZone = nil
local ZoneEntryTime = nil
local PlantSpawnLimit = 5
local PlantSpawnRadius = 30

local Zones = {
    ['MTCHIL'] = { label = "Mount Chiliad", radius = 30 },
    ['MTGORDO'] = { label = "Mount Gordo", radius = 30 },
    ['CCREAK'] = { label = "Cassidy Creek", radius = 30 },
    ['GALFISH'] = { label = "Galilee Fishing Area", radius = 30 },
}

local function pick(loc)
    if not progressbar("Picking coca plant...", 4000, 'uncuff') then return end
    TriggerServerEvent("coke:pickupCane", loc)  
    return true
end

local function spawnPlant(model, coords, heading, loc)
    local hash = GetHashKey(model)
    LoadModel(hash)
    if not CocaPlant[loc] then
        CocaPlant[loc] = CreateObject(hash, coords.x, coords.y, coords.z, false, true, true)
        Freeze(CocaPlant[loc], true, heading)
        AddSingleModel(CocaPlant[loc], {
            icon = "fa-solid fa-seedling",
            label = "Pick Coca Plant",
            action = function() if not pick(loc) then return end end
        }, loc)
    end
end

RegisterNetEvent('coke:respawnCane', function(loc)
    local v = GlobalState.CocaPlant[loc]
    if v then
        spawnPlant(v.model, v.location, v.heading, loc)
    end
end)

RegisterNetEvent('coke:removeCane', function(loc)
    if DoesEntityExist(CocaPlant[loc]) then DeleteEntity(CocaPlant[loc]) end
    CocaPlant[loc] = nil
end)

RegisterNetEvent("coke:init", function()
    for k, v in pairs(GlobalState.CocaPlant) do
        if not v.taken then
            spawnPlant(v.model, v.location, v.heading, k)
        end
    end
end)

Citizen.CreateThread(function()
    while true do
        local playerCoords = GetEntityCoords(PlayerPedId())
        local zoneName = GetNameOfZone(playerCoords.x, playerCoords.y, playerCoords.z)

        if Zones[zoneName] then
            if CurrentZone ~= zoneName then
                CurrentZone = zoneName
                ZoneEntryTime = GetGameTimer()
            elseif GetGameTimer() - ZoneEntryTime > 5000 then -- 5 seconds delay
                TriggerServerEvent('coke:spawnPlantsInZone', zoneName, PlantSpawnLimit, PlantSpawnRadius)
                ZoneEntryTime = nil
            end
        else
            CurrentZone = nil
            ZoneEntryTime = nil
        end

        Wait(500)
    end
end)

AddEventHandler('onResourceStop', function(resourceName)
    if GetCurrentResourceName() == resourceName then
        for _, plant in pairs(CocaPlant) do
            if DoesEntityExist(plant) then
                DeleteEntity(plant)
                SetEntityAsNoLongerNeeded(plant)
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
    if not config then print('why') return end
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
