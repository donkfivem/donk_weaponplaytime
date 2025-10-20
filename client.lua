local isRestricted = true
local checkingWeapon = false

-- Notification Helper Function
local function SendNotification(title, description, type, duration)
    if not Config.Notifications.enabled then return end

    local notifType = Config.Notifications.type

    if notifType == 'ox_lib' then
        lib.notify({
            title = title,
            description = description,
            type = type,
            duration = duration or 5000
        })
    elseif notifType == 'qb' then
        TriggerEvent('QBCore:Notify', description, type, duration or 5000)
    elseif notifType == 'esx' then
        TriggerEvent('esx:showNotification', description, type, duration or 5000)
    elseif notifType == 'custom' then
        Config.CustomNotify(title, description, type, duration)
    end
end

-- Get Current Weapon Function
local function GetCurrentWeapon()
    if Config.Inventory == 'ox_inventory' then
        return exports.ox_inventory:getCurrentWeapon()
    elseif Config.Inventory == 'qb-inventory' then
        local ped = PlayerPedId()
        local weapon = GetSelectedPedWeapon(ped)
        return weapon ~= `WEAPON_UNARMED` and weapon or nil
    elseif Config.Inventory == 'custom' then
        -- Add your custom inventory check here
        local ped = PlayerPedId()
        local weapon = GetSelectedPedWeapon(ped)
        return weapon ~= `WEAPON_UNARMED` and weapon or nil
    end
    return nil
end

-- Disarm Function
local function DisarmPlayer()
    if Config.Inventory == 'ox_inventory' then
        TriggerEvent('ox_inventory:disarm', true)
    elseif Config.Inventory == 'qb-inventory' then
        local ped = PlayerPedId()
        SetCurrentPedWeapon(ped, `WEAPON_UNARMED`, true)
    elseif Config.Inventory == 'custom' then
        -- Add your custom disarm code here
        local ped = PlayerPedId()
        SetCurrentPedWeapon(ped, `WEAPON_UNARMED`, true)
    end
end

-- Main restriction check thread
CreateThread(function()
    while true do
        Wait(Config.CheckIntervals.mainCheck)
        local canUse, hours, minutes = lib.callback.await('weaponRestriction:canUseWeapon', false)
        if canUse then
            isRestricted = false
            break
        else
            isRestricted = true
        end
    end
end)

-- Weapon check thread
CreateThread(function()
    while true do
        Wait(Config.CheckIntervals.weaponCheck)
        if isRestricted and not checkingWeapon then
            local currentWeapon = GetCurrentWeapon()
            if currentWeapon then
                checkingWeapon = true
                DisarmPlayer()
                local canUse, hours, minutes = lib.callback.await('weaponRestriction:canUseWeapon', false)

                local description = string.format(
                    Config.Notifications.messages.restricted,
                    Config.RestrictionTime,
                    hours or 0,
                    minutes or 0
                )

                SendNotification(
                    Config.Notifications.messages.restrictedTitle,
                    description,
                    'error',
                    5000
                )

                Wait(1000)
                checkingWeapon = false
            end
        else
            Wait(500)
        end
    end
end)

-- Periodic check for restriction lift
CreateThread(function()
    while isRestricted do
        Wait(Config.CheckIntervals.periodicCheck)
        local canUse = lib.callback.await('weaponRestriction:canUseWeapon', false)
        if canUse then
            isRestricted = false
            SendNotification(
                Config.Notifications.messages.liftedTitle,
                Config.Notifications.messages.liftedDescription,
                'success',
                5000
            )
        end
    end
end)

-- Debug Information
if Config.Debug then
    print('[Weapon Playtime] Client initialized')
    print(string.format('[Weapon Playtime] Inventory System: %s', Config.Inventory))
end