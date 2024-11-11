local QBCore = exports['qb-core']:GetCoreObject()
local tableout = false


local function loadParticle(dict)
    if not HasNamedPtfxAssetLoaded(dict) then
        RequestNamedPtfxAsset(dict)
    end
    while not HasNamedPtfxAssetLoaded(dict) do
        Wait(0)
    end
    SetPtfxAssetNextCall(dict)
end

CreateThread(function() 
local Ped = "s_m_m_scientist_01"
	lib.requestModel(Ped, Config.RequestModelTime)
	local tabdealer = CreatePed(0, Ped,Config.buylsdlabkit.x,Config.buylsdlabkit.y,Config.buylsdlabkit.z-1, Config.buylsdlabkit.w, false, false)
    Freeze(tabdealer, true, Config.buylsdlabkit.w)
    AddSingleModel(tabdealer,{ type = "client", label = "Purchase Supplies", icon = "fas fa-eye", event = "md-drugs:client:buylabkit", distance = 2.0}, tabdealer )
end)


RegisterNetEvent("md-drugs:client:getlysergic", function(data) 
    if not minigame(2, 8) then return end
	if not progressbar(Lang.lsd.steallys, 4000, 'uncuff') then return end
    TriggerServerEvent("md-drugs:server:getlysergic",data.data)
end)


RegisterNetEvent("md-drugs:client:getdiethylamide", function(data) 
    if not minigame(2, 8) then return end
	if not progressbar(Lang.lsd.stealdie, 4000, 'uncuff') then return end
    TriggerServerEvent('md-drugs:server:getdiethylamide', data.data)
end)

RegisterNetEvent("md-drugs:client:setlsdlabkit", function()
if tableout then 
    Notify(Lang.lsd.tableout, 'error')
    TriggerServerEvent('md-drugs:server:getlabkitback')
else
    tableout = true
    local loc, head = StartRay()
    if not loc then tableout = false TriggerServerEvent('md-drugs:server:getlabkitback') return end
	if not progressbar(Lang.lsd.place, 4000, 'uncuff') then TriggerServerEvent('md-drugs:server:getlabkitback') return end
	local labkit = CreateObject("v_ret_ml_tablea", loc.x, loc.y, loc.z-1, true, false)
    SetEntityHeading(labkit, head)
    PlaceObjectOnGroundProperly(labkit)
    local options = {
        { event = "md-drugs:client:heatliquid",         icon = "fas fa-box-circle-check", label = "Heat Liquid" ,   data = labkit, },
        { event = "md-drugs:client:refinequalityacid",  icon = "fas fa-box-circle-check", label = "Refine",         data = labkit, },
		{ event = "md-drugs:client:maketabpaper",       icon = "fas fa-box-circle-check", label = "Dab Sheets",     data = labkit, },
		{ event = "md-drugs:client:getlabkitback",      icon = "fas fa-box-circle-check", label = "Pick Up",        data = labkit, canInteract = function() if tableout then return true end end},
    }
    AddMultiModel(labkit, options, labkit)
end
end)

RegisterNetEvent("md-drugs:client:getlabkitback", function(data) 
    if not progressbar(Lang.lsd.tablepack, 4000, 'uncuff') then return end
	DeleteObject(data.data)
	TriggerServerEvent('md-drugs:server:getlabkitback')
    tableout = false
end)

RegisterNetEvent("md-drugs:client:heatliquid", function(data) 
	local PedCoords = GetEntityCoords(data.data)
	dict = "scr_ie_svm_technical2"
    if not ItemCheck('lysergic_acid') then return end
    if not ItemCheck('diethylamide') then return end
	if not minigame(2, 8) then
        TriggerServerEvent("md-drugs:server:failheating")
		DeleteObject(data.data)
		local dirtylabkit = CreateObject("v_ret_ml_tablea", PedCoords.x, PedCoords.y, PedCoords.z-1, true, false)
		loadParticle(dict)
	    exitPtfx = StartParticleFxLoopedOnEntity("scr_dst_cocaine", dirtylabkit, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.5, false, false, false)
		PlaceObjectOnGroundProperly(dirtylabkit)
        SetParticleFxLoopedAlpha(exitPtfx, 3.0)
        Wait(100)
        local options = {
            {   event = "md-drugs:client:cleanlabkit",   icon = "fas fa-box-circle-check",   label = "Clean It", data = dirtylabkit}
        }
        AddMultiModel(dirtylabkit, options, nil )
        return end
    if not progressbar(Lang.lsd.heat, 7000, 'uncuff') then return end
    TriggerServerEvent("md-drugs:server:heatliquid")
end)

RegisterNetEvent("md-drugs:client:cleanlabkit", function(data)
    if not ItemCheck('cleaningkit')  then return end
    if not progressbar(Lang.lsd.clean, 4000, 'clean') then return end
    local check = lib.callback.await('md-drugs:server:removecleaningkit')
    if check then 
        local coord = GetEntityCoords(data.data)
        DeleteObject(data.data)
        local labkit = CreateObject("v_ret_ml_tablea", coord.x, coord.y, coord.z-1, true, false)
        PlaceObjectOnGroundProperly(labkit)
        local options = {
            { event = "md-drugs:client:heatliquid",         icon = "fas fa-box-circle-check", label = "Heat Liquid" ,   data = labkit, },
            { event = "md-drugs:client:refinequalityacid",  icon = "fas fa-box-circle-check", label = "Refine",         data = labkit, },
		    { event = "md-drugs:client:maketabpaper",       icon = "fas fa-box-circle-check", label = "Dab Sheets",     data = labkit, },
		    { event = "md-drugs:client:getlabkitback",      icon = "fas fa-box-circle-check", label = "Pick Up",        data = labkit, canInteract = function() if tableout then return true end end},
        }
        AddMultiModel(labkit, options, labkit)
	end
end)

RegisterNetEvent("md-drugs:client:refinequalityacid", function()
    if not ItemCheck('lsd_one_vial')  then return end 
    if not minigame(2, 8) then TriggerServerEvent("md-drugs:server:failrefinequality") return end
    if not progressbar(Lang.lsd.refine, 4000, 'uncuff') then return end
    TriggerServerEvent("md-drugs:server:refinequalityacid")
end)

RegisterNetEvent("md-drugs:client:maketabpaper", function()
    if not ItemCheck('tab_paper')  then return end 
    if not minigame(2, 8) then TriggerServerEvent("md-drugs:server:failtabs") return end
	if not progressbar(Lang.lsd.dip, 4000, 'uncuff') then return end
    TriggerServerEvent("md-drugs:server:maketabpaper")
end)

RegisterNetEvent("md-drugs:client:buytabs", function(data) 
	if not progressbar(Lang.lsd.buypaper, 4000, 'uncuff') then return end
    TriggerServerEvent("md-drugs:server:gettabpaper", data.data)
end)


RegisterNetEvent("md-drugs:client:buylabkit", function()
    if QBCore.Functions.HasItem('lsdlabkit') then Notify('You Have One Idiot', 'error') return end 
	if not progressbar(Lang.lsd.buykit, 4000, 'uncuff') then return end
	TriggerServerEvent("md-drugs:server:getlabkit")
end)
