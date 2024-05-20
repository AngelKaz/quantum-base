-- ALL DEVO MISC IN 1 SCRIPT
local zones = { 
	{ ['x'] = 1641.78, ['y'] = 2641.07, ['z'] = 32.65}
}


CreateThread(function()
    RequestIpl("shr_int")
end)

CreateThread(function()
    local dict = "anim@mp_player_intmenu@key_fob@"
    local thumbsUpDict = "anim@mp_player_intincarthumbs_upbodhi@ps@"

    RequestAnimDict(dict)
    
    while not HasAnimDictLoaded(dict) do
        Wait(100)
    end

    local lock = false
        
    RequestAnimDict(thumbsUpDict)
    while not HasAnimDictLoaded(thumbsUpDict) do
        Wait(100)
    end
    local thumbsup = false

	while true do
		Wait(0)
        local id = PlayerId()
        local ped = PlayerPedId()
        local coords = GetEntityCoords(PlayerPedId())
        local car = GetVehiclePedIsIn(ped, false)

        -- Disable Car Rewards
		DisablePlayerVehicleRewards(id)	
	
        
        -- Disable HUD
        HideHudComponentThisFrame(6)
		HideHudComponentThisFrame(7)
		HideHudComponentThisFrame(8)
        HideHudComponentThisFrame(9)

        ClearPlayerWantedLevel(PlayerId())
        SetPlayerWantedLevelNow(PlayerId(),false)

        -- Remove Shop Cars

		if GetDistanceBetweenCoords(coords, -33.7, -1102.01, 26.42, true) < 1 then
			ClearAreaOfVehicles(-337, -1102.01, 26.42, 50.0, false, false, false, false, false)
		end

		if GetDistanceBetweenCoords(coords, -2123.46, 3098.64, 32.83, true) < 350 then
			ClearAreaOfVehicles(-2123.46, 3098.64, 32.83, 400.0, false, false, false, false, false)
		end

        -- Car Clean Up
        
        if car then
            Citizen.InvokeNative(0xB736A491E64A32CF, Citizen.PointerValueIntInitialized(car))
        end

        -- Anim-Lock
        if IsControlJustPressed(1, 182) then ---L
            if not lock then
                TaskPlayAnim(ped, dict, "fob_click_fp", 8.0, 8.0, -1, 48, 1, false, false, false)
                StopAnimTask = true
            end
        end

        -- Thumbs Up
        if IsControlPressed(0, 246) then
            if not thumbsup then
                TaskPlayAnim(ped, thumbsUpDict, "enter", 8.0, 8.0, -1, 50, 0, false, false, false)
                thumbsup = true
            else
                thumbsup = false
                ClearPedTasks(ped)
            end
        end
    end
end)

Citizen.CreateThread(function()
    local dict = "missminuteman_1ig_2"
    
	RequestAnimDict(dict)
	while not HasAnimDictLoaded(dict) do
		Citizen.Wait(100)
	end
    local handsup = false
	while true do
		Citizen.Wait(0)
		if IsControlJustPressed(1, 323) then --Start holding X
            if not handsup then
                TaskPlayAnim(GetPlayerPed(-1), dict, "handsup_enter", 8.0, 8.0, -1, 50, 0, false, false, false)
                handsup = true
            else
                handsup = false
                ClearPedTasks(GetPlayerPed(-1))
            end
        end
    end
end)
	


CreateThread(function()
	while not NetworkIsPlayerActive(PlayerId()) do
		Wait(100)
	end
	
	while true do
		local playerPed = GetPlayerPed(-1)
		local x, y, z = table.unpack(GetEntityCoords(playerPed, true))
		local minDistance = 100000
		for i = 1, #zones, 1 do
			dist = Vdist(zones[i].x, zones[i].y, zones[i].z, x, y, z)
			if dist < minDistance then
				minDistance = dist
				closestZone = i
			end
		end

		Wait(100)
	end
end)

CreateThread(function()
	while not NetworkIsPlayerActive(PlayerId()) do
	
		Wait(100)
	end
	
	while true do
		Wait(100)
		local player = GetPlayerPed(-1)
		local x,y,z = table.unpack(GetEntityCoords(player, true))
		local veh = GetVehiclePedIsUsing(ped)
		local dist = Vdist(zones[closestZone].x, zones[closestZone].y, zones[closestZone].z, x, y, z)
	
		if dist <= 250.0 then  
			if not jailOut then	
				SetPlayerInvincible(GetPlayerIndex(), true)
				SetEntityHealth(player, 2000)
			end
		else
			if not jailIn then
				SetPlayerInvincible(GetPlayerIndex(), false)	
			end
	 	end
	end
end)


