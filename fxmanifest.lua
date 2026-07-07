fx_version 'cerulean'
game 'gta5'
lua54 'yes'

name 'bd-badges'
author 'BayloraiDevelopment'
description 'Show a police badge to nearby players (QBox/QBCore, ox_inventory/qb-inventory)'
version '1.0.1'

shared_script '@ox_lib/init.lua'
shared_script 'config.lua'

client_scripts {
    'client/bridge.lua',
    'client/cl_main.lua'
}

server_scripts {
    'server/bridge.lua',
    'server/sv_main.lua'
}

ui_page 'ui/index.html'

files {
    'ui/index.html',
    'ui/style.css',
    'ui/script.js',
    'ui/images/*.png'
}

dependencies {
    'ox_lib'
}
