-- Client logic for bldr_crafting
-- Sets up interactive crafting stations, shows a menu of recipes
-- using ox_lib (if available) and starts a progress bar while
-- crafting.  Relies on QBCore notifications and progressbar.

local QBCore = exports['qb-core']:GetCoreObject()

-- Detect which target system is available
local TargetSystem = nil
if GetResourceState('ox_target') == 'started' then
    TargetSystem = 'ox_target'
elseif GetResourceState('qb-target') == 'started' then
    TargetSystem = 'qb-target'
else
    print("[bldr_crafting] WARNING: No target system detected (ox_target or qb-target)")
end

-- helper to build a description string from a recipe's inputs
local function buildInputDescription(inputs)
    local parts = {}
    for item, count in pairs(inputs) do
        table.insert(parts, (count .. ' x ' .. item))
    end
    return table.concat(parts, ', ')
end

-- create interaction zones for each crafting station
CreateThread(function()
    Wait(1000)
    print("[bldr_crafting] Setting up crafting stations...")
    
    if not Config.CraftingStations then
        print("[bldr_crafting] ERROR: Config.CraftingStations is nil!")
        return
    end
    
    if not TargetSystem then
        print("[bldr_crafting] ERROR: No target system available!")
        return
    end
    
    print(("[bldr_crafting] Found %d crafting stations using %s"):format(#Config.CraftingStations, TargetSystem))
    
    for index, station in ipairs(Config.CraftingStations) do
        local zoneName = 'bldr_craft_' .. index
        local coords = station.coords
        
        print(("[bldr_crafting] Setting up station %d: %s at %s"):format(index, station.label, tostring(coords)))
        
        if TargetSystem == 'ox_target' then
            -- Use ox_target
            local success, err = pcall(function()
                exports.ox_target:addSphereZone({
                    coords = coords,
                    radius = 1.5,
                    debug = false,
                    options = {
                        {
                            name = zoneName,
                            icon = station.icon or 'fas fa-box-open',
                            label = station.label or 'Craft Items',
                            onSelect = function()
                                TriggerEvent('bldr_crafting:clientOpenStation', { stationId = index })
                            end,
                            distance = 2.0
                        }
                    }
                })
            end)
            
            if success then
                print(("[bldr_crafting] Successfully created ox_target zone: %s"):format(zoneName))
            else
                print(("[bldr_crafting] ERROR creating ox_target zone %s: %s"):format(zoneName, tostring(err)))
            end
            
        elseif TargetSystem == 'qb-target' then
            -- Use qb-target
            local success, err = pcall(function()
                exports['qb-target']:AddCircleZone(zoneName, coords, 1.5, {
                    name = zoneName,
                    useZ = true,
                    debugPoly = false
                }, {
                    options = {
                        {
                            type  = 'client',
                            event = 'bldr_crafting:clientOpenStation',
                            icon  = station.icon or 'fas fa-box-open',
                            label = station.label or 'Craft Items',
                            stationId = index
                        }
                    },
                    distance = 2.0
                })
            end)
            
            if success then
                print(("[bldr_crafting] Successfully created qb-target zone: %s"):format(zoneName))
            else
                print(("[bldr_crafting] ERROR creating qb-target zone %s: %s"):format(zoneName, tostring(err)))
            end
        end
    end
    
    print("[bldr_crafting] Station setup complete!")
end)

-- Debug command to test UI opening
RegisterCommand('testcraft', function()
    print("[bldr_crafting] Test command triggered")
    
    -- Simulate opening the first crafting station
    TriggerEvent('bldr_crafting:clientOpenStation', { stationId = 1 })
end, false)

-- open UI for crafting when interacting with a station
RegisterNetEvent('bldr_crafting:clientOpenStation', function(data)
    print("[bldr_crafting] Station interaction triggered with data:", json.encode(data))
    
    local stationId = data.stationId
    local station = Config.CraftingStations[stationId]
    if not station then 
        print("[bldr_crafting] ERROR: Station not found for ID:", stationId)
        return 
    end
    
    print(("[bldr_crafting] Opening station: %s (Level required: %d)"):format(station.label, station.requiredLevel or 0))
    
    -- Check if player meets station level requirement
    QBCore.Functions.TriggerCallback('bldr_crafting:getPlayerLevel', function(playerLevel)
        print(("[bldr_crafting] Player level: %d, Required: %d"):format(playerLevel or 0, station.requiredLevel or 0))
        
        if playerLevel < (station.requiredLevel or 0) then
            QBCore.Functions.Notify(('You need level %d to use this station'):format(station.requiredLevel), 'error')
            return
        end
        
        -- Get player inventory for ingredient checking
        QBCore.Functions.TriggerCallback('bldr_crafting:getInventory', function(inventory)
            print("[bldr_crafting] Received inventory with items:", inventory and table.type(inventory) or "nil")
            
            -- build an array of recipes with details for the UI
            local recipeList = {}
            print(("[bldr_crafting] Filtering recipes for station category: %s"):format(station.category or "none"))
            
            for key, recipe in pairs(Config.Recipes) do
                -- Filter recipes by station category - strict matching
                local showRecipe = false
                
                if station.category == 'general' then
                    -- General station shows general recipes AND recipes without a category
                    showRecipe = (recipe.category == 'general' or not recipe.category)
                elseif station.category then
                    -- Specialized stations only show their specific category
                    showRecipe = (recipe.category == station.category)
                else
                    -- Station with no category shows all recipes (fallback)
                    showRecipe = true
                end
                
                print(("[bldr_crafting] Recipe '%s' (category: %s) - Show: %s"):format(key, recipe.category or "none", tostring(showRecipe)))
                
                if showRecipe then
                    local canCraft = true
                    local missingItems = {}
                    
                    -- Check if player has required ingredients and format them for UI
                    local ingredients = {}
                    for item, count in pairs(recipe.inputs) do
                        local playerItem = inventory[item]
                        local playerCount = playerItem and playerItem.amount or 0
                        local hasEnough = playerCount >= count
                        
                        if not hasEnough then
                            canCraft = false
                            table.insert(missingItems, {
                                item = item,
                                needed = count,
                                have = playerCount
                            })
                        end
                        
                        -- Format ingredient for UI display
                        table.insert(ingredients, {
                            item = item,
                            label = playerItem and playerItem.label or item,
                            amount = count,
                            available = hasEnough,
                            playerCount = playerCount
                        })
                    end
                    
                    table.insert(recipeList, {
                        key         = key,
                        label       = recipe.label,
                        description = recipe.description or "",
                        category    = recipe.category or 'General',
                        ingredients = ingredients,
                        inputs      = recipe.inputs,
                        outputs     = recipe.outputs,
                        time        = recipe.time,
                        xp          = recipe.xp,
                        level       = recipe.level or 0,
                        blueprint   = recipe.blueprint or nil,
                        difficulty  = recipe.difficulty or 'easy',
                        canCraft    = canCraft,
                        missing     = missingItems,
                        moneyReward = recipe.moneyReward or 0,
                        -- Advanced features
                        toolRequired = recipe.toolRequired,
                        toolDurabilityLoss = recipe.toolDurabilityLoss,
                        stationUpgrade = recipe.stationUpgrade,
                        specialStation = recipe.specialStation,
                        chainStep = recipe.chainStep,
                        batchCraftingEnabled = recipe.batchCraftingEnabled,
                        maxBatchSize = recipe.maxBatchSize,
                        dangerLevel = recipe.dangerLevel,
                        explosionChance = recipe.explosionChance
                    })
                end
            end
            
            -- Get station upgrades for enhanced features
            QBCore.Functions.TriggerCallback('bldr_crafting:getStationUpgrades', function(upgrades)
                print(("[bldr_crafting] Received upgrades, opening UI with %d recipes"):format(#recipeList))
                
                -- send data to UI via event
                TriggerEvent('bldr_crafting:openUI', { 
                    recipes = recipeList, 
                    station = station,
                    playerLevel = playerLevel,
                    stationUpgrades = upgrades or {},
                    stationId = stationId
                })
            end, stationId)
        end) -- End of getInventory callback
    end) -- End of getPlayerLevel callback
end) -- End of bldr_crafting:clientOpenStation event

-- handle crafting start: forward to UI progress
RegisterNetEvent('bldr_crafting:craftingStarted', function(recipeKey, time, label, category)
    -- [FIX] Add immediate debug logging to see if event is received
    print("^1^1^1 ========== CRAFTING STARTED EVENT FIRED ========== ^0^0^0")
    print("^1[CRAFTING] Recipe: " .. tostring(recipeKey) .. "^0")
    print("^1[CRAFTING] Time: " .. tostring(time) .. "^0")
    print("^1[CRAFTING] Label: " .. tostring(label) .. "^0")
    print("^1[CRAFTING] Category: " .. tostring(category) .. "^0")
    
    -- server indicates crafting has started.  Hide the crafting UI and
    -- perform the progress bar and skill check on the client.  Once
    -- complete send the result back to the server.
    
    -- Ensure time is a valid number
    time = tonumber(time) or 5000
    label = label or 'Item'
    category = category or 'general'
    
    -- close the NUI crafting list to prevent further interaction
    TriggerEvent('bldr_crafting:closeUI')
    
    -- Get recipe for difficulty settings
    local recipe = Config.Recipes[recipeKey]
    local difficulty = recipe and recipe.difficulty or 'easy'
    local diffSettings = Config.Difficulty and Config.Difficulty[difficulty] or {}
    
    -- Get animation config for category
    local animConfig = nil
    if Config.Animations and Config.Animations.enabled and Config.Animations.byCategory then
        animConfig = Config.Animations.byCategory[category] or Config.Animations.byCategory.general
    end
    
    -- Start minigame immediately (no wait needed, minigame provides timing)
    local success = true
    local quality = nil
    local minigameResult = 'skipped'
    local ped = PlayerPedId()
    
    -- [FIX] Debug logging - ALWAYS PRINT (not behind Config.Debug)
    print("^3========== CRAFTING PROCESSING START ==========^0")
    print("^3[CRAFTING] Recipe: " .. tostring(recipeKey) .. "^0")
    print("^3[CRAFTING] Minigame enabled: " .. tostring(Config.CraftingMinigame and Config.CraftingMinigame.enabled) .. "^0")
    print("^3[CRAFTING] ShowCraftingMinigame type: " .. type(ShowCraftingMinigame) .. "^0")
    print("^3[CRAFTING] ShowCraftingMinigame value: " .. tostring(ShowCraftingMinigame) .. "^0")
    
    -- Check if minigame is enabled and function exists
    if Config.CraftingMinigame and Config.CraftingMinigame.enabled and type(ShowCraftingMinigame) == 'function' then
        print("^2[CRAFTING] >>> STARTING MINIGAME PATH <<<^0")
        
        -- [FIX] Show minigame and WAIT for callback before proceeding
        local minigameCompleted = false
        
        ShowCraftingMinigame(recipeKey, difficulty, function(result)
            print("^2[CRAFTING] Minigame callback received! Result: " .. result .. "^0")
            minigameResult = result
            
            -- Clear animation after minigame
            if animConfig then
                ClearPedTasks(ped)
                if animConfig.dict then
                    RemoveAnimDict(animConfig.dict)
                end
            end
            
            -- Calculate quality based on minigame result
            local rewards = Config.CraftingMinigame.rewards[result] or Config.CraftingMinigame.rewards.success
            
            if result == 'success' then
                success = true
                quality = math.random(80, 100)
            elseif result == 'failed' then
                -- Check if crafting fails completely
                if math.random() < (rewards.failureChance or 0) then
                    success = false
                    quality = 0
                else
                    success = true
                    quality = math.random(30, 60)
                end
            elseif result == 'cancelled' then
                -- [FIX] Handle cancellation properly
                success = false
                quality = 0
                print("^1[CRAFTING] Minigame cancelled by player^0")
            else
                -- Default
                success = true
                quality = math.random(70, 85)
            end
            
            -- send result back to server with minigame data
            print("^2[CRAFTING] Sending result to server: success=" .. tostring(success) .. " quality=" .. tostring(quality) .. "^0")
            TriggerServerEvent('bldr_crafting:finishCraft', recipeKey, success, quality, minigameResult)
        end)
        
        -- [FIX] Don't continue - callback handles everything
        print("^2[CRAFTING] Minigame started, waiting for completion...^0")
        return
    else
        print("^1[CRAFTING] >>> USING FALLBACK PATH (No minigame) <<<^0")
        -- No minigame enabled, play animation and wait for crafting time
        if animConfig then
            local ped = PlayerPedId()
            
            if animConfig.dict then
                RequestAnimDict(animConfig.dict)
                while not HasAnimDictLoaded(animConfig.dict) do
                    Wait(10)
                end
                TaskPlayAnim(ped, animConfig.dict, animConfig.anim, 8.0, -8.0, -1, animConfig.flag or 1, 0, false, false, false)
            elseif animConfig.scenario then
                TaskStartScenarioInPlace(ped, animConfig.scenario, 0, true)
            end
            
            -- If particle effects defined, spawn them
            if animConfig.particleEffect then
                local particleEffect = animConfig.particleEffect
                if particleEffect.dict and particleEffect.name then
                    CreateThread(function()
                        local startTime = GetGameTimer()
                        local duration = time
                        
                        RequestNamedPtfxAsset(particleEffect.dict)
                        while not HasNamedPtfxAssetLoaded(particleEffect.dict) do
                            Wait(10)
                        end
                        
                        while GetGameTimer() - startTime < duration do
                            local coords = GetEntityCoords(ped)
                            UseParticleFxAssetNextCall(particleEffect.dict)
                            StartParticleFxNonLoopedAtCoord(particleEffect.name, coords.x, coords.y, coords.z + 0.5, 0.0, 0.0, 0.0, particleEffect.scale or 1.0, false, false, false)
                            Wait(1000) -- Spawn particle every second
                        end
                        
                        RemoveNamedPtfxAsset(particleEffect.dict)
                    end)
                end
            end
        end
        
        Wait(time)
        
        -- Clear animation
        if animConfig then
            local ped = PlayerPedId()
            ClearPedTasks(ped)
            if animConfig.dict then
                RemoveAnimDict(animConfig.dict)
            end
        end
        
        quality = math.random(70, 100)
        
        -- send result back to server
        TriggerServerEvent('bldr_crafting:finishCraft', recipeKey, success, quality, 'none')
    end
end)

-- display notifications from server
RegisterNetEvent('bldr_crafting:message', function(msg, ntype)
    if QBCore and QBCore.Functions and QBCore.Functions.Notify then
        QBCore.Functions.Notify(msg or 'Notification', ntype or 'primary')
    else
        TriggerEvent('chat:addMessage', { args = { '[bldr_crafting]', msg } })
    end
end)

-- 🔧 ADVANCED CRAFTING FEATURES

-- Station Upgrade Menu
RegisterNetEvent('bldr_crafting:openUpgradeMenu', function(stationId, currentUpgrades)
    local options = {
        {
            title = '🏭 Station Upgrades',
            description = 'Enhance your crafting capabilities',
            icon = 'fas fa-cogs',
            disabled = true
        }
    }
    
    if Config.StationUpgrades then
        for upgradeType, upgradeLevels in pairs(Config.StationUpgrades) do
            local currentLevel = currentUpgrades[upgradeType] or 0
            local nextLevel = currentLevel + 1
            local nextUpgrade = upgradeLevels['level' .. nextLevel]
            
            if nextUpgrade then
                local upgradeIcon = upgradeType == 'efficiency' and 'fas fa-tachometer-alt' or 
                                  upgradeType == 'quality' and 'fas fa-award' or 'fas fa-expand'
                
                table.insert(options, {
                    title = string.format('%s %s Level %d', upgradeIcon, upgradeType:gsub('^%l', string.upper), nextLevel),
                    description = getUpgradeDescription(upgradeType, nextUpgrade),
                    icon = upgradeIcon,
                    metadata = {
                        { label = 'Current Level', value = currentLevel },
                        { label = 'Upgrade Cost', value = '$' .. nextUpgrade.cost },
                        { label = 'Requirement', value = nextUpgrade.requirement }
                    },
                    onSelect = function()
                        TriggerServerEvent('bldr_crafting:purchaseUpgrade', stationId, upgradeType, nextLevel)
                    end
                })
            else
                table.insert(options, {
                    title = string.format('✅ %s Maxed', upgradeType:gsub('^%l', string.upper)),
                    description = 'This upgrade is fully maxed out',
                    icon = 'fas fa-check-circle',
                    disabled = true
                })
            end
        end
    end
    
    exports['ox_lib']:registerContext({
        id = 'upgrade_menu',
        title = 'Station Upgrades',
        options = options
    })
    exports['ox_lib']:showContext('upgrade_menu')
end)

-- Batch Crafting Interface
RegisterNetEvent('bldr_crafting:openBatchMenu', function(recipeKey, recipeData, maxBatch)
    local input = exports['ox_lib']:inputDialog('Batch Crafting', {
        {
            type = 'number',
            label = 'Quantity to Craft',
            description = 'How many ' .. recipeData.label .. ' would you like to craft?',
            icon = 'fas fa-calculator',
            min = 1,
            max = maxBatch or 10,
            default = 1
        }
    })
    
    if input and input[1] then
        local quantity = tonumber(input[1])
        if quantity and quantity > 0 then
            TriggerServerEvent('bldr_crafting:startBatchCraft', recipeKey, quantity)
        end
    end
end)

-- Blueprint Research Interface
RegisterNetEvent('bldr_crafting:openResearchMenu', function(playerResearch, availableBlueprints)
    local options = {
        {
            title = '🔬 Research Laboratory',
            description = 'Discover new crafting blueprints through scientific research',
            icon = 'fas fa-flask',
            disabled = true
        },
        {
            title = '📊 Research Points: ' .. (playerResearch.points or 0),
            description = 'Available points for blueprint research',
            icon = 'fas fa-star',
            disabled = true
        }
    }
    
    if availableBlueprints then
        for _, blueprint in ipairs(availableBlueprints) do
            table.insert(options, {
                title = '🔍 Research: ' .. blueprint.name,
                description = blueprint.description or 'Unlock advanced crafting recipe',
                icon = getRarityIcon(blueprint.rarity),
                metadata = {
                    { label = 'Rarity', value = blueprint.rarity:gsub('^%l', string.upper) },
                    { label = 'Cost', value = blueprint.researchCost .. ' points' },
                    { label = 'Success Rate', value = blueprint.successChance .. '%' },
                    { label = 'Time Required', value = blueprint.researchTime .. 's' }
                },
                onSelect = function()
                    TriggerServerEvent('bldr_crafting:startResearch', blueprint.id)
                end
            })
        end
    end
    
    exports['ox_lib']:registerContext({
        id = 'research_menu',
        title = 'Blueprint Research Laboratory',
        options = options
    })
    exports['ox_lib']:showContext('research_menu')
end)

-- Tool Management Interface
RegisterNetEvent('bldr_crafting:openToolMenu', function(playerTools)
    local options = {
        {
            title = '⚒️ Tool Workshop',
            description = 'Manage and maintain your specialized crafting tools',
            icon = 'fas fa-tools',
            disabled = true
        }
    }
    
    if playerTools and #playerTools > 0 then
        for _, tool in ipairs(playerTools) do
            local durabilityPercent = math.floor((tool.durability / tool.maxDurability) * 100)
            local durabilityColor = durabilityPercent > 75 and 'success' or 
                                  durabilityPercent > 25 and 'warning' or 'error'
            
            table.insert(options, {
                title = string.format('🔧 %s', tool.name),
                description = 'Professional crafting tool with enhanced capabilities',
                icon = 'fas fa-wrench',
                metadata = {
                    { label = 'Durability', value = durabilityPercent .. '%', color = durabilityColor },
                    { label = 'Total Uses', value = tool.totalUses },
                    { label = 'Quality Bonus', value = '+' .. math.floor((tool.quality - 1) * 100) .. '%' },
                    { label = 'Repair Cost', value = '$' .. (tool.repairCost or 0) }
                },
                onSelect = function()
                    if durabilityPercent < 100 then
                        TriggerServerEvent('bldr_crafting:repairTool', tool.id)
                    else
                        QBCore.Functions.Notify('Tool is in perfect condition!', 'success')
                    end
                end
            })
        end
    else
        table.insert(options, {
            title = '❌ No Tools Found',
            description = 'Purchase crafting tools to enhance your capabilities',
            icon = 'fas fa-exclamation-triangle',
            disabled = true
        })
    end
    
    exports['ox_lib']:registerContext({
        id = 'tool_menu',
        title = 'Tool Workshop',
        options = options
    })
    exports['ox_lib']:showContext('tool_menu')
end)

-- Helper Functions for Advanced Features
function getUpgradeDescription(upgradeType, upgradeData)
    if upgradeType == 'efficiency' then
        return 'Reduces crafting time by ' .. math.floor((upgradeData.speedMultiplier - 1) * 100) .. '%'
    elseif upgradeType == 'quality' then
        return 'Increases item quality by ' .. math.floor(upgradeData.qualityBonus * 100) .. '%'
    elseif upgradeType == 'capacity' then
        return 'Enables batch crafting up to ' .. upgradeData.batchMultiplier .. 'x items'
    end
    return 'Improves station capabilities'
end

function getRarityIcon(rarity)
    local icons = {
        common = 'fas fa-circle',
        uncommon = 'fas fa-star',
        rare = 'fas fa-gem', 
        epic = 'fas fa-crown',
        legendary = 'fas fa-trophy'
    }
    return icons[rarity] or 'fas fa-question'
end