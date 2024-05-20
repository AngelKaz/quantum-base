fx_version 'cerulean'
games { 'gta5' }

dependency 'vrp'

server_scripts {
    '@vrp/lib/utils.lua',
    'server.lua'
}

client_scripts {
    'client.lua'
}