local htmlEntities = module("lib/htmlEntities")
local Tools = module("lib/Tools")
local lang = vRP.lang
local cfg = module("cfg/admin")

-- this module define some admin menu functions
local player_lists = {}

local function ch_list(player,choice)
    local user_id = vRP.getUserId(player)
    if user_id ~= nil and vRP.hasPermission(user_id,"player.list") then
        if player_lists[player] then -- hide
            player_lists[player] = nil
            vRPclient.removeDiv(player,{"user_list"})
        else -- show
            local content = ""
            local count = 0
            for k,v in pairs(vRP.rusers) do
                count = count+1
                local source = vRP.getUserSource(k)
                vRP.getUserIdentity(k, function(identity)
                    if source ~= nil then
                        if identity then
                            content = content.."("..k..") <span class=\"pseudo\">"..vRP.getPlayerName(source).."</span> - <span class=\"name\">"..htmlEntities.encode(identity.firstname).." "..htmlEntities.encode(identity.name).."</span> CPR: <span class=\"reg\">"..identity.registration.."</span> TLF: <span class=\"phone\">"..identity.phone.."</span><br>"
                        end
                    end

                    -- check end
                    count = count-1
                    if count == 0 then
                        player_lists[player] = true
                        local css = [[
				.div_user_list{ 
				  margin: auto; 
				  padding: 8px; 
				  width: 650px; 
				  margin-top: 90px; 
				  background: black; 
				  color: white; 
				  font-weight: bold; 
				  font-size: 16px;
				  font-family: arial;
				} 

				.div_user_list .pseudo{ 
				  color: rgb(0,255,125);
				}

				.div_user_list .endpoint{ 
				  color: rgb(255,0,0);
				}

				.div_user_list .name{ 
				  color: #309eff;
				}

				.div_user_list .reg{ 
				  color: rgb(0,125,255);
				}
							  
				.div_user_list .phone{ 
				  color: rgb(211, 0, 255);
				}
            ]]
                        vRPclient.setDiv(player,{"user_list", css, content})
                    end
                end)
            end
        end
    end
end

local function ch_whitelist(player,choice)
    local user_id = vRP.getUserId(player)
    if user_id ~= nil and vRP.hasPermission(user_id,"player.whitelist") then
        vRP.prompt(player,"ID: ","",function(player,id)
            id = parseInt(id)

            if id == 0 then
                return TriggerClientEvent('quantum-notify:notify', player, 'Admin Notifikation', 'Ugyldigt ID', 'error', 5000)
            end

            vRP.setWhitelisted(id,true)

            vRP.sendLog("whitelist", "**[ ID: " .. user_id .. " ] - Tilføjede whitelist til **[ ID: " .. tostring(id) .. " ]")

            TriggerClientEvent('quantum-notify:notify', player, 'Admin Notifikation', 'ID: ' .. id .. ' blev whitelisted', 'success', 5000)
        end)
    end
end

local function ch_unwhitelist(player,choice)
    local user_id = vRP.getUserId(player)
    if user_id ~= nil and vRP.hasPermission(user_id, "player.unwhitelist") then
        vRP.prompt(player,"ID: ","",function(player,id)
            id = parseInt(id)

            if id == 0 then
                return TriggerClientEvent('quantum-notify:notify', player, 'Admin Notifikation', 'Ugyldigt ID', 'error', 5000)
            end

            vRP.setWhitelisted(id,false)

            vRP.sendLog("whitelist", "**[ ID: " .. user_id .. " ]")
            TriggerClientEvent('quantum-notify:notify', player, 'Admin Notifikation', 'ID: ' .. id .. 'blev unwhitelisted', 'success', 5000)
        end)
    end
end

