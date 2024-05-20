local Tunnel = module("vrp", "lib/Tunnel")
local Proxy = module("vrp", "lib/Proxy")
local htmlEntities = module("vrp", "lib/htmlEntities")

vRPbm = {}
vRP = exports['vrp']:getObject()
vRPclient = Tunnel.getInterface("vRP","vRP_basic_menu")
BMclient = Tunnel.getInterface("vRP_basic_menu","vRP_basic_menu")
vRPbsC = Tunnel.getInterface("vRP_barbershop","vRP_basic_menu")
Tunnel.bindInterface("vrp_basic_menu",vRPbm)

local Lang = module("vrp", "lib/Lang")
local cfg = module("vrp", "cfg/base")
local lang = Lang.new(module("vrp", "cfg/lang/"..cfg.lang) or {})

local spikes = {}
local ch_spikes = {function(player,choice)
    local user_id = vRP.getUserId(player)
    BMclient.isCloseToSpikes(player,{},function(closeby)
        if closeby and (spikes[player] or vRP.hasPermission(user_id,"admin.spikes")) then
            BMclient.removeSpikes(player,{})
            spikes[player] = false
        elseif closeby and not spikes[player] and not vRP.hasPermission(user_id,"admin.spikes") then
            TriggerClientEvent("pNotify:SendNotification", player,{text = "Du kan kun bære et sæt sømmåtter!", type = "warning", queue = "global", timeout = 5000, layout = "centerRight",animation = {open = "gta_effects_open", close = "gta_effects_close"}})
        elseif not closeby and spikes[player] and not vRP.hasPermission(user_id,"admin.spikes") then
            TriggerClientEvent("pNotify:SendNotification", player,{text = "Du kan kun udstyre et sæt sømmåtte!", type = "warning", queue = "global", timeout = 5000, layout = "centerRight",animation = {open = "gta_effects_open", close = "gta_effects_close"}})
        elseif not closeby and (not spikes[player] or vRP.hasPermission(user_id,"admin.spikes")) then
            BMclient.setSpikesOnGround(player,{})
            spikes[player] = true
        end
    end)
end, "Smidt sømmåtter."}

--store money
local choice_store_money = {function(player, choice)
    local user_id = vRP.getUserId(player)
    if user_id ~= nil then
        local amount = vRP.getMoney(user_id)
        if vRP.tryPayment(user_id, amount) then -- unpack the money
            vRP.giveInventoryItem(user_id, "money", amount, true)
        end
    end
end, "Gem penge i din taske."}


