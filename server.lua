local RESTRICTION_TIME = Config.RestrictionTime * 60 * 60

local Framework = nil
local FrameworkName = Config.Framework

if FrameworkName == 'esx' then
    Framework = exports['es_extended']:getSharedObject()
elseif FrameworkName == 'qbcore' then
    Framework = exports['qb-core']:GetCoreObject()
elseif FrameworkName == 'qbx' then
    Framework = 'qbx'
end

local function GetPlayer(source)
    if FrameworkName == 'esx' then
        return Framework.GetPlayerFromId(source)
    elseif FrameworkName == 'qbcore' then
        return Framework.Functions.GetPlayer(source)
    elseif FrameworkName == 'qbx' then
        return exports.qbx_core:GetPlayer(source)
    end
    return nil
end

local function GetPlayerIdentifier(Player)
    if FrameworkName == 'esx' then
        return Player.identifier
    elseif FrameworkName == 'qbcore' or FrameworkName == 'qbx' then
        return Player.PlayerData.citizenid
    end
    return nil
end

local function GetDatabaseSettings()
    if FrameworkName == 'esx' then
        return Config.Database.ESX
    else
        return Config.Database.QBCore
    end
end

lib.callback.register('weaponRestriction:canUseWeapon', function(source)
    local Player = GetPlayer(source)
    if not Player then return false end

    local identifier = GetPlayerIdentifier(Player)
    local dbSettings = GetDatabaseSettings()

    local query = string.format('SELECT %s FROM %s WHERE %s = ?',
        dbSettings.firstJoinColumn,
        dbSettings.tableName,
        dbSettings.identifierColumn)

    local result = MySQL.single.await(query, {identifier})

    if not result or not result[dbSettings.firstJoinColumn] then
        local updateQuery = string.format('UPDATE %s SET %s = NOW() WHERE %s = ?',
            dbSettings.tableName,
            dbSettings.firstJoinColumn,
            dbSettings.identifierColumn)
        MySQL.update(updateQuery, {identifier})
        return false
    end

    local timeDiffQuery = string.format('SELECT TIMESTAMPDIFF(SECOND, %s, NOW()) FROM %s WHERE %s = ?',
        dbSettings.firstJoinColumn,
        dbSettings.tableName,
        dbSettings.identifierColumn)

    local timeDiff = MySQL.scalar.await(timeDiffQuery, {identifier})

    if timeDiff and timeDiff >= RESTRICTION_TIME then
        return true
    end

    local remainingTime = RESTRICTION_TIME - (timeDiff or 0)
    local hours = math.floor(remainingTime / 3600)
    local minutes = math.floor((remainingTime % 3600) / 60)

    return false, hours, minutes
end)

MySQL.ready(function()
    local dbSettings = GetDatabaseSettings()

    local alterQuery = string.format([[
        ALTER TABLE %s
        ADD COLUMN IF NOT EXISTS %s TIMESTAMP NULL DEFAULT NULL
    ]], dbSettings.tableName, dbSettings.firstJoinColumn)

    MySQL.query(alterQuery)

    if Config.Debug then
        print(string.format('[Weapon Playtime] Database initialized for %s framework', FrameworkName))
    end
end)

if Config.Debug then
    print(string.format('[Weapon Playtime] Framework: %s', FrameworkName))
    print(string.format('[Weapon Playtime] Restriction Time: %d hours', Config.RestrictionTime))
end