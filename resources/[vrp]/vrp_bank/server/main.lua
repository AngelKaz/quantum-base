vRP = exports['vrp']:getObject()
isTransfer = false

AddEventHandler("vRP:playerSpawn",function(user_id,source,last_login) 
    local bankbalance = vRP.getBankMoney(user_id)
    local wallet = vRP.getMoney(user_id)

    TriggerClientEvent('banking:updateBalance', source, bankbalance, wallet)
end)

RegisterServerEvent('playerSpawned')
AddEventHandler('playerSpawned', function()
  local user_id = vRP.getUserId(source)
  local bankbalance = vRP.getBankMoney(user_id)
  local wallet = vRP.getMoney(user_id)

  TriggerClientEvent('banking:updateBalance', source, bankbalance, wallet)
end)

-- HELPER FUNCTIONS
function bankBalance(player)
  return vRP.getBankMoney(vRP.getUserId(player))
end

function deposit(player, amount)
  local user_id = vRP.getUserId(player)
  local bankbalance = bankBalance(player)
  local new_balance = bankbalance + math.abs(amount)
  local wallet = vRP.getMoney(user_id)
  local new_wallet = wallet - math.abs(amount)

  TriggerClientEvent("banking:updateBalance", source, new_balance, new_wallet)
  vRP.tryDeposit(user_id, math.floor(math.abs(amount)))
end

function withdraw(player, amount)
  local user_id = vRP.getUserId(player)
  local bankbalance = bankBalance(player)
  local new_balance = bankbalance - math.abs(amount)
  local wallet = vRP.getMoney(user_id)
  local new_wallet = wallet + math.abs(amount)

  TriggerClientEvent("banking:updateBalance", source, new_balance, new_wallet)
  vRP.tryWithdraw(user_id,math.floor(math.abs(amount)))
end

function transfer (fPlayer, tPlayer, amount)
  local bankbalance = bankBalance(fPlayer)
  local bankbalance2 = bankBalance(tPlayer)
  local new_balance = bankbalance - math.abs(amount)
  local new_balance2 = bankbalance2 + math.abs(amount)
  local wallet = vRP.getMoney(user_id)

  local user_id = vRP.getUserId(fPlayer)
  local user_id2 = vRP.getUserId(tPlayer)

  vRP.setBankMoney(user_id, new_balance)
  vRP.setBankMoney(user_id2, new_balance2)

  TriggerClientEvent("banking:updateBalance", fPlayer, new_balance, wallet)
  TriggerClientEvent("banking:updateBalance", tPlayer, new_balance2, wallet)
end

function round(num, numDecimalPlaces)
  local mult = 5^(numDecimalPlaces or 0)
  return math.floor(num * mult + 0.5) / mult
end

function splitString(str, sep)
  if sep == nil then sep = "%s" end

  local t={}
  local i=1

  for str in string.gmatch(str, "([^"..sep.."]+)") do
    t[i] = str
    i = i + 1
  end

  return t
end

RegisterServerEvent('bank:update')
AddEventHandler('bank:update', function()
  local user_id = vRP.getUserId(source)
  local source = vRP.getUserSource(user_id)
  local bankbalance = vRP.getBankMoney(user_id)
  local wallet = vRP.getMoney(user_id)

  TriggerClientEvent("banking:updateBalance", source, bankbalance, wallet)
end)

