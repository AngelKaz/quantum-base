local Tunnel = module("vrp", "lib/Tunnel")
vRP = exports['vrp']:getObject()
vRPclient = Tunnel.getInterface("vRP","vRP_chests")

local chests = {}
chests = {
	{"Politi-Job", 478.48883056641,-984.86486816406,24.914697647095, "Politi-Job"}
}

local function create_pleschest(owner_access, x, y, z, player, name)
	local namex = name or "chest"
	
	local chest_enter = function(player, area)
		local user_id = vRP.getUserId(player)
		if user_id ~= nil then
			if owner_access == "none" or user_id == tonumber(owner_access) or vRP.hasGroup(user_id, owner_access) or vRP.hasPermission(user_id, owner_access) then
				vRP.openChest(player, "static:"..owner_access..":"..namex, 500, nil, nil, nil)
			end
		end
	end

	local chest_leave = function(player,area)
		vRP.closeMenu(player)
	end
	
	local nid = "vRP:static-"..namex..":"..owner_access
	vRPclient.setNamedMarker(player,{nid,x,y,z-1,0.7,0.7,0.5,0,148,255,125,150})
	vRP.setArea(player,nid,x,y,z,1,1.5,chest_enter,chest_leave)
end

AddEventHandler("vRP:playerSpawn",function(user_id,source,first_spawn)
  if first_spawn then
	for k, v in pairs(chests) do
		create_pleschest(v[1], v[2], v[3], v[4], source, v[5])
	end
  end
end)
