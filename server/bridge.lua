Bridge = {}

local framework = Config.Framework

if framework == 'auto' then
    if GetResourceState('qbx_core') == 'started' then
        framework = 'qbx'
    elseif GetResourceState('qb-core') == 'started' then
        framework = 'qbcore'
    end
end

local QBCore = nil
if framework == 'qbcore' then
    QBCore = exports['qb-core']:GetCoreObject()
end

if framework ~= 'qbx' and framework ~= 'qbcore' then
    error('[bd-badges] Could not detect a supported framework (qbx_core or qb-core). Set Config.Framework manually in config.lua.')
end

function Bridge.GetPlayer(src)
    if framework == 'qbx' then
        local player = exports.qbx_core:GetPlayer(src)
        return player and player.PlayerData
    else
        local player = QBCore.Functions.GetPlayer(src)
        return player and player.PlayerData
    end
end

local inventory = Config.Inventory

if inventory == 'auto' then
    if GetResourceState('ox_inventory') == 'started' then
        inventory = 'ox'
    elseif GetResourceState('qb-inventory') == 'started' then
        inventory = 'qb'
    end
end

if inventory ~= 'ox' and inventory ~= 'qb' then
    error('[bd-badges] Could not detect a supported inventory (ox_inventory or qb-inventory). Set Config.Inventory manually in config.lua.')
end

Bridge.InventoryName = inventory

function Bridge.GetItemCount(src, itemName)
    if not itemName then return 1 end

    if inventory == 'ox' then
        return exports.ox_inventory:GetItemCount(src, itemName) or 0
    else
        local item = exports['qb-inventory']:GetItemByName(src, itemName)
        return (item and item.amount) or 0
    end
end

function Bridge.RegisterUsableItems(itemNames, callback)
    if inventory ~= 'qb' then return end

    for _, itemName in ipairs(itemNames) do
        QBCore.Functions.CreateUseableItem(itemName, function(src, item)
            callback(src, item.name or itemName)
        end)
    end
end

function Bridge.Notify(src, msg, notifyType)
    TriggerClientEvent('ox_lib:notify', src, { type = notifyType or 'inform', description = msg })
end
