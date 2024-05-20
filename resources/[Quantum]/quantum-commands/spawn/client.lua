RegisterNetEvent("quantum-commands:spawn", function(veh)
    if veh == nil or veh == '' or veh == ' ' then
        exports['quantum-notify']:notify('Admin Notifikation', 'Kunne ikke fjerne køretøjet.. Prøv igen.', 'error', 5000)
    end

    local vehHash = GetHashKey(veh)
    RequestModel(vehHash)
    while not HasModelLoaded(vehHash) do
        Wait(75)
    end

    local ped = PlayerPedId()
    local vehicle = CreateVehicle(vehHash, GetEntityCoords(ped), GetEntityHeading(ped), true, false)
    TaskWarpPedIntoVehicle(ped, vehicle, -1)
    SetVehicleEngineHealth(vehicle, 9999)
    SetVehiclePetrolTankHealth(vehicle, 9999)
    SetVehicleFixed(vehicle)
end)