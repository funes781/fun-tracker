function loadAnimDict(dict)
    while not HasAnimDictLoaded(dict) do
        RequestAnimDict(dict)
        Citizen.Wait(50)
    end
end

function loadModel(model)
    if type(model) == 'number' then
        model = model
    else
        model = GetHashKey(model)
    end
    while not HasModelLoaded(model) do
        RequestModel(model)
        Citizen.Wait(0)
    end
end

function AddTargetZone(name, coords, size, heading, icon, label, onSelect, distance)
    if distance ~= nil then
        local zone = exports.ox_target:addBoxZone({
            coords = coords,
            size = size,
            rotation = heading,
            debug = Config.TargetDebugMode,
            drawSprite = Config.ShowTargetSprite,
            options = {
                {
                    name = name,
                    icon = icon,
                    label = label,
                    onSelect = onSelect,
                    distance = distance,
                },
            },
        })
    else
        local zone = exports.ox_target:addBoxZone({
            coords = coords,
            size = size,
            rotation = heading,
            debug = Config.TargetDebugMode,
            drawSprite = Config.ShowTargetSprite,
            options = {
                {
                    name = name,
                    icon = icon,
                    label = label,
                    onSelect = onSelect,
                    distance = Config.TargetDefaultDistance,
                },
            },
        })
    end
end

function Notify(title, message, type)
    if Config.Notifications == "ox_lib" then
        if type == "success" then
            lib.notify({
                title = title,
                description = message,
                type = 'success',
                duration = 5000,
            })
        elseif type == "error" then
            lib.notify({
                title = title,
                description = message,
                type = 'error',
                duration = 5000,
            })
        elseif type == "info" then
            lib.notify({
                title = title,
                description = message,
                type = 'inform',
                duration = 5000,
            })
        end
    elseif Config.Notifications == "okokNotify" then
        if type == "success" then
            exports['okokNotify']:Alert(title, message, 5000, 'success')
        elseif type == "error" then
            exports['okokNotify']:Alert(title, message, 5000, 'error')
        elseif type == "info" then
            exports['okokNotify']:Alert(title, message, 5000, 'info')
        end
    elseif Config.Notifications == "esx" then
        ESX.ShowHelpNotification(message, false, false, -1)
    elseif Config.Notifications == "custom" then
        print('ADD CUSTOM NOTIFICATIONS')
    end
end

function DispachAlert(coords, vehiclemodel)
    local przyklad = {
        code = "10-90",
        street = "Model: "..vehiclemodel,
        id = exports['esx_dispatch']:randomId(),
        priority = 8,
        title = "Kradziez pojazdu",
        duration = 10000,
        blipname = "#[10-90] Kradziez pojazdu!",
        color = 1,
        sprite = 161,
        fadeOut = 60,
        position = {
            x = coords.x,
            y = coords.y,
            z = coords.z
        },
        job = "police"
    }
    TriggerServerEvent("dispatch:svNotify", przyklad)
end