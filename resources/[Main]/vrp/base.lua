local Proxy = module("lib/Proxy")
local Tunnel = module("lib/Tunnel")
local Lang = module("lib/Lang")
Debug = module("lib/Debug")
local config = module("cfg/base")

vRP = {}
tvRP = {}

Proxy.addInterface("vRP",vRP)
Tunnel.bindInterface("vRP", tvRP)
vRPclient = Tunnel.getInterface("vRP", "vRP")

vRP.users = {}
vRP.rusers = {}
vRP.user_tables = {}
vRP.user_tmp_tables = {}
vRP.user_sources = {}

-- load language
local dict = module("cfg/lang/"..config.lang) or {}
vRP.lang = Lang.new(dict)


vRP.sendLog = function(logType, message, username)
    if username == nil then username = "Quantum" end
    local webhook = config.webhooks[logType]

    if webhook == nil then
        return print("[vRP SendLog] - Webhook: " .. logType .. " er ugyldig")
    end
    
    PerformHttpRequest(webhook, function(err, text, headers) end, 'POST', 
        json.encode({ username = username, content = message }), 
    { ['Content-Type'] = 'application/json' })
end


vRP.getUserData = function(user_id, cb)
    local task = Task(cb)
    
    MySQL.Async.fetchAll("SELECT * FROM vrp_users WHERE id = @user_id", { user_id = user_id }, function(result)
        if #result > 0 then
            task({result[1]})
        else
            task()
        end
    end)
end

vRP.isBanned = function(user_id, cb)
    local task = Task(cb)

    MySQL.Async.fetchAll("SELECT * FROM vrp_users WHERE id = @user_id", {user_id = user_id}, function(result)
        if #result > 0 then
            task({result[1].banned})
        else
            task()
        end
    end)
end

vRP.getBannedReason = function(user_id, cb)
    local task = Task(cb)
    
    MySQL.Async.fetchAll("SELECT * FROM vrp_users WHERE id = @user_id", {user_id = user_id}, function(result)
        if #result > 0 then
            task({result[1].ban_reason})
        else
            task()
        end
    end)
end

vRP.setBanned = function(user_id,banned)
    if banned ~= false then
        MySQL.Async.execute("UPDATE vrp_users SET banned=@banned,ban_reason=@reason WHERE id = @user_id", {user_id = user_id, banned = 1, reason = banned})
    else
        MySQL.Async.execute("UPDATE vrp_users SET banned = '0' WHERE id = @user_id", {user_id = user_id})
    end
end

vRP.isWhitelisted = function(user_id, cb)
    local task = Task(cb)

    MySQL.Async.fetchAll("SELECT whitelisted FROM vrp_users WHERE id = @user_id", {user_id = user_id}, function(result)
        if #result > 0 then
            task({result[1].whitelisted})
        else
            task()
        end
    end)
end


vRP.setWhitelisted = function(user_id, whitelisted)
  MySQL.Async.execute("UPDATE vrp_users SET whitelisted = @whitelisted WHERE id = @user_id", {user_id = user_id, whitelisted = whitelisted})
end

vRP.getPlayerName = function(player)
  return GetPlayerName(player) or "ukendt"
end

vRP.setUData = function(user_id,key,value)
    MySQL.Async.execute("REPLACE INTO vrp_user_data(user_id, dkey, dvalue) VALUES(@user_id, @key, @value)", {user_id = user_id, key = key, value = value})
end

vRP.getUData = function(user_id,key,cb)
    local task = Task(cb)

    MySQL.Async.fetchAll("SELECT dvalue FROM vrp_user_data WHERE user_id = @user_id AND dkey = @key", {user_id = user_id, key = key}, function(result)
        if #result > 0 then
            task({result[1].dvalue})
        else
            task()
        end
    end)
end

vRP.setSData = function(key,value)
    MySQL.Async.execute("REPLACE INTO vrp_srv_data(dkey, dvalue) VALUES(@key, @value)", {key = key, value = value})
end

vRP.getSData = function(key, cb)
    local task = Task(cb)

    MySQL.Async.fetchAll("SELECT dvalue FROM vrp_srv_data WHERE dkey = @key", {key = key}, function(result)
        if #result > 0 then
            task({result[1].dvalue})
        else
            task()
        end
    end)
end

vRP.getUserDataTable = function(user_id)
    return vRP.user_tables[user_id]
end

vRP.getUserTmpTable = function(user_id)
    return vRP.user_tmp_tables[user_id]
end

vRP.isConnected = function(user_id)
    return vRP.rusers[user_id] ~= nil
end

vRP.isFirstSpawn = function(user_id)
    local tmp = vRP.getUserTmpTable(user_id)
    return tmp and tmp.spawns == 1
end

vRP.getUserId = function(source)
    if source ~= nil then
        local ids = GetPlayerIdentifiers(source)

        if ids ~= nil and #ids > 0 then
            return vRP.users[ids[1]]
        end
    end

    return nil
