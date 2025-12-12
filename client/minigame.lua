-- Crafting Minigame Client
-- Custom button-mashing minigame with visual UI

-- [FIX] Print IMMEDIATELY without any dependencies
print("========== MINIGAME.LUA LOADING ==========")

local isMinigameActive = false
local minigameThread = nil

-- [FIX] Safe debug logger that doesn't crash if Config is nil
local function DebugLog(msg)
    -- Only log if Config exists AND Debug is true
    if type(Config) == "table" and Config.Debug == true then
        print("[MINIGAME DEBUG] " .. tostring(msg))
    end
end

-- Define function in global scope immediately
ShowCraftingMinigame = function(recipeKey, difficulty, callback)
    DebugLog("ShowCraftingMinigame called!")
    DebugLog("- Recipe: " .. tostring(recipeKey))
    DebugLog("- Difficulty: " .. tostring(difficulty))
    DebugLog("- Callback type: " .. type(callback))
    
    if not Config or not Config.CraftingMinigame or not Config.CraftingMinigame.enabled then
        DebugLog("Minigame disabled or config missing, returning success")
        if callback then callback('success') end
        return
    end
    
    -- [FIX] Stronger protection against double-start
    if isMinigameActive then
        DebugLog("Minigame already active, rejecting new start")
        if callback then callback('failed') end
        return
    end
    
    DebugLog("Starting minigame!")
    isMinigameActive = true  -- [FIX] Set flag IMMEDIATELY
    difficulty = difficulty or 'medium'
    local settings = Config.CraftingMinigame.difficulties[difficulty] or Config.CraftingMinigame.difficulties.medium
    DebugLog("Settings - Duration: " .. settings.duration .. " Presses: " .. settings.buttonPresses)
    
    local startTime = GetGameTimer()
    local duration = settings.duration or 3000
    local requiredPresses = settings.buttonPresses or 10
    local pressCount = 0
    local lastPress = 0
    local cooldown = 150
    local result = 'failed'
    local cancelled = false  -- [FIX] Track if player cancelled
    
    -- [FIX] Store thread reference
    minigameThread = CreateThread(function()
        while isMinigameActive do
            local currentTime = GetGameTimer()
            local elapsed = currentTime - startTime
            
            -- [FIX] Check for ESC key to cancel
            if IsControlJustPressed(0, 322) then  -- ESC key
                DebugLog("Minigame cancelled by player (ESC)")
                result = 'cancelled'
                cancelled = true
                break
            end
            
            -- Check if time is up
            if elapsed >= duration then
                if pressCount >= (requiredPresses * 0.7) then
                    result = 'success'
                    DebugLog("Time's up - SUCCESS (" .. pressCount .. "/" .. requiredPresses .. ")")
                else
                    result = 'failed'
                    DebugLog("Time's up - FAILED (" .. pressCount .. "/" .. requiredPresses .. ")")
                end
                break
            end
            
            -- [FIX] Disable player controls during minigame
            DisableControlAction(0, 1, true)   -- LookLeftRight
            DisableControlAction(0, 2, true)   -- LookUpDown
            DisableControlAction(0, 24, true)  -- Attack
            DisableControlAction(0, 25, true)  -- Aim
            DisableControlAction(0, 37, true)  -- Weapon Wheel
            DisableControlAction(0, 44, true)  -- Cover
            DisableControlAction(0, 45, true)  -- Reload
            DisableControlAction(0, 140, true) -- Melee Attack Light
            DisableControlAction(0, 141, true) -- Melee Attack Heavy
            DisableControlAction(0, 142, true) -- Melee Attack Alternate
            DisableControlAction(0, 257, true) -- Attack 2
            DisableControlAction(0, 263, true) -- Melee Attack 1
            DisableControlAction(0, 264, true) -- Melee Attack 2
            
            Wait(0)
            
            -- [FIX] Modern UI with glow effects and animations
            
            -- Pulsing glow effect
            local pulseAlpha = math.floor(100 + (math.sin(elapsed / 200) * 50))
            
            -- Outer glow layers for depth
            DrawRect(0.5, 0.88, 0.326, 0.146, 52, 152, 219, pulseAlpha * 0.3) -- Outer glow
            DrawRect(0.5, 0.88, 0.323, 0.143, 52, 152, 219, pulseAlpha * 0.5) -- Mid glow
            
            -- Main background with gradient simulation
            DrawRect(0.5, 0.88, 0.32, 0.14, 15, 15, 20, 200) -- Dark blue-black
            
            -- Animated border glow
            DrawRect(0.5, 0.808, 0.32, 0.003, 52, 152, 219, 255) -- Top border thick
            DrawRect(0.5, 0.808, 0.32, 0.001, 100, 200, 255, pulseAlpha) -- Top glow
            DrawRect(0.5, 0.952, 0.32, 0.003, 52, 152, 219, 255) -- Bottom border thick
            DrawRect(0.5, 0.952, 0.32, 0.001, 100, 200, 255, pulseAlpha) -- Bottom glow
            
            -- Side accent lines
            DrawRect(0.34, 0.88, 0.002, 0.14, 52, 152, 219, 200) -- Left
            DrawRect(0.66, 0.88, 0.002, 0.14, 52, 152, 219, 200) -- Right
            
            -- Title with intense glow
            SetTextFont(4)
            SetTextProportional(1)
            SetTextScale(0.50, 0.50)
            SetTextColour(100, 200, 255, 255) -- Bright cyan
            SetTextDropshadow(2, 0, 0, 0, 255)
            SetTextEdge(2, 52, 152, 219, 255)
            SetTextCentre(true)
            SetTextEntry("STRING")
            AddTextComponentString("⚡ CRAFTING ⚡")
            DrawText(0.5, 0.82)
            
            -- Instruction text with gradient effect simulation
            SetTextFont(0)
            SetTextScale(0.35, 0.35)
            SetTextColour(180, 220, 255, 255)
            SetTextDropshadow(1, 0, 0, 0, 200)
            SetTextCentre(true)
            SetTextEntry("STRING")
            AddTextComponentString("Press ~g~E~w~ rapidly to craft")
            DrawText(0.5, 0.86)
            
            -- Progress bar with multi-layer design
            local progress = math.min(1.0, pressCount / requiredPresses)
            
            -- Progress bar background with depth
            DrawRect(0.5, 0.902, 0.244, 0.044, 0, 0, 0, 180) -- Outer shadow
            DrawRect(0.5, 0.9, 0.242, 0.042, 0, 0, 0, 200) -- Shadow
            DrawRect(0.5, 0.9, 0.24, 0.04, 10, 10, 15, 255) -- Container
            
            -- Progress bar fill with animated gradient
            local barColor = {231, 76, 60} -- Red
            local glowColor = {255, 100, 100}
            if progress >= 0.7 then
                barColor = {46, 204, 113} -- Green
                glowColor = {100, 255, 150}
            elseif progress >= 0.4 then
                barColor = {241, 196, 15} -- Gold
                glowColor = {255, 220, 100}
            end
            
            if progress > 0 then
                local barWidth = 0.236 * progress
                local barX = 0.5 - (0.236 / 2) + (barWidth / 2)
                
                -- Multi-layer glow effect
                DrawRect(barX, 0.9, barWidth + 0.004, 0.044, glowColor[1], glowColor[2], glowColor[3], pulseAlpha * 0.4)
                DrawRect(barX, 0.9, barWidth + 0.002, 0.040, glowColor[1], glowColor[2], glowColor[3], pulseAlpha * 0.6)
                DrawRect(barX, 0.9, barWidth, 0.036, barColor[1], barColor[2], barColor[3], 255)
                
                -- Shine effect on top
                DrawRect(barX, 0.891, barWidth * 0.9, 0.012, 255, 255, 255, 80)
                -- Bottom gradient
                DrawRect(barX, 0.909, barWidth, 0.018, barColor[1] * 0.7, barColor[2] * 0.7, barColor[3] * 0.7, 180)
            end
            
            -- Counter text with outline
            SetTextFont(4)
            SetTextScale(0.42, 0.42)
            SetTextColour(255, 255, 255, 255)
            SetTextDropshadow(2, 0, 0, 0, 255)
            SetTextEdge(2, 0, 0, 0, 255)
            SetTextCentre(true)
            SetTextEntry("STRING")
            AddTextComponentString(string.format("%d / %d", pressCount, requiredPresses))
            DrawText(0.5, 0.888)
            
            -- Time bar with sleek design
            local timeProgress = 1.0 - (elapsed / duration)
            DrawRect(0.5, 0.937, 0.242, 0.020, 0, 0, 0, 200) -- Shadow
            DrawRect(0.5, 0.935, 0.24, 0.018, 10, 10, 15, 255) -- Container
            
            if timeProgress > 0 then
                local timeColor = timeProgress > 0.5 and {52, 152, 219} or {231, 76, 60}
                local timeGlow = timeProgress > 0.5 and {100, 200, 255} or {255, 100, 100}
                local timeWidth = 0.236 * timeProgress
                local timeX = 0.5 - (0.236 / 2) + (timeWidth / 2)
                
                -- Glowing time bar
                DrawRect(timeX, 0.935, timeWidth + 0.002, 0.022, timeGlow[1], timeGlow[2], timeGlow[3], pulseAlpha * 0.5)
                DrawRect(timeX, 0.935, timeWidth, 0.014, timeColor[1], timeColor[2], timeColor[3], 255)
                DrawRect(timeX, 0.930, timeWidth * 0.9, 0.006, 255, 255, 255, 60) -- Shine
            end
            
            -- Time label with styling
            SetTextFont(0)
            SetTextScale(0.30, 0.30)
            SetTextColour(180, 220, 255, 255)
            SetTextDropshadow(1, 0, 0, 0, 200)
            SetTextCentre(true)
            SetTextEntry("STRING")
            local remainingTime = math.ceil((duration - elapsed) / 1000)
            AddTextComponentString(string.format("⏱ %ds  |  Press ~r~ESC~w~ to cancel", remainingTime))
            DrawText(0.5, 0.946)
            
            -- Check for E press
            if IsControlJustPressed(0, 38) then
                if currentTime - lastPress > cooldown then
                    pressCount = pressCount + 1
                    lastPress = currentTime
                    PlaySoundFrontend(-1, "CLICK_BACK", "WEB_NAVIGATION_SOUNDS_PHONE", true)
                    
                    if pressCount >= requiredPresses then
                        result = 'success'
                        DebugLog("Required presses reached - SUCCESS")
                        break
                    end
                end
            end
        end
        
        -- [FIX] Cleanup happens BEFORE callback to prevent race conditions
        isMinigameActive = false
        minigameThread = nil
        
        DebugLog("Minigame completed! Result: " .. result)
        PlaySoundFrontend(-1, result == 'success' and "PICK_UP" or "ERROR", "HUD_FRONTEND_DEFAULT_SOUNDSET", true)
        
        -- [FIX] Callback is called AFTER cleanup
        if callback then 
            DebugLog("Calling callback with result: " .. result)
            callback(result)
        else
            DebugLog("WARNING: No callback provided!")
        end
    end)
end

-- [FIX] Function to force-stop minigame (emergency cleanup)
function StopCraftingMinigame()
    if isMinigameActive then
        DebugLog("Force stopping minigame")
        isMinigameActive = false
        minigameThread = nil
    end
end

RegisterCommand('testcraftminigame', function()
    ShowCraftingMinigame(nil, 'medium', function(result)
        print('Minigame Result: ' .. result)
    end)
end, false)

-- [FIX] ALWAYS print load confirmation
print("========================================")
print("[MINIGAME] minigame.lua FULLY LOADED!")
print("[MINIGAME] ShowCraftingMinigame type: " .. type(ShowCraftingMinigame))
print("[MINIGAME] _G check: " .. type(_G.ShowCraftingMinigame))
print("========================================")

_G['ShowCraftingMinigame'] = ShowCraftingMinigame
_G['StopCraftingMinigame'] = StopCraftingMinigame
