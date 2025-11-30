-- Server logic for bldr_crafting
-- Handles crafting requests, verifies inputs, manages progress
-- state and awards outputs and XP upon completion.  Requires
-- bldr_drugs_core (or bldr_core) for XP management.

local QBCore = exports['qb-core']:GetCoreObject()

-- track players currently crafting to prevent duplicate crafts
local pendingCrafts = {}

-- chance table to alert police when crafting certain items.  Keys are
-- the output item names and values are probabilities between 0 and 1.
local policeChances = {
    weed_bag   = 0.10,
    weed_joint = 0.20,
    cocaine_bag= 0.50
}

-- notify police about illegal crafting activity.  This function
-- iterates through all online players and sends a notification to
-- those with a police‑related job.  You can adapt this to trigger
-- your own dispatch system.
local function alertPolice(itemName, coords)
    local chance = policeChances[itemName]
    if not chance or chance <= 0 then return end
    if math.random() >= chance then return end
    for _, id in pairs(QBCore.Functions.GetPlayers()) do
        local ply = QBCore.Functions.GetPlayer(id)
        if ply and ply.PlayerData and ply.PlayerData.job and ply.PlayerData.job.name then
            local job = ply.PlayerData.job.name
            if job == 'police' or job == 'sheriff' or job == 'state' then
                TriggerClientEvent('QBCore:Notify', id, 'Suspicious crafting activity reported.', 'error')
                -- custom dispatch integration can be inserted here
            end
        end
    end
end

-- helper to notify players
local function notify(src, msg, ntype)
    TriggerClientEvent('bldr_crafting:message', src, msg, ntype)
end

--[[
    Local admin permission check for crafting

    Determines if a player has permission to use admin commands.  It
    attempts to call the IsBLDRAdmin export from bldr_core (or
    bldr_drugs_core), and falls back to a local check based on QBCore
    permissions, ACE permissions and Config.AdminWhitelist.  This
    avoids errors when the core export is missing.
]]
local function isBLDRAdmin(src)
    -- console always allowed
    if src <= 0 then return true end
    -- runtime bypass via convar
    if GetConvarInt('bldr_admin_bypass', 0) == 1 then return true end
    -- QBCore group checks
    if QBCore and QBCore.Functions and QBCore.Functions.HasPermission then
        if QBCore.Functions.HasPermission(src, 'god') or QBCore.Functions.HasPermission(src, 'admin') then
            return true
        end
    end
    -- ACE permissions
    if IsPlayerAceAllowed(src, 'bldr.admin') or IsPlayerAceAllowed(src, 'command') then
        return true
    end
    -- static whitelist
    if _G.Config and _G.Config.AdminWhitelist then
        local lic
        for _, id in ipairs(GetPlayerIdentifiers(src)) do
            if id:sub(1,8) == 'license:' then lic = id break end
        end
        if lic and _G.Config.AdminWhitelist[lic] then
            return true
        end
    end
    return false
end

--[[
    grantBlueprintRewards

    Checks the player's crafting/farming level and awards blueprint items
    accordingly.  Players receive the weed joint blueprint at level 2
    and the cocaine bag blueprint at level 4.  If the player already
    possesses the blueprint item it will not be given again.  This
    helper should be called after XP is awarded (for example in
    finishCraft or admin XP grants) to automatically unlock new
    crafting recipes as the player progresses.

    @param src number: the player source id
]]
local function grantBlueprintRewards(src)
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end
    -- determine current level via core exports
    local lvl = 0
    local coreExport = nil
    if exports['bldr_core'] and exports['bldr_core'].GetLevel then
        coreExport = exports['bldr_core']
    elseif exports['bldr_drugs_core'] and exports['bldr_drugs_core'].GetLevel then
        coreExport = exports['bldr_drugs_core']
    end
    if coreExport then
        lvl = coreExport:GetLevel(src) or 0
    end
    -- level 2: weed joint blueprint
    if lvl >= 2 then
        local item = Player.Functions.GetItemByName('weed_joint_bp')
        if not item or item.amount < 1 then
            Player.Functions.AddItem('weed_joint_bp', 1)
            notify(src, 'You have unlocked a new blueprint: Joint', 'success')
        end
    end
    -- level 4: cocaine bag blueprint
    if lvl >= 4 then
        local item = Player.Functions.GetItemByName('cocaine_bag_bp')
        if not item or item.amount < 1 then
            Player.Functions.AddItem('cocaine_bag_bp', 1)
            notify(src, 'You have unlocked a new blueprint: Cocaine Bag', 'success')
        end
    end
end

