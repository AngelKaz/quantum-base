
RegisterCommand("addgroup", function(src, args)
    if src ~= 0 then return end

    local user_id = args[1]
    local group = args[2]

    vRP.addUserGroup(tonumber(user_id), group)
end)
