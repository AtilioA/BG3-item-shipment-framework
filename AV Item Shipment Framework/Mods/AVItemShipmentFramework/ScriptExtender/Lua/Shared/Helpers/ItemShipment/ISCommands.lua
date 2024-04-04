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
    -- Step 1: Move all items from mailboxes to their camp chests
    -- Get all camp chests and their mailboxes
    local ISFModVars = Ext.Vars.GetModVariables(ModuleUUID)
    local campChestUUIDs = VCHelpers.Camp:GetAllCampChestUUIDs()

    -- Iterate mailboxes
    -- TODO: change this when refactoring to access mailboxes with the camp chest template name
    for index, mailboxUUID in pairs(ISFModVars.Mailboxes) do
        local campChestUUID = campChestUUIDs[index]
        ISFDebug(2, "Checking mailbox " .. mailboxUUID .. " in camp chest " .. campChestUUID)
        if campChestUUID then
            -- Move items from mailbox to camp chest
            -- Get items in mailbox
            local mailboxItems = VCHelpers.Inventory:GetInventory(mailboxUUID, true, true)
            for _, item in pairs(mailboxItems) do
                local amount, total = Osi.GetStackAmount(item.Guid)
                Osi.ToInventory(item.Guid, campChestUUID, total, 0, 1)
            end

            ISFDebug(0, "Moved items from mailbox " .. mailboxUUID .. " to camp chest " .. campChestUUID)
        end

        VCHelpers.Timer:OnTime(2000, function()
            -- Delete mailbox
            Osi.RequestDelete(mailboxUUID)
            ISFDebug(0, "Deleted mailbox " .. mailboxUUID)
        end)
    end
    VCHelpers.Timer:OnTime(2000, function()
        ISFPrint(0,
            "Item Shipment Framework has been uninstalled. You may now safely remove the mod from your load order.")
    end)
end)