local function ch_addgroup(player,choice)
    local user_id = vRP.getUserId(player)

    if user_id ~= nil and vRP.hasPermission(user_id,"player.group.add") then
        vRP.prompt(player,"ID: ","",function(player,id)
            id = parseInt(id)
            local checkid = vRP.getUserSource(tonumber(id))

            if checkid ~= nil then
                vRP.prompt(player,"Job: ","",function(player,group)
                    if group == " " or group == "" or group == null or group == 0 or group == nil then
                        TriggerClientEvent('quantum-notify:notify', player, 'Admin Notifikation', 'Ugyldigt job angivet', 'error', 5000)
                    else
                        if group == "Staff" or group == "ledelse" or group == "Head Admin" or group == "Senior Admin" or group == "Admin" or group == "Moderator" or group == "Supporter" then
                            TriggerClientEvent('quantum-notify:notify', player, 'Admin Notifikation', 'Du har ikke rettigheder til at tildele rank/job ' .. group, 'error', 5000)
                        else
                            vRP.addUserGroup(id, group)
                            vRP.sendLog("user-group", "[ ID: " .. user_id .. " ] Har givet job/rank (" .. group .. ") til [ ID: " .. id .. " ]")
                            TriggerClientEvent('quantum-notify:notify', player, 'Admin Notifikation', 'ID: ' .. id .. ' har fået rank/jobbet: ' .. group, 'info', 5000)
                        end
                    end
                end)
            else
                TriggerClientEvent('quantum-notify:notify', player, 'Admin Notifikation', 'ID: ' .. id .. ' er ikke online', 'error', 5000)
            end
        end)
    end
end

local function ch_removegroup(player,choice)
    local user_id = vRP.getUserId(player)

    if user_id ~= nil and vRP.hasPermission(user_id,"player.group.remove") then
        vRP.prompt(player,"ID: ","",function(player,id)
            id = parseInt(id)

            local checkid = vRP.getUserSource(tonumber(id))

            if checkid ~= nil then
                vRP.prompt(player,"Job: ","",function(player,group)
                    if group == " " or group == "" or group == null or group == 0 or group == nil then
                        TriggerClientEvent('quantum-notify:notify', player, 'Admin Notifikation', 'Ugyldigt job angivet', 'error', 5000)
                    else
                        if group == "Staff" or group == "ledelse" or group == "Head Admin" or group == "Senior Admin" or group == "Admin" or group == "Moderator" or group == "Supporter" then
                            TriggerClientEvent('quantum-notify:notify', player, 'Admin Notifikation', 'Du har ikke rettigheder til at fjerne rank/job ' .. group, 'error', 5000)
                        else
                            vRP.removeUserGroup(id,group)

                            vRP.sendLog("user-group", "[ ID: " .. user_id .. " ] Har fjernet rank/job (" .. group .. ") fra [ ID: " .. id .. " ]")
                            TriggerClientEvent('quantum-notify:notify', player, 'Admin Notifikation', 'ID: ' .. id .. ' har fået fjernet rank/job: ' .. group, 'success', 5000)
                        end
                    end
                end)
            else
                TriggerClientEvent('quantum-notify:notify', player, 'Admin Notifikation', 'ID: ' .. id .. ' er ikke online', 'error', 5000)
            end
        end)
    end
end

local function ch_addgroup_staff(player,choice)
    local user_id = vRP.getUserId(player)

    if user_id ~= nil and vRP.hasPermission(user_id,"player.group.add.staff") then
        vRP.prompt(player,"ID: ","",function(player,id)
            id = parseInt(id)

            local checkid = vRP.getUserSource(tonumber(id))

            if checkid ~= nil then
                vRP.prompt(player,"Job: ","",function(player,group)
                    if group == " " or group == "" or group == null or group == 0 or group == nil then
                        TriggerClientEvent('quantum-notify:notify', player, 'Admin Notifikation', 'Ugyldigt job/rank', 'error', 5000)
                    else
                        vRP.addUserGroup(id, group)
                        vRP.sendLog("user-group", "[ ID: " .. user_id .. " ] Har fjernet rank/job (" .. group .. ") fra [ ID: " .. id .. " ]")
                        TriggerClientEvent('quantum-notify:notify', player, 'Admin Notifikation', 'ID: ' .. id .. ' har fået job/rank: ' .. group, 'success', 5000)
                    end
                end)
            else
                TriggerClientEvent('quantum-notify:notify', player, 'Admin Notifikation', 'ID: ' .. id .. ' er ikke online', 'error', 5000)
            end
        end)
    end
