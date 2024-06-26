fx_version "adamant"
game "gta5"
lua54 'yes'

name         'azakit_typingicon'
version      '1.0.0'
author 'Azakit'
description 'An icon above the player head indicates when they are typing in the chat.'

client_scripts {
    'config.lua',
    'client/*'
}

server_scripts {
    'config.lua',
    'server/*'
}