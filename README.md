# bd-badges
Show your department badge to nearby players with a leather-wallet-style ID card with your name, rank, callsign, and department badge, shown on the screens of anyone standing close enough.

Works with **either**:
- Framework: `qbx_core` (QBox) or `qb-core` (QBCore)
- Inventory: `ox_inventory` or `qb-inventory`
Auto-detected at resource start — no config changes needed for a standard setup.

## Features

- `/showbadge` command (or configurable keybind) plays an animation and shows your badge to nearby players
- Also triggers automatically when a player **uses their badge item** from their inventory
- Per-department presentation: label, badge image, accent color, and required item
- Server-side validation of job and item — the client can't fake which badge is shown
- Cooldown and distance are configurable

## Dependencies

- [`ox_lib`](https://github.com/overextended/ox_lib) — required regardless of framework/inventory, used for notifications
- One of: `qbx_core` or `qb-core`
- One of: `ox_inventory` or `qb-inventory`

## Installation

1. Drop the `bd-badges` folder into your server's resources directory.
2. Add badge item(s) to your inventory config if they don't already exist (see [Items](#items) below).
3. Add `ensure bd-badges` to your `server.cfg`, after your framework, inventory, and `ox_lib`.
4. (Optional) Edit `config.lua` to adjust departments, cooldown, distance, or force a specific framework/inventory instead of auto-detect.

### Departments
Each entry in `Config.Departments` is keyed by the job name as it appears in your framework:

```lua
['police'] = {
    label = 'Los Santos Police Department', -- shown on the ID card
    idTitle = 'POLICE',                     -- header text on the ID card
    badgeImage = 'badge-lspd.png',          -- file name, must live in ui/images/
    color = '#1e3a8a',                      -- accent color for the ID card
    badgeItem = 'police_badge'              -- required item (only checked if Config.RequireItem is true)
},
['ambulance'] = {
        label = 'Emergency Medical Services',
        idTitle = 'EMS',
        badgeImage = 'ems_badge.png',
        color = '#b91c1c',
        badgeItem = 'ems_badge'
    }
```

Add, remove, or edit entries to match your server's jobs. Any job without an entry here simply can't use the command.
