local QBCore = exports['qb-core']:GetCoreObject()

local progressbartype = Config.progressbartype 
local minigametype = Config.minigametype
local notifytype = Config.Notify 
local dispatch = Config.Dispatch

function progressbar(text, time, anim)
	TriggerEvent('animations:client:EmoteCommandStart', {anim}) 
	if progressbartype == 'oxbar' then 
	  if lib.progressBar({ duration = time, label = text, useWhileDead = false, canCancel = true, disable = { car = true, move = true},}) then 
		if GetResourceState('scully_emotemenu') == 'started' then
			exports.scully_emotemenu:cancelEmote()
		else
			TriggerEvent('animations:client:EmoteCommandStart', {"c"}) 
		end
		return true
	  end	 
	elseif progressbartype == 'oxcir' then
	  if lib.progressCircle({ duration = time, label = text, useWhileDead = false, canCancel = true, position = 'bottom', disable = { car = true,move = true},}) then 
		if GetResourceState('scully_emotemenu') == 'started' then
			exports.scully_emotemenu:cancelEmote()
		else
			TriggerEvent('animations:client:EmoteCommandStart', {"c"}) 
		end
		return true
	  end
	elseif progressbartype == 'qb' then
	local test = false
		local cancelled = false
	  QBCore.Functions.Progressbar("drink_something", text, time, false, true, { disableMovement = true, disableCarMovement = true, disableMouse = false, disableCombat = true, disableInventory = true,
	  }, {}, {}, {}, function()-- Done
		test = true
		if GetResourceState('scully_emotemenu') == 'started' then
			exports.scully_emotemenu:cancelEmote()
		else
			TriggerEvent('animations:client:EmoteCommandStart', {"c"}) 
		end
	  end, function()
		cancelled = true
		if GetResourceState('scully_emotemenu') == 'started' then
			exports.scully_emotemenu:cancelEmote()
		else
			TriggerEvent('animations:client:EmoteCommandStart', {"c"}) 
		end
	end)
	  repeat 
		Wait(100)
	  until cancelled or test
	  if test then return true end
	else
			print"^1 SCRIPT ERROR: Md-DRUGS set your progressbar with one of the options!"
	end	  
  end

  function minigame(tier)
	local time = 0
	local game = Config.Minigames
	if minigametype == 'ps_circle' then
		local check 
		exports['ps-ui']:Circle(function(success)
			check = success
		end, game['ps_circle'].amount, game['ps_circle'].speed) 
		return check
	elseif minigametype == 'ps_maze' then
	   local check 
	   exports['ps-ui']:Maze(function(success)
		   check = success
	   end, game['ps_maze'].timelimit)
	   return check
   elseif minigametype == 'ps_scrambler' then
	   local check 
	   exports['ps-ui']:Scrambler(function(success)
		   check = success
	   end, game['ps_scrambler'].type,  game['ps_scrambler'].time, game['ps_scrambler'].mirrored)
	   return check
   elseif minigametype == 'ps_var' then
	   local check 
	   exports['ps-ui']:VarHack(function(success)
		   check = success
	   end, game['ps_var'].numBlocks,  game['ps_var'].time)
	   return check
   elseif minigametype == 'ps_thermite' then
	   local check 
	   exports['ps-ui']:Thermite(function(success)
		   check = success
	   end, game['ps_thermite'].time,  game['ps_thermite'].gridsize, game['ps_thermite'].incorrect)
	   return check
	elseif minigametype == 'ox' then
		local success = lib.skillCheck(game['ox'], {'1', '2', '3', '4'})
		return success 
	elseif minigametype == 'blcirprog' then
		local success = exports.bl_ui:CircleProgress(game['blcirprog'].amount, game['blcirprog'].speed)
		return success
	elseif minigametype == 'blprog' then
		local success = exports.bl_ui:Progress(game['blprog'].amount, game['blprog'].speed)
		return success
	elseif minigametype == 'blkeyspam' then
		local success = exports.bl_ui:KeySpam(game['blkeyspam'].amount, game['blprog'].difficulty)
		return success
	elseif minigametype == 'blkeycircle' then
		local success = exports.bl_ui:KeyCircle(game['blkeycircle'].amount, game['blkeycircle'].difficulty, game['blkeycircle'].keynumbers)
		return success	
	elseif minigametype == 'blnumberslide' then
		local success = exports.bl_ui:NumberSlide(game['blnumberslide'].amount, game['blnumberslide'].difficulty, game['blnumberslide'].keynumbers)
		return success	
	elseif minigametype == 'blrapidlines' then
		local success = exports.bl_ui:RapidLines(game['blrapidlines'].amount, game['blrapidlines'].difficulty, game['blrapidlines'].numberofline)
		return success	
	elseif minigametype == 'blcircleshake' then
		local success = exports.bl_ui:CircleShake(game['blcircleshake'].amount, game['blcircleshake'].difficulty, game['blcircleshake'].stages)
		return success	
	elseif minigametype == 'glpath' then 
		local settings = {gridSize = game['glpath'].gridSize, lives = game['glpath'].lives, timeLimit = game['glpath'].timelimit}
		local successes = false
		 exports["glow_minigames"]:StartMinigame(function(success)
			 if success then successes = true else successes = false  end
		 end, "path", settings)
		 repeat
			Wait(1000)
			time = time + 1
		 until successes or time == 100
		 if successes then return true end
	elseif minigametype == 'glspot' then
		local settings = {gridSize = game['glspot'].gridSize, timeLimit = game['glspot'].gridSize, charSet =  game['glspot'].charSet, required = game['glspot'].required}
		local successes = false
		exports["glow_minigames"]:StartMinigame(function(success)
		   if success then successes = true else successes = false  end
		end, "spot", settings)
		repeat
		   Wait(1000)
		   time = time + 1
		until successes or time == 100
	elseif minigametype == 'glmath' then
		local settings = {timeLimit  = game['glmath'].timeLimit}
		local successes = false
		exports["glow_minigames"]:StartMinigame(function(success)
		   if success then successes = true else successes = false  end
		end, "math", settings)
		repeat
		   Wait(1000)
		   time = time + 1
		until successes or time == 100
	elseif minigametype == 'none' then 
		return true			
	else	
		   print"^1 SCRIPT ERROR: Md-Drugs set your minigame with one of the options!"
	end
 end



 function Notify(text, type)
	if notifytype =='ox' then
	  lib.notify({title = text, type = type})
        elseif notifytype == 'qb' then
	  QBCore.Functions.Notify(text, type)
	elseif notifytype == 'okok' then
	  exports['okokNotify']:Alert('', text, 4000, type, false)
	else 
       	print"^1 SCRIPT ERROR: Md-DRUGS set your notification with one of the options!"
    end   
  end

