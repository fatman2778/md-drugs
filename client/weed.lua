local QBCore = exports['qb-core']:GetCoreObject()
local WeedPlant = {}
local exploded = nil
local drying = false
function LoadModel(hash)
    hash = GetHashKey(hash)
    RequestModel(hash)
    while not HasModelLoaded(hash) do
        Wait(3000)
    end
end 

local function hasJob()
	if Config.Joblock then
		if  QBCore.Functions.GetPlayerData().job.name == Config.weedjob then
			return true else return false end
	else
	return true end
 end


RegisterNetEvent('weed:respawnCane', function(loc)
    local v = GlobalState.WeedPlant[loc]
    local hash = GetHashKey(v.model)
    if not HasModelLoaded(hash) then LoadModel(hash) end
    if not WeedPlant[loc] then
        WeedPlant[loc] = CreateObject(hash, v.location.x, v.location.y, v.location.z-3.5, false, true, true)
		Freeze(WeedPlant[loc],true,  v.heading)
        AddSingleModel(WeedPlant[loc], 
			{
               icon = "fas fa-hand",
               label = "Pick Weed",
               action = function()
                  if not progressbar(Lang.Weed.pick, 4000, 'uncuff') then return end
                   TriggerServerEvent("weed:pickupCane", loc)
				end
           }, loc)
    end
end)

RegisterNetEvent('weed:removeCane', function(loc)
    if DoesEntityExist(WeedPlant[loc]) then DeleteEntity(WeedPlant[loc]) end
    WeedPlant[loc] = nil
end)

RegisterNetEvent("weed:init", function()
    for k, v in pairs (GlobalState.WeedPlant) do
        local hash = GetHashKey(v.model)
        if not HasModelLoaded(hash) then LoadModel(hash) end
        if not v.taken then
            WeedPlant[k] = CreateObject(hash, v.location.x, v.location.y, v.location.z-3.5, false, true, true)
			Freeze(WeedPlant[k],true,  v.heading)
			AddSingleModel(WeedPlant[k],  
			    {
                    icon = "fas fa-hand",
                    label = "Pick Weed",
                    action = function()
					if not progressbar(Lang.Weed.pick, 4000, 'uncuff') then return end
					TriggerServerEvent("weed:pickupCane", k)
                    end
                }, k)
        end
    end
end)

AddEventHandler('onResourceStart', function(resource)
    if resource == GetCurrentResourceName() then
        LoadModel('bkr_prop_weed_lrg_01b')
        TriggerEvent('weed:init')
    end
 end)
 RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
     Wait(3000)
     LoadModel('bkr_prop_weed_lrg_01b')
     TriggerEvent('weed:init')
 end)
 
AddEventHandler('onResourceStop', function(resourceName)
    if GetCurrentResourceName() == resourceName then
        SetModelAsNoLongerNeeded(GetHashKey('bkr_prop_weed_lrg_01b'))
        for k, v in pairs(WeedPlant) do
            if DoesEntityExist(v) then
                DeleteEntity(v) SetEntityAsNoLongerNeeded(v)
            end
        end
    end
end)

