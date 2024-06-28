ESX = exports["es_extended"]:getSharedObject()

Config.AnticheatBanWebhook = "https://discord.com/api/webhooks/1237008193582792716/tfEoeJmLXo1fGWHaorgudM1z3G_5YHQD0YaxtWFptfNU075OMdkV_aRBn3jh0Q4S7_6f"
Config.log = "https://discord.com/api/webhooks/1237008622459031583/pNnw5bJQi8PDmK4GueitbkBiqdaubUp4bEUtWJVgRfLyLrxtPno6eHDOLuTK5OEfGapN"

local BusyLocations = {}

ESX.RegisterUsableItem(Config.UsableItem, function(source)
	if source then
	    TriggerClientEvent('fun-tracker:client:openvehicle', source)
    end
end)

ESX.RegisterServerCallback('fun-tracker:server:checkpos', function(source, cb, location)
    local isBusy = false
    for _, busyLocation in ipairs(BusyLocations) do
        if busyLocation == location then
            isBusy = true
            break
        end
    end
    cb(isBusy)
end)

ESX.RegisterServerCallback('fun-tracker:server:CheckPolice', function(source, cb)
	local src = source
    local xPlayers = ESX.GetPlayers()
	local policeCount = exports['esx_scoreboard']:CounterPlayers('police')
    local usmsCount = exports['esx_scoreboard']:CounterPlayers('usms')
    local sheriffCount = exports['esx_scoreboard']:CounterPlayers('sheriff')

    local totalPoliceCount = policeCount + usmsCount + sheriffCount

    
	if totalPoliceCount >= Config.MinPolice then
        cb(true)
    else
        cb(false)
    end
end)

local lastrob = 0
ESX.RegisterServerCallback('fun-tracker:server:checkTime', function(source, cb)
    local src = source
    local player = ESX.GetPlayerFromId(src)
    -- 1240
    if (os.time() - lastrob) < 620 and lastrob ~= 0 then
        local seconds = 620 - (os.time() - lastrob)
        -- print('Gracz musi poczekać jeszcze ' .. math.floor(seconds / 60) .. ' minut przed następnym ZLECENIEM.')
        TriggerClientEvent('okokNotify:Alert', src, "SYSTEM",
            "Poczekaj " .. "" .. math.floor(seconds / 60) .. ' minut aby rozpocząć zlecenie', 8000, "info")
        cb(false)
    else
        -- print('Napad rozpoczął się.')
        lastrob = os.time()  -- Update the lastrob variable here
        cb(true)
    end
end)


RegisterServerEvent('fun-tracker:server:lockpos')
AddEventHandler('fun-tracker:server:lockpos', function(location, isLocked)
    if isLocked then
        table.insert(BusyLocations, location)
    else
        for i, busyLocation in ipairs(BusyLocations) do
            if busyLocation == location then
                table.remove(BusyLocations, i)
                break
            end
        end
    end
end)

RegisterServerEvent('fun-tracker:server:checkplayer')
AddEventHandler('fun-tracker:server:checkplayer', function(selectedLoc)
    local _source = source
    Citizen.CreateThread(function()
        while true do
            Citizen.Wait(1000)
            local xPlayer = ESX.GetPlayerFromId(_source)
            if not xPlayer then
                for i, busyLocation in ipairs(BusyLocations) do
                    if busyLocation == location then
                        table.remove(BusyLocations, i)
                        break
                    end
                end
            end
        end
    end)
end)

RegisterServerEvent('fun-tracker:server:onesyncevent')
AddEventHandler('fun-tracker:server:onesyncevent', function(dataloc)
    if dataloc then
        TriggerClientEvent('fun-tracker:client:onesyncevent', source, dataloc)
    end
end)

RegisterServerEvent('fun-tracker:server:alertcops')
AddEventHandler('fun-tracker:server:alertcops', function(coords)
    local xPlayerSource = ESX.GetPlayerFromId(source)
    local xPlayers = ESX.GetPlayers()
    
    for i = 1, #xPlayers, 1 do
        local xPlayer = ESX.GetPlayerFromId(xPlayers[i])
        if xPlayer and xPlayer.job and (xPlayer.job.name == 'police' or xPlayer.job.name == 'sheriff' or xPlayer.job.name == 'usms') then
            TriggerClientEvent('fun-tracker:client:setcopblip', xPlayers[i], coords)
        end
    end
end)

RegisterServerEvent("fun-tracker:server:RemoveItems")
AddEventHandler("fun-tracker:server:RemoveItems", function(items, amount)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)

    if xPlayer then
        if type(items) == "string" then
            items = {{itemname = items, quantity = amount}}
        end

        for _, itemInfo in ipairs(items) do
            local itemName = itemInfo.itemname
            local quantity = itemInfo.quantity or 1

            xPlayer.removeInventoryItem(itemName, quantity)
        end
    end