CreateThread(function() 
    TriggerEvent('chat:addSuggestion', '/discord', 'Viser discord link.') 
end)

RegisterCommand("discord", function(source, args, rawCommandString)
    TriggerEvent('chatMessage', "[Quantum]", { 128, 128, 128 }, "Discord link | https://discord.gg/5QU2h6MFju")
end, false)

-- Discord Rich Prescence --
CreateThread(function()
	while true do
		SetDiscordAppId(1230208784744321054)
        SetRichPresence("Quantum")
		SetDiscordRichPresenceAsset('quantum')
        SetDiscordRichPresenceAction(0, 'Discord', 'https://discord.gg/5QU2h6MFju')

		Wait(60000)
    end
end)


local BONES = {
	--[[Pelvis]][11816] = true,
	--[[SKEL_L_Thigh]][58271] = true,
	--[[SKEL_L_Calf]][63931] = true,
	--[[SKEL_L_Foot]][14201] = true,
	--[[SKEL_L_Toe0]][2108] = true,
	--[[IK_L_Foot]][65245] = true,
	--[[PH_L_Foot]][57717] = true,
	--[[MH_L_Knee]][46078] = true,
	--[[SKEL_R_Thigh]][51826] = true,
	--[[SKEL_R_Calf]][36864] = true,
	--[[SKEL_R_Foot]][52301] = true,
	--[[SKEL_R_Toe0]][20781] = true,
	--[[IK_R_Foot]][35502] = true,
	--[[PH_R_Foot]][24806] = true,
	--[[MH_R_Knee]][16335] = true,
	--[[RB_L_ThighRoll]][23639] = true,
	--[[RB_R_ThighRoll]][6442] = true,
}


CreateThread(function()
	while true do
		Wait(0)
		local ped = PlayerPedId()
        local playerVeh = GetVehiclePedIsIn(ped, false)

		if HasEntityBeenDamagedByAnyPed(ped) then
			Disarm(ped)
		end
		ClearEntityLastDamageEntity(ped)


		if DoesEntityExist(playerVeh) then
			DisplayRadar(true)
		else
			DisplayRadar(false)
		end

        if IsPedBeingStunned(ped) then
		    SetPedMinGroundTimeForStungun(ped, 5000)
		end
	 end
end)



function Bool (num) return num == 1 or num == true end

-- WEAPON DROP OFFSETS
local function GetDisarmOffsetsForPed (ped)
	local v

	if IsPedWalking(ped) then v = { 0.6, 4.7, -0.1 }
	elseif IsPedSprinting(ped) then v = { 0.6, 5.7, -0.1 }
	elseif IsPedRunning(ped) then v = { 0.6, 4.7, -0.1 }
	else v = { 0.4, 4.7, -0.1 } end

	return v
end

function Disarm (ped)
	if IsEntityDead(ped) then return false end

	local boneCoords
	local hit, bone = GetPedLastDamageBone(ped)

	hit = Bool(hit)

	if hit then
		if BONES[bone] then
			

			boneCoords = GetWorldPositionOfEntityBone(ped, GetPedBoneIndex(ped, bone))
			SetPedToRagdoll(GetPlayerPed(-1), 5000, 5000, 0, 0, 0, 0)
			

			return true
		end
	end

	return false
end



---- AFK ----
secondsUntilKick = 15 * 60

-- Warn players if 3/4 of the Time Limit ran up
kickWarning = true

-- CODE --

CreateThread(function()
	while true do
		Wait(1000)

		playerPed = PlayerPedId()
		if playerPed then
			currentPos = GetEntityCoords(playerPed, true)

			if currentPos == prevPos then
				if time > 0 then
					if kickWarning and time == math.ceil(secondsUntilKick / 4) then
						TriggerEvent("chatMessage", "Advarsel", {255, 0, 0}, "^1Du bliver kicked om " .. time .. " sec for at være AFK!")
					end

					time = time - 1
				else
					TriggerServerEvent("quantum-smallresources:kickAFKuser")
				end
			else
				time = secondsUntilKick
			end

			prevPos = currentPos
		end
	end
end)

