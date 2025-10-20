Config = {}

-- Framework Selection ('qbcore', 'qbx', or 'esx')
Config.Framework = 'qbx' -- Change to 'qbcore', 'qbx', or 'esx'

-- Restriction Time in hours
Config.RestrictionTime = 5 -- Hours that new players cannot use weapons

-- Notification Settings
Config.Notifications = {
    enabled = true,
    type = 'ox_lib', -- 'ox_lib', 'qb', 'esx', or 'custom'

    -- Notification Messages
    messages = {
        restricted = 'New players cannot use weapons for %d hours. Time remaining: %dh %dm',
        restrictedTitle = 'Weapon Restricted',
        liftedTitle = 'Weapon Restriction Lifted',
        liftedDescription = 'You can now use weapons!',
    }
}

-- Check Intervals (in milliseconds)
Config.CheckIntervals = {
    mainCheck = 1000,      -- How often to check if player can use weapons
    weaponCheck = 100,     -- How often to check for equipped weapons
    periodicCheck = 60000  -- How often to check for restriction lift
}

-- Inventory System
Config.Inventory = 'ox_inventory' -- 'ox_inventory', 'qb-inventory', or 'custom'

-- Debug Mode
Config.Debug = false

-- Database Settings
Config.Database = {
    -- ESX specific settings
    ESX = {
        tableName = 'users',
        identifierColumn = 'identifier',
        firstJoinColumn = 'first_join'
    },
    -- QBCore/QBX specific settings
    QBCore = {
        tableName = 'players',
        identifierColumn = 'citizenid',
        firstJoinColumn = 'first_join'
    }
}

-- Custom notification function (if Config.Notifications.type = 'custom')
Config.CustomNotify = function(title, description, type, duration)
    -- Add your custom notification code here
    print(string.format('[%s] %s: %s', type, title, description))
end
