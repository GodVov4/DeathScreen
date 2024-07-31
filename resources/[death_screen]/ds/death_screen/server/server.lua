local QBCore = exports['qb-core']:GetCoreObject()

RegisterNetEvent('setPlayerIsDead')
AddEventHandler('setPlayerIsDead', function(isDead)
    local Player = QBCore.Functions.GetPlayer(source)

    if Player then
        Player.Functions.SetMetaData("isDead", isDead)
    end
end)

RegisterNetEvent('removeRandomItem')
AddEventHandler('removeRandomItem', function(stealChance)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local randomItem = nil

    if Player then
        local inventory = Player.PlayerData.items
        if math.random() <= stealChance and #inventory > 0 then
            randomItem = inventory[math.random(1, #inventory)]
            Player.Functions.RemoveItem(randomItem.name, randomItem.amount, randomItem.slot, 'steal')
        end
        TriggerClientEvent('itemRemoved', -1, randomItem)
    end
end)