CreateThread(function()
    SetRelationshipBetweenGroups(1, GetHashKey("AMBIENT_GANG_HILLBILLY"), GetHashKey('PLAYER'))
    SetRelationshipBetweenGroups(1, GetHashKey("AMBIENT_GANG_BALLAS"), GetHashKey('PLAYER'))
    SetRelationshipBetweenGroups(1, GetHashKey("AMBIENT_GANG_MEXICAN"), GetHashKey('PLAYER'))
    SetRelationshipBetweenGroups(1, GetHashKey("AMBIENT_GANG_FAMILY"), GetHashKey('PLAYER'))
    SetRelationshipBetweenGroups(1, GetHashKey("AMBIENT_GANG_MARABUNTE"), GetHashKey('PLAYER'))
    SetRelationshipBetweenGroups(1, GetHashKey("AMBIENT_GANG_SALVA"), GetHashKey('PLAYER'))
    SetRelationshipBetweenGroups(1, GetHashKey("GANG_1"), GetHashKey('PLAYER'))
    SetRelationshipBetweenGroups(1, GetHashKey("GANG_2"), GetHashKey('PLAYER'))
    SetRelationshipBetweenGroups(1, GetHashKey("GANG_9"), GetHashKey('PLAYER'))
    SetRelationshipBetweenGroups(1, GetHashKey("GANG_10"), GetHashKey('PLAYER'))
    SetRelationshipBetweenGroups(1, GetHashKey("FIREMAN"), GetHashKey('PLAYER'))
    SetRelationshipBetweenGroups(1, GetHashKey("MEDIC"), GetHashKey('PLAYER'))
    SetRelationshipBetweenGroups(1, GetHashKey("COP"), GetHashKey('PLAYER'))
end)

local crouched = false

CreateThread(function()
    while true do 
        Wait(1)

        RemoveAllPickupsOfType(0xDF711959)
        RemoveAllPickupsOfType(0xF9AFB48F)
        RemoveAllPickupsOfType(0xA9355DCD)

        local ped = PlayerPedId()

        if (DoesEntityExist(ped) and not IsEntityDead(ped)) then 
            DisableControlAction( 0, 36, true )

            if (not IsPauseMenuActive()) then 
                if (IsDisabledControlJustPressed( 0, 36 )) then 
                    RequestAnimSet("move_ped_crouched")

                    while (not HasAnimSetLoaded( "move_ped_crouched")) do 
                        Wait( 100 )
                    end 

                    if (crouched == true) then 
                        ResetPedMovementClipset( ped, 0 )
                        crouched = false 
                    elseif (crouched == false) then
                        SetPedMovementClipset(ped, "move_ped_crouched", 0.25)
                        crouched = true 
                    end 
                end
            end 
        end 
    end
end)

local mp_pointing = false
local keyPressed = false

local function startPointing()
    local ped = GetPlayerPed(-1)
    RequestAnimDict("anim@mp_point")
    while not HasAnimDictLoaded("anim@mp_point") do
        Wait(0)
    end
    SetPedCurrentWeaponVisible(ped, 0, 1, 1, 1)
    SetPedConfigFlag(ped, 36, 1)
    Citizen.InvokeNative(0x2D537BA194896636, ped, "task_mp_pointing", 0.5, 0, "anim@mp_point", 24)
    RemoveAnimDict("anim@mp_point")
end

local function stopPointing()
    local ped = GetPlayerPed(-1)
    Citizen.InvokeNative(0xD01015C7316AE176, ped, "Stop")
    if not IsPedInjured(ped) then
        ClearPedSecondaryTask(ped)
    end
    if not IsPedInAnyVehicle(ped, 1) then
        SetPedCurrentWeaponVisible(ped, 1, 1, 1, 1)
    end
    SetPedConfigFlag(ped, 36, 0)
    ClearPedSecondaryTask(PlayerPedId())
end

local once = true
local oldval = false
local oldvalped = false

