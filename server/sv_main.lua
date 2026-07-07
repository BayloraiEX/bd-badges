local lastUse = {}

local function isValidSource(src)
    if type(src) ~= 'number' or src <= 0 then return false end

    local ped = GetPlayerPed(src)
    return ped and ped ~= 0
end

local function getSourceCoords(src)
    local ped = GetPlayerPed(src)
    if not ped or ped == 0 then return nil end

    return GetEntityCoords(ped)
end

---@param src number source of the player showing the badge
---@param coords vector3 the player's position at the time they showed the badge
---@param jobName string the job to present (must match the player's actual job)
local function broadcastBadge(src, coords, jobName)
    local now = GetGameTimer()

    if not isValidSource(src) then return false end
    if type(jobName) ~= 'string' then return false end
    if not coords then return false end

    if lastUse[src] and now - lastUse[src] < Config.Cooldown then return false end
    lastUse[src] = now

    local playerData = Bridge.GetPlayer(src)
    if not playerData or not playerData.job then return false end

    if playerData.job.name ~= jobName then return false end

    local dept = Config.Departments[jobName]
    if not dept then return false end

    if Config.RequireItem and dept.badgeItem then
        local count = Bridge.GetItemCount(src, dept.badgeItem)
        if not count or count < 1 then return false end
    end

    local charinfo = playerData.charinfo or {}
    local firstname = charinfo.firstname or 'Unknown'
    local lastname = charinfo.lastname or 'Officer'
    local officerName = ('%s %s'):format(firstname, lastname)
    local signature = ('%s. %s'):format(firstname:sub(1, 1), lastname)
    local callsign = (playerData.metadata and playerData.metadata.callsign)
        or playerData.citizenid
    local rank = playerData.job.grade and playerData.job.grade.name

    for _, playerId in ipairs(GetPlayers()) do
        local targetId = tonumber(playerId)
        if targetId then
            local targetPed = GetPlayerPed(playerId)
            if targetPed and targetPed ~= 0 then
                local targetCoords = GetEntityCoords(targetPed)
                if #(targetCoords - coords) <= Config.Distance then
                    TriggerClientEvent('bd-badges:client:displayBadge', targetId, src, jobName, officerName, callsign, rank, signature)
                end
            end
        end
    end

    return true
end

RegisterNetEvent('bd-badges:server:broadcastBadge', function(jobName)
    local src = source
    local coords = getSourceCoords(src)
    if not coords then return end

    broadcastBadge(src, coords, jobName)
end)

---@param src number
---@param itemName string
local function onBadgeItemUsed(src, itemName)
    if not isValidSource(src) then return false end
    if type(itemName) ~= 'string' then return false end

    local playerData = Bridge.GetPlayer(src)
    if not playerData or not playerData.job then return false end

    local playerJob = playerData.job.name
    local playerDept = Config.Departments[playerJob]

    if not playerDept or playerDept.badgeItem ~= itemName then
        Bridge.Notify(src, "This isn't your department's badge.", 'error')
        return false
    end

    if Config.RequireItem and playerDept.badgeItem then
        local count = Bridge.GetItemCount(src, playerDept.badgeItem)
        if not count or count < 1 then
            Bridge.Notify(src, "You don't have a badge on you.", 'error')
            return false
        end
    end

    local now = GetGameTimer()
    if lastUse[src] and now - lastUse[src] < Config.Cooldown then return false end

    local coords = getSourceCoords(src)
    if not coords then return false end

    TriggerClientEvent('bd-badges:client:playBadgeAnim', src)
    return broadcastBadge(src, coords, playerJob)
end

exports('useBadge', function(event, item, inventory, slot, data)
    if Bridge.InventoryName ~= 'ox' then return end
    if event ~= 'usingItem' then return end
    if type(inventory) ~= 'table' or type(inventory.id) ~= 'number' then return false end
    if type(item) ~= 'table' or type(item.name) ~= 'string' then return false end

    return onBadgeItemUsed(inventory.id, item.name)
end)

AddEventHandler('playerDropped', function()
    lastUse[source] = nil
end)

do
    local badgeItems, seen = {}, {}
    for _, dept in pairs(Config.Departments) do
        if dept.badgeItem and not seen[dept.badgeItem] then
            seen[dept.badgeItem] = true
            badgeItems[#badgeItems + 1] = dept.badgeItem
        end
    end

    Bridge.RegisterUsableItems(badgeItems, onBadgeItemUsed)
end
