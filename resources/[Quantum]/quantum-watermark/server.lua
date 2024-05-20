vRP = exports['vrp']:getObject()


RegisterServerEvent("GetID:server")
AddEventHandler("GetID:server", function()
    local src = source
    local user_id = vRP.getUserId(src)
    
    TriggerClientEvent("GetID:client", src, user_id or "?")
end)
