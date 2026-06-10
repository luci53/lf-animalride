fx_version 'cerulean'
game 'gta5'
lua54 'yes'

name 'lf-animalride'
author 'Lucifer'
description 'Rideable animal companions for QBox, QBCore and ESX (tame, summon, ride, buff)'
version '2.0.0'
repository 'https://github.com/luci53/lf-animalride'

shared_scripts {
    '@ox_lib/init.lua',
    'config.lua',
}

client_scripts {
    'client/main.lua',
}

server_scripts {
    'server/bridge.lua',
    'server/main.lua',
}

dependencies {
    'ox_lib',
    'ox_target',
}
