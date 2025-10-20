# Weapon Playtime Restriction

A FiveM resource that prevents new players from using weapons for a configurable period of time. This helps prevent RDM (Random Deathmatch) and gives new players time to learn the server rules before accessing weapons.

## Features

- **Multi-Framework Support**: Works with ESX, QBCore, and QBX
- **Fully Configurable**: All settings can be adjusted in the config file
- **Flexible Notification System**: Supports ox_lib, QBCore, ESX, and custom notifications
- **Multiple Inventory Support**: Compatible with ox_inventory, qb-inventory, and custom inventory systems
- **Automatic Database Setup**: Automatically creates necessary database columns
- **Real-time Monitoring**: Constantly checks and enforces weapon restrictions
- **Player Notifications**: Informs players of remaining time and when restrictions are lifted
- **Debug Mode**: Built-in debug logging for troubleshooting

## Dependencies

- [ox_lib](https://github.com/overextended/ox_lib) - Required for callbacks and notifications
- [oxmysql](https://github.com/overextended/oxmysql) - Required for database operations
- One of the following frameworks:
  - [es_extended](https://github.com/esx-framework/esx-legacy) (ESX)
  - [qb-core](https://github.com/qbcore-framework/qb-core) (QBCore)
  - [qbx_core](https://github.com/Qbox-project/qbx_core) (QBX)

## Installation

1. **Download the resource** and place it in your server's `resources` folder
2. **Rename** the folder to `donk_weaponplaytime` (or your preferred name)
3. **Configure** the `config.lua` file to match your server setup
4. **Add to server.cfg**:
   ```
   ensure donk_weaponplaytime
   ```
5. **Restart your server**

The resource will automatically create the required database column on first startup.

## Configuration

### Basic Setup

Open `config.lua` and configure the following:

```lua
-- Framework Selection
Config.Framework = 'qbx' -- Options: 'qbcore', 'qbx', or 'esx'

-- Restriction Time in hours
Config.RestrictionTime = 5 -- New players cannot use weapons for this many hours

-- Inventory System
Config.Inventory = 'ox_inventory' -- Options: 'ox_inventory', 'qb-inventory', or 'custom'
```

### Advanced Configuration

#### Notification Settings

```lua
Config.Notifications = {
    enabled = true,
    type = 'ox_lib', -- Options: 'ox_lib', 'qb', 'esx', or 'custom'

    messages = {
        restricted = 'New players cannot use weapons for %d hours. Time remaining: %dh %dm',
        restrictedTitle = 'Weapon Restricted',
        liftedTitle = 'Weapon Restriction Lifted',
        liftedDescription = 'You can now use weapons!',
    }
}
```

#### Check Intervals

Adjust performance by modifying check intervals (in milliseconds):

```lua
Config.CheckIntervals = {
    mainCheck = 1000,      -- How often to check if player can use weapons
    weaponCheck = 100,     -- How often to check for equipped weapons
    periodicCheck = 60000  -- How often to check for restriction lift
}
```

#### Database Settings

The resource supports different database structures for ESX and QBCore:

```lua
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
```

#### Debug Mode

Enable debug mode to troubleshoot issues:

```lua
Config.Debug = true -- Set to false in production
```

## Framework-Specific Setup

### ESX Setup

1. Set `Config.Framework = 'esx'` in `config.lua`
2. Ensure `es_extended` is started before this resource
3. The resource will use the `users` table with `identifier` column

### QBCore Setup

1. Set `Config.Framework = 'qbcore'` in `config.lua`
2. Ensure `qb-core` is started before this resource
3. The resource will use the `players` table with `citizenid` column

### QBX Setup

1. Set `Config.Framework = 'qbx'` in `config.lua`
2. Ensure `qbx_core` is started before this resource
3. The resource will use the `players` table with `citizenid` column

## How It Works

1. **First Join Detection**: When a player joins for the first time, the resource records a timestamp in the database
2. **Restriction Check**: The resource continuously checks if the configured time period has elapsed
3. **Weapon Detection**: If a restricted player attempts to equip a weapon, they are automatically disarmed
4. **Notification**: Players receive notifications showing remaining time and when restrictions are lifted
5. **Automatic Lift**: Once the time period elapses, restrictions are automatically removed

## Database

The resource automatically creates a `first_join` column in your player database table:

```sql
-- For ESX
ALTER TABLE users ADD COLUMN IF NOT EXISTS first_join TIMESTAMP NULL DEFAULT NULL;

-- For QBCore/QBX
ALTER TABLE players ADD COLUMN IF NOT EXISTS first_join TIMESTAMP NULL DEFAULT NULL;
```

This happens automatically on resource start - no manual SQL execution required.

## Custom Integration

### Custom Notification System

To use a custom notification system:

1. Set `Config.Notifications.type = 'custom'`
2. Modify the `Config.CustomNotify` function in `config.lua`:

```lua
Config.CustomNotify = function(title, description, type, duration)
    -- Your custom notification code here
    exports['your-notify']:Show(title, description, type, duration)
end
```

### Custom Inventory System

To use a custom inventory system:

1. Set `Config.Inventory = 'custom'`
2. Modify the `GetCurrentWeapon()` and `DisarmPlayer()` functions in `client.lua`

## Troubleshooting

### Weapons still equip for new players

- Enable debug mode: `Config.Debug = true`
- Check server console for errors
- Verify the database column was created successfully
- Ensure ox_lib callbacks are working properly

### Framework not detected

- Verify the framework name is spelled correctly in config
- Ensure the framework is started before this resource
- Check that framework exports are available

### Database errors

- Ensure oxmysql is properly installed and configured
- Verify database connection in server console
- Check that the user has ALTER TABLE permissions

### Performance issues

- Increase check intervals in config
- Reduce the frequency of database queries
- Monitor server performance with resource monitor

## Support

For issues, questions, or contributions:

1. Open an issue on the GitHub repository
2. Provide server logs with debug mode enabled
3. Include your framework and inventory system information

## Credits

**Author**: donk
**Version**: 2.0.0
**License**: MIT

## Changelog

### Version 2.0.0
- Added multi-framework support (ESX, QBCore, QBX)
- Implemented configuration system
- Added multiple notification system support
- Added multiple inventory system support
- Improved code structure and maintainability
- Added debug mode
- Updated documentation

### Version 1.0.0
- Initial release
- QBX support only
- Fixed restriction time

## License

This project is licensed under the MIT License - feel free to modify and distribute as needed.

---

**Note**: This resource is designed for roleplay servers to prevent new players from immediately accessing weapons. Adjust the restriction time based on your server's needs and new player onboarding process.