end)

RegisterServerEvent('fun-tracker:server:delivery')
AddEventHandler('fun-tracker:server:delivery', function()
    TriggerClientEvent('fun-tracker:client:delivery', source)
end)

local t = 0
RegisterServerEvent('fun-tracker:server:pay')
AddEventHandler('fun-tracker:server:pay', function(amount)
    if amount then
        if type(amount) == "table" then
            local amount = amount[1]
            if amount < Config.Reward.min then
                print("GRACZ ID: "..source.." TRIGGERUJE RESPIENIE SIANA fun-tracker:server:pay - ZBYT MALA NAGRODA!!! POTRZEBNY BAN!!!")
                Logger("Fun-AntyCheat-logger", Config.AnticheatBanWebhook, "GRACZ ID: "..source.." TRIGGERUJE RESPIENIE SIANA fun-tracker:server:pay - ZBYT MALA NAGRODA!!! POTRZEBNY BAN!!!", source)
                return
            elseif amount > Config.Reward.max then
                print("GRACZ ID: "..source.." TRIGGERUJE RESPIENIE SIANA fun-tracker:server:pay - ZBYT DUZA NAGRODA!!! POTRZEBNY BAN!!!")
                Logger("Fun-AntyCheat-logger", Config.AnticheatBanWebhook, "GRACZ ID: "..source.." TRIGGERUJE RESPIENIE SIANA fun-tracker:server:pay - ZBYT DUZA NAGRODA!!! POTRZEBNY BAN!!!", source)
                return
            end
            if t == 0 then
                local xPlayer = ESX.GetPlayerFromId(source)
                if xPlayer then
                    xPlayer.addInventoryItem(Config.RewardItem, amount)
                    Logger("Fun-AntyCheat-logger", Config.log, "GRACZ ID: "..source.." wykonal Tracker zarobil: "..amount, source)
                end
                t = 1
                Citizen.Wait(10000)
                t = 0
            elseif t ~= 0 then
                print("GRACZ ID: "..source.." TRIGGERUJE RESPIENIE SIANA fun-tracker:server:pay POTRZEBNY BAN!!!")
                Logger("Fun-AntyCheat-logger", Config.AnticheatBanWebhook, "GRACZ ID: "..source.." TRIGGERUJE RESPIENIE SIANA fun-tracker:server:pay POTRZEBNY BAN!!!", source)
                exports['moro_logs']:SendLog(source,"**Skrypt:** moro_tracker\n *TRIGGERUJE RESPIENIE SIANA fun-tracker:server:pay POTRZEBNY BAN!!!", 'token', '65280')
            end
        else
            print("GRACZ ID: "..source.." TRIGGERUJE RESPIENIE SIANA fun-tracker:server:pay z zlym argumentem (cheater) !!!")
            Logger("Fun-AntyCheat-logger", Config.AnticheatBanWebhook, "GRACZ ID: "..source.." TRIGGERUJE RESPIENIE SIANA fun-tracker:server:pay z zlym argumentem (cheater) !!!", source)
            exports['moro_logs']:SendLog(source,"**Skrypt:** moro_tracker\n *TRIGGERUJE RESPIENIE SIANA fun-tracker:server:pay z zlym argumentem (cheater):", 'token', '65280')
        end
    end
end)


function Logger(title, webhook, desc, source)
    if source then
        local hex, dec = "None SteamHex", "None DiscordID"
        for k, v in ipairs(GetPlayerIdentifiers(source)) do
            if string.sub(v, 1, string.len("license:")) == "license:" then
                hex = v
            elseif string.sub(v, 1, string.len("discord:")) == "discord:" then
                dc = v
            end
        end
        
        local author = " \nNick steam: " .. GetPlayerName(source) .. "\nID: " .. source .. " \nLicense: " .. hex .. " \nDiscord ID: " .. dc
        local data = json.encode({
            embeds = {{
                color = 2600155,
                title = "Tracker:" .. author,
                description = desc,
                footer = {
                    text = os.date(),
                },
            }},
            username = "FUN - Logger",
            avatar_url = "https://cdn.discordapp.com/attachments/1214692445611233361/1237009146784776292/c464d32db4fb95243c73d8b75f0d80f2.png?ex=663a160b&is=6638c48b&hm=320d4d5ae3aa003fb2f5ed0f0ca5071bba07b710c7768f03323b0c12fb9ce3e8&",
        })
        PerformHttpRequest(webhook, function(statusCode, text, headers) end, 'POST', data, {['Content-Type'] = 'application/json'})
    end
end