end

vRP.getUsers = function()
    local users = {}
    for k,v in pairs(vRP.user_sources) do
        users[k] = v
    end

    return users
end

vRP.getUserSource = function(user_id)
  return vRP.user_sources[user_id]
end

vRP.ban = function(user_id,reason)
    if user_id ~= nil then
        vRP.setBanned(user_id,reason)

        local player = vRP.getUserSource(user_id)
        if player ~= nil then
            vRP.kick(player, "[Banned] "..reason)
        end
    end
end

vRP.kick = function(source,reason)
    DropPlayer(source,reason)
end

-- tasks

function task_save_datatables()
    SetTimeout(config.save_interval*1000, task_save_datatables)
    TriggerEvent("vRP:save")

    for k,v in pairs(vRP.user_tables) do
        vRP.setUData(k, "vRP:datatable", json.encode(v))
    end
end

CreateThread(function()
    task_save_datatables()
end)

tvRP.ping = function()
    local user_id = vRP.getUserId(source)
    if user_id ~= nil then
        local tmpdata = vRP.getUserTmpTable(user_id)
        tmpdata.pings = 0
    end
end

AddEventHandler("playerConnecting",function(name,setMessage, deferrals)
    deferrals.defer()
    local source = source
    local steam = GetPlayerIdentifiers(source)[1]
  
    if steam ~= nil then
      deferrals.update("[Quantum] | Tjekker om du er banned..")
      local banned = false
      local whitelisted = false
      local user_ids = exports['quantum-multikarakter']:GetCharsbySteam(steam)
      local user_string = "IDS: "
  
      if next(user_ids) then
        for i = 1, #user_ids do
          user_string = user_string.." "..user_ids[i].user_id
  
          vRP.isWhitelisted(user_ids[i].user_id, function(iswhitelisted)
            if iswhitelisted == true then
              whitelisted = true
            end
          end)
  
          vRP.isBanned(user_ids[i].user_id, function(isbanned)
            if isbanned == true then 
              banned = true
            end
          end)
        end
  
        Wait(250)
  
        if config.whitelist == true and whitelisted == false then
          deferrals.done("Du er ikke whitelisted på serveren. "..user_string)
          return
        end
  
        if banned == true then
          deferrals.done("Du er banned fra serveren. "..user_string)
          return
        end   
        deferrals.done()
      else
        deferrals.done()
      end
    
    else 
      deferrals.done("[Quantum] | Du skal have steam åben")
    end
end)

RegisterNetEvent("quantum-multikarakter:LoadCharacter", function(data)
  local source = tonumber(data.source)
  local user_id = tonumber(data.user_id)
  local name = GetPlayerName(source)

  if vRP.rusers[user_id] == nil then
    vRP.users[data.steam] = user_id
    vRP.rusers[user_id] = data.steam
    vRP.user_tables[user_id] = {}
    vRP.user_tmp_tables[user_id] = {}
    vRP.user_sources[user_id] = source

    vRP.getUData(user_id, "vRP:datatable", function(sdata)
        local data = json.decode(sdata)
        
        if type(data) == "table" then 
            vRP.user_tables[user_id] = data 
        end

        local tmpdata = vRP.getUserTmpTable(user_id)
        tmpdata.spawns = 0

        TriggerEvent("vRP:playerJoin", user_id, source, name)
    end)
  else
    TriggerEvent("vRP:playerRejoin", user_id, source, name)

    local tmpdata = vRP.getUserTmpTable(user_id)
    tmpdata.spawns = 0
  end
end)

RegisterNetEvent("quantum-multikarakter:SwitchChar",function(source)
  local source = source
  vRPclient.removePlayer(-1,{source})
  local user_id = vRP.getUserId(source)

  if user_id ~= nil then
    TriggerEvent("vRP:playerLeave", user_id, source)

    vRP.setUData(user_id, "vRP:datatable", json.encode(vRP.getUserDataTable(user_id)))

    vRP.users[vRP.rusers[user_id]] = nil
    vRP.rusers[user_id] = nil
    vRP.user_tables[user_id] = nil
    vRP.user_tmp_tables[user_id] = nil
    vRP.user_sources[user_id] = nil
  end
end)

RegisterServerEvent("vRPcli:playerSpawned")
AddEventHandler("vRPcli:playerSpawned", function(source)
    local user_id = vRP.getUserId(source)

    if user_id ~= nil then
        vRP.user_sources[user_id] = source
        local tmp = vRP.getUserTmpTable(user_id)
        tmp.spawns = tmp.spawns+1
        local first_spawn = (tmp.spawns == 1)

        if first_spawn then
            for k,v in pairs(vRP.user_sources) do
                vRPclient.addPlayer(source,{v})
            end
            
            vRPclient.addPlayer(-1,{source})
        end
        
        TriggerEvent("vRP:playerSpawn",user_id, source, first_spawn)
    end

end)

RegisterServerEvent("vRP:playerDied")