end

local function ch_removegroup_staff(player,choice)
    local user_id = vRP.getUserId(player)

    if user_id ~= nil and vRP.hasPermission(user_id,"player.group.remove.staff") then
        vRP.prompt(player,"ID: ","",function(player,id)
            id = parseInt(id)
            local checkid = vRP.getUserSource(tonumber(id))

            if checkid ~= nil then
                vRP.prompt(player,"Job: ","",function(player,group)
                    if group == " " or group == "" or group == null or group == 0 or group == nil then
                        TriggerClientEvent('quantum-notify:notify', player, 'Admin Notifikation', 'Ugyldigt job/rank', 'error', 5000)
                    else
                        vRP.removeUserGroup(id,group)
                        vRP.sendLog("user-group", "[ ID: " .. user_id .. " ] Har fået fjernet rank/job (" .. group .. ") fra [ ID: " .. id .. " ]")
                        TriggerClientEvent('quantum-notify:notify', player, 'Admin Notifikation', 'ID: ' .. id .. ' har fået fjernet job/rank: ' .. group, 'error', 5000)
                    end
                end)
            else
                TriggerClientEvent('quantum-notify:notify', player, 'Admin Notifikation', 'ID: ' .. id .. ' er ikke online', 'info', 5000)
            end
        end)
    end
end

local function ch_seize(player,choice)
    local user_id = vRP.getUserId(player)
    local seized_items = {}
    if user_id ~= nil then
        vRPclient.getNearestPlayer(player, {5}, function(nplayer)
            local nuser_id = vRP.getUserId(nplayer)
            if nuser_id ~= nil and vRP.hasPermission(nuser_id, "staff.seizable") then
                vRP.getUserIdentity(user_id, function(identity_cop)
                    vRP.getUserIdentity(nuser_id, function(identity_civ)
                        if identity_cop and identity_civ then
                            local cop_name = identity_cop.firstname
                            local cop_lname = identity_cop.name
                            local civ_name = identity_civ.firstname
                            local civ_lname = identity_civ.name

                            table.insert(seized_items, "**"..cop_name.." "..cop_lname.." ("..user_id..")** beslaglagde de her genstande fra **"..civ_name.." "..civ_lname.." ("..nuser_id..")**: \n")
                            
                            for k,v in pairs(cfg.removeable_items) do -- transfer seizable items
                                local amount = vRP.getInventoryItemAmount(nuser_id,v)
                                if amount > 0 then
                                    local item = vRP.items[v]
                                    if item then -- do transfer
                                        if vRP.tryGetInventoryItem(nuser_id,v,amount,true) then
                                            table.insert(seized_items, "- "..amount.."x "..vRP.getItemName(v).."\n")
                                            TriggerClientEvent('quantum-notify:notify', player, 'Ny Notifikation', lang.police.menu.seize.seized({item.name, amount}), 'info', 5000)
                                        end
                                    end
                                end
                            end


                            vRP.sendLog("seize", table.concat(seized_items))
                            TriggerClientEvent('quantum-notify:notify', nplayer, 'Politi Beslaglæg', lang.police.menu.seize.items.seized(), 'info', 5000)
                        end
                    end)
                end)
            else
                TriggerClientEvent('quantum-notify:notify', player, 'Admin Notifikation', 'Ingen spillere i nærheden', 'error', 5000)
            end
        end)
    end
end

local function ch_kick(player,choice)
    local user_id = vRP.getUserId(player)

    if user_id ~= nil and vRP.hasPermission(user_id,"player.kick") then
        vRP.prompt(player,"ID: ","",function(player,id)
            id = parseInt(id)

            vRP.prompt(player,"Årsag: ","",function(player,reason)
                local source = vRP.getUserSource(id)

                if source ~= nil then
                    vRP.kick(source, reason)
                    vRP.sendLog("kick", "ID: " .. user_id .. " kickede ID: " .. id .. "\n**Årsag:** " .. tostring(reason))
                    TriggerClientEvent('quantum-notify:notify', player, 'Admin Notifikation', 'Du kickede ID: ' .. id, 'success', 5000)
                else
                    TriggerClientEvent('quantum-notify:notify', player, 'Admin Notifikation', 'Personen er ikke online.', 'error', 5000) 
                end
            end)
        end)
    end
