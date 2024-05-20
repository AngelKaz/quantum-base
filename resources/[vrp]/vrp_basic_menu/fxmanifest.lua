fx_version 'cerulean'
games { 'gta5' }

dependency "vrp"

client_scripts{ 
  "client/Tunnel.lua",
  "client/Proxy.lua",
  "client.lua",
  "tptowaypoint/client.lua",
  "drag/client.lua",
  "spikes/client.lua"
}

server_scripts{ 
  "@vrp/lib/utils.lua",
  "server.lua"
}
