RegisterCommand("fix", function(source)
    local user_id = vRP.getUserId(source)

    if vRP.hasPermission(user_id,"ledelse.fix") then
        TriggerClientEvent('quantum-commands:fix', source)
    end
end)