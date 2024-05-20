local k5NotifSettingsOpen = false
local command = 'notifysettings'

RegisterNetEvent("quantum-notify:notify", function(title, text, type, duration)
  notify(title, text, type, duration)
end)

function notify(title, text, type, duration)
  SendNUIMessage({
    action = "notify",
    data = {
      title = title,
      text = text,
      type = type,
      duration = duration
    }
  })
end

RegisterCommand(command, function()
  if k5NotifSettingsOpen then
    closeSettings() 
  else
    k5NotifSettingsOpen = true
    SendNUIMessage({
      action = "settings"
    })
    SetNuiFocus(true, true)
  end
end)

CreateThread(function()
    TriggerEvent('chat:addSuggestion', command, 'Change Notify Settings', {})
end)

function closeSettings()
  k5NotifSettingsOpen = false
  SendNUIMessage({
    action = "closeSettings"
  })
  SetNuiFocus(false, false)
end


RegisterNUICallback("action", function(data, cb)
	if data.action == "close" then
		closeSettings()
    end
end)