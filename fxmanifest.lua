fx_version "adamant"
game 'rdr3'
rdr3_warning 'I acknowledge that this is a prerelease build of RedM, and I am aware my resources *will* become incompatible once RedM ships.'

author 'fuzzy'
lua54 'yes'
description 'Wounds script for bone damage and injuries'
repository 'https://github.com/yzzuf/fuzzy_wounds'

server_scripts {
    'server/server.lua',
}

shared_script {
    'config.lua',
}

client_scripts {
    'client/client.lua',
}

version = "1.0.0"