--loot corpse
local choice_loot = {function(player,choice)
    local user_id = vRP.getUserId(player)
    if user_id ~= nil then
        vRPclient.getNearestPlayer(player,{2},function(nplayer)
            local nuser_id = vRP.getUserId(nplayer)
            if nuser_id ~= nil then
                if vRP.hasGroup(nuser_id,"Politi-Job") or vRP.hasGroup(nuser_id,  "DVS") == false  then
                    vRPclient.isInComa(nplayer,{}, function(in_coma)
                        if in_coma then
                            local revive_seq = {
                                {"amb@medic@standing@kneel@enter","enter",1},
                                {"amb@medic@standing@kneel@idle_a","idle_a",1},
                                {"amb@medic@standing@kneel@exit","exit",1}
                            }
                            vRPclient.playAnim(player,{false,revive_seq,false}) -- anim
                            SetTimeout(15000, function()
                                local ndata = vRP.getUserDataTable(nuser_id)
                                local fields = {}
                                if ndata ~= nil then
                                    if ndata.inventory ~= nil then -- gives inventory items
                                        vRP.clearInventory(nuser_id,false)
                                        local items = ""
                                        for k,v in pairs(ndata.inventory) do
                                            vRP.giveInventoryItem(user_id,k,v.amount,true)
                                            items = items.."\n"..k.." ("..v.amount..")"
                                        end
                                        table.insert(fields, { name = "Inventory:", value = items })
                                    end

                                    local nmoney = vRP.getMoney(nuser_id)
                                    if nmoney > 0 then
                                        if vRP.tryPayment(nuser_id,nmoney) then
                                            vRP.giveMoney(user_id,nmoney)
                                            table.insert(fields, { name = "Penge:", value = nmoney})
                                        end
                                    end

                                    vRPclient.getWeapons(nplayer,{},function(weapons)
                                        local vitems = ""
                                        for k,v in pairs(weapons) do
                                            -- convert weapons to parametric weapon items
                                            vRP.giveInventoryItem(user_id, "wbody|"..k, 1, true)
                                            vitems = vitems.."\nwbody|"..k.." (1)"
                                            if v.ammo > 0 then
                                                vitems = vitems.."\nwammo|"..k.." ("..v.ammo..")"
                                                vRP.giveInventoryItem(user_id, "wammo|"..k, v.ammo, true)
                                            end
                                        end
                                        -- clear all weapons
                                        vRPclient.giveWeapons(nplayer,{{},true})
                                        if vitems ~= "" then table.insert(fields, { name = "Equiped:", value = vitems }) end
                                        PerformHttpRequest('https://discordapp.com/api/webhooks/642435109076729886/01E2zivPKqy3Q56pFeicWZ0LtFwv6Vt5BYP1Cx5z7Al1aS6ZdrQBjNAmVvgbZAFufQaE', function(err, text, headers) end, 'POST', json.encode(
                                            {
                                                username = "Server "..GetConvar("servernumber", "1").." - Loot",
                                                content = "**".. tostring(user_id).. "** har lige lootet **".. tostring(nuser_id) .. "**",
                                                embeds = {
                                                    {
                                                        color = 16769280,
                                                        fields = fields
                                                    }
                                                }
                                            }), { ['Content-Type'] = 'application/json' })
                                    end)
                                end
                            end)
                            vRPclient.stopAnim(player,{false})
                        else
                            TriggerClientEvent("pNotify:SendNotification", player,{text = "Ikke i koma!", type = "error", queue = "global", timeout = 5000, layout = "centerRight",animation = {open = "gta_effects_open", close = "gta_effects_close"}})
                        end
                    end)
                else
                    TriggerClientEvent("pNotify:SendNotification", player,{text = "Du kan ikke loote en betjent!", type = "error", queue = "global", timeout = 5000, layout = "centerRight",animation = {open = "gta_effects_open", close = "gta_effects_close"}})
                end
            else
                TriggerClientEvent("pNotify:SendNotification", player,{text = "Ingen spiller nær dig", type = "info", queue = "global", timeout = 5000, layout = "centerRight",animation = {open = "gta_effects_open", close = "gta_effects_close"}})
            end
        end)
    end
end,"Røv den nærmeste!"}
-- STRIPS
vRP.defInventoryItem("strip","Strips","Bruges til og binde folk", function(args)
    local choices = {}
    choices["> Brug"] = {function(player,choice)
        local user_id = vRP.getUserId(player)
        if user_id ~= nil then
            vRPclient.getNearestPlayer(player,{1},function(nplayer)
                local nuser_id = vRP.getUserId(nplayer)
                if nuser_id ~= nil then
                    if vRP.tryGetInventoryItem(user_id, "strip", 1, true) then
                        vRPclient.setStriped(nplayer,{true})
                    end
                else
                    TriggerClientEvent("pNotify:SendNotification", player,{text = "Ingen personer nær dig", type = "error", queue = "global", timeout = 4000, layout = "bottomCenter",animation = {open = "gta_effects_fade_in", close = "gta_effects_fade_out"}})
                end
            end)
            vRP.closeMenu(player)
        end
    end,"Bind den nærmeste person"}

    return choices
end, 0.05)

-- drag player
local ch_drag = {function(player,choice)
    -- get nearest player
    local user_id = vRP.getUserId(player)
    if user_id ~= nil then
        vRPclient.getNearestPlayer(player,{10},function(nplayer)
            if nplayer ~= nil then
                local nuser_id = vRP.getUserId(nplayer)
                if nuser_id ~= nil then
                    vRPclient.canBeDragged(nplayer,{},function(handcuffed)
                        if handcuffed then
                            TriggerClientEvent("dr:drag", nplayer, player)
                        else
                            TriggerClientEvent("pNotify:SendNotification", player,{text = "Spilleren er ikke i håndjern.", type = "error", queue = "global", timeout = 5000, layout = "centerRight",animation = {open = "gta_effects_open", close = "gta_effects_close"}})
                        end
                    end)
                else
                    TriggerClientEvent("pNotify:SendNotification", player,{text = "Ingen spiller nær dig", type = "error", queue = "global", timeout = 5000, layout = "centerRight",animation = {open = "gta_effects_open", close = "gta_effects_close"}})
                end
            else
                TriggerClientEvent("pNotify:SendNotification", player,{text = "Ingen spiller nær dig", type = "error", queue = "global", timeout = 5000, layout = "centerRight",animation = {open = "gta_effects_open", close = "gta_effects_close"}})
            end
        end)
    end
end, "Løft den nærmeste spiller."}

