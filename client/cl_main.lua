ESX = exports["es_extended"]:getSharedObject()

local hasTask = false
local notified = false
local veh
local vehicleModel = nil
local vehiclecoords = nil
local tasklocation = nil
local reciveTarget

local policegps = false

Citizen.CreateThread(function()
    loadModel(C.Ped.model)
    local npc = CreatePed(4, C.Ped.model, C.Ped.pos[1], C.Ped.pos[2], C.Ped.pos[3] - 1, false, false)
    SetEntityHeading(npc, C.Ped.pos[4])
    SetPedHearingRange(npc, 0.0)
    SetEntityInvincible(npc, true)
    FreezeEntityPosition(npc, true)
    SetPedSeeingRange(npc, 0.0)
    TaskSetBlockingOfNonTemporaryEvents(npc, true)

    AddTargetZone("interact", vector3(C.Ped.pos[1], C.Ped.pos[2], C.Ped.pos[3]), vector3(2.0, 2.0, 2.0), C.Ped.pos[4],"fa-solid fa-comments", S['talk'], function()
        AttemptTask()
    end)
end)

function AttemptTask()
    ESX.TriggerServerCallback('fun-tracker:server:CheckPolice', function(state)
        if state then
            ESX.TriggerServerCallback("fun-tracker:server:checkTime", function(cb)
                if cb then
                    if not hasTask then
                        local vehicleModel = GetRandomVehicle()
                        GetRandomLocation(function(vehicleLocation)
                            if vehicleLocation and vehicleModel then
                                Notify(S['guy'], S['goto']:format(vehicleModel), 'info')
                                TriggerServerEvent('fun-tracker:server:onesyncevent', vehicleLocation)
                                DisanceChecker(vehicleLocation, vehicleModel)
                                tasklocation = vehicleLocation
                                vehiclemodel = vehicleModel
                                hasTask = true
                            end
                        end)
                    else
                        Notify(S['guy'], S['hastask'], 'error')
                    end
                end
            end)
        else
            Notify(S['guy'], S['nopolice'], 'error')
        end
    end)
end

