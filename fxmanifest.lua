fx_version 'cerulean'
game 'gta5'
lua54 'yes'

author 'donk'
description 'Prevents new players from using weapons for configurable time period - Supports ESX, QBCore, and QBX'
version '2.0.0'

shared_scripts {
    '@ox_lib/init.lua',
    'config.lua'
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server.lua'
}

client_scripts {
    'client.lua'
}