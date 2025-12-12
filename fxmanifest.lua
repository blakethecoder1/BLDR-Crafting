-- fxmanifest.lua for bldr_crafting
-- This resource implements a simple crafting system that allows players
-- to convert raw contraband or resources into processed products.
-- It integrates with bldr_drugs_core (or bldr_core) to award XP.

fx_version 'cerulean'
game 'gta5'
lua54 'yes'

name 'bldr_crafting'
description 'Simple crafting system for BLDR'
author 'blakethepet'

dependencies {
    'bldr-core',
    'qb-core'
    -- 'qb-target' -- Optional: use qb-target OR ox_target
    -- 'ox_target' -- Optional: use ox_target OR qb-target
    -- 'ox_inventory' -- Optional: use ox_inventory OR qb-inventory
}

shared_script 'config.lua'

client_scripts {
    'client/minigame.lua',  -- Load minigame FIRST
    'client/progressbar.lua',
    'client/main.lua',
    'client/ui.lua'
}

ui_page 'html/index.html'

files {
    'html/index.html',
    'html/images/cocaine_bag_bp.png',
    'html/images/weed_joint_bp.png'
}

server_scripts {
    'server/main.lua'
}