-- Kropsvisiter spiller menu
local choice_user_check = {function(player,choice)
    vRPclient.getNearestPlayer(player,{5},function(nplayer)
        local nuser_id = vRP.getUserId(nplayer)
        if nuser_id ~= nil then
            TriggerClientEvent("pNotify:SendNotification", player,{text = "Anmoder...", type = "info", queue = "global", timeout = 3000, layout = "centerRight",animation = {open = "gta_effects_open", close = "gta_effects_close"}})
            vRP.request(nplayer,"Vil du visiteres?",30,function(nplayer,ok)
                if ok then
                    vRPclient.getWeapons(nplayer,{},function(weapons)
                        -- prepare display data (money, items, weapons)
                        local money = vRP.getMoney(nuser_id)
                        local items = ""
                        local data = vRP.getUserDataTable(nuser_id)
                        if data and data.inventory then
                            for k,v in pairs(data.inventory) do
                                local item_name = vRP.getItemName(k)
                                if item_name then
                                    items = items.."<br />"..item_name.." ("..v.amount..")"
                                end
                            end
                        end

                        local weapons_info = ""
                        for k,v in pairs(weapons) do
                            weapons_info = weapons_info.."<br />"..k.." ("..v.ammo..")"
                        end

                        vRPclient.setDiv(player,{"police_check",".div_police_check{ background-color: rgba(0,0,0,0.75); color: white; font-weight: bold; width: 500px; padding: 10px; margin: auto; margin-top: 150px; }",lang.police.menu.check.info({money,items,weapons_info})})
                        -- request to hide div
                        vRP.request(player, "Luk vindue", 1000, function(player,ok)
                            vRPclient.removeDiv(player,{"police_check"})
                        end)
                    end)
                else
                    TriggerClientEvent("pNotify:SendNotification", player,{text = "Anmodning nægtet!", type = "error", queue = "global", timeout = 3000, layout = "centerRight",animation = {open = "gta_effects_open", close = "gta_effects_close"}})
                end
            end)
        else
            TriggerClientEvent("pNotify:SendNotification", player,{text = "Ingen spiller nær dig", type = "error", queue = "global", timeout = 3000, layout = "centerRight",animation = {open = "gta_effects_open", close = "gta_effects_close"}})
        end
    end)
end, "Visitere nærmeste person"}

-- armor item
vRP.defInventoryItem("body_armor","Body Armor","Gem vest.",
    function(args)
        local choices = {}

        choices["Equip"] = {function(player,choice)
            local user_id = vRP.getUserId(player)
            if user_id ~= nil then
                if vRP.tryGetInventoryItem(user_id, "body_armor", 1, true) then
                    BMclient.setArmour(player,{100,true})
                    vRP.closeMenu(player)
                end
            end
        end}

        return choices
    end,
5.00)

-- store armor
local choice_store_armor = {function(player, choice)
    local user_id = vRP.getUserId(player)
    if user_id ~= nil then
        BMclient.getArmour(player,{},function(armour)
            if armour > 95 then
                vRP.giveInventoryItem(user_id, "body_armor", 1, true)
                -- clear armor
                BMclient.setArmour(player,{0,false})
            else
                TriggerClientEvent("pNotify:SendNotification", player,{text = "Smadret veste kan ikke opbevares!", type = "error", queue = "global", timeout = 5000, layout = "centerRight",animation = {open = "gta_effects_open", close = "gta_effects_close"}})
            end
        end)
    end
end, "Gem armor i din taske."}

