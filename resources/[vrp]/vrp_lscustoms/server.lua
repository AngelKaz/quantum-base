local Tunnel = module("vrp", "lib/Tunnel")
local Proxy = module("vrp", "lib/Proxy")

vRP = exports['vrp']:getObject()
vRPclient = Tunnel.getInterface("vRP","vRP_lscustoms")

local tbl = {
	[1] = {locked = false},
	[2] = {locked = false},
	[3] = {locked = false},
	[4] = {locked = false},
	[5] = {locked = false},
}
RegisterServerEvent('lockGarage')
AddEventHandler('lockGarage', function(b,garage)
	tbl[tonumber(garage)].locked = b
	TriggerClientEvent('lockGarage',-1,tbl)
	--print(json.encode(tbl))
end)
RegisterServerEvent('getGarageInfo')
AddEventHandler('getGarageInfo', function()
TriggerClientEvent('lockGarage',-1,tbl)
--print(json.encode(tbl))
end)

RegisterServerEvent('lscustoms:payGarageDN')
AddEventHandler('lscustoms:payGarageDN', function(button)
  local user_id = vRP.getUserId(source)
  local player = vRP.getUserSource(user_id)
  if button.costs ~= nil then
	if vRP.tryFullPayment(user_id,tonumber(button.costs)) then 
	  TriggerClientEvent("lscustoms:buttonSelected", player, button)
	else
	  TriggerClientEvent("lscustoms:payGarageFalse", player)
	end
  else
    TriggerClientEvent("lscustoms:buttonSelected", player, button)
  end
end)

RegisterServerEvent('lscustoms:UpdateVeh')
AddEventHandler('lscustoms:UpdateVeh', function(vehicle, plate, plateindex, primarycolor, secondarycolor, pearlescentcolor, wheelcolor, neoncolor1, neoncolor2, neoncolor3, windowtint, wheeltype, mods0, mods1, mods2, mods3, mods4, mods5, mods6, mods7, mods8, mods9, mods10, mods11, mods12, mods13, mods14, mods15, mods16, turbo, tiresmoke, xenon, mods23, mods24, neon0, neon1, neon2, neon3, bulletproof, smokecolor1, smokecolor2, smokecolor3, variation)
  local user_id = vRP.getUserId(source)
  local player = vRP.getUserSource(user_id)
  MySQL.Async.fetchAll("SELECT vehicle FROM vrp_user_vehicles WHERE user_id = @user_id AND vehicle = @vehicle AND vehicle_plate = @plate", {user_id = user_id, vehicle = vehicle, plate = plate}, function(rows, affected)
    if #rows > 0 then -- has vehicle
        MySQL.Async.execute("UPDATE vrp_user_vehicles SET vehicle_plateindex=@plateindex, vehicle_colorprimary=@primarycolor, vehicle_colorsecondary=@secondarycolor, vehicle_pearlescentcolor=@pearlescentcolor, vehicle_wheelcolor=@wheelcolor, vehicle_neoncolor1=@neoncolor1, vehicle_neoncolor2=@neoncolor2, vehicle_neoncolor3=@neoncolor3, vehicle_windowtint=@windowtint, vehicle_wheeltype=@wheeltype, vehicle_mods0=@mods0, vehicle_mods1=@mods1, vehicle_mods2=@mods2, vehicle_mods3=@mods3, vehicle_mods4=@mods4, vehicle_mods5=@mods5, vehicle_mods6=@mods6, vehicle_mods7=@mods7, vehicle_mods8=@mods8, vehicle_mods9=@mods9, vehicle_mods10=@mods10, vehicle_mods11=@mods11, vehicle_mods12=@mods12, vehicle_mods13=@mods13, vehicle_mods14=@mods14, vehicle_mods15=@mods15, vehicle_mods16=@mods16, vehicle_turbo=@turbo, vehicle_tiresmoke=@tiresmoke, vehicle_xenon=@xenon, vehicle_mods23=@mods23, vehicle_mods24=@mods24, vehicle_neon0=@neon0, vehicle_neon1=@neon1, vehicle_neon2=@neon2, vehicle_neon3=@neon3, vehicle_bulletproof=@bulletproof, vehicle_smokecolor1=@smokecolor1, vehicle_smokecolor2=@smokecolor2, vehicle_smokecolor3=@smokecolor3, vehicle_modvariation=@variation WHERE user_id=@user_id AND vehicle=@vehicle", {
    	user_id = user_id,  
	    vehicle = vehicle,  
    	plateindex = plateindex,  
	    primarycolor = primarycolor, 
    	secondarycolor = secondarycolor,  
	    pearlescentcolor = pearlescentcolor, 
    	wheelcolor = wheelcolor, 
	    neoncolor1 = neoncolor1,
    	neoncolor2 = neoncolor2, 
	    neoncolor3 = neoncolor3,
    	windowtint = windowtint, 
	    wheeltype = wheeltype, 
    	mods0 = mods0, 
	    mods1 = mods1,
    	mods2 = mods2, 
	    mods3 = mods3,
    	mods4 = mods4,
	    mods5 = mods5,
    	mods6 = mods6, 
	    mods7 = mods7, 
    	mods8 = mods8, 
	    mods9 = mods9, 
    	mods10 = mods10, 
	    mods11 = mods11, 
    	mods12 = mods12, 
	    mods13 = mods13,
    	mods14 = mods14,
	    mods15 = mods15, 
    	mods16 = mods16,
	    turbo = turbo, 
    	tiresmoke = tiresmoke,
	    xenon = xenon,
    	mods23 = mods23,
	    mods24 = mods24, 
    	neon0 = neon0,
	    neon1 = neon1, 
    	neon2 = neon2,
	    neon3 = neon3,
    	bulletproof = bulletproof,
	    smokecolor1 = smokecolor1,
    	smokecolor2 = smokecolor2,
	    smokecolor3 = smokecolor3, 
    	variation = variation})
        TriggerClientEvent('lscustoms:UpdateDone', player)
    else
        TriggerClientEvent('lscustoms:StoreVehicleFalse', player)
	end
  end)
end)