end

local function ch_ban(player,choice)
    local user_id = vRP.getUserId(player)
    if user_id ~= nil and vRP.hasPermission(user_id, "player.ban") then
        vRP.prompt(player,"ID: ","",function(player,id)
            id = parseInt(id)

            vRP.prompt(player,"Årsag: ","",function(player,reason)
                vRP.ban(id, reason, true)
                TriggerClientEvent('quantum-notify:notify', player, 'Admin Notifikation', 'Du bannede ID: ' .. id, 'success', 5000)
                vRP.sendLog("ban", "ID: " .. user_id .. " bannede ID: " .. id .. "\n**Årsag:** " .. reason)
            end)
        end)
    end
end

local function ch_unban(player,choice)
    local user_id = vRP.getUserId(player)

    if user_id ~= nil and vRP.hasPermission(user_id, "player.unban") then
        vRP.prompt(player,"ID: ","",function(player, id)
            id = parseInt(id)

            vRP.setBanned(id, false)
            TriggerClientEvent('quantum-notify:notify', player, 'Admin Notifikation', 'Du unbannede ID: ' .. id, 'success', 5000)
            vRP.sendLog("unban", "[ ID: " .. user_id .. "] unbannede ID: " .. id)
        end)
    end
end

local function ch_revivePlayer(player,choice)
    local nuser_id = vRP.getUserId(player)

    vRP.prompt(player,"ID:","",function(player,id)
        id = parseInt(id)
        local deadplayer = vRP.getUserSource(tonumber(id))

        if deadplayer == nil or deadplayer == 0 then
            TriggerClientEvent('quantum-notify:notify', player, 'Admin Notifikation', 'ID: ' .. id .. ' er ikke online', 'error', 5000)
        else
            vRPclient.varyHealth(deadplayer, { 100 })
            vRP.setHunger(tonumber(id), 0)
            vRP.setThirst(tonumber(id), 0)
            
            vRP.sendLog("genopliv", "[ ID: " .. nuser_id .. " ] har genoplivet [ ID: " .. id .. " ]")
            TriggerClientEvent('quantum-notify:notify', player, 'Admin Notifikation', 'Du genoplivede ', 'info', 5000)
        end
    end)
end


local function ch_repairVehicle(player,choice)
    vRPclient.fixeNearestVehicleAdmin(player, {3})
end

local function ch_coords(player,choice)
    vRPclient.getPosition(player,{},function(x,y,z,h)
        vRP.prompt(player, "Kopier koordinaterne med CTRL-A CTRL-C", x..","..y..","..z..","..h, function(player,choice) end)
    end)
end

local function ch_tptome(player,choice)
    vRPclient.getPosition(player,{},function(x,y,z)
        vRP.prompt(player,"ID: ", "",function(player,user_id)
            local tplayer = vRP.getUserSource(tonumber(user_id))

            if tplayer ~= nil then
                vRPclient.teleport(tplayer,{x,y,z})
            end
        end)
    end)
end

local function ch_tpto(player,choice)
    vRP.prompt(player,"ID: ","",function(player,user_id)
        local tplayer = vRP.getUserSource(tonumber(user_id))
        if tplayer ~= nil then
            vRPclient.getPosition(tplayer,{},function(x,y,z)
                vRPclient.teleport(player,{x,y,z})
            end)
        end
    end)
end

local function ch_tptocoords(player,choice)
    vRP.prompt(player,"Koordinater x,y,z:","",function(player,fcoords)
        local coords = {}
        for coord in string.gmatch(fcoords or "0,0,0","[^,]+") do
            table.insert(coords,tonumber(coord))
        end

        local x,y,z = 0,0,0
        if coords[1] ~= nil then x = coords[1] end
        if coords[2] ~= nil then y = coords[2] end
        if coords[3] ~= nil then z = coords[3] end

        if x == 0 and y == 0 and z == 0 then
            TriggerClientEvent('quantum-notify:notify', player, 'Admin Notifikation', 'Koordinaterne er ugyldige', 'error', 5000)
        else
            vRPclient.teleport(player,{x,y,z})
        end
    end)
