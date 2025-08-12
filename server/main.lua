local QBCore = exports['qb-core']:GetCoreObject()

RegisterNetEvent('lf-animalride:server:useSaddle', function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end
    Player.Functions.RemoveItem(Config.SaddleItem, 1)
end)

RegisterNetEvent('lf-animalride:server:returnSaddle', function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end
    Player.Functions.AddItem(Config.SaddleItem, 1)
end)

RegisterNetEvent('lf-animalride:server:returnSpawnItem', function(itemName)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end
    Player.Functions.AddItem(itemName, 1)
end)

RegisterNetEvent('lf-animalride:server:removeItem', function(itemName)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end
    Player.Functions.RemoveItem(itemName, 1)
end)

for itemName, itemData in pairs(Config.SpawnItems) do
    QBCore.Functions.CreateUseableItem(itemName, function(source, item)
        local Player = QBCore.Functions.GetPlayer(source)
        if not Player then return end
        TriggerClientEvent('lf-animalride:client:spawnAnimal', source, itemData.model, item.name)
    end)
end


QBCore.Functions.CreateUseableItem('animal_stimulant', function(source)
    TriggerClientEvent('lf-animalride:client:applySpeedBoost', source)
end)

QBCore.Functions.CreateUseableItem('ironhide_apple', function(source)
    TriggerClientEvent('lf-animalride:client:applyInvincibility', source)
end)