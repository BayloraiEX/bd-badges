-- Copy these entries into ox_inventory/data/items.lua

['police_badge'] = {
    label = 'Police Badge',
    weight = 100,
    stack = false,
    close = true,
    consume = 0,
    description = 'Official law enforcement badge.',
    server = {
        export = 'bd-badges.useBadge'
    }
},

['ems_badge'] = {
    label = 'EMS Badge',
    weight = 100,
    stack = false,
    close = true,
    consume = 0,
    description = 'Official emergency medical services badge.',
    server = {
        export = 'bd-badges.useBadge'
    }
},