-- start crafting: verify inputs and remove them
RegisterNetEvent('bldr_crafting:startCraft', function(recipeKey)
    local src = source
    local recipe = Config.Recipes[recipeKey]
    if not recipe then return end
    if pendingCrafts[src] then
        notify(src, 'You are already crafting something.', 'error')
        return
    end
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end
    -- check level requirement via bldr core
    local levelReq = recipe.level or 0
    local lvl = 0
    local coreExport = nil
    if exports['bldr_core'] and exports['bldr_core'].GetLevel then
        coreExport = exports['bldr_core']
    elseif exports['bldr_drugs_core'] and exports['bldr_drugs_core'].GetLevel then
        coreExport = exports['bldr_drugs_core']
    end
    if coreExport then
        lvl = coreExport:GetLevel(src) or 0
    end
    if lvl < levelReq then
        notify(src, ('You must be level %d to craft %s.'):format(levelReq, recipe.label), 'error')
        return
    end
    -- blueprint requirement: if a recipe defines a blueprint item the
    -- player must possess it.  Blueprints are not consumed but act as
    -- unlock items.  You can create corresponding items in your
    -- qb-core/shared/items.lua.  For example: weed_joint_bp,
    -- cocaine_bag_bp, etc.
    if recipe.blueprint and recipe.blueprint ~= '' then
        local bpItem = Player.Functions.GetItemByName(recipe.blueprint)
        if not bpItem or bpItem.amount < 1 then
            notify(src, ('You need a %s to craft %s.'):format(recipe.blueprint, recipe.label), 'error')
            return
        end
    end
    -- check that player has all inputs
    for item, count in pairs(recipe.inputs) do
        local invItem = Player.Functions.GetItemByName(item)
        if not invItem or invItem.amount < count then
            notify(src, 'You need ' .. count .. ' ' .. item .. ' to craft ' .. recipe.label .. '.', 'error')
            return
        end
    end
    -- remove inputs
    for item, count in pairs(recipe.inputs) do
        Player.Functions.RemoveItem(item, count)
    end
    pendingCrafts[src] = recipeKey
    -- instruct client to show progress bar and skill check
    TriggerClientEvent('bldr_crafting:craftingStarted', src, recipeKey, recipe.time, recipe.label)
end)

-- finish crafting: give outputs and XP
RegisterNetEvent('bldr_crafting:finishCraft', function(recipeKey, success, quality)
    local src = source
    local key = pendingCrafts[src]
    if not key or key ~= recipeKey then
        return
    end
    pendingCrafts[src] = nil
    local recipe = Config.Recipes[recipeKey]
    if not recipe then return end
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end
    -- success defaults to true if nil
    if success == nil then success = true end
    if success then
        -- determine quality fallback
        local itemQuality = tonumber(quality) or math.random(70, 100)
        -- give outputs with quality meta
        for item, count in pairs(recipe.outputs) do
            for i=1, count do
                Player.Functions.AddItem(item, 1, false, { quality = itemQuality })
            end
        end
        -- award XP
        local xpExport = nil
        if exports['bldr_core'] and exports['bldr_core'].AddXP then
            xpExport = exports['bldr_core']
        elseif exports['bldr_drugs_core'] and exports['bldr_drugs_core'].AddXP then
            xpExport = exports['bldr_drugs_core']
        end
        if xpExport then
            xpExport:AddXP(src, recipe.xp)
            -- check and grant blueprint rewards after XP gain
            grantBlueprintRewards(src)
        end
        
        -- award money if configured and bldr_core available
        if recipe.moneyReward and recipe.moneyReward > 0 then
            if exports['bldr_core'] and exports['bldr_core'].AddMoney then
                exports['bldr_core']:AddMoney(src, recipe.moneyReward, 'cash', itemQuality)
            elseif exports['bldr_drugs_core'] and exports['bldr_drugs_core'].AddMoney then
                exports['bldr_drugs_core']:AddMoney(src, recipe.moneyReward, 'cash')
            else
                -- fallback to direct QBCore payment
                Player.Functions.AddMoney('cash', recipe.moneyReward, 'crafting-reward')
            end
        end
        -- potentially alert police based on output items
        local ped = GetPlayerPed(src)
        local coords = ped and GetEntityCoords(ped) or nil
        for item, _ in pairs(recipe.outputs) do
            alertPolice(item, coords)
        end
        notify(src, ('You crafted %s (quality %d%%)!'):format(recipe.label, itemQuality), 'success')
    else
        -- crafting failed: nothing is produced; optionally refund part of the inputs
        notify(src, ('Crafting %s failed and you lost the materials!'):format(recipe.label), 'error')
    end
end)

--[[
    Admin/testing command for crafting

    Allows server admins to quickly test crafting logic without
    gathering materials.  Only players with 'admin' or 'god'
    permissions (as defined by QBCore) may use this command.

    Subcommands:
      bp                 - Gives both drug blueprint items
      xp <amount>        - Adds XP via bldr_core/bldr_drugs_core exports
      item <name> <amt>  - Gives arbitrary item to the caller
      craft <recipeKey>  - Instantly crafts the specified recipe and
                           awards outputs and XP (ignores inputs)

    Examples:
      /craftadmin bp
      /craftadmin xp 500
      /craftadmin item weed 10
      /craftadmin craft weed_joint
]]
-- Callback to get player level from bldr_core
QBCore.Functions.CreateCallback('bldr_crafting:getPlayerLevel', function(source, cb)
    print(("[bldr_crafting] Getting player level for source: %d"):format(source))
    
    local lvl = 0
    local coreExport = nil
    if exports['bldr_core'] and exports['bldr_core'].GetLevel then
        coreExport = exports['bldr_core']
    elseif exports['bldr_drugs_core'] and exports['bldr_drugs_core'].GetLevel then
        coreExport = exports['bldr_drugs_core']
    end
    if coreExport then
        lvl = coreExport:GetLevel(source) or 0
    end
    
    print(("[bldr_crafting] Player level returned: %d"):format(lvl))
    cb(lvl)
end)

