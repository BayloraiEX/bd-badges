local showingBadge = false
local lastUse = 0

local function canShowBadge()
    local job = Bridge.GetPlayerJob()
    local dept = job and Config.Departments[job.name]

    if not dept then
        return false, nil, nil
    end

    return true, job, dept
end

local function hasBadgeItem(dept)
    if not Config.RequireItem then return true end
    if not dept.badgeItem then return true end

    return Bridge.HasItem(dept.badgeItem)
end

local function playBadgeAnim()
    local dict = Config.Animation.dict
    RequestAnimDict(dict)

    local timeout = GetGameTimer() + 2000
    while not HasAnimDictLoaded(dict) and GetGameTimer() < timeout do
        Wait(10)
    end

    local ped = PlayerPedId()
    TaskPlayAnim(ped, dict, Config.Animation.anim, 3.0, 3.0, -1, Config.Animation.flag, 0, false, false, false)
    Wait(Config.Animation.duration)
    ClearPedTasks(ped)
end

local function showBadge()
    if showingBadge then return end

    local now = GetGameTimer()
    if now - lastUse < Config.Cooldown then
        Bridge.Notify('You just showed your badge, wait a moment.', 'error')
        return
    end

    local authorized, job, dept = canShowBadge()
    if not authorized then
        Bridge.Notify('You are not authorized to show a badge.', 'error')
        return
    end

    if not hasBadgeItem(dept) then
        Bridge.Notify("You don't have a badge on you.", 'error')
        return
    end

    showingBadge = true
    lastUse = now

    playBadgeAnim()

    local coords = GetEntityCoords(PlayerPedId())
    TriggerServerEvent('bd-badges:server:broadcastBadge', coords, job.name)

    showingBadge = false
end

RegisterCommand(Config.Command, showBadge, false)

if Config.Keybind then
    RegisterKeyMapping(Config.Command, 'Show Police Badge', 'keyboard', Config.Keybind)
end

RegisterNetEvent('bd-badges:client:playBadgeAnim', function()
    playBadgeAnim()
end)

RegisterNetEvent('bd-badges:client:displayBadge', function(jobName, officerName, callsign, rank, signature)
    local dept = Config.Departments[jobName]
    if not dept then return end

    SendNUIMessage({
        action = 'showBadge',
        department = dept.label,
        idTitle = dept.idTitle or dept.label,
        image = dept.badgeImage,
        color = dept.color,
        officer = officerName,
        callsign = callsign,
        rank = rank,
        signature = signature,
        duration = Config.DisplayTime
    })
end)
