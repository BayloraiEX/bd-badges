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

function Bridge.GetPlayerJob()
    if framework == 'qbx' then
        local playerData = exports.qbx_core:GetPlayerData()
        return playerData and playerData.job
    else
        local playerData = QBCore.Functions.GetPlayerData()
        return playerData and playerData.job
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

function Bridge.HasItem(itemName)
    if not itemName then return true end

    if inventory == 'ox' then
        local count = exports.ox_inventory:Search('count', itemName)
        return count and count > 0
    else
        local hasItem = exports['qb-inventory']:HasItem(itemName)
        if type(hasItem) == 'number' then
            return hasItem > 0
        end
        return hasItem == true
    end
end

function Bridge.Notify(msg, notifyType)
    exports.ox_lib:notify({ type = notifyType or 'inform', description = msg })
end