CreateThread(function()
	AddBoxZoneMulti('weeddry', Config.WeedDry, {
		name = 'dryweed',
		icon = "fas fa-sign-in-alt",
		label = "Dry Weed",
		distance = 1,
		action = function()
			if not ItemCheck('wetcannabis') then return end
			if drying then
				Notify(Lang.Weed.busy, "error")
			else
				local loc = GetEntityCoords(PlayerPedId())
				local weedplant = CreateObject("bkr_prop_weed_drying_01a", loc.x, loc.y+.2, loc.z, true, false)
				drying = true
				FreezeEntityPosition(weedplant, true)
				Notify("Wait A little Bit To Dry", "success")
				Wait(math.random(1000,5000))
				Notify("Take Down The Weed", "success")
				AddSingleModel(weedplant, {
					icon = "fas fa-sign-in-alt",
					label = "Pick Up Weed",
					action = function()
						DeleteEntity(weedplant)
						drying = false
						TriggerServerEvent('md-drugs:server:dryoutweed')
					end,
					canInteract = function()
						if hasJob() then return true end end									
				}, nil)
			end
		end,
		canInteract = function()
			if hasJob() then return true end end	
	})

AddBoxZoneSingle('teleinweedout', Config.Teleout, { name = 'teleout', icon = "fas fa-sign-in-alt", label = "Enter Building", distance = 2.0, action = function() SetEntityCoords(PlayerPedId(),Config.Telein) end,
	canInteract = function() if hasJob() then return true end end	
}) 
AddBoxZoneSingle('teleinweedin', Config.Telein, { name = 'teleout', icon = "fas fa-sign-in-alt", label = "Exit Building", distance = 2.0, action = function() SetEntityCoords(PlayerPedId(),Config.Teleout) end,
	canInteract = function() if hasJob() then return true end end	
}) 
AddBoxZoneSingle('MakeButterCrafting', Config.MakeButter, {label = 'Open Butter Menu', action = function() lib.showContext('ButterCraft') end, icon = "fas fa-sign-in-alt", 
canInteract = function() if hasJob() then return true end end	
}) 

AddBoxZoneSingle('makeoil',Config.MakeOil, {
	name = 'Oil',
	icon = "fas fa-sign-in-alt",
	label = "Make Oil",
	action = function()
		if not ItemCheckMulti({'butane', 'grindedweed'}) then return end
		if not minigame(2, 8) then 
			local explosion = math.random(1,100)
				local loc = GetEntityCoords(PlayerPedId())
				if explosion <= 99 then
					AddExplosion(loc.x, loc.y, loc.z, 49, 10, true, false, true, true)
					exploded = true
					Notify(Lang.Weed.stovehot, "error")
					Wait(1000 * 30)
					exploded = nil
				end	
		return end
		if not progressbar(Lang.Weed.shat, 4000, 'uncuff') then return end
		TriggerServerEvent("md-drugs:server:makeoil")       			
	end,
	canInteract = function()
	if hasJob() and exploded == nil then return true end
	end,
} )
end)

CreateThread(function()
    BikerWeedFarm = exports['bob74_ipl']:GetBikerWeedFarmObject()
    BikerWeedFarm.Style.Set(BikerWeedFarm.Style.upgrade)
    BikerWeedFarm.Security.Set(BikerWeedFarm.Security.upgrade)
    BikerWeedFarm.Details.Enable(BikerWeedFarm.Details.chairs, true)
    BikerWeedFarm.Details.Enable({BikerWeedFarm.Details.production, BikerWeedFarm.Details.chairs, BikerWeedFarm.Details.drying}, true)
	BikerWeedFarm.Plant1.Clear(false)
    BikerWeedFarm.Plant2.Clear(false)
    BikerWeedFarm.Plant3.Clear(false)
    BikerWeedFarm.Plant4.Clear(false)
    BikerWeedFarm.Plant5.Clear(false)
    BikerWeedFarm.Plant6.Clear(false)
    BikerWeedFarm.Plant7.Clear(false)
    BikerWeedFarm.Plant8.Clear(false)
    BikerWeedFarm.Plant9.Clear(false)
    RefreshInterior(BikerWeedFarm.interiorId)
	stove = CreateObject("prop_cooker_03",vector3(1045.49, -3198.46, -38.15-1), true, false)
	SetEntityHeading(stove, 270.00)
	FreezeEntityPosition(stove, true)
	stove2 = CreateObject("prop_cooker_03",vector3(1038.90, -3198.66, -38.17-1), true, false)
	SetEntityHeading(stove2, 90.00)
	FreezeEntityPosition(stove2, true)
end)


RegisterNetEvent("md-drugs:client:rollanim", function()
if not progressbar(Lang.Weed.roll, 4000, 'uncuff') then return end
end)

RegisterNetEvent("md-drugs:client:grind", function()
	if not progressbar("grinding", 4000, 'uncuff') then return end
end)

RegisterNetEvent("md-drugs:client:dodabs", function()
if not progressbar('Doing Dabs', 4000, 'bong2') then return end
AlienEffect()
end)

