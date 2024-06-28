--[[ FX Information ]]--
fx_version   'cerulean'
lua54        'yes'
game         'gta5'

--[[ Resource Information ]]--
name         'fun-tracker'
author       'funes781'
version      '1.0.0'
description  "vehicle tracker"

--[[ Manifest ]]--


shared_scripts {
    'shared/strings.lua',
    'shared/*.lua',
    '@ox_lib/init.lua',
}

server_script {
    'server/*.lua',
}

client_scripts { 
    'client/*.lua',
}
