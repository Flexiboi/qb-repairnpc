local QBCore = exports['qb-core']:GetCoreObject()

QBCore.Functions.CreateCallback('qb-npcrepair:server:hasrepair', function(source, cb, what)
    local Player = QBCore.Functions.GetPlayer(source)
    if Player.PlayerData.money.cash >= Config.repaircost then
        cb(true)
    else
        cb(false)
    end
end)

QBCore.Functions.CreateCallback('qb-npcrepair:server:hascolor', function(source, cb, what)
    local Player = QBCore.Functions.GetPlayer(source)
    if Player.PlayerData.money.cash >= Config.colorcost then
        cb(true)
    else
        cb(false)
    end
end)

RegisterNetEvent('qb-npcrepair:server:removemoney', function(amount)
    local src = source
    local Player = QBCore.Functions.GetPlayer(source)
    Player.Functions.RemoveMoney("cash", amount, "hersenlozemaken")
end)