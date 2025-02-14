ESX  = nil
TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
ESX.RegisterUsableItem('radio', function(source)
	local xPlayer = ESX.GetPlayerFromId(source)
  TriggerClientEvent('ls-radio:use', source)
end)

ESX.RegisterServerCallback('ls-radio:getItemAmount', function(source, cb, item)
  local xPlayer = ESX.GetPlayerFromId(source)
  local items = xPlayer.getInventoryItem(item)
  
  if items == nil then
      cb(0)
  else
    cb(items.count)
  end
end)

Citizen.CreateThread(function()
  while true do
    Citizen.Wait(1000)
    local xPlayers = ESX.GetPlayers()
    for i=1, #xPlayers, 1 do
      local xPlayer = ESX.GetPlayerFromId(xPlayers[i])
      if xPlayer ~= nil then
        if xPlayer.getInventoryItem('radio').count == 0 then
        local source = xPlayers[i]
        TriggerClientEvent('ls-radio:onRadioDrop', source)
          break
        end
      end
    end
  end
end)