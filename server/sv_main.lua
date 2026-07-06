local lastUse = {}

---@param src number source of the player showing the badge
---@param coords vector3 the player's position at the time they showed the badge
---@param jobName string the job to present (must match the player's actual job)
local function broadcastBadge(src, coords, jobName)
    local now = GetGameTimer()

    if lastUse[src] and now - lastUse[src] < Config.Cooldown then return end
    lastUse[src] = now

    local playerData = Bridge.GetPlayer(src)
    if not playerData then return end

    if playerData.job.name ~= jobName then return end

    local dept = Config.Departments[jobName]
    if not dept then return end

    if Config.RequireItem and dept.badgeItem then
        local count = Bridge.GetItemCount(src, dept.badgeItem)
        if not count or count < 1 then return end
    end

    local firstname = playerData.charinfo.firstname
    local lastname = playerData.charinfo.lastname
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
                    TriggerClientEvent('bd-badges:client:displayBadge', targetId, jobName, officerName, callsign, rank, signature)
                end
            end
        end
    end
end

RegisterNetEvent('bd-badges:server:broadcastBadge', function(coords, jobName)
    broadcastBadge(source, coords, jobName)
end)

---@param src number
---@param itemName string
local function onBadgeItemUsed(src, itemName)
    local playerData = Bridge.GetPlayer(src)
    if not playerData then return end

    local playerJob = playerData.job.name
    local playerDept = Config.Departments[playerJob]

    if not playerDept or playerDept.badgeItem ~= itemName then
        Bridge.Notify(src, "This isn't your department's badge.", 'error')
        return false 
    end

    TriggerClientEvent('bd-badges:client:playBadgeAnim', src)

    local coords = GetEntityCoords(GetPlayerPed(src))
    broadcastBadge(src, coords, playerJob)
end

exports('useBadge', function(event, item, inventory, slot, data)
    if Bridge.InventoryName ~= 'ox' then return end
    if event ~= 'usingItem' then return end

    return onBadgeItemUsed(inventory.id, item.name)
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
