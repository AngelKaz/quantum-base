CreateThread(function()
    while true do
        Wait(3)

        local ped = PlayerPedId()
        local vehtypes = {"car", "bike", "citybike", "default"}
        
        if IsControlPressed(0,182) then
            local closeVeh = tvRP.getNearestOwnedVehicle(5)

            if closeVeh ~= false then
                if not ok then
                    for _,v in pairs(vehtypes) do
                        tvRP.vc_toggleLock(v)
                    end
                    
                    Wait(2000)
                else
                    Wait(2000)
                end
            end
        end

        if IsControlPressed(0,167) then
            local closeVeh = tvRP.getNearestOwnedVehicle(5)
            if closeVeh ~= false then
                if IsPedInAnyVehicle(ped, true) then
                    local veh = "car"
                    tvRP.vc_NeonToggle(veh)
                    Wait(1000)
                else
                    Wait(500)
                end
            end
        end
    end
end)