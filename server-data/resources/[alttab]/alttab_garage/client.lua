local Keys = {
	["ESC"] = 322, ["F1"] = 288, ["F2"] = 289, ["F3"] = 170, ["F5"] = 166, ["F6"] = 167, ["F7"] = 168, ["F8"] = 169, ["F9"] = 56, ["F10"] = 57,
	["~"] = 243, ["1"] = 157, ["2"] = 158, ["3"] = 160, ["4"] = 164, ["5"] = 165, ["6"] = 159, ["7"] = 161, ["8"] = 162, ["9"] = 163, ["-"] = 84, ["="] = 83, ["BACKSPACE"] = 177,
	["TAB"] = 37, ["Q"] = 44, ["W"] = 32, ["E"] = 38, ["R"] = 45, ["T"] = 245, ["Y"] = 246, ["U"] = 303, ["P"] = 199, ["["] = 39, ["]"] = 40, ["ENTER"] = 18,
	["CAPS"] = 137, ["A"] = 34, ["S"] = 8, ["D"] = 9, ["F"] = 23, ["G"] = 47, ["H"] = 74, ["K"] = 311, ["L"] = 182,
	["LEFTSHIFT"] = 21, ["Z"] = 20, ["X"] = 73, ["C"] = 26, ["V"] = 0, ["B"] = 29, ["N"] = 249, ["M"] = 244, [","] = 82, ["."] = 81,
	["LEFTCTRL"] = 36, ["LEFTALT"] = 19, ["SPACE"] = 22, ["RIGHTCTRL"] = 70,
	["HOME"] = 213, ["PAGEUP"] = 10, ["PAGEDOWN"] = 11, ["DELETE"] = 178,
	["LEFT"] = 174, ["RIGHT"] = 175, ["TOP"] = 27, ["DOWN"] = 173,
	["NENTER"] = 201, ["N4"] = 108, ["N5"] = 60, ["N6"] = 107, ["N+"] = 96, ["N-"] = 97, ["N7"] = 117, ["N8"] = 61, ["N9"] = 118
}

local CurrentAction = nil
local GUI                       = {}
GUI.Time                        = 0
local HasAlreadyEnteredMarker   = false
local LastZone                  = nil
local CurrentActionMsg          = ''
local CurrentActionData         = {}
local times 			= 0

local this_Garage = {}


-- Init ESX
ESX = nil

Citizen.CreateThread(function()
	while ESX == nil do
		TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
		Citizen.Wait(0)
	end
end)

--- Blips Management
RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(xPlayer)
    --PlayerData = xPlayer
    --TriggerServerEvent('esx_jobs:giveBackCautionInCaseOfDrop')
    refreshBlips()
end)

function refreshBlips()
	local zones = {}
	local blipInfo = {}

	for zoneKey,zoneValues in pairs(Config.Garages)do

		if (zoneValues.Pos.x == 462.68) or (zoneValues.Pos.x == -451.58) or (zoneValues.Pos.x == 1225.27) then
		else
			local blip = AddBlipForCoord(zoneValues.Pos.x, zoneValues.Pos.y, zoneValues.Pos.z)
			SetBlipSprite (blip, Config.BlipInfos.Sprite)
			SetBlipDisplay(blip, 4)
			SetBlipScale  (blip, 0.8)
			SetBlipColour (blip, Config.BlipInfos.Color)
			SetBlipAsShortRange(blip, true)
			BeginTextCommandSetBlipName("STRING")
			AddTextComponentString(zoneKey)
			EndTextCommandSetBlipName(blip)
		
		end

		local blip = AddBlipForCoord(zoneValues.MunicipalPoundPoint.Pos.x, zoneValues.MunicipalPoundPoint.Pos.y, zoneValues.MunicipalPoundPoint.Pos.z)
		SetBlipSprite (blip, Config.BlipPound.Sprite)
		SetBlipDisplay(blip, 4)
		SetBlipScale  (blip, 0.8)
		SetBlipColour (blip, Config.BlipPound.Color)
		SetBlipAsShortRange(blip, true)
		BeginTextCommandSetBlipName("STRING")
		AddTextComponentString(_U('impound_yard'))
		EndTextCommandSetBlipName(blip)
	end
end

--Menu function

