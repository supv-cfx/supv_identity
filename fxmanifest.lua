fx_version 'cerulean'
game 'gta5'
lua54 'yes'
use_experimental_fxv2_oal 'yes'

author 'SUP2Ak#3755'
description 'A simple identity creator with ox_lib input dialog'
version '1.3'

files {
    'config/shared.lua',
    'locales/*.json'
}

shared_scripts {
    '@ox_lib/init.lua',
    '@es_extended/imports.lua',
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/*.lua'
}

client_scripts {
    'client/*.lua'
}

depandencies {
    '/onesync',
    'oxmysql',
    'ox_lib',
    'es_extended',
    'supv_convert-unix'
}