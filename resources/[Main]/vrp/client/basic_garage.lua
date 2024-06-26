local vehicles = {}

AddEventHandler('quantum-garage:setVehicle', function(vtype, vehicle)
  vehicles[vtype] = vehicle
end)


function tvRP.spawnGarageVehicle(vtype,name,pos) -- vtype is the vehicle type (one vehicle per type allowed at the same time)

  local vehicle = vehicles[vtype]
  if vehicle and not IsVehicleDriveable(vehicle[3]) then -- precheck if vehicle is undriveable
    -- despawn vehicle
    SetVehicleHasBeenOwnedByPlayer(vehicle[3],false)
    Citizen.InvokeNative(0xAD738C3085FE7E11, vehicle[3], false, true) -- set not as mission entity
    SetVehicleAsNoLongerNeeded(Citizen.PointerValueIntInitialized(vehicle[3]))
    Citizen.InvokeNative(0xEA386986E786A54F, Citizen.PointerValueIntInitialized(vehicle[3]))
    vehicles[vtype] = nil
  end

  vehicle = vehicles[vtype]
  if vehicle == nil then
    -- load vehicle model
    local mhash = GetHashKey(name)

    local i = 0
    while not HasModelLoaded(mhash) and i < 10000 do
      RequestModel(mhash)
      Citizen.Wait(10)
      i = i+1
    end

    -- spawn car
    if HasModelLoaded(mhash) then
      local x,y,z = tvRP.getPosition()
      if pos then
        x,y,z = table.unpack(pos)
      end

      local nveh = CreateVehicle(mhash, x,y,z+0.5, 0.0, true, false)
      SetVehicleOnGroundProperly(nveh)
      SetEntityInvincible(nveh,false)
      SetPedIntoVehicle(GetPlayerPed(-1),nveh,-1) -- put player inside
      SetVehicleNumberPlateText(nveh, "P "..tvRP.getRegistrationNumber())
      if GetVehicleClass(nveh) == 18 then
        SetVehicleDirtLevel(nveh,0.0)
        TriggerEvent("advancedFuel:setEssence", 100, GetVehicleNumberPlateText(nveh), GetDisplayNameFromVehicleModel(GetEntityModel(nveh)))
      end
      -- Citizen.InvokeNative(0xAD738C3085FE7E11, nveh, true, true) -- set as mission entity
      SetVehicleHasBeenOwnedByPlayer(nveh,true)

      local nid = NetworkGetNetworkIdFromEntity(nveh)
      SetNetworkIdCanMigrate(nid,true)


      vehicles[vtype] = {vtype,name,nveh} -- set current vehicule

      SetModelAsNoLongerNeeded(mhash)
    end
  else
    local cartype = ""
    if vtype == "car" then
      cartype = "bil"
    elseif vtype == "bike" then
      cartype = "motorcykel"
    elseif vtype == "citybike" then
      cartype = "cykel"
    end
    
    TriggerEvent('quantum-notify:notify', 'Ny Notifikation', 'Du kan kun have én ' .. cartype.. ' ude af gangen.', 'error', 5000)
  end
end

function tvRP.despawnGarageVehicle(vtype,max_range)
  local vehicle = vehicles[vtype]
  if vehicle then
    local x,y,z = table.unpack(GetEntityCoords(vehicle[3],true))
    local px,py,pz = tvRP.getPosition()

    if GetDistanceBetweenCoords(x,y,z,px,py,pz,true) < max_range then -- check distance with the vehicule
      -- remove vehicle
      SetVehicleHasBeenOwnedByPlayer(vehicle[3],false)
      Citizen.InvokeNative(0xAD738C3085FE7E11, vehicle[3], false, true) -- set not as mission entity
      SetVehicleAsNoLongerNeeded(Citizen.PointerValueIntInitialized(vehicle[3]))
      Citizen.InvokeNative(0xEA386986E786A54F, Citizen.PointerValueIntInitialized(vehicle[3]))
      vehicles[vtype] = nil
      TriggerEvent('quantum-notify:notify', 'Ny Notifikation', 'Køretøjet er blevet parkeret', 'success', 5000)
    else
        TriggerEvent('quantum-notify:notify', 'Ny Notifikation', 'Du er for langt fra køretøjet', 'error', 5000)
    end
  end
