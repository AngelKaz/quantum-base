vRP = exports['vrp']:getObject()


RegisterServerEvent('taxi:update')
AddEventHandler('taxi:update', function(veh)
  local user_id = vRP.getUserId(source)
  local src = vRP.getUserSource(user_id)

  TriggerClientEvent("taxi:updatefare", src, veh)
end)

RegisterServerEvent('taxi:syncmeter')
AddEventHandler('taxi:syncmeter', function(veh)
  local user_id = vRP.getUserId(source)
  local src = vRP.getUserSource(user_id)

  TriggerClientEvent("taxi:updatefare", src, veh)
end)