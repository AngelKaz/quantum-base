fx_version 'cerulean'
games { 'gta5' }

description "vRP showroom"
--ui_page "ui/index.html"

dependency "vrp"

server_scripts{
    '@oxmysql/lib/MySQL.lua',
    "@vrp/lib/utils.lua",
    "server.lua"
}

client_scripts{ 
  "lib/Proxy.lua",
  "client.lua"
}