fx_version 'cerulean'
game 'gta5'
lua54 'yes'
use_experimental_fxv2_oal 'yes'

author 'SUP2Ak#3755'
description 'A simple identity creator with ox_lib input dialog'
version '1.0'

shared_scripts {
    '@ox_lib/init.lua',
    '@es_extended/imports.lua',
    '_g.lua',
    'config/shared.lua',
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'config/server.lua',
    'server/*.lua'
}

client_scripts {
    'client/*.lua'
}

files {
    'locales/*.json'
}

ui_page 'web/ui.html'

files {
    'web/ui.html',
    'web/js/*.js',
}