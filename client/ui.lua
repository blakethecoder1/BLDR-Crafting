-- Enhanced UI controller for bldr_crafting
-- Modern crafting interface with smooth animations and better UX

local QBCore = exports['qb-core']:GetCoreObject()
local isUIOpen = false

-- Performance optimization: Cache DOM updates
local pendingUIUpdates = {}
local UI_UPDATE_INTERVAL = 100 -- ms

-- Initialize UI state
CreateThread(function()
    Wait(500) -- Allow NUI to load
    SetNuiFocus(false, false)
    SetNuiFocusKeepInput(false)
    SendNUIMessage({ action = 'hide' })
end)

-- Batch UI updates for better performance
CreateThread(function()
    while true do
        Wait(UI_UPDATE_INTERVAL)
        if #pendingUIUpdates > 0 then
            for i = 1, #pendingUIUpdates do
                SendNUIMessage(pendingUIUpdates[i])
            end
            pendingUIUpdates = {}
        end
    end
end)

local function queueUIUpdate(message)
    pendingUIUpdates[#pendingUIUpdates + 1] = message
end

-- Open the enhanced crafting UI
RegisterNetEvent('bldr_crafting:openUI', function(data)
    print("[bldr_crafting] UI openUI event received with data:", json.encode(data))
    
    if isUIOpen then 
        print("[bldr_crafting] UI already open, ignoring request")
        return 
    end
    
    print("[bldr_crafting] Opening UI...")
    
    isUIOpen = true
    SetNuiFocus(true, true)
    SetNuiFocusKeepInput(false)
    
    -- Send enhanced recipe data to new UI
    SendNUIMessage({ 
        action = 'open', 
        payload = {
            recipes = data.recipes or {},
            station = data.station or {},
            playerLevel = data.playerLevel or 0
        }
    })
    
    print("[bldr_crafting] UI opened successfully")
    
    -- Add some visual feedback
    QBCore.Functions.Notify('Crafting workshop opened', 'primary', 2000)
end)

-- Close the UI with smooth animation
RegisterNetEvent('bldr_crafting:closeUI', function()
    if not isUIOpen then return end
    
    isUIOpen = false
    SetNuiFocus(false, false)
    SetNuiFocusKeepInput(false)
    SendNUIMessage({ action = 'close' })
end)

-- Handle crafting request from UI
RegisterNUICallback('craft', function(data, cb)
    print("^5^5^5 ========== CRAFT CALLBACK FROM NUI ========== ^0^0^0")
    print("^5[UI] Data received: " .. json.encode(data) .. "^0")
    
    cb('ok') -- Immediate callback to prevent NUI timeout
    
    if data and data.key then
        -- Add crafting started notification
        print("^5[UI] Triggering server event: bldr_crafting:startCraft^0")
        print("^5[UI] Recipe key: " .. tostring(data.key) .. "^0")
        QBCore.Functions.Notify('Starting to craft...', 'primary', 2000)
        TriggerServerEvent('bldr_crafting:startCraft', data.key)
        print("^5[UI] Server event triggered^0")
    else
        print("^1[UI] ERROR: No recipe key in data!^0")
    end
    
    -- Close UI after slight delay for better UX
    CreateThread(function()
        Wait(300)
        TriggerEvent('bldr_crafting:closeUI')
    end)
end)

-- Handle UI close callback
RegisterNUICallback('close', function(_, cb)
    cb('ok')
    TriggerEvent('bldr_crafting:closeUI')
end)

-- Enhanced error handling and recovery
RegisterNetEvent('bldr_crafting:uiError', function(errorMsg)
    QBCore.Functions.Notify('UI Error: ' .. (errorMsg or 'Unknown error'), 'error')
    TriggerEvent('bldr_crafting:closeUI')
end)

-- UI state management for debugging
RegisterNetEvent('bldr_crafting:getUIState', function()
    print('UI Open:', isUIOpen)
    print('Pending Updates:', #pendingUIUpdates)
end)

-- Emergency UI reset with enhanced recovery
RegisterCommand('uireset_craft', function()
    isUIOpen = false
    pendingUIUpdates = {}
    SetNuiFocus(false, false)
    SetNuiFocusKeepInput(false)
    SendNUIMessage({ action = 'hide' })
    QBCore.Functions.Notify('Crafting UI completely reset', 'success')
    print('Crafting UI reset - all states cleared')
end)

-- Auto-cleanup on resource restart
AddEventHandler('onResourceStop', function(resourceName)
    if GetCurrentResourceName() == resourceName then
        isUIOpen = false
        SetNuiFocus(false, false)
        SetNuiFocusKeepInput(false)
    end
end)

-- Release focus on resource stop
AddEventHandler('onResourceStop', function(res)
    if res == GetCurrentResourceName() then
        SetNuiFocus(false, false)
        SetNuiFocusKeepInput(false)
    end
end)