vRP = exports['vrp']:getObject()

RegisterNetEvent('carwash:checkmoney', function(dirt)
	local user_id = vRP.getUserId(source)
	local player = vRP.getUserSource(user_id)

	if parseFloat(dirt) > parseFloat(1.0) then
        if vRP.tryFullPayment(user_id, 145) then
            TriggerClientEvent('carwash:success', player)
        else
            TriggerClientEvent('carwash:notenough', player)
        end
	else
	    TriggerClientEvent('carwash:alreadyclean', player)
	end
end)