function OpenMenuGarage(PointType)

	ESX.UI.Menu.CloseAll()

	local elements = {}


	if PointType == 'spawn' then
		table.insert(elements,{label = _U('list_vehicles'), value = 'list_vehicles'})
	end

	if PointType == 'delete' then
		table.insert(elements,{label = _U('stock_vehicle'), value = 'stock_vehicle'})
	end

	if PointType == 'pound' then
		table.insert(elements,{label = _U('return_vehicle', 100), value = 'return_vehicle'})
	end

	ESX.UI.Menu.Open(
		'default', GetCurrentResourceName(), 'garage_menu',
		{
			title    = _U('garage'),
			align    = 'top',
			elements = elements,
		},
		function(data, menu)

			menu.close()
			if(data.current.value == 'list_vehicles') then
				ListVehiclesMenu()
			end
			if(data.current.value == 'stock_vehicle') then
				StockVehicleMenu()
			end
			if(data.current.value == 'return_vehicle') then
				ReturnVehicleMenu()
			end

			local playerPed = GetPlayerPed(-1)
			SpawnVehicle(data.current.value)

		end,
		function(data, menu)
			menu.close()

		end
	)
end


-- View Vehicle Listings
function ListVehiclesMenu()
	local elements = {}

	ESX.TriggerServerCallback('eden_garage:getVehicles', function(vehicles)

 	for _,v in pairs(vehicles) do

        	local hashVehicule = v.vehicle.model
        	local vehicleName = GetDisplayNameFromVehicleModel(hashVehicule)
        	local labelvehicle
        	if (v.state) then
        	labelvehicle = vehicleName _U('status_in_garage', GetLabelText(vehicleName))

        	else
        	labelvehicle = vehicleName _U('status_impounded', GetLabelText(vehicleName))
        	end
        	table.insert(elements, {label =labelvehicle , value = v})

					-- local jc = Config.JobCars
					-- for i = 1, #jc do
					-- 	if labelvehicle == jc[i] then
					-- 		table.remove(elements, nil)
					-- 	end
					-- end
   	end

		ESX.UI.Menu.Open(
		'default', GetCurrentResourceName(), 'spawn_vehicle',
		{
			title    = _U('garage'),
			align    = 'top',
			elements = elements,
		},
		function(data, menu)
			if(data.current.value.state)then
				menu.close()
				SpawnVehicle(data.current.value.vehicle)
			else
				ESX.ShowNotification(_U('notif_car_impounded'))
			end
		end,
		function(data, menu)
			menu.close()
			--CurrentAction = 'open_garage_action'
		end
	)
	end)
end

function reparation(prix,vehicle,vehicleProps)

	ESX.UI.Menu.CloseAll()

	local elements = {
		{label = _U('reparation_yes', prix), value = 'yes'},
		{label = _U('reparation_no', prix), value = 'no'},
	}
	ESX.UI.Menu.Open(
		'default', GetCurrentResourceName(), 'delete_menu',
		{
			title    = _U('reparation'),
			align    = 'top',
			elements = elements,
		},
		function(data, menu)

			menu.close()
			if(data.current.value == 'yes') then
				TriggerServerEvent('eden_garage:payhealth', prix)
				ranger(vehicle,vehicleProps)
			end
			if(data.current.value == 'no') then
				ESX.ShowNotification(_U('reparation_no_notif'))
			end

		end,
		function(data, menu)
			menu.close()
		end
	)
end

RegisterNetEvent('eden_garage:deletevehicle_cl')
AddEventHandler('eden_garage:deletevehicle_cl', function(plate)
	local _plate = plate:gsub("^%s*(.-)%s*$", "%1")
	local playerPed  = GetPlayerPed(-1)
	if IsPedInAnyVehicle(playerPed,  false) then
		local playerPed = GetPlayerPed(-1)
		local coords    = GetEntityCoords(playerPed)
		local vehicle = GetVehiclePedIsIn(playerPed,false)
		local vehicleProps  = ESX.Game.GetVehicleProperties(vehicle)
		local usedPlate = vehicleProps.plate:gsub("^%s*(.-)%s*$", "%1")
		if usedPlate == _plate then
			ESX.Game.DeleteVehicle(vehicle)
		end
	end
end)


