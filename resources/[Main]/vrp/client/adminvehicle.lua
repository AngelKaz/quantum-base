local distanceToCheck = 5.0

RegisterNetEvent('hp:deletevehicle',function()
    local ped = PlayerPedId()

    if (DoesEntityExist(ped) and not IsEntityDead(ped)) then 
        local pos = GetEntityCoords(ped)

        if (IsPedSittingInAnyVehicle(ped)) then 
            local vehicle = GetVehiclePedIsIn(ped,false)

            if (GetPedInVehicleSeat(vehicle,-1) == ped) then 
                SetEntityAsMissionEntity(vehicle,true,true)
                deleteCar(vehicle)

                if (DoesEntityExist(vehicle)) then 
                    TriggerEvent('quantum-notify:notify', 'Admin Notifikation', 'Kunne ikke slette køretøjet, prøv igen', 'info', 5000)
				else 
                    TriggerEvent('quantum-notify:notify', 'Admin Notifikation', 'Køretøjet er blevet slettet', 'info', 5000)
                end 
			else 
                TriggerEvent('quantum-notify:notify', 'Admin Notifikation', 'Du skal sidde i føresædet for at slette køretøjet', 'info', 5000)
            end 
        else
            local playerPos = GetEntityCoords(ped, 1)
            local inFrontOfPlayer = GetOffsetFromEntityInWorldCoords(ped,0.0,distanceToCheck,0.0)
            local vehicle = GetVehicleInDirection(playerPos,inFrontOfPlayer)

            if (DoesEntityExist(vehicle)) then 
                SetEntityAsMissionEntity(vehicle,true,true)
                deleteCar(vehicle)

                if (DoesEntityExist(vehicle)) then
                    return TriggerEvent('quantum-notify:notify', 'Admin Notifikation', 'Kunne ikke slette køretøjet, prøv igen', 'info', 5000)
				else 

                TriggerEvent('quantum-notify:notify', 'Admin Notifikation', 'Køretøjet er blevet slettet', 'info', 5000)
			else 
                TriggerEvent('quantum-notify:notify', 'Admin Notifikation', 'Du skal være i nærheden af køretøjet eller i føresædet', 'info', 5000)
            end 
        end 
    end 
end)

function deleteCar(entity)
    Citizen.InvokeNative(0xEA386986E786A54F,Citizen.PointerValueIntInitialized(entity))
end

function GetVehicleInDirection(coordFrom,coordTo)
    local rayHandle = CastRayPointToPoint(coordFrom.x,coordFrom.y,coordFrom.z,coordTo.x,coordTo.y,coordTo.z,10,GetPlayerPed(-1),0)
    local _,_,_,_,vehicle = GetRaycastResult(rayHandle)
    return vehicle
end

function ShowNotification(text)
    SetNotificationTextEntry("STRING")
    AddTextComponentString(text)
    DrawNotification(false,false)
end

RegisterNetEvent('hp:spawnvehicle')
AddEventHandler('hp:spawnvehicle',function(car)
  local mhash = GetHashKey(car)

  local i = 0
  while not HasModelLoaded(mhash) and i < 10000 do
    RequestModel(mhash)
    Citizen.Wait(10)
    i = i+1
  end

  -- spawn car
  if HasModelLoaded(mhash) then
    local x,y,z = table.unpack(GetEntityCoords(GetPlayerPed(-1),true))
    local nveh = CreateVehicle(mhash, x,y,z+0.5, GetEntityHeading(GetPlayerPed(-1)), true, false) -- added player heading
    SetVehicleOnGroundProperly(nveh)
    SetEntityInvincible(nveh,false)
    SetPedIntoVehicle(GetPlayerPed(-1),nveh,-1) -- put player inside
    SetEntityAsMissionEntity(nveh, true, true) -- set as mission entity
	  
	Citizen.CreateThread(function()
	    Citizen.Wait(1000)
		TriggerEvent("advancedFuel:setEssence", 100, GetVehicleNumberPlateText(GetVehiclePedIsUsing(GetPlayerPed(-1))), GetDisplayNameFromVehicleModel(GetEntityModel(GetVehiclePedIsUsing(GetPlayerPed(-1)))))
	end)

    SetModelAsNoLongerNeeded(mhash)
    TriggerEvent('quantum-notify:notify', 'Admin Notifikation', 'Køretøj Spawned', 'info', 5000)
  end
end)