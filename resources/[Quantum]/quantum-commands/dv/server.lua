vRP = exports['vrp']:getObject()

RegisterCommand('dv', function(source)
    delVeh(source)
end)

RegisterCommand('delveh', function(source)
    delVeh(source)
end)

function delVeh(src)
    local user_id = vRP.getUserId(src)

    if vRP.hasPermission(user_id, "ledelse.fix") then
        TriggerClientEvent('quantum-commands:fixveh', src )
    end
end