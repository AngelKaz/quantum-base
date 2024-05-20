
RegisterCommand("revive", function(src, args)
    local target = vRP.getUserId(src)
    
    if vRP.hasPermission(target, "ledelse.fix") then
        if args[1] ~= '' and args[1] ~= ' ' and tonumber(args[1]) ~= nil then
            target = tonumber(args[1])
        end

        if target ~= nil then
            vRP.varyHunger(target, -100)
            vRP.varyThirst(target, -100)
            TriggerClientEvent('quantum-commands:setHealth', vRP.getUserSource(target))
        end
    end
end)