function GetImage(img)
    -- Check if ox_inventory is started
    if GetResourceState('ox_inventory') == 'started' then
        local Items = exports['ox_inventory']:Items()
        
        -- Ensure the item exists before accessing its properties
        if Items[img] and Items[img]['client'] then
            return Items[img]['client']['image'] or ("nui://ox_inventory/web/images/" .. img .. ".png")
        else
            return "nui://ox_inventory/web/images/" .. img .. ".png"
        end
    
    -- Check for other inventories
    elseif GetResourceState('ps-inventory') == 'started' then
        return "nui://ps-inventory/html/images/" .. (QBCore.Shared.Items[img] and QBCore.Shared.Items[img].image or img .. ".png")
    elseif GetResourceState('lj-inventory') == 'started' then
        return "nui://lj-inventory/html/images/" .. (QBCore.Shared.Items[img] and QBCore.Shared.Items[img].image or img .. ".png")
    elseif GetResourceState('qb-inventory') == 'started' then
        return "nui://qb-inventory/html/images/" .. (QBCore.Shared.Items[img] and QBCore.Shared.Items[img].image or img .. ".png")
    elseif GetResourceState('qs-inventory') == 'started' then
        return "nui://qs-inventory/html/img/" .. (QBCore.Shared.Items[img] and QBCore.Shared.Items[img].image or img .. ".png")
    elseif GetResourceState('origen_inventory') == 'started' then
        return "nui://origen_inventory/html/img/" .. (QBCore.Shared.Items[img] and QBCore.Shared.Items[img].image or img .. ".png")
    elseif GetResourceState('core_inventory') == 'started' then
        return "nui://core_inventory/html/img/" .. (QBCore.Shared.Items[img] and QBCore.Shared.Items[img].image or img .. ".png")
    end
