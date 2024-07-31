fx_version 'cerulean'
game 'gta5'
lua54 'yes'


client_scripts {
    'car_spawn/client/client.lua',
    'death_screen/client/client.lua',
}

server_scripts {
    'death_screen/server/server.lua'
}

shared_scripts {
	'config.lua'
}

ui_page 'death_screen/html/index.html'

files {
    'death_screen/html/index.html',
    'heartbeat.mp3'
}

dependencies {
    'qb-core'
}