RegisterNetEvent("quantum-commands:setHealth", function()
    SetEntityHealth(PlayerPedId(), 200)
    Wait(1000)
    SetEntityHealth(PlayerPedId(), 200)
end)