end

function GetLabel(label)
    -- Check if ox_inventory is started
    if GetResourceState('ox_inventory') == 'started' then
        local Items = exports['ox_inventory']:Items()
        
        -- Ensure the item exists before accessing its properties
        if Items[label] and Items[label]['label'] then
            return Items[label]['label']
        else
            return "Unknown Label" -- Fallback in case the label doesn't exist
        end
    
    -- Fallback to QBCore if ox_inventory is not started
    else
        if QBCore.Shared.Items[label] and QBCore.Shared.Items[label]['label'] then
            return QBCore.Shared.Items[label]['label']
        else
            return "Unknown Label" -- Fallback for QBCore
        end
    end
end


function ItemCheck(item)
local success 
if GetResourceState('ox_inventory') == 'started' then
    if exports.ox_inventory:GetItemCount(item) >= 1 then return true else Notify('You Need ' .. GetLabel(item) .. " !", 'error') return false end
else
    if QBCore.Shared.Items[item] == nil then print("There Is No " .. item .. " In Your QB Items.lua") return end
    if QBCore.Functions.HasItem(item) then return true else Notify('You Need ' .. QBCore.Shared.Items[item].label .. " !", 'error') return false end
end
end

function ItemCheckMulti(item)
	local need = 0
	local has = 0
	for k,v in pairs (item) do 
		need = need + 1
		if GetResourceState('ox_inventory') == 'started' then
			if exports.ox_inventory:GetItemCount(v) >= 1 then has = has + 1 else Notify('You Need ' .. GetLabel(v) .. " !", 'error') end
		else
			if QBCore.Shared.Items[v] == nil then print("There Is No " .. item .. " In Your QB Items.lua") return end
			if QBCore.Functions.HasItem(v) then has = has + 1  else Notify('You Need ' .. QBCore.Shared.Items[v].label .. " !", 'error') end
		end
	end
	if need == has then 
		return true
	else
		return false
	end
end

function Email(sender, subject, message)
	if Config.Phone == 'yflip' then
		local receiver = GetPlayerServerId(PlayerId())
		local insertId, received = exports["yflip-phone"]:SendMail({
			title = subject,
			sender = sender,
			senderDisplayName = sender,
			content = message,
			
		}, 'phoneNumber', receiver)
	elseif Config.Phone == 'qs' then
		TriggerServerEvent('qs-smartphone:server:sendNewMail', {
   		sender = sender,
   		subject = subject,
    		message = message,
    		button = {}
		})
	else
		TriggerServerEvent('qb-phone:server:sendNewMail', {
			sender = sender,
			subject = subject,
			message = message,
		})
	end
end	  

function PoliceCall(chance)
	local math = math.random(1,100)
	if math <= chance then
		if dispatch == 'ps' then 
			exports['ps-dispatch']:DrugSale()
		elseif dispatch == 'cd' then
			local data = exports['cd_dispatch']:GetPlayerInfo()
			TriggerServerEvent('cd_dispatch:AddNotification', {
				job_table = {'police', }, 
				coords = data.coords,
				title = '420-69 Drug Sale',
				message = 'A '..data.sex..' robbing a store at '..data.street, 
				flash = 0,
				unique_id = data.unique_id,
				sound = 1,
				blip = {
					sprite = 431, 
					scale = 1.2, 
					colour = 3,
					flashes = false, 
					text = '420-69 Drug Sale',
					time = 5,
					radius = 0,
				}
			})
		elseif	dispatch == 'core' then
			exports['core_dispatch']:addCall("420-69", "Drugs Are Being Sold", {
				{icon="fa-ruler", info="4.5 MILES"},
				}, {GetEntityCoords(PlayerPedId())}, "police", 3000, 11, 5 )
		elseif dispatch == 'aty' then 
			exports["aty_dispatch"]:SendDispatch('Drug Sale', '420-69', 40, {'police'})
		elseif dispatch == 'qs' then
			exports['qs-dispatch']:DrugSale()
		else
			print('Congrats, You Choose 0 of the options :)')	
		end
	else
	end
end