function GetRandomVehicle()
    return C.Vehicles[math.random(#C.Vehicles)]
end

function GetRandomLocation(callback)
    local trys = 0
    local selectedLoc = math.random(#C.Locations)
    ESX.TriggerServerCallback('fun-tracker:server:checkpos', function(pos)
        if not pos then
            TriggerServerEvent('fun-tracker:server:lockpos', selectedLoc, true)
            TriggerServerEvent('fun-tracker:server:checkplayer', selectedLoc)
            callback(C.Locations[selectedLoc].pos)
        else
            GetRandomLocation(callback)
        end
    end, selectedLoc)
end

RegisterNetEvent('fun-tracker:client:onesyncevent')
AddEventHandler('fun-tracker:client:onesyncevent', function(dataloc)
    LocationBlip(dataloc)
end)

function LocationBlip(coords)
    local move_x, move_y = math.random(-130, 130), math.random(-130, 130)

    blipMapa = AddBlipForRadius(coords.x + move_x, coords.y + move_y, coords.z, 200.0)
    SetBlipHighDetail(blipMapa, true)
    SetBlipColour(blipMapa, 1)
    SetBlipAlpha(blipMapa, 100)
end

function DisanceChecker(coords, model)
    local played = false
    local spawned = false
    if coords then
        Citizen.CreateThread(function()
            while true do
                Citizen.Wait(0)
                local ped = PlayerPedId()
                local pedCo = GetEntityCoords(ped)
                local dist = #(pedCo - vector3(coords[1], coords[2], coords[3]))
                if dist <= 90.0 then
                    if not spawned then
                        if ESX.Game.IsSpawnPointClear(vector3(coords[1], coords[2], coords[3]), 5) then
                            loadModel(model)
                            ESX.Game.SpawnVehicle(model, vector3(coords[1], coords[2], coords[3]), coords[4], function(vehicle)
                                if DoesEntityExist(vehicle) then
                                    veh = vehicle
                                    local randomColorPrimary = math.random(0, 159)
                                    local randomColorSecondary = math.random(0, 159)
                                    SetVehicleColours(vehicle, randomColorPrimary, randomColorSecondary)

                                    SetVehicleDoorShut(vehicle, 0, true)
                                    SetVehicleDoorsLocked(vehicle, 2)
									SetVehicleMaxMods(vehicle, livery, offroad, wheelsxd, color,
                                    {}, -- Passing an empty table instead of data2.current.extrason
                                    {}, -- Passing an empty table instead of data2.current.extrasoff
                                    bulletproof, tint, wheel, tuning)

                                    vehiclecoords = GetEntityCoords(vehicle)


                                    if Config.RadomPlates then
                                        SetVehicleNumberPlateText(vehicle, Config.Plates[math.random(1, #Config.Plates)])
                                    end
                                end
                            end)
                        else
                            ClearAreaOfEverything(vector3(coords[1], coords[2], coords[3]), 10.0, false, false, false, false)
                            loadModel(model)
                            ESX.Game.SpawnVehicle(model, vector3(coords[1], coords[2], coords[3]), coords[4], function(vehicle)
                                if DoesEntityExist(vehicle) then
                                    local randomColorPrimary = math.random(0, 159)
                                    local randomColorSecondary = math.random(0, 159)
                                    SetVehicleColours(vehicle, randomColorPrimary, randomColorSecondary)

                                    SetVehicleDoorShut(vehicle, 0, true)
                                    SetVehicleDoorsLocked(vehicle, 2)
									SetVehicleMaxMods(vehicle, livery, offroad, wheelsxd, color,
                                    {}, -- Passing an empty table instead of data2.current.extrason
                                    {}, -- Passing an empty table instead of data2.current.extrasoff
                                    bulletproof, tint, wheel, tuning)

                                    vehiclecoords = GetEntityCoords(vehicle)


                                    if Config.RadomPlates then
                                        SetVehicleNumberPlateText(vehicle, Config.Plates[math.random(1, #Config.Plates)])
                                    end
                                end
                            end)
                        end
                        spawned = true
                    end
                end
                if dist <= 10.0 then
                    if not played then
                        PlaySoundFrontend(-1, "BASE_JUMP_PASSED", "HUD_AWARDS", 0, 1)
                        RemoveBlip(blipMapa)
                        played = true
                    end
                end
            end 
        end)
    end
end


-- Define SetVehicleMaxMods function
function SetVehicleMaxMods(vehicle, livery, offroad, wheelsxd, color, extrason, extrasoff, bulletproof, tint, wheel, tuning)
	local t = {
		modArmor        = 0,
		modTurbo        = true,
		modXenon        = true,
		bulletProofTyre = false,
		windowTint      = 0,
		dirtLevel       = 0,
		-- color1          = 0,
		-- color2          = 0,
		modEngine = 3,
		modBrakes = 2,
		modTransmission = 2,
		modSuspension = 3,
	}

	if tuning then
		t.modEngine = 3
		t.modBrakes = 2
		t.modTransmission = 2
		t.modSuspension = 3
	end

	if offroad then
		t.wheelColor = 5
		t.wheels = 4
		t.modFrontWheels = 17
	end

	if wheelsxd then
		t.wheels = 1
		t.modFrontWheels = 5
	end

	if bulletproof then
		t.bulletProofTyre = true
	end

	if color then
		t.color1 = color
	end

	if tint then
		t.windowTint = tint
	end

	if wheel then
		t.wheelColor = wheel.color
		t.wheels = wheel.group
		t.modFrontWheels = wheel.type
	end

	ESX.Game.SetVehicleProperties(vehicle, t)

	if extrason then
		for i = 1, #extrason do
			SetVehicleExtra(vehicle, extrason[i], false)
		end
	end

	if extrasoff then
		for i = 1, #extrasoff do
			SetVehicleExtra(vehicle, extrasoff[i], true)
		end
	end

	if livery then
		SetVehicleLivery(vehicle, livery)
	end
end

RegisterNetEvent('fun-tracker:client:openvehicle')
AddEventHandler('fun-tracker:client:openvehicle', function()
    local unlocked = false
    local played = false
    local coords = vehiclecoords
    Citizen.CreateThread(function()
        while true do 
            Citizen.Wait(0)
            local pedCo = GetEntityCoords(PlayerPedId())
            local dist = #(pedCo - coords)
            if dist <= 2.5 then
                if hasTask then
                    if not played and not unlocked then
                        loadAnimDict("anim@amb@clubhouse@tutorial@bkr_tut_ig3@")
                        TaskPlayAnim(PlayerPedId(), "anim@amb@clubhouse@tutorial@bkr_tut_ig3@", "machinic_loop_mechandplayer", 3.5, 1.0, -1, 11, 0.0, 0, 0, 0)
                        -- local success = nil
                        -- if Config.Debug then
                        --     success = true
                        -- else
                            success = lib.skillCheck({ 'easy', 'easy', { areaSize = 60, speedMultiplier = 2 }, 'medium' },{ 'w', 'a', 's', 'd' })
                        -- end
                        if success then
                            TriggerServerEvent("fun-tracker:server:RemoveItems", Config.UsableItem, 1)
                            unlocked = true
                            SetVehicleDoorsLocked(veh, 1)
                            ClearPedTasksImmediately(PlayerPedId())
                            DispachAlert(coords, vehiclemodel)
                            policegps = true
                            Notify(S['guy'], S['tracker'], 'info')
                            PlayerCoords(PlayerPedId())
                            VehicleCheck()
                            Wait(420000) -- 420000
                            policegps = false
                            Notify(S['guy'], S['trackerdead'], 'success')
                            if hasTask then 
                                TriggerServerEvent('fun-tracker:server:delivery')
                            end
                        else
                            Notify(S['guy'], "Nie udało ci się otworzyć pojazdu", 'info')
                            ClearPedTasksImmediately(PlayerPedId())
                            TriggerServerEvent("fun-tracker:server:RemoveItems", Config.UsableItem, 1)
                        end

                        played = true
                    end
                end
            end
        end
    end)
end)

function PlayerCoords(ped)
    if ped then
        Citizen.CreateThread(function()
            while policegps do
                Citizen.Wait(3000)
                if DoesEntityExist(veh) then
                    local coords = GetEntityCoords(veh)
                    TriggerServerEvent('fun-tracker:server:alertcops', coords)
                end
            end
        end)
    end
end 

function VehicleCheck()
    Citizen.CreateThread(function()
        Citizen.Wait(5000)
        while hasTask do
            Citizen.Wait(500)
            local currveh = GetVehiclePedIsUsing(PlayerPedId())
            if currveh ~= 0 and GetHashKey(currveh) == GetHashKey(veh) and hasTask then
            else
                Notify(S['guy'], S['backveh'], 'info')
                local timer = 0
                while timer < 60 and (currveh == 0 or GetHashKey(currveh) ~= GetHashKey(veh)) do
                    Wait(1000)
                    timer = timer + 1
                    playerPed = PlayerPedId()
                    currveh = GetVehiclePedIsUsing(playerPed)
                end
                if timer >= 60 and (currveh == 0 or GetHashKey(currveh) ~= GetHashKey(veh)) then
                    Notify(S['guy'], S['error'], 'info')
                    AbortDelivery()
                    hasTask = false
                end
            end
        end
    end)
end

RegisterNetEvent('fun-tracker:client:setcopblip')
AddEventHandler('fun-tracker:client:setcopblip', function(coords)
    local copblip = AddBlipForCoord(coords)
    SetBlipSprite(copblip, 227)
    SetBlipScale(copblip, 0.8)
    SetBlipColour(copblip, 8)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString("Kradziony pojazd")
    EndTextCommandSetBlipName(copblip)
    PulseBlip(copblip)

    Wait(1500)

    RemoveBlip(copblip)
end)

function AbortDelivery()
    if hasTask then
        Citizen.Wait(5000)
        SetEntityAsNoLongerNeeded(veh)
        SetVehicleEngineHealth(veh, 0)
        RemoveBlip(deliveryblip)
        policegps = false
        veh = nil
        vehiclecoords = nil
        hasTask = false
        TriggerServerEvent('fun-tracker:server:lockpos', tasklocation, false)
        tasklocation = nil
    else
        Citizen.Wait(5000)
        SetEntityAsNoLongerNeeded(veh)
        SetVehicleEngineHealth(veh, 0)
        RemoveBlip(deliveryblip)
        policegps = false
        veh = nil
        vehiclecoords = nil
        hasTask = false
        TriggerServerEvent('fun-tracker:server:lockpos', tasklocation, false)
        tasklocation = nil
    end
end

RegisterNetEvent('fun-tracker:client:delivery')
AddEventHandler('fun-tracker:client:delivery', function()
    local deliveryPoint = C.Delivery[math.random(1, #C.Delivery)]

    deliveryblip = AddBlipForCoord(deliveryPoint.pos)
    SetBlipSprite(deliveryblip, 1)
    SetBlipDisplay(deliveryblip, 4)
    SetBlipScale(deliveryblip, 1.0)
    SetBlipColour(deliveryblip, 5)
    SetBlipAsShortRange(deliveryblip, true)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString("Punkt Dostawy")
    EndTextCommandSetBlipName(deliveryblip)
    SetBlipRoute(deliveryblip, true)

    loadModel(C.Ped.model2)
    npc2 = CreatePed(4, C.Ped.model2, deliveryPoint.pos[1], deliveryPoint.pos[2], deliveryPoint.pos[3]-1, false, false)
    SetEntityHeading(npc2, deliveryPoint.pos[4])
    SetPedHearingRange(npc2, 0.0)
    SetEntityInvincible(npc2, true)
    FreezeEntityPosition(npc2, true)
    SetPedSeeingRange(npc2, 0.0)
    TaskSetBlockingOfNonTemporaryEvents(npc2, true)

    reciveTarget = exports.ox_target:addBoxZone({
        coords = vector3(deliveryPoint.pos[1], deliveryPoint.pos[2], deliveryPoint.pos[3]),
        size = vec3(2.0, 2.0, 2.0),
        rotation = deliveryPoint.pos[4],
        debug = false,
        drawSprite = false,
        options = {
            {
                name = "fun-tracker:target:recivetask",
                icon = 'fa-regular fa-comment',
                label = "oddaj pojazd",
                onSelect = function()
                    if hasTask then
                        if GetVehiclePedIsUsing(PlayerPedId() == veh) then
                            SetEntityAsNoLongerNeeded(GetVehiclePedIsUsing(PlayerPedId()))
                            DeleteEntity(GetVehiclePedIsUsing(PlayerPedId()))
                            DeleteEntity(veh)
                            RemoveBlip(deliveryblip)
                    
                            local finalpayment = math.random(Config.Reward.min, Config.Reward.max)
                            local procent = (deliveryPoint.price / finalpayment) * 100
                            local reward = finalpayment + procent
                            TriggerServerEvent('fun-tracker:server:pay', {reward})
                    
                            exports.ox_target:removeZone(reciveTarget)
                            hasTask = false
                            DeletePed(npc2)
                            veh = nil
                            vehiclecoords = nil
                            TriggerServerEvent('fun-tracker:server:lockpos', tasklocation, false)
                            tasklocation = nil
                        else
                            print('gowno')
                        end
                    end
                end,
                distance = 5.0,
            },
        },
    })
end)