end

-- teleport waypoint
local function ch_tptowaypoint(player,choice)
    TriggerClientEvent("TpToWaypoint", player)
end

local function ch_givemoney(player,choice)
    local user_id = vRP.getUserId(player)

    if user_id ~= nil then
        vRP.prompt(player,"Beløb:","",function(player,amount)
            vRP.prompt(player,"Formål ved spawn af penge:","",function(player,reason)
                if reason == " " or reason == "" or reason == null or reason == 0 or reason == nil then
                    reason = "Ingen kommentar..."
                end

                amount = parseInt(amount)

                if amount == " " or amount == "" or amount == null or amount == 0 or amount == nil then
                    TriggerClientEvent('quantum-notify:notify', player, 'Admin Notifikation', 'Beløbet skal være et tal', 'error', 5000)
                else
                    vRP.giveMoney(user_id, amount)
                    vRP.sendLog("money", "[ ID: " .. user_id .. " ] har spawned " .. amount .. ",- med grunden: " .. reason)
                    TriggerClientEvent('quantum-notify:notify', player, 'Admin Notifikation', 'Du spawnede ' .. amount .. ',- DKK', 'success', 5000)
                end
            end)
        end)
    end
end

local function ch_giveitem(player,choice)
    local user_id = vRP.getUserId(player)

    if user_id ~= nil then
        vRP.prompt(player,"Tingens ID:","",function(player,idname)
            idname = idname

            if idname == " " or idname == "" or idname == null or idname == nil then
                TriggerClientEvent('quantum-notify:notify', player, 'Admin Notifikation', 'Ugyldig item', 'error', 5000)
            else
                vRP.prompt(player,"Antal:","",function(player,amount)
                    vRP.prompt(player,"Formål ved spawn af ting:","",function(player,reason)
                        if reason == " " or reason == "" or reason == null or reason == 0 or reason == nil then
                            reason = "Ingen kommentar..."
                        end

                        amount = parseInt(amount)

                        if amount == 0 then
                            TriggerClientEvent('quantum-notify:notify', player, 'Admin Notifikation', 'Antallet skal være et tal', 'error', 5000)
                        else
                            vRP.giveInventoryItem(user_id, idname, amount, true)
                            vRP.sendLog('item-spawn', '[ ID: ' .. user_id .. ' ] har spawnet: ' .. idname .. ', mængde: ' .. amount)
                        end
                    end)
                end)
            end
        end)
    end
end

local function ch_calladmin(player,choice)
    local user_id = vRP.getUserId(player)

    if user_id ~= nil then
        vRP.prompt(player,"Hvad har du brug for hjælp til? MIN: 10 tegn","",function(player, desc)
            desc = desc or ""

            local answered = false
            local players = {}
            for k,v in pairs(vRP.rusers) do
                local player = vRP.getUserSource(tonumber(k))
                -- check user
                if vRP.hasPermission(k,"admin.tickets") and player ~= nil then
                    table.insert(players,player)
                end
            end

            -- send notify and alert to all listening players
            if string.len(desc) > 10 and string.len(desc) < 1000 then
                for k,v in pairs(players) do
                    vRP.request(v,"Admin Case (ID: "..user_id..")?: "..htmlEntities.encode(desc), 60, function(v, ok)
                        if ok then -- take the call
                            if not answered then
                                local steamname = GetPlayerName(v)
                                vRPclient.notify(player,{"En staff har taget din case!"})
                                TriggerClientEvent('quantum-notify:notify', player, 'Admin Case', 'En staff har taget din case', 'info', 5000)
                                vRPclient.getPosition(player, {}, function(x,y,z)
                                    vRPclient.teleport(v,{x,y,z})
                                end)
                                answered = true
                            else
                                vRPclient.notify(v,{"Allerede taget!"})
                            end
                        end
                    end)
                end
            else
                TriggerClientEvent('quantum-notify:notify', player, 'Ny Notifikation', 'Din beskrivelse skal være mere end 10 tegn', 'error', 5000)
            end
        end)
    end
