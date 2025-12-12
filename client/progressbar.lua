-- Custom Progress Bar
-- Simple visual progress bar without dependencies

if Config and Config.Debug then
    print("^3[PROGRESSBAR] Loading progressbar.lua^0")
end

local isProgressActive = false
local progressThread = nil  -- [FIX] Store thread reference for cleanup

-- [FIX] Debug logger with Config toggle
local function DebugLog(msg)
    if Config and Config.Debug then
        print("^3[PROGRESSBAR DEBUG] " .. msg .. "^0")
    end
end

function ShowCustomProgress(duration, label, callback)
    if isProgressActive then
        DebugLog("Progress bar already active, rejecting new start")
        if callback then callback(false) end
        return
    end
    
    DebugLog("Starting progress bar - Duration: " .. duration .. "ms Label: " .. tostring(label))
    isProgressActive = true
    local startTime = GetGameTimer()
    local success = true
    local cancelled = false  -- [FIX] Track cancellation
    
    progressThread = CreateThread(function()
        while isProgressActive do
            local currentTime = GetGameTimer()
            local elapsed = currentTime - startTime
            local progress = math.min(1.0, elapsed / duration)
            
            -- [FIX] Check for ESC to cancel
            if IsControlJustPressed(0, 322) then  -- ESC key
                DebugLog("Progress bar cancelled by player")
                success = false
                cancelled = true
                break
            end
            
            if elapsed >= duration then
                DebugLog("Progress bar completed successfully")
                break
            end
            
            Wait(0)
            
            -- [FIX] Cleaner progress bar design
            
            -- Main container with border
            DrawRect(0.5, 0.9, 0.27, 0.065, 0, 0, 0, 230)
            DrawRect(0.5, 0.9, 0.27, 0.001, 52, 152, 219, 255) -- Top border
            DrawRect(0.5, 0.9325, 0.27, 0.001, 52, 152, 219, 255) -- Bottom border
            
            -- Label with better styling
            SetTextFont(4)
            SetTextProportional(1)
            SetTextScale(0.35, 0.35)
            SetTextColour(52, 152, 219, 255)
            SetTextDropshadow(1, 0, 0, 0, 255)
            SetTextCentre(true)
            SetTextEntry("STRING")
            AddTextComponentString(label or "Processing...")
            DrawText(0.5, 0.875)
            
            -- Progress bar background with shadow
            DrawRect(0.5, 0.915, 0.242, 0.027, 0, 0, 0, 150) -- Shadow
            DrawRect(0.5, 0.915, 0.24, 0.025, 20, 20, 20, 255) -- Container
            
            -- Progress bar fill with gradient
            if progress > 0 then
                local barWidth = 0.236 * progress
                local barX = 0.5 - (0.236 / 2) + (barWidth / 2)
                -- Main fill
                DrawRect(barX, 0.915, barWidth, 0.021, 46, 204, 113, 255)
                -- Inner glow
                DrawRect(barX, 0.915, barWidth, 0.011, 46, 204, 113, 100)
            end
            
            -- Percentage text
            SetTextFont(0)
            SetTextScale(0.3, 0.3)
            SetTextColour(200, 200, 200, 255)
            SetTextCentre(true)
            SetTextEntry("STRING")
            AddTextComponentString(string.format("%d%%", math.floor(progress * 100)))
            DrawText(0.5, 0.908)
        end
        
        -- [FIX] Cleanup BEFORE callback
        isProgressActive = false
        progressThread = nil
        
        DebugLog("Progress bar ended - Success: " .. tostring(success))
        
        if callback then
            callback(success)
        end
    end)
end

-- [FIX] Function to force-stop progress bar (emergency cleanup)
function StopCustomProgress()
    if isProgressActive then
        DebugLog("Force stopping progress bar")
        isProgressActive = false
        progressThread = nil
    end
end

-- Export the functions
exports('ShowCustomProgress', ShowCustomProgress)
exports('StopCustomProgress', StopCustomProgress)

if Config and Config.Debug then
    print("^3[PROGRESSBAR] progressbar.lua loaded successfully^0")
end