function ranger(vehicle,vehicleProps)
	TriggerServerEvent('eden_garage:deletevehicle_sv', vehicleProps.plate)
	TriggerServerEvent('eden_garage:modifystate', vehicleProps, true)
	ESX.ShowNotification(_U('ranger'))
end

-- Function that allows player to enter a vehicle
function StockVehicleMenu()
	local playerPed  = GetPlayerPed(-1)
	if IsPedInAnyVehicle(playerPed,  false) then

		local playerPed = GetPlayerPed(-1)
		local coords    = GetEntityCoords(playerPed)
		local vehicle = GetVehiclePedIsIn(playerPed,false)
		local vehicleProps  = ESX.Game.GetVehicleProperties(vehicle)
		local current 	    = GetPlayersLastVehicle(GetPlayerPed(-1), true)
		local engineHealth  = GetVehicleEngineHealth(current)

		ESX.TriggerServerCallback('eden_garage:stockv',function(valid)

			if (valid) then
				ESX.TriggerServerCallback('eden_garage:getVehicles', function(vehicules)
					local plate = vehicleProps.plate:gsub("^%s*(.-)%s*$", "%1")
					local owned = false
					for _,v in pairs(vehicules) do
						if plate == v.plate then
							owned = true
							TriggerServerEvent('eden_garage:debug', "vehicle plate returned to the garage: "  .. vehicleProps.plate)
							TriggerServerEvent('eden_garage:logging',"vehicle returned to the garage: " .. engineHealth)
							if engineHealth < 1000 then
								local fraisRep= math.floor((1000 - engineHealth) * Config.RepairMultiplier)
								reparation(fraisRep,vehicle,vehicleProps)
							else
								ranger(vehicle,vehicleProps)
							end
						end
					end
					if owned == false then

						ESX.ShowNotification(_U('stockv_not_owned'))
					end
				end)
			else
				ESX.ShowNotification(_U('stockv_not_owned'))
			end
		end,vehicleProps)
	else
		ESX.ShowNotification(_U('stockv_not_in_veh'))
	end

end



--Function for spawning vehicle
function SpawnVehicle(vehicle)
	

	if (this_Garage.Pos.x == 215.80) then
		ESX.Game.SpawnVehicle(vehicle.model,{
		x=230.71 ,
		y=-802.86,
		z=31.0
		},157.84, function(callback_vehicle)
		ESX.Game.SetVehicleProperties(callback_vehicle, vehicle)
		SetVehRadioStation(callback_vehicle, "OFF")
		TaskWarpPedIntoVehicle(GetPlayerPed(-1), callback_vehicle, -1)
		local plate = GetVehicleNumberPlateText(callback_vehicle)
		TriggerServerEvent("ls:mainCheck", plate, callback_vehicle, true)
		end)

		TriggerServerEvent('eden_garage:modifystate', vehicle, false)
	elseif (this_Garage.Pos.x == -351.0) then
		ESX.Game.SpawnVehicle(vehicle.model,{
		x=-351.73 ,
		y=-894.18,
		z=31.0
		},3.2, function(callback_vehicle)
		ESX.Game.SetVehicleProperties(callback_vehicle, vehicle)
		SetVehRadioStation(callback_vehicle, "OFF")
		TaskWarpPedIntoVehicle(GetPlayerPed(-1), callback_vehicle, -1)
		local plate = GetVehicleNumberPlateText(callback_vehicle)
		TriggerServerEvent("ls:mainCheck", plate, callback_vehicle, true)
		end)

		TriggerServerEvent('eden_garage:modifystate', vehicle, false)

	else
		ESX.Game.SpawnVehicle(vehicle.model,{ -- 229.700, -800.1149, 30.0
		x=this_Garage.SpawnPoint.Pos.x ,
		y=this_Garage.SpawnPoint.Pos.y,
		z=this_Garage.SpawnPoint.Pos.z + 1
		},this_Garage.SpawnPoint.Heading, function(callback_vehicle)
		ESX.Game.SetVehicleProperties(callback_vehicle, vehicle)
		SetVehRadioStation(callback_vehicle, "OFF")
		TaskWarpPedIntoVehicle(GetPlayerPed(-1), callback_vehicle, -1)
		local plate = GetVehicleNumberPlateText(callback_vehicle)
		TriggerServerEvent("ls:mainCheck", plate, callback_vehicle, true)
		end)
		TriggerServerEvent('eden_garage:modifystate', vehicle, false)
		
	end