end

local function choice_bilforhandler(player, choice)
    local user_id = vRP.getUserId(player)

    if user_id ~= nil then
        local usrList = ""
        vRPclient.getNearestPlayers(player,{5},function(nplayer)
            for k,v in pairs(nplayer) do
                usrList = usrList .. " | " .. "[" .. vRP.getUserId(k) .. "]" .. GetPlayerName(k)
            end

            if usrList ~= "" then
                vRP.prompt(player,"Nærmeste spiller(e): " .. usrList .. "","",function(player,nuser_id)
                    if nuser_id ~= nil and nuser_id ~= "" then
                        local target = vRP.getUserSource(tonumber(nuser_id))

                        if target ~= nil then
                            vRP.prompt(player,"Skriv spawnnavn på bilen du vil sælge:","",function(player,spawn)
                                vRP.prompt(player,"Type? car/bike:","",function(player,veh_type)
                                    if veh_type == "car" or veh_type == "bike" then
                                        vRP.prompt(player,"Hvad skal den koste?","",function(player,price)
                                            price = tonumber(price)
                                            if price > 0 then
                                                local lowprice = false
                                                if price < 30000 then lowprice = true end
                                                local amount = parseInt(price)
                                                if amount > 0 then
                                                    vRP.prompt(player,"Bekræft: "..spawn.." sælges til "..nuser_id.." for "..format_thousands(tonumber(price)),"",function(player,bool)
                                                        if string.lower(bool) == "bekræft" then
                                                            if vRP.tryFullPayment(tonumber(nuser_id),tonumber(price)) then
                                                                vRP.getUserIdentity(tonumber(nuser_id), function(identity)
                                                                    local pp = math.floor(tonumber(price)/100*5)
                                                                    vRP.giveBankMoney(user_id,tonumber(pp))
                                                                    MySQL.Async.execute("INSERT IGNORE INTO vrp_user_vehicles(user_id,vehicle,vehicle_plate,veh_type) VALUES(@user_id,@vehicle,@vehicle_plate,@veh_type)", {user_id = tonumber(nuser_id), vehicle = spawn, vehicle_plate = "P "..identity.registration, veh_type = veh_type})
                                                                    
                                                                    TriggerClientEvent('quantum-notify:notify', player, 'Bilforhandler', identity.firstname .. ' ' .. identity.name .. " har modtaget " .. spawn .. " for " .. format_thousands(tonumber(price)) .. ",- DKK | Du modtog: " .. format_thousands(tonumber(pp)) .. ",- DKK for handlen", 'success', 5000)
                                                                end)

                                                                local message = "**"..user_id.."** solgte en **"..spawn.."** til **"..nuser_id.."** for **"..format_thousands(tonumber(price)).." DKK**"
                                                                if lowprice then message = message.." @everyone" end
                                                                PerformHttpRequest('https://discordapp.com/api/webhooks/640567792084451328/BZ7YRxRbJ2Hh6j3-PEaI3_Jcc8DYet_DGmY_qioK8La7ZeJI_K3uHBvEwQBNnnmuttxm', function(err, text, headers) end, 'POST', json.encode({username = "Server " .. GetConvar("servernumber","0") .." - Bilforhandler", content = message}), { ['Content-Type'] = 'application/json' })

                                                                TriggerClientEvent('quantum-notify:notify', target, 'Bilforhandler', 'Du er blevet solgt en ' .. spawn, 'success', 5000)
                                                            else
                                                                TriggerClientEvent('quantum-notify:notify', player, 'Bilforhandler', 'Personen har ikke nok penge', 'error', 5000)
                                                            end
                                                        else
                                                            TriggerClientEvent('quantum-notify:notify', player, 'Bilforhandler', 'Du har annulleret handlen', 'error', 5000)
                                                        end
                                                    end)
                                                else
                                                    TriggerClientEvent('quantum-notify:notify', player, 'Bilforhandler', 'Beløbet skal være over 0,- DKK', 'error', 5000)
                                                end
                                            end
                                        end)
                                    else
                                        TriggerClientEvent('quantum-notify:notify', player, 'Bilforhandler', 'Køretøjs Typen: ' .. veh_type .. ' findes ikke', 'error', 5000)
                                    end
                                end)
                            end)
                        else
                            TriggerClientEvent('quantum-notify:notify', player, 'Bilforhandler', 'ID: ' .. target .. ' er ikke online', 'error', 5000)
                        end
                    else
                        TriggerClientEvent('quantum-notify:notify', player, 'Bilforhandler', 'Du skal skrive et ID', 'error', 5000)
                    end
                end)
            else
                TriggerClientEvent('quantum-notify:notify', player, 'Bilforhandler', 'Ingen spillere i nærheden', 'error', 5000)
            end
        end)
    end
