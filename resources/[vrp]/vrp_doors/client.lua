local LockHotkey = {0,38}
local doors = {}

RegisterNetEvent('vrp_doors:load')
AddEventHandler('vrp_doors:load', function(list)
    doors = list
end)

RegisterNetEvent('vrp_doors:statusSend')
AddEventHandler('vrp_doors:statusSend', function(id,status)
    doors[id].locked = status
end)


CreateThread(function()
    while true do
        Wait(1)
        local coords = GetEntityCoords(PlayerPedId(),true)

        for k,v in pairs(doors) do
            local lradius = (v.range ~= nil and v.range or 2.0)
            if GetDistanceBetweenCoords(coords.x, coords.y, coords.z, v.coords[1], v.coords[2], v.coords[3], true) <= lradius then
                local closeDoor = GetClosestObjectOfType(v.coords[1], v.coords[2], v.coords[3], lradius, v.hash or GetHashKey(v.objName), false, false, false)
                if closeDoor ~= 0 then
                    if v.locked then
                        DrawText3Ds(v.coords[1], v.coords[2], v.coords[3], "Tryk ~g~E~w~ for at låse op")
                        local locked, heading = GetStateOfClosestDoorOfType(v.hash, v.coords[1], v.coords[2], v.coords[3], v.locked, 0)
                        if heading > -0.01 and heading < 0.01 then
                            FreezeEntityPosition(closeDoor, v.locked)
                        end
                    else
                        DrawText3Ds(v.coords[1], v.coords[2], v.coords[3], "Tryk ~r~E~w~ for at låse")
                        FreezeEntityPosition(closeDoor, v.locked)
                    end
                    if IsControlJustReleased(table.unpack(LockHotkey)) then
                        toggleClosestDoor()
                    end
                end
            end
        end
    end
end)

function toggleClosestDoor()
    local x,y,z = table.unpack(GetEntityCoords(PlayerPedId(), true))
    for k,v in pairs(doors) do
        if v.close ~= nil then
            local door1 = GetDistanceBetweenCoords(GetEntityCoords(GetPlayerPed(-1)), v.coords[1], v.coords[2], v.coords[3], true )
            local lradius = (v.range ~= nil and v.range or 2.0)
            if door1 < lradius then
                if door1 < GetDistanceBetweenCoords(x,y,z,doors[v.close].coords[1], doors[v.close].coords[2], doors[v.close].coords[3],true) then
                    TriggerServerEvent("vrp_doors:status", k, not v.locked)
                else
                    TriggerServerEvent("vrp_doors:status", v.close, not doors[v.close].locked)
                end
                break
            end
        else
            local lradius = (v.range ~= nil and v.range or 2.0)
            if GetDistanceBetweenCoords(x,y,z,v.coords[1], v.coords[2], v.coords[3],true) <= lradius then
                TriggerServerEvent("vrp_doors:status", k, not v.locked)
            end
        end
    end
end

function DrawText3Ds(x,y,z, text)
    local onScreen,_x,_y=World3dToScreen2d(x,y,z)
    local px,py,pz=table.unpack(GetGameplayCamCoords())

    SetTextScale(0.32, 0.32)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextColour(255, 255, 255, 255)
    SetTextEntry("STRING")
    SetTextCentre(1)
    AddTextComponentString(text)
    DrawText(_x,_y)
    local factor = (string.len(text)) / 370
    DrawRect(_x,_y+0.0125, 0.015+ factor, 0.03, 0, 0, 0, 80)
end