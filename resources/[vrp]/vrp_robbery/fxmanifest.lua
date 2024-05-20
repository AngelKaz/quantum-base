fx_version 'cerulean'
games { 'gta5' }

dependency "vrp"

client_scripts{ 
  "cfg/bank.lua",
  "client.lua"
}

server_scripts{ 
  "@vrp/lib/utils.lua",
  "cfg/bank.lua",
  "server.lua"
}