end

function format_thousands(v)
    local s = string.format("%d", math.floor(v))
    local pos = string.len(s) % 3
    if pos == 0 then pos = 3 end
    return string.sub(s, 1, pos) .. string.gsub(string.sub(s, pos+1), "(...)", ".%1")
end

local player_customs = {}

local function ch_display_custom(player, choice)
    vRPclient.getCustomization(player,{},function(custom)
        if player_customs[player] then -- hide
            player_customs[player] = nil
            vRPclient.removeDiv(player,{"customization"})
        else -- show
            local content = ""
            for k,v in pairs(custom) do
                content = content..k.." => "..json.encode(v).."<br />"
            end

            player_customs[player] = true
            vRPclient.setDiv(player,{"customization",".div_customization{ margin: auto; padding: 8px; width: 500px; margin-top: 80px; background: black; color: white; font-weight: bold; ", content})
        end
    end)
end

local function ch_noclip(player, choice)
    local user_id = vRP.getUserId(player)
    vRPclient.toggleNoclip(player, {}, function(data) end)
end



local function ch_freezeplayer(player, choice)
    local user_id = vRP.getUserId(player)
    vRP.prompt(player,"ID:","",function(player,user_id)
        local frozenplayer = vRP.getUserSource(tonumber(user_id))
        if frozenplayer == nil then
            TriggerClientEvent('quantum-notify:notify', player, 'Admin Notifikation', 'ID: ' .. user_id .. ' er ikke online', 'error', 5000)
        else
            TriggerClientEvent('quantum-notify:notify', player, 'Admin Notifikation', 'Du har frosset/optøet ID: ' .. user_id, 'info', 5000)
            vRPclient.toggleFreeze(frozenplayer, {})
        end
    end)
end

local function ch_spawnvehicle(player, choice)
    vRP.prompt(player,"Køretøjets modelnavn f.eks. adder:","",function(player,veh)
        if veh ~= "" then
            TriggerClientEvent("hp:spawnvehicle",player,veh)
        end
    end)
end

local function ch_deletevehicle(player, choice)
    TriggerClientEvent("hp:deletevehicle", player)
end

local function ch_unlockvehicle(player, choice)
    vRPclient.vehicleUnlockAdmin(player)
end

