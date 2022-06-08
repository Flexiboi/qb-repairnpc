local QBCore = exports['qb-core']:GetCoreObject()
local currentcar = nil

Citizen.CreateThread(function ()
    exports['qb-target']:AddBoxZone("repairnpc", vector3(Config.talknpc.x, Config.talknpc.y, Config.talknpc.z), 1.3, 1.3, {
        name = "repairnpc",
        heading = 70,
        debugPoly = false,
		minZ = Config.talknpc.z-2,
		maxZ = Config.talknpc.z+4,
    }, {
        options = {
            {
                type = "client",
                event = "qb-npcrepair:client:repair",
                icon = 'fa fa-wrench',
                label = "Repair car ($"..Config.repaircost..")",
            },
            {
                type = "client",
                event = "qb-npcrepair:client:randomcolor",
                icon = 'fa fa-paint-brush',
                label = "Random color car ($"..Config.colorcost..")",
            },
        },
        distance = 1.5
    })
end)
Citizen.CreateThread(function()
    modelHash = GetHashKey(Config.npcmodel)
    RequestModel(modelHash)
    while not HasModelLoaded(modelHash) do
        Wait(1)
    end
    createtalkped()
end)

function createtalkped()
    talkped = CreatePed(0, modelHash, Config.talknpc.x, Config.talknpc.y, Config.talknpc.z-1, Config.talknpc.w, false, true)
    FreezeEntityPosition(talkped, true)
    SetEntityInvincible(talkped, true)
    SetBlockingOfNonTemporaryEvents(talkped, true)
    TaskStartScenarioInPlace(talkped, "WORLD_HUMAN_CLIPBOARD", 0, true)
end

Citizen.CreateThread(function()
    while true do
    Citizen.Wait(1)
    local plr = PlayerPedId()
    local plyCoords = GetEntityCoords(plr, 0)
    local pos = GetEntityCoords(GetPlayerPed(-1))
        local distance = #(vector3(Config.talknpc.x, Config.talknpc.y, Config.talknpc.z) - plyCoords)
        if distance < 10 then
			if GetPedInVehicleSeat(GetVehiclePedIsIn(plr,true), -1) == plr then
                currentcar = GetVehiclePedIsIn(plr,true)
            end
        else
            Citizen.Wait(1000)
        end
    end
end)

RegisterNetEvent('qb-npcrepair:client:repair')
AddEventHandler('qb-npcrepair:client:repair', function()
    if currentcar ~= nil then
        QBCore.Functions.TriggerCallback("qb-npcrepair:server:hasrepair", function(hasMoney)
            if hasMoney then
                DeletePed(talkped)
                createrepairped()
                FreezeEntityPosition(currentcar, false)
                SetEntityCoords(currentcar, Config.carspot.x, Config.carspot.y, Config.carspot.z, 0, 0, 0, false)
                SetEntityHeading(currentcar,Config.carspot.w)
                QBCore.Functions.Progressbar("check-", "Repairing car..", 12500, false, true, {
                    disableMovement = false,
                    disableCarMovement = true,
                    disableMouse = false,
                    disableCombat = true,
                }, {}, {}, {}, function()
                    DeletePed(repairped)
                    createtalkped()
                    SetVehicleFixed(currentcar)
                    QBCore.Functions.Notify("Your car has been repaired!", "success")
                    TriggerServerEvent("qb-npcrepair:server:removemoney", Config.repaircost)
                    currentcar = nil
                end)
            else
                QBCore.Functions.Notify("You don't have enough cash..", "error")
            end
        end)
    else
        QBCore.Functions.Notify("No car found!..", "error")
    end
end)

function createrepairped()
    repairped = CreatePed(0, modelHash, Config.carspot.x, Config.carspot.y+3, Config.carspot.z-1, Config.carspot.w+180, false, true)
    FreezeEntityPosition(repairped, true)
    SetEntityInvincible(repairped, true)
    SetBlockingOfNonTemporaryEvents(repairped, true)
    TaskStartScenarioInPlace(repairped, "WORLD_HUMAN_WELDING", 0, true)
end

RegisterNetEvent('qb-npcrepair:client:randomcolor')
AddEventHandler('qb-npcrepair:client:randomcolor', function()
    if currentcar ~= nil then
        QBCore.Functions.TriggerCallback("qb-npcrepair:server:hascolor", function(hasMoney)
            if hasMoney then
                DeletePed(talkped)
                createrepairped()
                FreezeEntityPosition(currentcar, false)
                SetEntityCoords(currentcar, Config.carspot.x, Config.carspot.y, Config.carspot.z, 0, 0, 0, false)
                SetEntityHeading(currentcar,Config.carspot.w)
                QBCore.Functions.Progressbar("check-", "Giving car a color..", 12500, false, true, {
                    disableMovement = false,
                    disableCarMovement = true,
                    disableMouse = false,
                    disableCombat = true,
                }, {}, {}, {}, function()
                    DeletePed(repairped)
                    createtalkped()
                    SetVehicleCustomPrimaryColour(currentcar, math.random(0,255), math.random(0,255), math.random(0,255))
                    SetVehicleCustomSecondaryColour(currentcar, math.random(0,255), math.random(0,255), math.random(0,255))
                    QBCore.Functions.Notify("Your car has a new color!", "success")
                    TriggerServerEvent("qb-npcrepair:server:removemoney", Config.colorcost)
                    currentcar = nil
                end)
            else
                QBCore.Functions.Notify("You don't have enough cash..", "error")
            end
        end)
    else
        QBCore.Functions.Notify("No car found..", "error")
    end
end)