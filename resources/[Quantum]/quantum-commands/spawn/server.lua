RegisterCommand("spawn", function(source, args)
    local user_id = vRP.getUserId(source)
    local veh = args[1]

    if vRP.hasPermission(user_id, "ledelse.fix") then
        print(veh)
        TriggerClientEvent('quantum-commands:spawn', source, veh)
    end
end)