vRP.registerMenuBuilder("main", function(add, data)
    local user_id = vRP.getUserId(data.player)
    if user_id ~= nil then
        local choices = {}

        -- build admin menu
        choices["> Admin"] = {function(player,choice)

            local menu = {name="Admin menu",css={top="75px",header_color="#0d1624"}}
            menu.onclose = function(player) vRP.openMainMenu(player) end -- nest menu

            if vRP.hasPermission(user_id,"player.list") then
                menu["> Brugerliste"] = {ch_list,"Vis/Gem"}
            end
            if vRP.hasPermission(user_id,"player.group.add") then
                menu["Tilføj job"] = {ch_addgroup}
            end
            if vRP.hasPermission(user_id,"player.group.remove") then
                menu["Fjern job"] = {ch_removegroup}
            end
            if vRP.hasPermission(user_id,"player.group.add.staff") then
                menu["Tilføj job/rang"] = {ch_addgroup_staff}
            end
            if vRP.hasPermission(user_id,"player.group.remove.staff") then
                menu["Fjern job/rang"] = {ch_removegroup_staff}
            end
            if vRP.hasPermission(user_id,"player.kick") then
                menu["Kick"] = {ch_kick}
            end
            if vRP.hasPermission(user_id,"staff.seizable") then
                menu["Fjern items"] = {ch_seize}
            end
            if vRP.hasPermission(user_id,"player.ban") then
                menu["Ban"] = {ch_ban}
            end
            if vRP.hasPermission(user_id,"player.unban") then
                menu["Unban"] = {ch_unban}
            end
            if vRP.hasPermission(user_id,"player.freeze") then
                menu["Frys/optø spiller"] = {ch_freezeplayer}
            end
            if vRP.hasPermission(user_id,"admin.revive") then
                menu["Genopliv spiller"] = {ch_revivePlayer}
            end
            if vRP.hasPermission(user_id,"player.repairvehicle") then
                menu["Reparer køretøj"] = {ch_repairVehicle}
            end
            if vRP.hasPermission(user_id,"player.noclip") then
                menu["> Noclip"] = {ch_noclip}
            end
            if vRP.hasPermission(user_id,"player.spawnvehicle") then
                menu["Spawn køretøj"] = {ch_spawnvehicle}
            end
            if vRP.hasPermission(user_id,"player.deletevehicle") then
                menu["Fjern køretøj"] = {ch_deletevehicle}
            end
            if vRP.hasPermission(user_id,"player.unlockvehicle") then
                menu["Lås køretøj op"] = {ch_unlockvehicle}
            end
            if vRP.hasPermission(user_id,"player.coords") then
                menu["Koordinater"] = {ch_coords}
            end
            if vRP.hasPermission(user_id,"player.tptome") then
                menu["TP person til mig"] = {ch_tptome}
            end
            if vRP.hasPermission(user_id,"player.tpto") then
                menu["TP til person"] = {ch_tpto}
            end
            if vRP.hasPermission(user_id,"player.tpto") then
                menu["TP til koordinater"] = {ch_tptocoords}
            end
            if vRP.hasPermission(user_id,"player.list") then
                menu["Visiter Spiller"] = {admin_check}
            end
            if vRP.hasPermission(user_id,"player.tptowaypoint") then
                menu["TP til waypoint"] = {ch_tptowaypoint} -- teleport user to map blip
            end
            if vRP.hasPermission(user_id,"player.givemoney") then
                menu["Spawn penge"] = {ch_givemoney}
            end
            if vRP.hasPermission(user_id,"player.giveitem") then
                menu["Spawn ting"] = {ch_giveitem}
            end
            if vRP.hasPermission(user_id,"player.calladmin") then
                menu["> Tilkald staff"] = {ch_calladmin}
            end
            if vRP.hasPermission(user_id,"admin.bilforhandler") then
                menu["Sælg bil"] = {choice_bilforhandler}
            end
			if vRP.hasPermission(user_id,"player.whitelist") then
                menu["Whitelist"] = {ch_whitelist}
            end
			if vRP.hasPermission(user_id,"player.unwhitelist") then
                menu["Unwhitelist"] = {ch_unwhitelist}
            end

            vRP.openMenu(player,menu)
        end}

        add(choices)
    end
end)

-- admin god mode
-- function task_god()
-- SetTimeout(10000, task_god)

-- for k,v in pairs(vRP.getUsersByPermission("admin.god")) do
-- vRP.setHunger(v, 0)
-- vRP.setThirst(v, 0)

-- local player = vRP.getUserSource(v)
-- if player ~= nil then
-- vRPclient.setHealth(player, {200})
-- end
-- end
-- end

-- task_god()

function sendToDiscord2(discord, name, message)
    if message == nil or message == '' or message:sub(1, 1) == '/' then return FALSE end
    PerformHttpRequest(discord, function(err, text, headers) end, 'POST', json.encode({username = name,content = message}), { ['Content-Type'] = 'application/json' })
end
