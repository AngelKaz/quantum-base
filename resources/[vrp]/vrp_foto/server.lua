vRP = exports['vrp']:getObject()

RegisterServerEvent('betalFart')
AddEventHandler('betalFart', function(tax,kmhspeed,maxspeed,license)
	local source = source
	local user_id = vRP.getUserId(source)
	local player = vRP.getUserSource(user_id)

    local cop = vRP.hasGroup(user_id,"Politi-Job")
	local ems = vRP.hasGroup(user_id,"EMS-Job")
    
	vRP.getUserIdentity(user_id, function(identity)
		local regi = identity.registration

		if license:find("P "..regi) then
			if cop or ems then
				TriggerClientEvent("pNotify:SendNotification", player,{text = "Du får ingen bøde da du er betjent eller læge", type = "success", queue = "global", timeout = 10000, layout = "centerRight",animation = {open = "gta_effects_fade_in", close = "gta_effects_fade_out"}})   
			else
				vRP.tryFullPayment(user_id, tax)
				TriggerClientEvent("pNotify:SendNotification", player, {text = "<b style='color:#ED2939'>Fartfælde</b><br /><br />Du kørte " .. kmhspeed .. "KM/T hvor du må køre "..tostring(maxspeed).." KM/T <br /><b style='color:#26ff26'>Bøde</b>: " .. tax ..",- DKK",type = "error",timeout = 8000,layout = "centerRight"})
			end
		end
	end)
end)