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

-- TODO: move to VC
--- Guess this is our life now
---@param eventId string
---@param content string
---@param force? number
---@param initiation? GUIDSTRING -- Initiation? More like initiation of the end times
---@param char1? GUIDSTRING
---@param char2? GUIDSTRING
---@param char3? GUIDSTRING
function DustyMessageBox(eventId, content, initiation, char1, char2, char3, force)
    force = force or 1
    initiation = initiation or Osi.GetHostCharacter()
    char1 = char1 or ""
    char2 = char2 or ""
    char3 = char3 or ""
    Osi.ReadyCheckSpecific(eventId, content, force, initiation, char1, char2, char3)
end

--- Register console command for uninstalling Item Shipment Framework.
-- NOTE: ModVars are wiped after saving without the mod loaded
---@return nil
Ext.RegisterConsoleCommand('isf_uninstall', function(cmd)
    ISFWarn(0,
        "Uninstalling A&V Item Shipment Framework. All non-ISF items from the mailboxes may be moved to the camp chests. Mailboxes will be deleted.")

    DustyMessageBox('isf_uninstall_move_items',
        Messages.ResolvedMessages.uninstall_should_move_out_of_mailboxes)
end)

--- Register console command for refilling all mailboxes with items.
--- The refill will add the difference between the mailbox and the camp chest. Any missing items from the mailbox will be added, regardless of existence checks. However, only the difference will be added. If the item configuration declares that 2 copies of an item should be in the mailbox, but there is already 1, only 1 will be added.
Ext.RegisterConsoleCommand('isf_refill', function(cmd)
    ISFPrint(0, "Refilling all mailboxes with items.")

    ItemShipmentInstance:LoadShipments()

    ISMailboxes:RefillMailboxes()
end)