local unjailed = {}
function jail_clock(target_id,timer)
    local target = vRP.getUserSource(tonumber(target_id))
    local users = vRP.getUsers()
    local online = false
    for k,v in pairs(users) do
        if tonumber(k) == tonumber(target_id) then
            online = true
        end
    end
    if online then
        if timer>0 then
            TriggerClientEvent("pNotify:SendNotification", target,{text = "Tid tilbage: " .. timer .. " minut(ter).", type = "error", queue = "global", timeout = 5000, layout = "centerRight",animation = {open = "gta_effects_open", close = "gta_effects_close"}})
            vRP.setUData(tonumber(target_id),"vRP:jail:time",json.encode(timer))
            SetTimeout(60*1000, function()
                for k,v in pairs(unjailed) do -- check if player has been unjailed by cop or admin
                    if v == tonumber(target_id) then
                        unjailed[v] = nil
                        timer = 0
                    end
                end
                vRP.setHunger(tonumber(target_id), 0)
                vRP.setThirst(tonumber(target_id), 0)
                jail_clock(tonumber(target_id),timer-1)
            end)
        else
            BMclient.loadFreeze(target,{false,true,true})
            SetTimeout(15000,function()
                BMclient.loadFreeze(target,{false,false,false})
            end)

            vRPclient.teleport(target,{1846.2209472656,2585.8195800781,45.672046661377}) -- teleport to outside jail
            vRPclient.setHandcuffed(target,{false})
            TriggerClientEvent("pNotify:SendNotification", target,{text = "Du er sat fri", type = "info", queue = "global", timeout = 5000, layout = "centerRight",animation = {open = "gta_effects_open", close = "gta_effects_close"}})
            vRP.setUData({tonumber(target_id),"vRP:jail:time",json.encode(-1)})
        end
    end
end

-- dynamic jail
local ch_jail = {function(player,choice)
    vRPclient.getNearestPlayers(player,{15},function(nplayers)
        local user_list = ""
        for k,v in pairs(nplayers) do
            user_list = user_list .. "[" .. vRP.getUserId({k}) .. "]" .. GetPlayerName(k) .. " | "
        end
        if user_list ~= "" then
            vRP.prompt(player,"Spillere i nærheden:" .. user_list,"",function(player,target_id)
                if target_id ~= nil and target_id ~= "" then
                    vRP.prompt(player,"Fængsels tid i minutter:","1",function(player,jail_time)
                        if jail_time ~= nil and jail_time ~= "" then
                            local target = vRP.getUserSource(tonumber(target_id))
                            if target ~= nil then
                                if tonumber(jail_time) > 750 then
                                    jail_time = 750
                                end
                                if tonumber(jail_time) < 1 then
                                    jail_time = 1
                                end

                                vRPclient.isHandcuffed(target,{}, function(handcuffed)
                                    if handcuffed then
                                        BMclient.loadFreeze(target,{false,true,true})
                                        SetTimeout(15000,function()
                                            BMclient.loadFreeze(target,{false,false,false})
											vRPclient.setHandcuffed(target,{false})
                                        end)
                                        vRPclient.teleport(target,{1708.1635742188,2594.5412597656,50.188068389893}) -- teleport to inside jail
                                        TriggerClientEvent("pNotify:SendNotification", target,{text = "Du er blevet sendt til fængsel", type = "info", queue = "global", timeout = 5000, layout = "centerRight",animation = {open = "gta_effects_open", close = "gta_effects_close"}, sounds = { sources = {"jail.ogg"}, volume = 0.5, conditions = {"docVisible"}}})
                                        TriggerClientEvent("pNotify:SendNotification", player,{text = "Du sendte en spiller til fængsel", type = "info", queue = "global", timeout = 5000, layout = "centerRight",animation = {open = "gta_effects_open", close = "gta_effects_close"}})
                                        vRP.setHunger(tonumber(target_id), 0)
                                        vRP.setThirst(tonumber(target_id), 0)
                                        jail_clock(tonumber(target_id),tonumber(jail_time))
                                        local user_id = vRP.getUserId(player)

                                        PerformHttpRequest('https://discordapp.com/api/webhooks/613052187572043860/7z7eF2XYEa4VUp2FeZ12KJVrzKXOHcofIk0yYzo36UEkoG54f22NcL_hq4aCL3SKy3D_', function(err, text, headers) end, 'POST', json.encode({username = "Server " .. GetConvar("servernumber","0").." - Fængsel", content = "**"..user_id .. "** fængslet **"..target_id.."** i **" .. jail_time .. " minut(ter)**"}), { ['Content-Type'] = 'application/json' })
                                    else
                                        TriggerClientEvent("pNotify:SendNotification", player,{text = "Spilleren ikke i håndjern.", type = "error", queue = "global", timeout = 5000, layout = "centerRight",animation = {open = "gta_effects_open", close = "gta_effects_close"}})
                                    end
                                end)
                            else
                                TriggerClientEvent("pNotify:SendNotification", player,{text = "Det id virker ugyldigt", type = "error", queue = "global", timeout = 5000, layout = "centerRight",animation = {open = "gta_effects_open", close = "gta_effects_close"}})
                            end
                        else
                            TriggerClientEvent("pNotify:SendNotification", player,{text = "Fængselstiden kan ikke være tom", type = "error", queue = "global", timeout = 5000, layout = "centerRight",animation = {open = "gta_effects_open", close = "gta_effects_close"}})
                        end
                    end)
                else
                    TriggerClientEvent("pNotify:SendNotification", player,{text = "Ingen spiller ID valgt", type = "error", queue = "global", timeout = 5000, layout = "centerRight",animation = {open = "gta_effects_open", close = "gta_effects_close"}})
                end
            end)
        else
            TriggerClientEvent("pNotify:SendNotification", player,{text = "Ingen spiller i nærheden", type = "error", queue = "global", timeout = 5000, layout = "centerRight",animation = {open = "gta_effects_open", close = "gta_effects_close"}})
        end
    end)
end,"Send en nærgående spiller til fængsel."}

