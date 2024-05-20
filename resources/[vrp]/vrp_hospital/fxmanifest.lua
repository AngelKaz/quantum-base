fx_version 'cerulean'
games { 'gta5' }

server_scripts {
	'sv_hospital.lua'
}

client_script {
    "lib/Tunnel.lua",
    "lib/Proxy.lua",
	'cl_hospital.lua'
}