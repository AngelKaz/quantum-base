local delay     = config.delay * 600000
local prefix    = config.prefix
local messages  = config.messages

CreateThread(function()
    while true do
        for a = 1, #config.messages do
            TriggerEvent('chat:addMessage', {args = { prefix .. messages[a] }})
            Wait(delay)
        end

        Wait(0)
    end
end)