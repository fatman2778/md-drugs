local QBCore = exports['qb-core']:GetCoreObject()
local amonia = nil
local tray = nil
local heated = nil
local active = nil

local function startcook()
	if not ItemCheck('empty_weed_bag') then return end
	if not ItemCheck('acetone') then return end
	if not ItemCheck('ephedrine') then return end
	if amonia == nil then
		active = true
		TriggerServerEvent("md-drugs:server:startcook")
		MethCooking()
		amonia = true
	else
		Notify(Lang.meth.inside, "error")
	end
end

local function dials()
	if amonia == true then
		if not minigame(2, 8) then
			AddExplosion(1005.773, -3200.402, -38.524, 49, 10, true, false, true, true)
			ClearPedTasks(PlayerPedId())
			amonia = nil
			active = nil
		return end
		Notify(Lang.meth.increaseheat, "success")
		ClearPedTasks(PlayerPedId())
		heated = true	
	else
	end
end

local function smash()
if tray then
	tray = false
	DeleteObject(trays)
	local bucket = CreateObject(`bkr_prop_meth_bigbag_03a`, vector3(1012.85, -3194.29, -39.2), true, true, true)
	Freeze(bucket, true, 90.0)
	SmashMeth()
	Wait(100)
	AddSingleModel(bucket, {name = 'bucket',icon = 'fa-solid fa-car',label = 'Bag Meth',action = function()	DeleteObject(bucket)amonia = nil heated = nil tray = nil active = nil BagMeth()	TriggerServerEvent('md-drugs:server:getmeth')end,}, bucket) 
end	
end

local function trayscarry()
	if amonia then
		local pos = GetEntityCoords(PlayerPedId(), true)
		RequestAnimDict('anim@heists@box_carry@')
		while (not HasAnimDictLoaded('anim@heists@box_carry@')) do
			Wait(7)
		end
		TaskPlayAnim(PlayerPedId(), 'anim@heists@box_carry@', 'idle', 5.0, -1, -1, 50, 0, false, false,
			false)
		RequestModel("bkr_prop_meth_tray_02a")
		while not HasModelLoaded("bkr_prop_meth_tray_02a") do
			Wait(0)
		end
		 trays = CreateObject("bkr_prop_meth_tray_02a", pos.x, pos.y, pos.z, true, true, true)
		AttachEntityToEntity(trays, PlayerPedId(), GetPedBoneIndex(PlayerPedId(), 28422), 0.01, -0.2,
			-0.2, 20.0, 0.0, 0.0, true, true, false, true, 1, true)
		tray = true
	end
end
CreateThread(function()
	BikerMethLab = exports['bob74_ipl']:GetBikerMethLabObject()
	BikerMethLab.Style.Set(BikerMethLab.Style.upgrade)
	BikerMethLab.Security.Set(BikerMethLab.Security.upgrade)
	BikerMethLab.Details.Enable(BikerMethLab.Details.production, true)
	RefreshInterior(BikerMethLab.interiorId)
end)

CreateThread(function()
	
	AddBoxZoneSingle("methTeleOut",Config.MethTeleIn, {name = 'teleout', icon = "fas fa-sign-in-alt", label = "Enter Building",	action = function()		SetEntityCoords(PlayerPedId(), Config.MethTeleOut)	end} )
	AddBoxZoneSingle("methtelein",Config.MethTeleOut, {name = 'teleout', icon = "fas fa-sign-in-alt", label = "Exit Building",	action = function()		SetEntityCoords(PlayerPedId(), Config.MethTeleIn)	end} )
	local options = {
		{ name = 'methcook', icon = "fas fa-sign-in-alt", label = "Cook Meth", distance = 2.5, action = function() 	startcook() end, onSelect = function() 	startcook() end,
				canInteract = function()
				if amonia == nil and active == nil then
					return true
				end
		  end,
		},
		{ name = 'grabtray', icon = "fas fa-sign-in-alt", label = "Grab Tray", distance = 2.5, onSelect = function() 	trayscarry() end, action = function() 	trayscarry() end,
		  canInteract = function()
				if heated and amonia and tray == nil then return true end
		  end,
		},
	}
	AddBoxZoneMultiOptions("cookmeth",vector3(1005.72, -3200.33, -38.52), options )
	AddBoxZoneSingle('boxmeth', vector3(1012.15, -3194.04, -39.20), {name = 'boxmeth',icon = "fas fa-sign-in-alt",label = "Box Up Meth",action = function()	smash()end,
			canInteract = function()
				if tray then return true end
			end})
	AddBoxZoneSingle('adjustdials',vector3(1007.89, -3201.17, -38.99),{	name = 'adjustdials',	icon = "fas fa-sign-in-alt",	label = "Adjust Dials",	distance = 5,	action = function()		dials()	end,
			canInteract = function()
				if amonia and heated == nil then return true end end
			})
	if Config.MethHeist == false then
		AddBoxZoneMulti('methep', Config.MethEph, {icon = "fas fa-sign-in-alt",	label = "Steal Ephedrine", event = 'md-drugs:client:stealeph'})
		AddBoxZoneMulti('methace', Config.Methace, {icon = "fas fa-sign-in-alt",	label = "Steal Acetone", event = 'md-drugs:client:stealace'})
	end
end)

CreateThread(function()
if not Config.MethHeist == false then
	local current = "g_m_y_famdnf_01"
	lib.requestModel(current, Config.RequestModelTime)
	local CurrentLocation = Config.MethHeistStart
	local methdealer = CreatePed(0, current, CurrentLocation.x, CurrentLocation.y, CurrentLocation.z - 1, false, false)
	Freeze(methdealer, true, 220.0)
	Wait(100)
	AddSingleModel(methdealer,{
		label = "Get Mission",
		icon = "fas fa-eye",
		action = function()
			Notify(Lang.meth.mission, "success")
			SpawnMethCarPedChase()
		end,
	},nil )
end
end)

RegisterNetEvent("md-drugs:client:stealeph", function(data)
	if not progressbar('Stealing Ephedrine', 4000, 'uncuff') then return end
	TriggerServerEvent("md-drugs:server:geteph", data.data)
end)

RegisterNetEvent("md-drugs:client:stealace", function(data)
	if not progressbar('Stealing Acetone', 4000, 'uncuff') then return end
	TriggerServerEvent("md-drugs:server:getace", data.data)
end)


