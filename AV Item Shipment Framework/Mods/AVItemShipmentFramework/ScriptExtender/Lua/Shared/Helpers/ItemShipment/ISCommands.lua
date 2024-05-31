---@class HelperISCommands: Helper
ISCommands = _Class:Create("HelperISCommands", Helper)

--- SE console command for shipping items from all mods.
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

--- SE console command for shipping items for a specific mod passed as argument.
---@example isf_ship_mod 12345678-1234-1234-1234-123456789012 true
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

--- SE console command for uninstalling Item Shipment Framework.
-- NOTE: ModVars are wiped after saving without the mod loaded
---@return nil
Ext.RegisterConsoleCommand('isf_uninstall', function(cmd)
    ISFWarn(0,
        "Uninstalling A&V Item Shipment Framework. All non-ISF items from the mailboxes may be moved to the camp chests. Mailboxes will be deleted.")

    VCHelpers.MessageBox:DustyMessageBox('isf_uninstall_move_items',
        Messages.ResolvedMessages.uninstall_should_move_out_of_mailboxes)
end)

--- SE console command for refilling all mailboxes with items.
--- The refill will add the difference between the mailbox and the camp chest. Any missing items from the mailbox will be added, regardless of existence checks. However, only the difference will be added. If the item configuration declares that 2 copies of an item should be in the mailbox, but there is already 1, only 1 will be added.
--- This also updates the tutorial chests in the mailboxes.
Ext.RegisterConsoleCommand('isf_refill', function(cmd)
    ISFPrint(0, "Refilling all mailboxes with items.")

    ItemShipmentInstance:LoadShipments()

    ISMailboxes:RefillMailboxes()
end)

--- SE console command for updating tutorial chests in mailboxes.
Ext.RegisterConsoleCommand('isf_tut_update', function(cmd)
    ISFPrint(0, "Updating tutorial chests in mailboxes.")
    ISMailboxes:UpdateTutorialChests()
end)

Ext.RegisterConsoleCommand('isf_uninstall_mod', function(cmd, modUUID)
    ISCommands:UninstallMod(modUUID)
end)

function ISCommands:UninstallMod(modUUID)
    local modName = Ext.Mod.GetMod(modUUID).Info.Name
    _D(ItemShipmentInstance.mods)
    ISFWarn(0, "Checking if " .. modName .. " uses A&V Item Shipment Framework.")
    if not ItemShipmentInstance.mods[modUUID] then
        ISFWarn(0, modName .. " is not using ISF. Please check the UUID.")
    end

    local modData = ItemShipmentInstance.mods[modUUID]
    local templateUUIDs = self:GetTemplateUUIDsFromModData(modData)
    local vanillaTemplateUUIDs = self:FilterOutVanillaTemplates(templateUUIDs)
    self:DeleteEntitiesWithTemplateUUIDs(vanillaTemplateUUIDs)
end

--- TODO: Move this to a separate helper
function ISCommands:GetTemplateUUIDsFromModData(modData)
    local templateUUIDs = {}
    for _, item in pairs(modData.Items) do
        local templateUUID = item.TemplateUUID
        if templateUUID then
            ISFWarn(0, "Marking template for deletion: " .. templateUUID)
            table.insert(templateUUIDs, templateUUID)
        end
    end
    return templateUUIDs
end

function ISCommands:FilterOutVanillaTemplates(templateUUIDs)
    local vanillaRootTemplates = VCHelpers.Template:GetAllVanillaTemplates()
    for i, templateUUID in pairs(templateUUIDs) do
        for _, vanillaTemplate in pairs(vanillaRootTemplates) do
            if vanillaTemplate == templateUUID then
                ISFWarn(0, "Removing vanilla template from deletion attempt: " .. templateUUID)
                table.remove(templateUUIDs, i)
                break
            end
        end
    end
    return templateUUIDs
end

function ISCommands:DeleteEntitiesWithTemplateUUIDs(templateUUIDs)
    local entities = Ext.Entity.GetAllEntitiesWithComponent("ServerItem")
    for _, entity in pairs(entities) do
        for _, templateUUID in pairs(templateUUIDs) do
            if entity and entity.ServerItem and entity.ServerItem.Template and entity.ServerItem.Template.Id == templateUUID then
                _D("Deleting entity: " .. entity.ServerItem.Template.Name)
                Osi.RequestDelete(entity.Uuid.EntityUuid)
            end
        end
    end
end

Ext.RegisterConsoleCommand('isf_refill_tut', function(cmd)
    ISFDebug(0, "Refilling tutorial chests.")
    ISMailboxes:RefillTutorialChestsInMailboxes()
end)

Ext.RegisterConsoleCommand('isf_tt', function(cmd)
    ISFWarn(0, "[DEV COMMAND] Testing treasure table retrieval.")
    -- I don't know what I'm doing B-)
    -- local template = Ext.Template.GetLocalTemplate("3761acb2-5274-e2aa-bcd3-49b5d785f70b")
    -- _D(Ext.Template.GetCacheTemplate("4708b966-e0a5-4551-9871-43cf42302419"))
    -- _D(Ext.Template.GetLocalCacheTemplate("4708b966-e0a5-4551-9871-43cf42302419"))
    -- _D(Ext.Template.GetLocalTemplate("4708b966-e0a5-4551-9871-43cf42302419"))

    -- _D(Ext.Template.GetTemplate("4708b966-e0a5-4551-9871-43cf42302419"))
    -- _D("== ROOT ==")
    -- _D(Ext.Template.GetRootTemplate("4708b966-e0a5-4551-9871-43cf42302419"))

    -- _D("TT")
    -- local treasureTableName = "MEQ_Item_Container_Underwear_TT"
    -- _D(Ext.Stats.TreasureTable.GetLegacy(treasureTableName))
    -- _D(Ext.Stats.TreasureCategory.GetLegacy(treasureTableName))
    -- local treasureTable = VCHelpers.TreasureTable:ProcessSingleTreasureTable(treasureTableName)
    -- if not treasureTable then
    --     ISFWarn(0, "Treasure table not found.")
    --     return
    -- end

    -- local treasureCategories = VCHelpers.TreasureTable:ExtractTreasureCategories(treasureTable)
    -- if not treasureCategories then
    --     ISFWarn(0, "Treasure categories not found.")
    --     return
    -- end

    -- _D(treasureCategories)
    -- for _, category in pairs(treasureCategories) do
    --     local categoryItems = category.Items
    --     for _, item in pairs(categoryItems) do
    --         _D(item.Name)
    --         _D(Ext.Template.GetRootTemplate(item.Name))
    --     end
    -- end

    -- _D(treasureTable[1])
    -- _D(Ext.Stats.TreasureCategory.GetLegacy(treasureTable[1]))
end)