-- Bank Deposit
RegisterServerEvent('bank:deposit')
AddEventHandler('bank:deposit', function(amount)
  if not amount then return end
    local user_id = vRP.getUserId(source)
    local source = vRP.getUserSource(user_id)
    local wallet = vRP.getMoney(user_id)
    local rounded = math.ceil(tonumber(amount))

    if(string.len(rounded) >= 9) then
      TriggerClientEvent('quantum-notify:notify', source, 'Banken', 'Beløbet er for højt', 'error', 5000)
    else
        local bankbalance = vRP.getBankMoney(user_id)
        local newbalance = bankbalance + rounded

        if(rounded <= wallet) then
            TriggerClientEvent("banking:updateBalance", source, bankbalance, wallet)  
            TriggerClientEvent("banking:addBalance", source, rounded)

            TriggerClientEvent('quantum-notify:notify', source, 'Banken', 'Du indsatte ' .. math.floor(rounded) .. ' DKK', 'success', 5000)
            deposit(source, rounded)
        else
            TriggerClientEvent('quantum-notify:notify', source, 'Banken', 'Du har ikke nok penge i pungen', 'error', 5000)
        end
    end
end)


RegisterServerEvent('bank:withdraw')
AddEventHandler('bank:withdraw', function(amount)
  if not amount then return end
    local source = source
    local user_id = vRP.getUserId(source)
    local rounded = round(tonumber(amount), 0)
    if(string.len(rounded) >= 9) then
      TriggerClientEvent('quantum-notify:notify', source, 'Banken', 'Beløbet er for højt', 'error', 5000)
    else
      local bankbalance = vRP.getBankMoney(user_id)
      local wallet = vRP.getMoney(user_id)
      local newbalance = bankbalance - rounded
      if(tonumber(rounded) <= tonumber(bankbalance)) then
        TriggerClientEvent("banking:updateBalance", source, newbalance, wallet)
        TriggerClientEvent("banking:removeBalance", source, rounded)
        TriggerClientEvent('quantum-notify:notify', source, 'Banken', 'Du hævede ' .. math.floor(rounded) .. ' DKK', 'success', 5000)
        withdraw(source, rounded)
      else
        TriggerClientEvent('quantum-notify:notify', source, 'Banken', 'Du har ikke nok penge på kontoen', 'error', 5000)
      end
    end
end)

RegisterServerEvent('bank:transfer')
AddEventHandler('bank:transfer', function(fromPlayer, toPlayer, amount)
    local source = source
    local user_id = vRP.getUserId(source)
    local fPlayer = vRP.getUserSource(user_id)
    local wallet = vRP.getMoney(user_id)

  if tonumber(fPlayer) == tonumber(toPlayer) then
    TriggerClientEvent('quantum-notify:notify', source, 'Banken', 'Du kan ikke overføre penge til dig selv', 'error', 5000)
    CancelEvent()
  else
    local rounded = round(tonumber(amount), 0)
    if(string.len(rounded) >= 9) then
        TriggerClientEvent('quantum-notify:notify', source, 'Banken', 'Beløbet er for højt.', 'error', 5000)
		CancelEvent()
    else
      local bankbalance = vRP.getBankMoney(user_id)
      local newbalance = bankbalance - rounded
      if(tonumber(rounded) <= tonumber(bankbalance)) then
        TriggerClientEvent("banking:updateBalance", fPlayer, newbalance, wallet)
        TriggerClientEvent("banking:removeBalance", fPlayer, rounded)
        local user_id2 = vRP.getUserId(toPlayer)
        local bankbalance2 = vRP.getBankMoney(user_id2)
		local newbalance2 = bankbalance2 + rounded
        
        transfer(fPlayer, toPlayer, rounded)
        
        TriggerClientEvent('quantum-notify:notify', source, 'Banken', 'Overførte: ' .. math.floor(rounded) .. ' DKK', 'success', 5000)

        TriggerClientEvent("banking:updateBalance", toPlayer, newbalance2, wallet)
        TriggerClientEvent("banking:addBalance", toPlayer, rounded)

        TriggerClientEvent('quantum-notify:notify', toPlayer, 'Banken', 'Modtog: ' .. math.floor(rounded) .. ' DKK', 'success', 5000)
        CancelEvent()
      else
        TriggerClientEvent('quantum-notify:notify', source, 'Banken', 'Du har ikke nok penge på kontoen', 'info', 5000)
      end
    end    
  end
end)
