---@class HelperISCommands: Helper
ISCommands = _Class:Create("HelperISCommands", Helper)

--- Register console command for shipping items from all mods.
---@param modUUID string The UUID of the mod being processed
---@param skipChecks string Whether to skip checking if the item already exists
---@return nil
Ext.RegisterConsoleCommand('isf_ship_all', function(cmd, skipChecks)
    local boolSkipChecks = skipChecks == 'true'
    local trigger = "ConsoleCommand"
    ItemShipmentInstance:SetShipmentTrigger(trigger)

    ItemShipmentInstance:LoadShipments()
    ItemShipmentInstance:ProcessShipments(boolSkipChecks)
end)

--- Register console command for shipping items for a specific mod passed as argument.
---@param modUUID string The UUID of the mod being processed
---@param skipChecks string Whether to skip checking if the item already exists
---@return nil
Ext.RegisterConsoleCommand('isf_ship_mod', function(cmd, modUUID, skipChecks)
    local boolSkipChecks = skipChecks == 'true'
    local trigger = "ConsoleCommand"
    ItemShipmentInstance:SetShipmentTrigger(trigger)

    ItemShipmentInstance:LoadShipments()
    ItemShipmentInstance:ProcessModShipments(modUUID, boolSkipChecks)
end)

--- Register console command for uninstalling Item Shipment Framework.
-- TODO: check if ModVars are wiped after saving without the mod loaded
---@return nil
Ext.RegisterConsoleCommand('isf_uninstall', function(cmd)
    ISFWarn(0,
        "[UNIMPLEMENTED] Uninstalling Item Shipment Framework. All non-ISF items from the mailboxes may be moved to the camp chests. Mailboxes will be deleted.")

    -- TODO: implement this and modularize
    -- Move all items from mailboxes to their camp chests
    -- Get all camp chests and their mailboxes
    -- Iterate mailboxes
    -- Move items from mailboxes to camp chests

    -- Step 2: remove all mailboxes with Osi.RequestDelete
    -- Iterate mailboxes and delete them

    -- Print a message to the player (debug 0)
end)
