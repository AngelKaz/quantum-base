vRP = exports['vrp']:getObject()
local cfg = module("vrp-chat", "cfg/config")

RegisterServerEvent('vrp-chat:chat_message')
AddEventHandler('vrp-chat:chat_message', function(source,author,message)
    local user_id = vRP.getUserId(source)
    local staff = false

    if vRP.hasPermission(user_id,cfg.notifyStaffPerm) then
        staff = true
    else
        TriggerClientEvent('chatMessage', source, "OOC ^7| ^5SPILLER ^7| "..user_id.." ^7| " ..author..": ^1" ..  message)
    end

    local users = vRP.getUsers()

    for k,v in pairs(users) do
        if v ~= nil then
            if vRP.hasPermission(k,cfg.notifyStaffPerm) then
                if staff then
                    TriggerClientEvent('chatMessage', v, "^1STAFFCHAT ^7| "..user_id.." ^7| " ..author..": ^1" ..  message)
                else
                    TriggerClientEvent('chatMessage', v, "^3HJÆLP ^7| ^5SPILLER ^7| "..user_id.." ^7| " ..author..": ^1" ..  message)
                end
            end
        end
    end
end)