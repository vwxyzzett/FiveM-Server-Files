ESX = nil

if Config.UseESX then
	TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

	RegisterServerEvent('alttab_advanced_fuel:pay')
	AddEventHandler('alttab_advanced_fuel:pay', function(price)
		local xPlayer = ESX.GetPlayerFromId(source)
		local amount = ESX.Math.Round(price)

		if price > 0 then
			xPlayer.removeMoney(amount)
		end
	end)
end
