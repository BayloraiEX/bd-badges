local showingBadge = false
local lastUse = 0
local badgeVisible = false
local badgeCloseToken = 0

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

local function createBadgePhotoUrl(serverId)
    if not serverId then return nil end

    local player = GetPlayerFromServerId(serverId)
    if player == -1 then return nil end

    local ped = GetPlayerPed(player)
    if not ped or ped == 0 then return nil end

    local handle = RegisterPedheadshot(ped)
    if not handle or handle == -1 then return nil end

    local timeout = GetGameTimer() + 1500
    while (not IsPedheadshotReady(handle) or not IsPedheadshotValid(handle)) and GetGameTimer() < timeout do
        Wait(25)
    end

    if not IsPedheadshotReady(handle) or not IsPedheadshotValid(handle) then
        UnregisterPedheadshot(handle)
        return nil
    end

    local txd = GetPedheadshotTxdString(handle)
    if not txd or txd == '' then
        UnregisterPedheadshot(handle)
        return nil
    end

    CreateThread(function()
        Wait((Config.DisplayTime or 6000) + 1000)
        UnregisterPedheadshot(handle)
    end)

    return ('https://nui-img/%s/%s'):format(txd, txd)
end

local function closeBadge()
    if not badgeVisible then return end

    badgeVisible = false
    badgeCloseToken = badgeCloseToken + 1
    SendNUIMessage({ action = 'hideBadge' })
end

local function watchBadgeClose(token, duration)
    local endTime = GetGameTimer() + (duration or Config.DisplayTime or 6000)

    while badgeVisible and badgeCloseToken == token and GetGameTimer() < endTime do
        if IsPauseMenuActive() then
            closeBadge()
            return
        end

        Wait(100)
    end

    if badgeCloseToken == token then
        badgeVisible = false
    end
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

    TriggerServerEvent('bd-badges:server:broadcastBadge', job.name)

    showingBadge = false
end

RegisterCommand(Config.Command, showBadge, false)

if Config.Keybind then
    RegisterKeyMapping(Config.Command, 'Show Police Badge', 'keyboard', Config.Keybind)
end

RegisterCommand('bd_closebadge', closeBadge, false)

if Config.CloseKey then
    RegisterKeyMapping('bd_closebadge', 'Close Badge', 'keyboard', Config.CloseKey)
end

RegisterNetEvent('bd-badges:client:playBadgeAnim', function()
    playBadgeAnim()
end)

RegisterNetEvent('bd-badges:client:displayBadge', function(sourceId, jobName, officerName, callsign, rank, signature)
    local dept = Config.Departments[jobName]
    if not dept then return end

    badgeVisible = true
    badgeCloseToken = badgeCloseToken + 1
    local token = badgeCloseToken

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
        photo = nil,
        duration = Config.DisplayTime
    })

    CreateThread(function()
        watchBadgeClose(token, Config.DisplayTime)
    end)

    CreateThread(function()
        local photoUrl = createBadgePhotoUrl(sourceId)
        if badgeVisible and badgeCloseToken == token and photoUrl then
            SendNUIMessage({
                action = 'setBadgePhoto',
                photo = photoUrl
            })
        end
    end)
end)
