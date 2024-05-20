fx_version 'cerulean'
games { 'gta5' }

server_scripts {
  '@vrp/lib/utils.lua',
  'config.lua',
  'server/main.lua',
}

client_scripts {
  'lib/Proxy.lua',
  'lib/Tunnel.lua',
  'config.lua',
  'client/main.lua'
}