fx_version 'cerulean'
game 'gta5'
author 'starkman'
description 'A script for mushroom hunting'
version '1.0.0'
shared_script {
    '@ox_lib/init.lua',
    '@ox_core/lib/init.lua',
    'shared/config.lua'
}
server_script {
    '@oxmysql/lib/MySQL.lua',
    'server/server.lua'
}
client_script 'client/client.lua'
dependencies {
    'ox_lib',
    'stress',
}
