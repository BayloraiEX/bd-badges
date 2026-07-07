Config = {}

-- Which framework to use. 'auto' will detect qbx_core or qb-core based on
-- whichever one is actually running. Set it explicitly only if you run both
-- resources side by side and auto-detection picks the wrong one.
-- Options: 'auto', 'qbx', 'qbcore'
Config.Framework = 'auto'

-- Which inventory to use. 'auto' will detect ox_inventory or qb-inventory.
-- Options: 'auto', 'ox', 'qb'
Config.Inventory = 'auto'

-- Command / keybind used to show the badge. You may also just use the item from your inventory
Config.Command = 'showbadge'
Config.Keybind = 'P' -- set to false to disable the default keybind
Config.CloseKey = 'BACK' -- Backspace closes the badge popup; set to false to disable

-- Require the player to be holding their department's badge item (ox_inventory) to use the command
Config.RequireItem = true

-- How close (in game units) another player needs to be to see the badge popup
Config.Distance = 5.0

-- How long the badge stays on nearby players' screens (ms)
Config.DisplayTime = 6000

-- Cooldown between uses per player (ms)
Config.Cooldown = 3000

Config.Animation = {
    dict = 'mp_common',
    anim = 'givetake1_a',
    flag = 49,
    duration = 1500
}

-- Map of job name (as used in qbx_core) -> department presentation
-- badgeItem is the ox_inventory item required to show that department's badge
-- (only checked if Config.RequireItem is true). image files should live in html/images/
Config.Departments = {
    ['police'] = {
        label = 'Los Santos Police Department',
        idTitle = 'POLICE',
        badgeImage = 'badge-lspd.png',
        color = '#1e3a8a',
        badgeItem = 'police_badge'
    },
    ['sheriff'] = {
        label = 'Blaine County Sheriff',
        idTitle = 'SHERIFF',
        badgeImage = 'bcso.png',
        color = '#78350f',
        badgeItem = 'police_badge'
    },
    ['sast'] = {
        label = 'San Andreas State Trooper',
        idTitle = 'STATE TROOPER',
        badgeImage = 'sast.png',
        color = '#374151',
        badgeItem = 'police_badge'
    },
    ['ambulance'] = {
        label = 'Emergency Medical Services',
        idTitle = 'EMS',
        badgeImage = 'ems_badge.png',
        color = '#b91c1c',
        badgeItem = 'ems_badge'
    }
}