-- dynamic unjail
local ch_unjail = {function(player,choice)
    vRP.prompt(player,"Spiller ID:","",function(player,target_id)
        if target_id ~= nil and target_id ~= "" then
            vRP.getUData(tonumber(target_id),"vRP:jail:time",function(value)
                if value ~= nil then
                    custom = json.decode(value)
                    if custom ~= nil then
                        local user_id = vRP.getUserId(player)
                        if tonumber(custom) > 0 or vRP.hasPermission(user_id,"admin.easy_unjail") then
                            local target = vRP.getUserSource(tonumber(target_id))
                            if target ~= nil then
                                unjailed[target] = tonumber(target_id)
                                TriggerClientEvent("pNotify:SendNotification", player,{text = "Mål vil blive frigivet snart", type = "info", queue = "global", timeout = 5000, layout = "centerRight",animation = {open = "gta_effects_open", close = "gta_effects_close"}})
                                TriggerClientEvent("pNotify:SendNotification", target,{text = "Nogen sank din dom", type = "info", queue = "global", timeout = 5000, layout = "centerRight",animation = {open = "gta_effects_open", close = "gta_effects_close"}})

                                PerformHttpRequest('https://discordapp.com/api/webhooks/613052187572043860/7z7eF2XYEa4VUp2FeZ12KJVrzKXOHcofIk0yYzo36UEkoG54f22NcL_hq4aCL3SKy3D_', function(err, text, headers) end, 'POST', json.encode({username = "Server " .. GetConvar("servernumber","0").." - Befriet", content = "**"..user_id .. "** befriet **"..target_id.."** fra sin dom på **" .. custom .. " minut(ter)**"}), { ['Content-Type'] = 'application/json' })
                            else
                                TriggerClientEvent("pNotify:SendNotification", player,{text = "Det id virker ugyldigt", type = "error", queue = "global", timeout = 5000, layout = "centerRight",animation = {open = "gta_effects_open", close = "gta_effects_close"}})
                            end
                        else
                            TriggerClientEvent("pNotify:SendNotification", player,{text = "Mål er ikke fængslet", type = "error", queue = "global", timeout = 5000, layout = "centerRight",animation = {open = "gta_effects_open", close = "gta_effects_close"}})
                        end
                    end
                end
            end)
        else
            TriggerClientEvent("pNotify:SendNotification", player,{text = "Ingen spiller ID valgt", type = "error", queue = "global", timeout = 5000, layout = "centerRight",animation = {open = "gta_effects_open", close = "gta_effects_close"}})
        end
    end)
end,"Frigør en fængslet spiller."}

