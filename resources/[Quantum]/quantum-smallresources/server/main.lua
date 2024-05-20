RegisterNetEvent('quantum-smallresources:kickAFKuser', function()
    local src = source
    DropPlayer(src, '[Quantum] Du har været AFK i 15 minutter')
end)