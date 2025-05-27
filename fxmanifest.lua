fx_version 'cerulean'
game 'gta5'

name 'Enhanced Kung Fu Combat'
description 'Advanced Kung Fu combat system for QB Core'
author 'RDE | SerpentsByte'
version '1.0.0'

shared_scripts {
    'config.lua'
}

client_scripts {
    'client.lua'
}

server_scripts {
    'server.lua'
}

dependencies {
    'qb-core'
}

ui_page 'html/ui.html'

files {
    'html/ui.html',
    'html/styles.css',
    'html/scripts.js',
    'html/fonts/*.ttf'
}
