fx_version 'cerulean'
games { 'gta5' }

dependency "vrp"

client_scripts{ 
  "client/Tunnel.lua",
  "client/Proxy.lua",
  "client.lua"
}

server_scripts{ 
  "@vrp/lib/utils.lua",
  "server.lua"
}