CreateThread(function()
local WeedShop = {}
local current = "u_m_m_jesus_01"

	lib.requestModel(current, Config.RequestModelTime)
	local CurrentLocation = Config.WeedSaleman
	local WeedGuy = CreatePed(0,current,CurrentLocation.x,CurrentLocation.y,CurrentLocation.z-1, CurrentLocation.h, false, false)
	Freeze(WeedGuy, true, CurrentLocation.h)
	AddSingleModel(WeedGuy, {label = "Weed Shop",icon = "fas fa-eye",action = function() lib.showContext('WeedShop')end}, nil)
	for k, v in pairs (Config.Weed.items) do 
		WeedShop[#WeedShop + 1] = {
			icon =  GetImage(v.name),
			 title = GetLabel(v.name),
			 description = '$'.. v.price,
			 event = "md-drugs:client:travellingmerchantox",
			 args = {
				item = v.name,
				cost = v.price,
			   	amount = v.amount,
			   	table = Config.Weed.items,
			  	 num = k,
			 }
		 }
	lib.registerContext({id = 'WeedShop',title = "Weed Shop", options = WeedShop})
	end
end)

CreateThread(function()
local items = lib.callback.await('md-drugs:server:GetRecipe', false,'weed', 'edibles')
local items2 = lib.callback.await('md-drugs:server:GetRecipe', false,'weed', 'blunts')
local items3 = lib.callback.await('md-drugs:server:GetRecipe', false,'weed', 'bluntwrap')
local craft = {} 
local blunt = {} 
local bluntwrap = {} 
local label = {}
for k, v in pairs (items) do
	label = {}
	local item = ''
	 for m, d in pairs (items[k].take) do 
		table.insert(label, GetLabel(m) .. ' X ' .. d)
	 end
	 for m,d in pairs (items[k].give) do
		item = m
	 end
	craft[#craft + 1] = {
		icon =  GetImage(item),
		description = table.concat(label, ", "),
		title = GetLabel(item),
		event = "md-drugs:client:MakeWeedItems",
		args = {
			item = item, 
			recipe = 'weed',
			num = k,
			label = 'Cooking Up ' .. GetLabel(item),
			table = 'edibles'

		}
	}
	lib.registerContext({id = 'ButterCraft',title = "Edible Cooking", options = craft})
end
for k, v in pairs (items2) do
	label = {}
	local item = ''
	 for m, d in pairs (items2[k].take) do 
		table.insert(label, GetLabel(m) .. ' X ' .. d)
	 end
	 for m, d in pairs (items2[k].give) do
		item = m
	 end
	 blunt[#blunt + 1] = {
		icon =  GetImage(item),
		description = table.concat(label, ", "),
		title = GetLabel(item),
		event = "md-drugs:client:MakeWeedItems",
		args = {
			item = item, 
			recipe = 'weed',
			num = k,
			label = 'Rolling A ' .. GetLabel(item),
			table = 'blunts'
		}
	}
	lib.registerContext({id = 'mddrugsblunts',title = "Roll Blunts", options = blunt})
end
for k, v in pairs (items3) do
	label = {}
	local item = ''
	 for m, d in pairs (items3[k].take) do 
		table.insert(label, GetLabel(m) .. ' X ' .. d)
	 end
	 for m,d in pairs (items3[k].give) do
		item = m
	 end
	 bluntwrap[#bluntwrap + 1] = {
		icon =  GetImage(item),
		description = table.concat(label, ", "),
		title = GetLabel(item),
		event = "md-drugs:client:MakeWeedItems",
		args = {
			item = item, 
			recipe = 'weed',
			num = k,
			label = 'Dipping Syrup To Make ' .. GetLabel(item),
			table = 'bluntwrap'
		}
	}
	lib.registerContext({id = 'mddrugsbluntwraps',title = "Dip Blunt Wrap", options = bluntwrap})
end
end)

RegisterNetEvent("md-drugs:client:MakeWeedItems", function(data)
	if not minigame() then return end
	if not progressbar('Making ' .. data.item, 4000, 'uncuff') then return end
	TriggerServerEvent('md-drugs:server:MakeWeedItems', data)
end)

RegisterNetEvent('md-drugs:client:makeBluntWrap', function(data)
	lib.showContext('mddrugsbluntwraps')
end)

RegisterNetEvent('md-drugs:client:rollBlunt', function(data)
	lib.showContext('mddrugsblunts')
end)
