CreateThread(function()
    while true do
        TriggerServerEvent("GetID:server")
        Wait(1000)
    end
end)
  
  
RegisterNetEvent("GetID:client")
AddEventHandler("GetID:client", function(id)
    local spillere = #GetActivePlayers()
    
    SendNUIMessage({
        id = id,
        spillere = spillere,
    })
end)