-- (server) called when a logged player spawn to check for vRP:jail in user_data
AddEventHandler("vRP:playerSpawn", function(user_id, source, first_spawn)
    local target = vRP.getUserSource(user_id)
    SetTimeout(35000,function()
        local custom = {}
        vRP.getUData(user_id,"vRP:jail:time",function(value)
            if value ~= nil then
                custom = json.decode(value)
                if custom ~= nil then
                    if tonumber(custom) > 0 then
                        BMclient.loadFreeze(target,{false,true,true})
                        SetTimeout(15000,function()
                            BMclient.loadFreeze(target,{false,false,false})
                        end)
                        vRPclient.setHandcuffed(target,{true})
                        vRPclient.teleport(target,{1641.5477294922,2570.4819335938,45.564788818359}) -- teleport inside jail
                        vRPclient.notify(target,{"~r~Færdiggør din dom."})
                        vRP.setHunger(tonumber(user_id), 0)
                        vRP.setThirst(tonumber(user_id), 0)
                        jail_clock(tonumber(user_id),tonumber(custom))
                    end
                end
            end
        end)
    end)
end)

-- dynamic fine
local ch_fine = {function(player,choice)
    vRPclient.getNearestPlayers(player,{5},function(nplayers)
        local user_list = ""
        for k,v in pairs(nplayers) do
            user_list = user_list .. "[" .. vRP.getUserId(k) .. "]" .. GetPlayerName(k) .. " | "
        end
        if user_list ~= "" then
            vRP.prompt(player,"Spillere i nærheden: " .. user_list,"",function(player,target_id)
                if target_id ~= nil and target_id ~= "" then
                    vRP.prompt(player,"Bøde værdi:","",function(player,fine)
                        if fine ~= nil and fine ~= "" then
                            vRP.prompt(player,"Bøde grund:","",function(player,reason)
                                if reason ~= nil and reason ~= "" then
                                    local target = vRP.getUserSource(tonumber(target_id))
                                    if target ~= nil then
                                        if tonumber(fine) > 1000000 then
                                            fine = 1000000
                                        end
                                        if tonumber(fine) < 100 then
                                            fine = 100
                                        end
                                        local payment = vRP.tryBankPaymentOrDebt(tonumber(target_id), tonumber(fine))
                                        if payment ~= false then
                                            vRP.insertPoliceRecord(tonumber(target_id), lang.police.menu.fine.record({reason,fine}))
                                            TriggerClientEvent("pNotify:SendNotification", player,{text = "Du gav en bøde på "..fine.." DKK for: "..reason, type = "info", queue = "global", timeout = 5000, layout = "centerRight",animation = {open = "gta_effects_open", close = "gta_effects_close"}})
                                            if payment == "paid" then
                                                TriggerClientEvent("pNotify:SendNotification", target,{text = "Du modtog en bøde på "..fine.." DKK for: "..reason, type = "info", queue = "global", timeout = 5000, layout = "centerRight",animation = {open = "gta_effects_open", close = "gta_effects_close"}})
                                            else
                                                TriggerClientEvent("pNotify:SendNotification", target,{text = "Du modtog en bøde på "..fine.." DKK for: "..reason.."<br>Nuværende gæld: <b style='color: #DB4646'>"..format_thousands(payment).." DKK</b>", type = "info", queue = "global", timeout = 5000, layout = "centerRight",animation = {open = "gta_effects_open", close = "gta_effects_close"}})
                                            end
                                            local user_id = vRP.getUserId(player)
                                            PerformHttpRequest('https://discordapp.com/api/webhooks/613052187572043860/7z7eF2XYEa4VUp2FeZ12KJVrzKXOHcofIk0yYzo36UEkoG54f22NcL_hq4aCL3SKy3D_', function(err, text, headers) end, 'POST', json.encode({username = "Server " .. GetConvar("servernumber","0").." - Bøde", content = "**"..user_id .. "** har givet en bøde til **"..target_id.."** på **" .. fine .. "** med grunden: ".. reason}), { ['Content-Type'] = 'application/json' })
                                            vRP.closeMenu(player)
                                        else
                                            TriggerClientEvent("pNotify:SendNotification", player,{text = "Ikke nok penge!", type = "error", queue = "global", timeout = 5000, layout = "centerRight",animation = {open = "gta_effects_open", close = "gta_effects_close"}})
                                        end
                                    else
                                        TriggerClientEvent("pNotify:SendNotification", player,{text = "Det id virker ugyldigt", type = "error", queue = "global", timeout = 5000, layout = "centerRight",animation = {open = "gta_effects_open", close = "gta_effects_close"}})
                                    end
                                else
                                    TriggerClientEvent("pNotify:SendNotification", player,{text = "Du kan ikke bøde uden grund", type = "error", queue = "global", timeout = 5000, layout = "centerRight",animation = {open = "gta_effects_open", close = "gta_effects_close"}})
                                end
                            end)
                        else
                            TriggerClientEvent("pNotify:SendNotification", player,{text = "Din bøde skal have en værdi", type = "error", queue = "global", timeout = 5000, layout = "centerRight",animation = {open = "gta_effects_open", close = "gta_effects_close"}})
                        end
                    end)
                else
                    TriggerClientEvent("pNotify:SendNotification", player,{text = "Ingen spiller ID valgt", type = "error", queue = "global", timeout = 5000, layout = "centerRight",animation = {open = "gta_effects_open", close = "gta_effects_close"}})
                end
            end)
        else
            TriggerClientEvent("pNotify:SendNotification", player,{text = "Ingen spiller i nærheden", type = "error", queue = "global", timeout = 5000, layout = "centerRight",animation = {open = "gta_effects_open", close = "gta_effects_close"}})
        end
    end)

end,"Bøder en nærgående spiller."}

