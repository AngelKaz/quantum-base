fx_version 'cerulean'
games { 'gta5' }

dependencies {
	'vrp',
}

ui_page 'html/ui.html'

files {
	'html/ui.html',
	'html/taximeter.ttf',
	'html/styles.css',
	'html/scripts.js',
	'html/debounce.min.js'
}

client_script "client.lua"

server_scripts{
	"@vrp/lib/utils.lua",
	"server.lua"
}