end

--Function for spawning vehicle
function SpawnPoundedVehicle(vehicle)

	ESX.Game.SpawnVehicle(vehicle.model, { 
		x = this_Garage.SpawnMunicipalPoundPoint.Pos.x ,
		y = this_Garage.SpawnMunicipalPoundPoint.Pos.y,
		z = this_Garage.SpawnMunicipalPoundPoint.Pos.z + 1
		},this_Garage.SpawnMunicipalPoundPoint.Heading, function(callback_vehicle)
		ESX.Game.SetVehicleProperties(callback_vehicle, vehicle)
		local plate = GetVehicleNumberPlateText(callback_vehicle)
		TriggerServerEvent("ls:mainCheck", plate, callback_vehicle, true)
		end)
	TriggerServerEvent('eden_garage:modifystate', vehicle, true)

	ESX.SetTimeout(10000, function()
		TriggerServerEvent('eden_garage:modifystate', vehicle, false)
	end)

end

-- Marker actions
AddEventHandler('eden_garage:hasEnteredMarker', function(zone)

	if zone == 'spawn' then
		CurrentAction     = 'spawn'
		CurrentActionMsg  = _U('spawn')
		CurrentActionData = {}
	end

	if zone == 'delete' then
		CurrentAction     = 'delete'
		CurrentActionMsg  = _U('delete')
		CurrentActionData = {}
	end

	if zone == 'pound' then
		CurrentAction     = 'pound_action_menu'
		CurrentActionMsg  = _U('pound_action_menu')
		CurrentActionData = {}
	end
end)

AddEventHandler('eden_garage:hasExitedMarker', function(zone)
	ESX.UI.Menu.CloseAll()
	CurrentAction = nil
end)

function ReturnVehicleMenu()

	ESX.TriggerServerCallback('eden_garage:getOutVehicles', function(vehicles)

		local elements = {}

		for _,v in pairs(vehicles) do

		local hashVehicule = v.model
		local vehicleName = GetDisplayNameFromVehicleModel(hashVehicule)
		local labelvehicle

		labelvehicle = vehicleName _U('impound_list', GetLabelText(vehicleName))

		table.insert(elements, {label =labelvehicle , value = v})

		end

		ESX.UI.Menu.Open(
		'default', GetCurrentResourceName(), 'return_vehicle',
		{
			title    = _U('impound_yard'),
			align    = 'top',
			elements = elements,
		},
		function(data, menu)

			ESX.TriggerServerCallback('eden_garage:checkMoney', function(hasEnoughMoney)
				if hasEnoughMoney then

					if times == 0 then
						TriggerServerEvent('eden_garage:pay')
						SpawnPoundedVehicle(data.current.value)
						times=times+1
					elseif times > 0 then
						ESX.SetTimeout(60000, function()
						times=0
						end)
					end
				else
					ESX.ShowNotification(_U('impound_not_enough_money'))
				end
			end)
		end,
		function(data, menu)
			menu.close()
			--CurrentAction = 'open_garage_action'
		end)
	end)
end