-- dynamic freeze
local ch_freeze = {function(player,choice)
    local user_id = vRP.getUserId(player)
    if vRP.hasPermission(user_id,"admin.bm_freeze") then
        vRP.prompt(player,"Spiller ID:","",function(player,target_id)
            if target_id ~= nil and target_id ~= "" then
                local target = vRP.getUserSource({tonumber(target_id)})
                if target ~= nil then
                    TriggerClientEvent("pNotify:SendNotification", player,{text = "Du frøs/un-frøs en spiller.", type = "info", queue = "global", timeout = 5000, layout = "centerRight",animation = {open = "gta_effects_open", close = "gta_effects_close"}})
                    BMclient.loadFreeze(target,{true,true,true})
                    local dname = "Server "..GetConvar("servernumber", "1").."- Freeze"
                    local dmessage = "**".. tostring(user_id).. "** har lige frosset **".. tostring(target_id) .. "**"
                    PerformHttpRequest('https://discordapp.com/api/webhooks/603158449651580949/AjR1J_eA_LzBGmY4D3ICZKhg8SV0OtKBwxQ3E36zBl7v0GFSle8hqciJCyHsJDrPaDok', function(err, text, headers) end, 'POST', json.encode({username = dname, content = dmessage}), { ['Content-Type'] = 'application/json' })
                else
                    TriggerClientEvent("pNotify:SendNotification", player,{text = "Det id virker ugyldigt", type = "error", queue = "global", timeout = 5000, layout = "centerRight",animation = {open = "gta_effects_open", close = "gta_effects_close"}})
                end
            else
                TriggerClientEvent("pNotify:SendNotification", player,{text = "Ingen spiller ID valgt", type = "error", queue = "global", timeout = 5000, layout = "centerRight",animation = {open = "gta_effects_open", close = "gta_effects_close"}})
            end
        end)
    else
        vRPclient.getNearestPlayer(player,{10},function(nplayer)
            local nuser_id = vRP.getUserId(nplayer)
            if nuser_id ~= nil then
                TriggerClientEvent("pNotify:SendNotification", player,{text = "Du frøs/un-frøs en spiller.", type = "error", queue = "global", timeout = 5000, layout = "centerRight",animation = {open = "gta_effects_open", close = "gta_effects_close"}})
                BMclient.loadFreeze(nplayer,{true,false,false})
            else
                vRPclient.notify(player,{lang.common.no_player_near()})
            end
        end)
    end
end,"Fryser en spiller."}

local ch_putinveh = {function(player,choice)
    vRPclient.getNearestPlayer(player,{10},function(nplayer)
        local nuser_id = vRP.getUserId(nplayer)
        if nuser_id ~= nil then
            vRPclient.canBeDragged(nplayer,{}, function(handcuffed)  -- check handcuffed
                if handcuffed then
                    vRPclient.putInNearestVehicleAsPassenger(nplayer, {5})
                    TriggerClientEvent("dr:undrag", nplayer)
                else
                    TriggerClientEvent("pNotify:SendNotification", player,{text = {lang.police.not_handcuffed()}, type = "error", queue = "global", timeout = 4000, layout = "centerRight",animation = {open = "gta_effects_fade_in", close = "gta_effects_fade_out"}})
                end
            end)
        else
            TriggerClientEvent("pNotify:SendNotification", player,{text = {lang.common.no_player_near()}, type = "error", queue = "global", timeout = 4000, layout = "centerRight",animation = {open = "gta_effects_fade_in", close = "gta_effects_fade_out"}})
        end
    end)
end,lang.police.menu.putinveh.description() }

