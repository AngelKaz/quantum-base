fx_version 'cerulean'
games { 'gta5' }

dependency "vrp"

client_scripts{ 
  "lib/Tunnel.lua",
  "lib/Proxy.lua",
  "client.lua"
}

server_scripts{ 
    "@oxmysql/lib/MySQL.lua",
    "@vrp/lib/utils.lua",
    "server.lua"
}