end

function tvRP.despawnNetVehicle(veh)
  if veh then
      veh = NetToVeh(veh)
      SetVehicleHasBeenOwnedByPlayer(veh,false)
      Citizen.InvokeNative(0xAD738C3085FE7E11, veh, false, true) -- set not as mission entity
      SetVehicleAsNoLongerNeeded(Citizen.PointerValueIntInitialized(veh))
      Citizen.InvokeNative(0xEA386986E786A54F, Citizen.PointerValueIntInitialized(veh))
  end
end

-- (experimental) this function return the nearest vehicle
-- (don't work with all vehicles, but aim to)
function tvRP.getNearestVehicle(radius)
  local x,y,z = tvRP.getPosition()
  local ped = GetPlayerPed(-1)
  if IsPedSittingInAnyVehicle(ped) then
    return GetVehiclePedIsIn(ped, true)
  else
    -- flags used:
    --- 8192: boat
    --- 4096: helicos
    --- 4,2,1: cars (with police)

    local veh = GetClosestVehicle(x+0.0001,y+0.0001,z+0.0001, radius+0.0001, 0, 8192+4096+4+2+1)  -- boats, helicos
    if not IsEntityAVehicle(veh) then veh = GetClosestVehicle(x+0.0001,y+0.0001,z+0.0001, radius+0.0001, 0, 4+2+1) end -- cars
    return veh
  end
end

function tvRP.getNearestVehicleHealth(radius)
  local x,y,z = tvRP.getPosition()
  local ped = GetPlayerPed(-1)
  if IsPedSittingInAnyVehicle(ped) then
    return {veh = GetVehiclePedIsIn(ped, true),health = GetVehicleEngineHealth(GetVehiclePedIsIn(ped, true))}
  else
    -- flags used:
    --- 8192: boat
    --- 4096: helicos
    --- 4,2,1: cars (with police)

    local veh = GetClosestVehicle(x+0.0001,y+0.0001,z+0.0001, radius+0.0001, 0, 8192+4096+4+2+1)  -- boats, helicos
    if not IsEntityAVehicle(veh) then veh = GetClosestVehicle(x+0.0001,y+0.0001,z+0.0001, radius+0.0001, 0, 4+2+1) end -- cars
    return {veh = veh,health = GetVehicleEngineHealth(veh)}
  end
end

function tvRP.fixeNearestVehicle(radius)
  local veh = tvRP.getNearestVehicle(radius)
  if IsEntityAVehicle(veh) then
    SetVehicleFixed(veh)
  end
end

function tvRP.lowfixNearestVehicle(veh)
  if IsEntityAVehicle(veh) then
    SetVehicleEngineHealth(veh, 200.0)
  end
end


function tvRP.fixeNearestVehicleAdmin(radius)
    local veh = tvRP.getNearestVehicle(radius)
    local ped = GetPlayerPed(-1)
    if IsEntityAVehicle(veh) then
        if not IsPedSittingInAnyVehicle(ped) then
            SetVehicleFixed(veh)
            TriggerEvent('quantum-notify:notify', 'Ny Notifikation', 'Nærmeste køretøj er repareret.', 'success', 5000)
        else
            TriggerEvent('quantum-notify:notify', 'Ny Notifikation', 'Du må ikke sidde i køretøjet imens du reparerer det', 'error', 5000)
        end
    else
        TriggerEvent('quantum-notify:notify', 'Ny Notifikation', 'Køretøjet blev ikke fundet', 'error', 5000)
    end
end

function tvRP.changeNummerPlate(radius)
    local veh = tvRP.getNearestVehicle(radius)
    if IsEntityAVehicle(veh) then
        local abyte = string.byte("A")
        local zbyte = string.byte("0")

        local format = "DLDLDL"
        local number = ""
        for i=1,#format do
        local char = string.sub(format, i,i)
        if char == "D" then number = number..string.char(zbyte+math.random(0,9))
        elseif char == "L" then number = number..string.char(abyte+math.random(0,25))
        else number = number..char end
        end

        SetVehicleNumberPlateText(veh, "P "..number)
    else
        TriggerEvent('quantum-notify:notify', 'Ny Notifikation', 'Køretøj blev ikke fundet', 'error', 5000)
    end
end

function tvRP.vehicleUnlockMekaniker()
    local ped = PlayerPedId()
    local veh = tvRP.getNearestVehicle(4)
    local plate = GetVehicleNumberPlateText(veh)

    SetVehicleDoorsLockedForAllPlayers(veh, false)
    SetVehicleDoorsLocked(veh, 1)
    SetVehicleDoorsLockedForPlayer(veh, ped, false)
    TriggerEvent('quantum-notify:notify', 'Ny Notifikation', 'Vent seks sekunder før køretøjet er låst op', 'error', 5000)
    Wait(6000)
    TriggerEvent('quantum-notify:notify', 'Ny Notifikation', 'Det nærmeste køretøj er låst op', 'error', 5000)
end

function tvRP.replaceNearestVehicle(radius)
    local veh = tvRP.getNearestVehicle(radius)
    local ped = GetPlayerPed(-1)
    local roll = GetEntityRoll(veh)

    if not IsPedSittingInAnyVehicle(ped) then
        if IsEntityAVehicle(veh) and (roll > 75.0 or roll < -75.0) and GetEntitySpeed(veh) < 2 then
            local heading = GetEntityHeading(veh)
            SetEntityRotation(veh, 0, 0, 0, 0 ,0)
            SetVehicleOnGroundProperly(veh)
            SetEntityHeading(veh, heading)
            TriggerEvent('quantum-notify:notify', 'Ny Notifikation', 'Køretøjet blev vendt om', 'info', 5000)
        end
    end
end

-- try to get a vehicle at a specific position (using raycast)
function tvRP.getVehicleAtPosition(x,y,z)
    x = x+0.0001
    y = y+0.0001
    z = z+0.0001

    local ray = CastRayPointToPoint(x,y,z,x,y,z+4,10,GetPlayerPed(-1),0)
    local a, b, c, d, ent = GetRaycastResult(ray)
    return ent
end

-- return ok,vtype,name
function tvRP.getNearestOwnedVehicle(radius)
    local px,py,pz = tvRP.getPosition()
    
    for k,v in pairs(vehicles) do
        local x,y,z = table.unpack(GetEntityCoords(v[3],true))
        local dist = GetDistanceBetweenCoords(x,y,z,px,py,pz,true)
        if dist <= radius+0.0001 then return true,v[1],v[2] end
    end

    return false,"",""
end

-- return ok,x,y,z
function tvRP.getAnyOwnedVehiclePosition()
  for k,v in pairs(vehicles) do
    if IsEntityAVehicle(v[3]) then
      local x,y,z = table.unpack(GetEntityCoords(v[3],true))
      return true,x,y,z
    end
  end

  return false,0,0,0
end

-- return x,y,z
function tvRP.getOwnedVehiclePosition(vtype)
  local vehicle = vehicles[vtype]
  local x,y,z = 0,0,0

  if vehicle then
    x,y,z = table.unpack(GetEntityCoords(vehicle[3],true))
  end

  return x,y,z
end

-- return ok, vehicule network id
function tvRP.getOwnedVehicleId(vtype)
  local vehicle = vehicles[vtype]
  if vehicle then
    return true, NetworkGetNetworkIdFromEntity(vehicle[3])
  else
    return false, 0
  end
end

-- eject the ped from the vehicle
function tvRP.ejectVehicle()
  local ped = GetPlayerPed(-1)
  if IsPedSittingInAnyVehicle(ped) then
    local veh = GetVehiclePedIsIn(ped,false)
    TaskLeaveVehicle(ped, veh, 4160)
  end
end

-- vehicle commands
local door
function tvRP.vc_toggleDoor(vtype, door_index)
  local vehicle = vehicles[vtype]
  if vehicle then
    if door then
      SetVehicleDoorOpen(vehicle[3],door_index,0,false)
    else
      SetVehicleDoorShut(vehicle[3],door_index,0,false)
    end
    door = not door
  end
end

local door
function tvRP.vc_openDoor(vtype, door_index)
  local vehicle = vehicles[vtype]
  if vehicle then
    if door then
      SetVehicleDoorShut(vehicle[3],door_index,0,false)
    else
      SetVehicleDoorOpen(vehicle[3],door_index)
    end
    door = not door
  end
end

function tvRP.vc_closeDoor(vtype, door_index)
  local vehicle = vehicles[vtype]
  if vehicle then
    SetVehicleDoorShut(vehicle[3],door_index)
  end
end

local neon
function tvRP.vc_NeonToggle(vtype)
  local vehicle = vehicles[vtype]
  if vehicle then
    if neon then
      SetVehicleNeonLightEnabled(vehicle[3],0,false)
      SetVehicleNeonLightEnabled(vehicle[3],1,false)
      SetVehicleNeonLightEnabled(vehicle[3],2,false)
      SetVehicleNeonLightEnabled(vehicle[3],3,false)
    else
      SetVehicleNeonLightEnabled(vehicle[3],0,true)
      SetVehicleNeonLightEnabled(vehicle[3],1,true)
      SetVehicleNeonLightEnabled(vehicle[3],2,true)
      SetVehicleNeonLightEnabled(vehicle[3],3,true)
    end
    neon = not neon
  end
end

function tvRP.vc_detachTrailer(vtype)
  local vehicle = vehicles[vtype]
  if vehicle then
    DetachVehicleFromTrailer(vehicle[3])
  end
end

function tvRP.vc_detachTowTruck(vtype)
  local vehicle = vehicles[vtype]
  if vehicle then
    local ent = GetEntityAttachedToTowTruck(vehicle[3])
    if IsEntityAVehicle(ent) then
      DetachVehicleFromTowTruck(vehicle[3],ent)
    end
  end
end

function tvRP.vc_detachCargobob(vtype)
  local vehicle = vehicles[vtype]
  if vehicle then
    local ent = GetVehicleAttachedToCargobob(vehicle[3])
    if IsEntityAVehicle(ent) then
      DetachVehicleFromCargobob(vehicle[3],ent)
    end
  end
end

function tvRP.vc_toggleEngine(vtype)
  local vehicle = vehicles[vtype]
  if vehicle then
    local running = Citizen.InvokeNative(0xAE31E7DF9B5B132E,vehicle[3]) -- GetIsVehicleEngineRunning
    SetVehicleEngineOn(vehicle[3],not running,true,true)
    if running then
      SetVehicleUndriveable(vehicle[3],true)
    else
      SetVehicleUndriveable(vehicle[3],false)
    end
  end
end

function tvRP.vc_toggleLock(vtype)
  local vehicle = vehicles[vtype]
  if vehicle then
    local ped = GetPlayerPed(-1)
    local veh = vehicle[3]
    local lveh = GetVehiclePedIsUsing(ped)
    TriggerEvent("ftn:carkeys")
    local locked = GetVehicleDoorLockStatus(veh) >= 2
    if locked then -- unlock
      SetVehicleDoorsLockedForAllPlayers(veh, false)
      SetVehicleDoorsLocked(veh,1)
      SetVehicleDoorsLockedForPlayer(veh, ped, false)
      TriggerEvent('quantum-notify:notify', 'Bilnøgler', 'Køretøjet er låst op', 'info', 5000)
    else -- lock
      SetVehicleDoorsLocked(veh,2)
      SetVehicleDoorsLockedForAllPlayers(veh, true)
      TriggerEvent('quantum-notify:notify', 'Bilnøgler', 'Køretøjet er blevet låst', 'info', 5000)
    end
    if not DoesEntityExist(lveh) or lveh ~= veh then
      TriggerServerEvent("InteractSound_SV:PlayWithinDistance", 0.5, "lock", 0.3)
      SetVehicleEngineOn(vehicle[3],true,true,false)
      SetVehicleIndicatorLights(veh, 0, true)
      SetVehicleIndicatorLights(veh, 1, true)
      Wait(3000)
      lveh = GetVehiclePedIsUsing(ped)
      SetVehicleIndicatorLights(veh, 0, false)
      SetVehicleIndicatorLights(veh, 1, false)
      if not DoesEntityExist(lveh) or lveh ~= veh then
        SetVehicleEngineOn(vehicle[3],false,true,false)
      end
    else
      if locked then
        TriggerServerEvent("InteractSound_SV:PlayWithinDistance", 2, "pressunlock", 0.4)
      else
        TriggerServerEvent("InteractSound_SV:PlayWithinDistance", 2, "presslock", 0.4)
      end
    end
  end
end