local ch_getoutveh = {function(player,choice)
    vRPclient.getNearestPlayer(player,{10},function(nplayer)
        local nuser_id = vRP.getUserId(nplayer)
        if nuser_id ~= nil then
            vRPclient.canBeDragged(nplayer,{}, function(handcuffed)  -- check handcuffed
                if handcuffed then
                    vRPclient.ejectVehicle(nplayer, {})
                else
                    TriggerClientEvent("pNotify:SendNotification", player,{text = {lang.police.not_handcuffed()}, type = "error", queue = "global", timeout = 4000, layout = "centerRight",animation = {open = "gta_effects_fade_in", close = "gta_effects_fade_out"}})
                end
            end)
        else
            TriggerClientEvent("pNotify:SendNotification", player,{text = {lang.common.no_player_near()}, type = "error", queue = "global", timeout = 4000, layout = "centerRight",animation = {open = "gta_effects_fade_in", close = "gta_effects_fade_out"}})
        end
    end)
end,lang.police.menu.getoutveh.description() }

-- REMEMBER TO ADD THE PERMISSIONS FOR WHAT YOU WANT TO USE
-- CREATES PLAYER SUBMENU AND ADD CHOICES
local ch_player_menu = {function(player,choice)
    local user_id = vRP.getUserId(player)
    local menu = {}
    menu.name = "SPILLER"
    menu.css = {top = "75px", header_color = "rgba(0,0,255,0.75)"}
    menu.onclose = function(player) vRP.openMainMenu(player) end -- nest menu

    if vRP.hasPermission(user_id,"player.store_money") then
        menu["Gem Penge"] = choice_store_money -- transforms money in wallet to money in inventory to be stored in houses and cars
    end

    if vRP.hasPermission(user_id,"player.loot") then
        menu["Loot"] = choice_loot
    end

    if vRP.hasPermission(user_id,"player.store_armor") then
        menu["Gem Armor"] = choice_store_armor -- store player armor
    end

    if vRP.hasPermission(user_id,"player.check") then
        menu["Kropsvisiter"] = choice_user_check -- checks nearest player inventory, like police check from vrp
    end
	
    vRP.openMenu(player, menu)
end}

-- REGISTER MAIN MENU CHOICES
vRP.registerMenuBuilder("main", function(add, data)
    local user_id = vRP.getUserId(data.player)
    if user_id ~= nil then
        local choices = {}

        if vRP.hasPermission(user_id,"player.player_menu") then
            choices["Spiller"] = ch_player_menu -- opens player submenu
        end

        add(choices)
    end
end)

-- REGISTER POLICE MENU CHOICES
vRP.registerMenuBuilder("police", function(add, data)
    local user_id = vRP.getUserId(data.player)
    if user_id ~= nil then
        local choices = {}

        if vRP.hasPermission(user_id,"police.store_money") then
            choices["GEM PENGE"] = choice_store_money -- transforms money in wallet to money in inventory to be stored in houses and cars
        end

        if vRP.hasPermission(user_id,"police.easy_jail") then
            choices["FÆNGSEL"] = ch_jail -- Send a nearby handcuffed player to jail with prompt for choice and user_list
        end

        if vRP.hasPermission(user_id,"police.easy_unjail") then
            choices["LØSLAD"] = ch_unjail -- Un jails chosen player if he is jailed (Use admin.easy_unjail as permission to have this in admin menu working in non jailed players)
        end

        if vRP.hasPermission(user_id,"police.easy_fine") then
            choices["BØDE"] = ch_fine -- Fines closeby player
        end

        if vRP.hasPermission(user_id,"police.spikes") then
            choices["SØMMÅTTE"] = ch_spikes -- Toggle spikes
        end

        if vRP.hasPermission(user_id,"police.dragg") then
            choices["LØFT/TAG FAT I"] = ch_drag -- Drags closest handcuffed player
        end

        add(choices)
    end
end)

function format_thousands(v)
    local s = string.format("%d", math.floor(v))
    local pos = string.len(s) % 3
    if pos == 0 then pos = 3 end
    return string.sub(s, 1, pos) .. string.gsub(string.sub(s, pos+1), "(...)", ".%1")
end