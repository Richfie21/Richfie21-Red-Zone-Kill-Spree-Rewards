-- Copyright (c) 2025 Richfie21
-- Licensed under the MIT License. See LICENSE file for details.

fx_version 'cerulean'
game 'gta5'

author 'Richfie21'
description 'RedZone Upgraded'
version '3.2.0'


ui_page 'html/index.html'

files {
    'html/index.html',
    'html/style.css',
    'html/script.js',
    'html/sounds/*.mp3'
}

client_scripts { 
    "config.lua",
    "client.lua", 
} 

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    "config.lua",
    "server.lua", 
} 


shared_scripts {
    '@ox_lib/init.lua'
}
 
lua54 'yes'  
dependency '/assetpacks'
