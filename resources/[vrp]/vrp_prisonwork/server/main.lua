vRP = exports['vrp']:getObject()

RegisterServerEvent('vRP:Pay')
AddEventHandler('vRP:Pay', function()
    local user_id = vRP.getUserId(source)
    local player = vRP.getUserSource(user_id)

	vRP.giveMoney(user_id,Config.Payment)
	TriggerClientEvent("pNotify:SendNotification", player,{text = "Du modtog: <b style='color: #4E9350'>" ..Config.Payment.. " DKK.</b> ", type = "success", queue = "global", timeout = 8000, layout = "centerRight",animation = {open = "gta_effects_fade_in", close = "gta_effects_fade_out"}, sounds = { sources = {"cash.ogg"}, volume = 0.6, conditions = {"docVisible"}}}) 

end)