function GetCops(number)
	if number == 0 then return true end
	local amount = lib.callback.await('md-drugs:server:GetCoppers', false)
	if amount >= number then return true else Notify('You Need '.. number - amount .. ' More Cops To Do This', 'error')  end
end


function Freeze(entity, toggle, head)
		SetEntityInvincible(entity, toggle)
		SetEntityAsMissionEntity(entity, toggle, toggle)
        FreezeEntityPosition(entity, toggle)
        SetEntityHeading(entity, head)
		SetBlockingOfNonTemporaryEvents(entity, toggle)
end

function tele(coords) 
	DoScreenFadeOut(500)
	Wait(1000)
	SetEntityCoords(PlayerPedId(),coords.x, coords.y, coords.z)
	Wait(1000)
	DoScreenFadeIn(500)
end

function Blip(entity, text)
	local deliveryBlip = AddBlipForCoord(entity)
    SetBlipSprite(deliveryBlip, 1)
    SetBlipDisplay(deliveryBlip, 2)
    SetBlipScale(deliveryBlip, 1.0)
    SetBlipAsShortRange(deliveryBlip, false)
    SetBlipColour(deliveryBlip, 27)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentSubstringPlayerName(text)
    EndTextCommandSetBlipName(deliveryBlip)
    SetBlipRoute(deliveryBlip, true)
end

function RemoveBlips()
	RemoveBlip(deliveryBlip)
end

function AddBoxZoneSingle(name, loc, data)
	if Config.Target == 'qb' then
		exports['qb-target']:AddBoxZone(name, loc, 1.5, 1.75, {name = name, minZ = loc.z-1,maxZ = loc.z +1}, 
		{ options = {
			{
			  type = data.type or nil, 
			  event = data.event or nil,
			  action = data.action or nil,
			  icon = data.icon, 
			  label = data.label,
			  data = data.data,
			  canInteract = data.canInteract,
			}
		}, 
		distance = 2.0
	 })
	elseif Config.Target == 'ox' then
		exports.ox_target:addBoxZone({coords = loc, size = vec3(1,1,1), options = {
			{
			  type = data.type or nil, 
			  event = data.event or nil,
			  onSelect = data.action or nil,
			  distance = 2.5,
			  icon = data.icon, 
			  label = data.label,
			  data = data.data,
			  canInteract = data.canInteract,
			}
		}, })
	end
end

function AddModelTargetZone(name, models, data)
    for k, v in pairs(models) do
        if v.modelHash then
            exports.ox_target:addModel(344662182, {
    options = {
        {
            event = "md-drugs:client:getdiethylamide",
            icon = "fas fa-sign-in-alt",
            label = "Stealing Diethylamide"
        }
    },
    distance = 2.5
})
        else
            print("Error: Missing 'modelHash' for entry in models table at index " .. k)
        end
    end
end

function AddBoxZoneMulti(name, table, data) 
	for k, v in pairs (table) do
		if v.gang == nil or v.gang == '' or v.gang == "" then v.gang = 1 end
		if Config.Target == 'qb' then
			exports['qb-target']:AddBoxZone(name .. k, v.loc, 1.5, 1.75, {name = name..k, minZ = v.loc.z-1.50,maxZ = v.loc.z +1.5}, 
			{ options = {
				{
				  type = data.type or nil, 
				  event = data.event or nil,
				  action = data.action or nil,
				  icon = data.icon, 
				  label = data.label,
				  data = k,
				  canInteract = data.canInteract or function()
					if QBCore.Functions.GetPlayerData().gang.name == v.gang or v.gang == 1 then return true end end
				}
			}, 
			distance = 2.5
		 })
		elseif Config.Target == 'ox' then
			exports.ox_target:addBoxZone({coords = v.loc, size = vec3(1,1,1), options = {
				{
				  type = data.type or nil, 
				  event = data.event or nil,
				  onSelect = data.action or nil,
				  icon = data.icon, 
				  label = data.label,
				  data = k,
				  distance = 1.0,
				  canInteract = data.canInteract or function()
					if QBCore.Functions.GetPlayerData().gang.name == v.gang or v.gang == 1 then return true end end
				}
			}, 
			distance = 1.5			
			})
		end
	end
end

