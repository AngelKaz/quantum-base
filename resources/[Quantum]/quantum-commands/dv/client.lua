RegisterNetEvent('quantum-commands:fixveh', function()
    local ped = PlayerPedId()

    if IsPedSittingInAnyVehicle(ped) then 
        local vehicle = GetVehiclePedIsIn(ped, false)

        if GetPedInVehicleSeat(vehicle, -1) == ped then 
            SetEntityAsMissionEntity(vehicle, true, true)
            deleteCar(vehicle)

            if DoesEntityExist(vehicle) then 
                exports['quantum-notify']:notify('Admin Notifikation', 'Kunne ikke fjerne køretøjet.. Prøv igen.', 'error', 5000)
            else
                exports['quantum-notify']:notify('Admin Notifikation', 'Køretøj fjernet.', 'info', 5000)
            end 
        else 
            exports['quantum-notify']:notify('Admin Notifikation', 'Du skal sidde på forsædet i bilen.', 'error', 5000)
        end 
    else
        exports['quantum-notify']:notify('Admin Notifikation', 'Du skal sidde i et køretøj for at fjerne det.', 'error', 5000)
    end 
end)


function deleteCar(entity)
    Citizen.InvokeNative(0xEA386986E786A54F, Citizen.PointerValueIntInitialized(entity))
end