-- Callback to get player inventory for ingredient checking
QBCore.Functions.CreateCallback('bldr_crafting:getInventory', function(source, cb)
    print(("[bldr_crafting] Getting inventory for source: %d"):format(source))
    
    local Player = QBCore.Functions.GetPlayer(source)
    if not Player then 
        cb({})
        return
    end
    
    local inventory = {}
    if Player.PlayerData.items then
        for _, item in pairs(Player.PlayerData.items) do
            if item and item.name and item.amount then
                inventory[item.name] = {
                    amount = item.amount,
                    info = item.info
                }
            end
        end
    end
    cb(inventory)
end)

-- Callback to get station upgrades
QBCore.Functions.CreateCallback('bldr_crafting:getStationUpgrades', function(source, cb, stationId)
    print(("[bldr_crafting] Getting station upgrades for station: %d"):format(stationId or 0))
    
    -- For now, return empty upgrades - this can be expanded later
    -- to include actual upgrade data from database or player progress
    local upgrades = {}
    
    cb(upgrades)
end)

RegisterCommand('craftadmin', function(source, args)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end
    -- check admin permissions via core or fallback
    if not isBLDRAdmin(src) then
        TriggerClientEvent('bldr_crafting:message', src, 'No permission.', 'error')
        return
    end
    local action = args[1] and tostring(args[1]):lower() or ''
    if action == 'bp' or action == 'bps' or action == 'blueprints' then
        local bps = { 'weed_joint_bp', 'cocaine_bag_bp' }
        for _, item in ipairs(bps) do
            Player.Functions.AddItem(item, 1)
        end
        TriggerClientEvent('bldr_crafting:message', src, 'Admin: given blueprint items.', 'success')
    elseif action == 'xp' then
        local amount = tonumber(args[2] or '0') or 0
        if amount <= 0 then
            TriggerClientEvent('bldr_crafting:message', src, 'Usage: /craftadmin xp <amount>', 'error')
            return
        end
        local xpExport = nil
        if exports['bldr_core'] and exports['bldr_core'].AddXP then
            xpExport = exports['bldr_core']
        elseif exports['bldr_drugs_core'] and exports['bldr_drugs_core'].AddXP then
            xpExport = exports['bldr_drugs_core']
        end
        if xpExport then
            xpExport:AddXP(src, amount)
            -- award blueprint rewards based on new level
            grantBlueprintRewards(src)
            TriggerClientEvent('bldr_crafting:message', src, ('Admin: added %d XP.'):format(amount), 'success')
        else
            TriggerClientEvent('bldr_crafting:message', src, 'Admin: XP export unavailable.', 'error')
        end
    elseif action == 'item' then
        local itemName = args[2] and tostring(args[2]):lower() or ''
        local count    = tonumber(args[3] or '1') or 1
        if itemName == '' then
            TriggerClientEvent('bldr_crafting:message', src, 'Usage: /craftadmin item <name> <amount>', 'error')
            return
        end
        Player.Functions.AddItem(itemName, count)
        TriggerClientEvent('bldr_crafting:message', src, ('Admin: given %d x %s.'):format(count, itemName), 'success')
    elseif action == 'craft' then
        local recipeKey = args[2] and tostring(args[2]) or ''
        local recipe = Config.Recipes[recipeKey]
        if not recipe then
            TriggerClientEvent('bldr_crafting:message', src, 'Invalid recipe key.', 'error')
            return
        end
        -- give outputs instantly ignoring inputs; assign random quality
        local itemQuality = math.random(80, 100)
        for item, count in pairs(recipe.outputs) do
            for i=1, count do
                Player.Functions.AddItem(item, 1, false, { quality = itemQuality })
            end
        end
        -- award XP
        local xpExport = nil
        if exports['bldr_core'] and exports['bldr_core'].AddXP then
            xpExport = exports['bldr_core']
        elseif exports['bldr_drugs_core'] and exports['bldr_drugs_core'].AddXP then
            xpExport = exports['bldr_drugs_core']
        end
        if xpExport then
            xpExport:AddXP(src, recipe.xp)
            -- grant blueprint rewards after XP gain
            grantBlueprintRewards(src)
        end
        -- optionally alert police if applicable
        local ped = GetPlayerPed(src)
        local coords = ped and GetEntityCoords(ped) or nil
        for item, _ in pairs(recipe.outputs) do
            alertPolice(item, coords)
        end
        TriggerClientEvent('bldr_crafting:message', src, ('Admin: crafted %s (quality %d%%).'):format(recipe.label, itemQuality), 'success')
    else
        TriggerClientEvent('bldr_crafting:message', src, 'Invalid subcommand. Use bp, xp, item, or craft.', 'error')
    end
end, false)