function AddBoxZoneMultiOptions(name, loc, data) 

		if Config.Target == 'qb' then
			exports['qb-target']:AddBoxZone(name , loc, 1.5, 1.75, {name = name, minZ = loc.z-1.50,maxZ = loc.z +1.5}, 
			{ options = data, distance = 2.5})
		elseif Config.Target == 'ox' then
			exports.ox_target:addBoxZone({coords = loc, size = vec3(1,1,1), options = data })
		end
	end


function AddSingleModel(model, data, num)
	if Config.Target == 'qb' then
		exports['qb-target']:AddTargetEntity(model, {options = {
			{icon = data.icon, label = data.label, event = data.event or nil, action = data.action or nil, data = num }
		}, distance = 2.5})
	elseif Config.Target == 'ox' then
		exports.ox_target:addLocalEntity(model, {icon = data.icon, label = data.label, event = data.event or nil, onSelect = data.action or nil, data = num, distance = 2.5 })
	end
end

function AddMultiModel(model, data, num)
	if Config.Target == 'qb' then
		exports['qb-target']:AddTargetEntity(model, {options = data, distance = 2.5})
	elseif Config.Target == 'ox' then
		exports.ox_target:addLocalEntity(model, data)
	end
end

local created = false
local heading = 180.0
function StartRay()
    local run = true
	local pedcoord = GetEntityCoords(PlayerPedId())
	local table = CreateObject('v_ret_ml_tablea', pedcoord.x, pedcoord.y, pedcoord.z+1, heading, false, false)
    repeat
        local hit, entityHit, endCoords, surfaceNormal, matHash = lib.raycast.cam(511, 4, 10)
		if not created then 
			created = true
			lib.showTextUI([[[E] To Place   
			[DEL] To Cancel  
			[<-] To Move Left  
			[->] To Move Right]])
		else
			SetEntityCoords(table, endCoords.x, endCoords.y, endCoords.z+1)
			SetEntityHeading(table, heading)
			SetEntityCollision(table, false, false)
			SetEntityAlpha(table, 100)
		end
		if IsControlPressed(0, 174) then
            heading = heading - 2
        end
		if IsControlPressed(0, 175) then
            heading = heading + 2
        end
        if IsControlPressed(0, 38) then
            lib.hideTextUI()
            run = false
			DeleteObject(table)
			created = false
            return endCoords, heading
        end

        if IsControlPressed(0, 178) then
            lib.hideTextUI()
            run = false
			created = false
			DeleteObject(table)
            return nil, nil
		end
        Wait(0)
    until run == false
end

function StartRay2()
    local run = true
	local pedcoord = GetEntityCoords(PlayerPedId())
	local table = CreateObject('bkr_prop_coke_press_01aa', pedcoord.x, pedcoord.y, pedcoord.z+1, heading, false, false)
    repeat
        local hit, entityHit, endCoords, surfaceNormal, matHash = lib.raycast.cam(511, 4, 10)
		if not created then 
			created = true
			lib.showTextUI([[[E] To Place   
			[DEL] To Cancel  
			[<-] To Move Left  
			[->] To Move Right]])
		else
			SetEntityCoords(table, endCoords.x, endCoords.y, endCoords.z+1)
			SetEntityHeading(table, heading)
			SetEntityCollision(table, false, false)
			SetEntityAlpha(table, 100)
		end
		if IsControlPressed(0, 174) then
            heading = heading - 2
        end
		if IsControlPressed(0, 175) then
            heading = heading + 2
        end
        if IsControlPressed(0, 38) then
            lib.hideTextUI()
            run = false
			DeleteObject(table)
			created = false
            return endCoords, heading
        end

        if IsControlPressed(0, 178) then
            lib.hideTextUI()
            run = false
			created = false
			DeleteObject(table)
            return nil, nil
		end
        Wait(0)
    until run == false
end


RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
	Wait(3000)
	local check = lib.callback.await('md-drugs:server:GetRep', false)

	return 
end)
local active = false
RegisterNetEvent('md-drugs:client:minusTier', function(data) 
	if active then return end
	if not data then return end
	active = true
	if not progressbar('Cutting This ' ..GetLabel(data.item) .. ' More', 4000, 'uncuff') then return end
	TriggerServerEvent('md-drugs:server:AddMas', data)
	active = false
end)