Citizen.CreateThread(function()
    while true do
        Wait(0)

        if once then
            once = false
        end

        if not keyPressed then
            if IsControlPressed(0, 29) and not mp_pointing and IsPedOnFoot(PlayerPedId()) then
                Wait(200)
                if not IsControlPressed(0, 29) then
                    keyPressed = true
                    startPointing()
                    mp_pointing = true
                else
                    keyPressed = true
                    while IsControlPressed(0, 29) do
                        Wait(50)
                    end
                end
            elseif (IsControlPressed(0, 29) and mp_pointing) or (not IsPedOnFoot(PlayerPedId()) and mp_pointing) then
                keyPressed = true
                mp_pointing = false
                stopPointing()
            end
        end

        if keyPressed then
            if not IsControlPressed(0, 29) then
                keyPressed = false
            end
        end
        if Citizen.InvokeNative(0x921CE12C489C4C41, PlayerPedId()) and not mp_pointing then
            stopPointing()
        end
        if Citizen.InvokeNative(0x921CE12C489C4C41, PlayerPedId()) then
            if not IsPedOnFoot(PlayerPedId()) then
                stopPointing()
            else
                local ped = GetPlayerPed(-1)
                local camPitch = GetGameplayCamRelativePitch()
                if camPitch < -70.0 then
                    camPitch = -70.0
                elseif camPitch > 42.0 then
                    camPitch = 42.0
                end
                camPitch = (camPitch + 70.0) / 112.0

                local camHeading = GetGameplayCamRelativeHeading()
                local cosCamHeading = Cos(camHeading)
                local sinCamHeading = Sin(camHeading)
                if camHeading < -180.0 then
                    camHeading = -180.0
                elseif camHeading > 180.0 then
                    camHeading = 180.0
                end
                camHeading = (camHeading + 180.0) / 360.0

                local blocked = 0
                local nn = 0

                local coords = GetOffsetFromEntityInWorldCoords(ped, (cosCamHeading * -0.2) - (sinCamHeading * (0.4 * camHeading + 0.3)), (sinCamHeading * -0.2) + (cosCamHeading * (0.4 * camHeading + 0.3)), 0.6)
                local ray = Cast_3dRayPointToPoint(coords.x, coords.y, coords.z - 0.2, coords.x, coords.y, coords.z + 0.2, 0.4, 95, ped, 7);
                nn,blocked,coords,coords = GetRaycastResult(ray)

                Citizen.InvokeNative(0xD5BB4025AE449A4E, ped, "Pitch", camPitch)
                Citizen.InvokeNative(0xD5BB4025AE449A4E, ped, "Heading", camHeading * -1.0 + 1.0)
                Citizen.InvokeNative(0xB0A6CFD2C69C1088, ped, "isBlocked", blocked)
                Citizen.InvokeNative(0xB0A6CFD2C69C1088, ped, "isFirstPerson", Citizen.InvokeNative(0xEE778F8C7E1142E2, Citizen.InvokeNative(0x19CAFA3C87F7C2FF)) == 4)

            end
        end
    end
end)

CreateThread(function()
    Citizen.InvokeNative(GetHashKey("ADD_TEXT_ENTRY"), 'FE_THDR_GTAO', 'Quantum')
end)

Citizen.CreateThread(function()
    local vehicleModels = {
        "ambulance", "firetruk", "polmav", "police", "police2", "police3", "police4", "fbi", "fbi2", "policet", "policeb", "riot", "apc", "barracks", "barracks2", "barracks3", "rhino", "hydra", "lazer", "valkyrie", 
        "valkyrie2", "savage", "trailersmall2", "barrage", "chernobog", "khanjali", "menacer", "scarab", "scarab2", "scarab3", "armytanker", "avenger", "avenger2", "tula", "bombushka", "molotok", "volatol", "starling", 
        "mogul", "nokota", "strikeforce", "rogue", "cargoplane", "jet", "buzzard", "besra", "titan", "cargobob", "cargobob2", "cargobob3", "cargobob4", "akula", "hunt"
    }

    local pedModels = {
        "s_m_m_paramedic_01", "s_m_m_paramedic_02", "s_m_y_fireman_01", "s_m_y_pilot_01", "s_m_y_cop_01", "s_m_y_cop_02", "s_m_y_swat_01", "s_m_y_hwaycop_01", "s_m_y_marine_01", "s_m_y_marine_02", "s_m_y_marine_03", 
        "s_m_m_marine_01", "s_m_m_marine_02"
    }

    for _, modelName in ipairs(vehicleModels) do
        SetVehicleModelIsSuppressed(GetHashKey(modelName), true)
    end

    for _, modelName in ipairs(pedModels) do
        SetPedModelIsSuppressed(GetHashKey(modelName), true)
    end

    while true do
        Wait(1250)

        local playerPed = GetPlayerPed(-1)
        local playerLocalisation = GetEntityCoords(playerPed)
        ClearAreaOfCops(playerLocalisation.x, playerLocalisation.y, playerLocalisation.z, 400.0)

        local vehicles = GetGamePool("CVehicle")
        for i = 1, #vehicles do
            local vehicle = vehicles[i]
            local model = GetEntityModel(vehicle)

            for _, modelName in ipairs(vehicleModels) do
                if model == GetHashKey(modelName) then
                    SetEntityAsMissionEntity(vehicle, true, true)
                    DeleteVehicle(vehicle)
                    break
                end
            end
        end

        local peds = GetGamePool("CPed")
        for i = 1, #peds do
            local ped = peds[i]
            local model = GetEntityModel(ped)

            for _, modelName in ipairs(pedModels) do
                if model == GetHashKey(modelName) then
                    SetEntityAsMissionEntity(ped, true, true)
                    DeletePed(ped)
                    break
                end
            end
        end
    end
end)