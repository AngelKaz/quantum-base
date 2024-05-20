fx_version 'cerulean'
games { 'gta5' }

ui_page 'html/ui.html'
dependency 'vrp'
files {
	'html/ui.html',
	'html/dmv.png',
	'html/cursor.png',
	'html/styles.css',
	'html/questions.js',
	'html/scripts.js',
	'html/debounce.min.js'
}

server_scripts {
    "@oxmysql/lib/MySQL.lua",
	'@vrp/lib/utils.lua',
	'server.lua'
}

client_script {
	'client.lua',
	'GUI.lua'
}