-- Display markers
Citizen.CreateThread(function()
	while true do
		Wait(0)
		local coords = GetEntityCoords(GetPlayerPed(-1))

		for k,v in pairs(Config.Garages) do
			if(GetDistanceBetweenCoords(coords, v.Pos.x, v.Pos.y, v.Pos.z, true) < Config.DrawDistance) then
				DrawMarker(v.SpawnPoint.Marker, v.SpawnPoint.Pos.x, v.SpawnPoint.Pos.y, v.SpawnPoint.Pos.z, 0.0, 0.0, 0.0, 0, 0.0, 0.0, v.SpawnPoint.Size.x, v.SpawnPoint.Size.y, v.SpawnPoint.Size.z, v.SpawnPoint.Color.r, v.SpawnPoint.Color.g, v.SpawnPoint.Color.b, 100, false, true, 2, false, false, false, false)
				DrawMarker(v.DeletePoint.Marker, v.DeletePoint.Pos.x, v.DeletePoint.Pos.y, v.DeletePoint.Pos.z, 0.0, 0.0, 0.0, 0, 0.0, 0.0, v.DeletePoint.Size.x, v.DeletePoint.Size.y, v.DeletePoint.Size.z, v.DeletePoint.Color.r, v.DeletePoint.Color.g, v.DeletePoint.Color.b, 100, false, true, 2, false, false, false, false)
			end
			if(GetDistanceBetweenCoords(coords, v.MunicipalPoundPoint.Pos.x, v.MunicipalPoundPoint.Pos.y, v.MunicipalPoundPoint.Pos.z, true) < Config.DrawDistance) then
				DrawMarker(v.MunicipalPoundPoint.Marker, v.MunicipalPoundPoint.Pos.x, v.MunicipalPoundPoint.Pos.y, v.MunicipalPoundPoint.Pos.z, 0.0, 0.0, 0.0, 0, 0.0, 0.0, v.MunicipalPoundPoint.Size.x, v.MunicipalPoundPoint.Size.y, v.MunicipalPoundPoint.Size.z, v.MunicipalPoundPoint.Color.r, v.MunicipalPoundPoint.Color.g, v.MunicipalPoundPoint.Color.b, 100, false, true, 2, false, false, false, false)
				DrawMarker(v.SpawnMunicipalPoundPoint.Marker, v.SpawnMunicipalPoundPoint.Pos.x, v.SpawnMunicipalPoundPoint.Pos.y, v.SpawnMunicipalPoundPoint.Pos.z, 0.0, 0.0, 0.0, 0, 0.0, 0.0, v.SpawnMunicipalPoundPoint.Size.x, v.SpawnMunicipalPoundPoint.Size.y, v.SpawnMunicipalPoundPoint.Size.z, v.SpawnMunicipalPoundPoint.Color.r, v.SpawnMunicipalPoundPoint.Color.g, v.SpawnMunicipalPoundPoint.Color.b, 100, false, true, 2, false, false, false, false)
			end
		end
	end
end)

-- Open/close menus
Citizen.CreateThread(function()
	local currentZone = 'garage'
	while true do

		Wait(0)
		

		local coords      = GetEntityCoords(GetPlayerPed(-1))
		local isInMarker  = false

		for _,v in pairs(Config.Garages) do
			if(GetDistanceBetweenCoords(coords, v.SpawnPoint.Pos.x, v.SpawnPoint.Pos.y, v.SpawnPoint.Pos.z, true) < v.Size.x) then
				isInMarker  = true
				this_Garage = v
				currentZone = 'spawn'
			end

			if(GetDistanceBetweenCoords(coords, v.DeletePoint.Pos.x, v.DeletePoint.Pos.y, v.DeletePoint.Pos.z, true) < v.Size.x) then
				isInMarker  = true
				this_Garage = v
				currentZone = 'delete'
			end
			if(GetDistanceBetweenCoords(coords, v.MunicipalPoundPoint.Pos.x, v.MunicipalPoundPoint.Pos.y, v.MunicipalPoundPoint.Pos.z, true) < v.MunicipalPoundPoint.Size.x) then
				isInMarker  = true
				this_Garage = v
				currentZone = 'pound'
			end
		end

		if isInMarker and not hasAlreadyEnteredMarker then
			hasAlreadyEnteredMarker = true
			LastZone                = currentZone
			TriggerEvent('eden_garage:hasEnteredMarker', currentZone)
		end

		if not isInMarker and hasAlreadyEnteredMarker then
			hasAlreadyEnteredMarker = false
			TriggerEvent('eden_garage:hasExitedMarker', LastZone)
		end

	end
end)


-- Button press
Citizen.CreateThread(function()
	while true do

		Citizen.Wait(0)

		if CurrentAction ~= nil then

			SetTextComponentFormat('STRING')
			AddTextComponentString(CurrentActionMsg)
			DisplayHelpTextFromStringLabel(0, 0, 1, -1)

			if IsControlPressed(0,  Keys['E']) and (GetGameTimer() - GUI.Time) > 150 then

				if CurrentAction == 'pound_action_menu' then
					OpenMenuGarage('pound')
				end
				if CurrentAction == 'spawn' then
					OpenMenuGarage('spawn')
				end
				if CurrentAction == 'delete' then
					OpenMenuGarage('delete')
				end


				CurrentAction = nil
				GUI.Time      = GetGameTimer()

			end
		end
	end
end)
-- Fin controle touche
