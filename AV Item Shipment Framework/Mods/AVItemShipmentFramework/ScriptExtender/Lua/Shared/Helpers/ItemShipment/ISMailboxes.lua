---@class HelperISMailboxes: Helper
ISMailboxes = _Class:Create("HelperISMailboxes", Helper)

ISMailboxes.MailboxTemplateUUID = "b99474ea-43f9-4dbb-9917-e0a6daa3b9e3"
ISMailboxes.UtilitiesCaseUUID = "f6164829-6513-462e-85fd-8b290cc38170"
ISMailboxes.TutChestTemplateName = "CONT_ISF_TutorialChest_Container"
ISMailboxes.TutChestTemplateUUID = "38b65f43-6681-4e78-961b-e6797c7d52bb"
ISMailboxes.PlayerChestIndexMapping = {
    ["1"] = "Player1Chest",
    ["2"] = "Player2Chest",
    ["3"] = "Player3Chest",
    ["4"] = "Player4Chest"
}

--- Get the mailbox inside the camp chest given an index
---@param mailboxIndex integer
---@return string|nil
function ISMailboxes:GetPlayerMailbox(mailboxIndex)
    local ISFModVars = Ext.Vars.GetModVariables(ModuleUUID)

    if not ISFModVars.Mailboxes then
        ISFDebug(1, "Mailboxes table is nil. Returning.")
        return nil
    end

    return ISFModVars.Mailboxes[mailboxIndex]
end

--- Initialize mailboxes for each player chest
---@return nil
function ISMailboxes:InitializeMailboxes()
    local ISFModVars = Ext.Vars.GetModVariables(ModuleUUID)
    -- Initialize the mailboxes table ModVars if needed
    ISUtils:InitializeMailboxesTable()

    local campChestUUIDs = VCHelpers.Camp:GetAllCampChestUUIDs()

    for index, chestUUID in pairs(campChestUUIDs) do
        ISFDebug(2, "Initializing mailbox for index: " .. index .. ", chestUUID: " .. chestUUID)
        ISFDebug(2, "Mailboxes: " .. Ext.Json.Stringify(ISFModVars.Mailboxes), { Beautify = true })
        local mailboxUUID = self:GetPlayerMailbox(index)
        if chestUUID and mailboxUUID == nil then
            ISFDebug(2, "Adding mailbox (" .. self.MailboxTemplateUUID .. ") to chest " .. chestUUID .. ".")
            Osi.TemplateAddTo(self.MailboxTemplateUUID, chestUUID, 1)
            Osi.ShowNotification(Osi.GetHostCharacter(), Messages.ResolvedMessages.mailbox_added_to_camp_chest)
            -- NOTE: Assignment to Mailboxes table is done in the OnTemplateAddedTo event handler
        end
    end

    -- Check if the utilities case exists, and add it if it doesn't
    self:InitializeUtilitiesCaseForAllMailboxes()
end

--- Initialize the utilities case for a specific mailbox
---@return nil
function ISMailboxes:InitializeUtilitiesCaseForMailbox(mailboxUUID)
    local utilitiesCaseUUID = self.UtilitiesCaseUUID

    ISFDebug(1, "Checking if mailbox " .. mailboxUUID .. " has the utilities case.")
    local utilityCaseInsideMailbox = VCHelpers.Inventory:GetItemTemplateInInventory(utilitiesCaseUUID, mailboxUUID)
    if utilityCaseInsideMailbox == nil then
        ISFPrint(2, "Utilities case " .. utilitiesCaseUUID .. " not found in mailbox " .. mailboxUUID)
        ISFPrint(1, "Adding utilities case " .. utilitiesCaseUUID .. " to mailbox " .. mailboxUUID)
        Osi.TemplateAddTo(utilitiesCaseUUID, mailboxUUID, 1, 0)
    end
end

--- Initialize the utilities case for mailboxes if it doesn't exist
---@return nil
function ISMailboxes:InitializeUtilitiesCaseForAllMailboxes()
    local ISFModVars = Ext.Vars.GetModVariables(ModuleUUID)

    -- Check if the utilities case exists in any of the mailboxes
    for _, mailboxUUID in pairs(ISFModVars.Mailboxes) do
        self:InitializeUtilitiesCaseForMailbox(mailboxUUID)
    end

    -- Add items to the utilities cases for all mailboxes
    self:RefillUtilitiesCaseForAllMailboxes()
end

--- Refill the utilities case with the scrolls, if missing
---@return nil
function ISMailboxes:RefillUtilitiesCaseForAllMailboxes()
    local ISFModVars = Ext.Vars.GetModVariables(ModuleUUID)
    local utilitiesCaseUUID = self.UtilitiesCaseUUID

    ISFDebug(1, "Refilling utilities case with items.")

    for _, mailboxUUID in pairs(ISFModVars.Mailboxes) do
        ISFDebug(2, "Checking mailbox " .. mailboxUUID .. " for utilities case.")
        local utilitiesCaseItem = VCHelpers.Inventory:GetItemTemplateInInventory(utilitiesCaseUUID, mailboxUUID)
        if utilitiesCaseItem then
            ISFPrint(2, "Refilling utilities case in mailbox " .. mailboxUUID)
            self:RefillUtilitiesCaseForMailbox(mailboxUUID)
        else
            ISFPrint(1, "Utilities case not found in mailbox " .. mailboxUUID .. ". Adding it.")
            self:InitializeUtilitiesCaseForMailbox(mailboxUUID)
        end
    end
end

--- Refill the utilities case for a specific mailbox
---@param mailboxUUID string The UUID of the mailbox
---@return nil
function ISMailboxes:RefillUtilitiesCaseForMailbox(mailboxUUID)
    -- Items that the utilities case is supposed to have
    local refillMailbox1 = "fa088082-2fc1-4710-8ba3-ff497f5229c3"
    local refillMailbox2 = "7bf93529-26dc-4c38-9341-97147926147b"
    local refillMailbox3 = "42b7bffb-0d8d-4a54-9261-6aa130eb5493"
    local refillMailbox4 = "48608d58-00e0-405c-af2a-cc520519b194"
    -- local updateTutChest = "d5ef2737-820c-4865-a39d-f17e7bd68970"
    local uninstallScroll = "7348db1f-991e-4347-a334-88d13db7fbbe"

    local utilitiesCaseItem = VCHelpers.Inventory:GetItemTemplateInInventory(self.UtilitiesCaseUUID, mailboxUUID)
    if utilitiesCaseItem then
        VCHelpers.Inventory:RefillInventoryWithItem(refillMailbox1, 1, utilitiesCaseItem.Uuid.EntityUuid)
        VCHelpers.Inventory:RefillInventoryWithItem(refillMailbox2, 1, utilitiesCaseItem.Uuid.EntityUuid)
        VCHelpers.Inventory:RefillInventoryWithItem(refillMailbox3, 1, utilitiesCaseItem.Uuid.EntityUuid)
        VCHelpers.Inventory:RefillInventoryWithItem(refillMailbox4, 1, utilitiesCaseItem.Uuid.EntityUuid)
        VCHelpers.Inventory:RefillInventoryWithItem(uninstallScroll, 1, utilitiesCaseItem.Uuid.EntityUuid)
    end
end

--- Move mailboxes inside camp chests if they exist and are not already inside.
---@return nil
function ISMailboxes:MakeSureMailboxesAreInsideChests()
    local ISFModVars = Ext.Vars.GetModVariables(ModuleUUID)
    if not ISFModVars.Mailboxes then
        ISFDebug(1, "Mailboxes table is nil. Returning.")
        return
    end

    local campChestUUIDs = VCHelpers.Camp:GetAllCampChestUUIDs()
    for index, mailboxUUID in pairs(ISFModVars.Mailboxes) do
        local campChestUUID = campChestUUIDs[tostring(index)]
        if campChestUUID and Osi.IsInInventoryOf(mailboxUUID, campChestUUID) == 0 then
            Osi.ToInventory(mailboxUUID, campChestUUID, 1, 1, 1)
            Osi.ShowNotification(Osi.GetHostCharacter(), Messages.ResolvedMessages.mailbox_moved_to_camp_chest)
        end
    end
end

--- Move all items from mailboxes to their respective camp chests
---@return nil
function ISMailboxes:MoveItemsFromMailboxesToCampChests()
    local ISFModVars = Ext.Vars.GetModVariables(ModuleUUID)
    local campChestUUIDs = VCHelpers.Camp:GetAllCampChestUUIDs()

    for index, mailboxUUID in pairs(ISFModVars.Mailboxes) do
        local campChestUUID = campChestUUIDs[index]
        ISFDebug(2, "Checking mailbox " .. mailboxUUID .. " in camp chest " .. campChestUUID)
        if campChestUUID then
            -- Move items from mailbox to camp chest
            if EHandlers.moveItems then
                self:MoveItemsFromMailboxToCampChest(mailboxUUID, campChestUUID)
            end
            ISFPrint(0, "Moved items from mailbox " .. mailboxUUID .. " to camp chest " .. campChestUUID)
        end
    end
end

--- Move all non-ISF items from a mailbox to a camp chest
---@param mailboxUUID string The UUID of the mailbox
---@param campChestUUID string The UUID of the camp chest
---@return nil
function ISMailboxes:MoveItemsFromMailboxToCampChest(mailboxUUID, campChestUUID)
    local mailboxItems = VCHelpers.Inventory:GetInventory(mailboxUUID, true, false)
    for _, item in pairs(mailboxItems) do
        -- Only move non-ISF items
        if not string.match(item.TemplateName, "_ISF_") then
            local _, total = Osi.GetStackAmount(item.Guid)
            Osi.ToInventory(item.Guid, campChestUUID, total, 0, 1)
        end
    end
end

--- Delete all mailboxes
---@return nil
function ISMailboxes:DeleteMailboxes()
    local ISFModVars = Ext.Vars.GetModVariables(ModuleUUID)
    for _, mailboxUUID in pairs(ISFModVars.Mailboxes) do
        VCHelpers.Timer:OnTime(2000, function()
            -- Delete mailbox
            Osi.RequestDelete(mailboxUUID)
            ISFPrint(0, "Deleted mailbox " .. mailboxUUID)
        end)
    end
    ISFModVars.Mailboxes = nil
    ISFModVars.Mailboxes = ISFModVars.Mailboxes
    VCHelpers.ModVars:Sync(ModuleUUID)
end

--- Refill all mailboxes with items.
---@return nil
function ISMailboxes:RefillMailboxes()
    local ISFModVars = Ext.Vars.GetModVariables(ModuleUUID)
    local campChestUUIDs = VCHelpers.Camp:GetAllCampChestUUIDs()

    for index, mailboxUUID in pairs(ISFModVars.Mailboxes) do
        local campChestUUID = campChestUUIDs[index]
        if mailboxUUID and campChestUUID then
            self:RefillMailbox(index, mailboxUUID)
        end
    end
end

--- Refill a single mailbox with items.
---@param index number The index of the mailbox
---@param mailboxUUID string The UUID of the mailbox
---@return nil
function ISMailboxes:RefillMailbox(index, mailboxUUID)
    for _modGUID, modData in pairs(ItemShipmentInstance.mods) do
        for _, item in pairs(modData.Items) do
            if item.Send.To.CampChest["Player" .. index .. "Chest"] == true then
                self:RefillMailboxWithItem(item, mailboxUUID)
            end
        end
    end
    ISMailboxes:IntegrateTutorialChest(mailboxUUID)
end

--- Refill a mailbox with a specific item.
---@param item table The item data
---@param mailboxUUID string The UUID of the mailbox
---@return nil
function ISMailboxes:RefillMailboxWithItem(item, mailboxUUID)
    return VCHelpers.Inventory:RefillInventoryWithItem(item.TemplateUUID, item.Send.Quantity, mailboxUUID)
end

--- Update all mailboxes with a new Tutorial Chest instance
---@return nil
function ISMailboxes:UpdateTutorialChests()
    local ISFModVars = Ext.Vars.GetModVariables(ModuleUUID)
    for _, mailboxUUID in pairs(ISFModVars.Mailboxes) do
        self:IntegrateTutorialChest(mailboxUUID)
    end
end

--- Integrate the Tutorial Chest with a mailbox.
---@param mailboxUUID string The UUID of the mailbox
---@return nil
function ISMailboxes:IntegrateTutorialChest(mailboxUUID)
    ISFDebug(2, "Processing mailbox: " .. mailboxUUID .. " for Tutorial Chest integration.")
    self:RemoveTutorialChestFromContainer(mailboxUUID)
    self:AddTutorialChestToContainer(mailboxUUID)
end

--- Remove any Tutorial Chest copies from a container.
---@param mailboxUUID string The UUID of the container
---@return nil
function ISMailboxes:RemoveTutorialChestFromContainer(mailboxUUID)
    local tutorialChestsInMailbox = VCHelpers.Inventory:GetAllItemsWithTemplateInInventory(self.TutChestTemplateUUID,
        mailboxUUID)
    for _, tutorialChestInMailbox in pairs(tutorialChestsInMailbox) do
        ISFDebug(2, "Removing Tutorial Chest from mailbox: " .. mailboxUUID)
        Osi.RequestDelete(tutorialChestInMailbox.Guid)
    end
end

--- Remove any Tutorial Chest copies from all mailboxes.
---@return nil
function ISMailboxes:RemoveTutorialChestsFromAllMailboxes()
    local ISFModVars = Ext.Vars.GetModVariables(ModuleUUID)
    for _, mailboxUUID in pairs(ISFModVars.Mailboxes) do
        self:RemoveTutorialChestFromContainer(mailboxUUID)
    end
end

--- Add the Tutorial Chest to a container.
---@param mailboxUUID string The UUID of the container
---@return nil
function ISMailboxes:AddTutorialChestToContainer(mailboxUUID)
    ISFDebug(2, "Adding Tutorial Chest to mailbox: " .. mailboxUUID)
    Osi.TemplateAddTo(self.TutChestTemplateUUID, mailboxUUID, 1, 0)
end

-- TODO: Do the same with any other containers managed by ISF that may need to be refilled
function ISMailboxes:RefillTutorialChests(mailboxIndexStart, mailboxIndexEnd)
    local ISFModVars = Ext.Vars.GetModVariables(ModuleUUID)

    if not mailboxIndexStart or not mailboxIndexEnd then
        mailboxIndexStart = 1
        mailboxIndexEnd = #ISFModVars.Mailboxes
    end

    local treasureTableName = "TUT_Chest_Potions"
    local treasureTableItemsTable = VCHelpers.TreasureTable:GetTableOfItemsFromTreasureTable(treasureTableName)

    if not treasureTableItemsTable then
        ISFWarn(1, "Treasure table items not found.")
        return
    end

    if not ISFModVars.Mailboxes then
        ISFWarn(1, "Mailboxes not found.")
        return
    end

    for i = mailboxIndexStart, mailboxIndexEnd do
        if not ISFModVars.Mailboxes[i] then
            ISFWarn(1, "Mailbox at index " .. i .. " not found.")
            return
        end
        self:RefillTutorialChestsInMailbox(ISFModVars.Mailboxes[i], treasureTableItemsTable)
    end
end

function ISMailboxes:RefillTutorialChestsInHostMailbox()
    self:RefillTutorialChests(1, 1)
end

function ISMailboxes:RefillTutorialChestsInRemainingMailboxes()
    local ISFModVars = Ext.Vars.GetModVariables(ModuleUUID)
    self:RefillTutorialChests(2, #ISFModVars.Mailboxes)
end

--- Refills all tutorial chests in a mailbox with items from the treasure table.
---@param mailboxUUID string The UUID of the mailbox.
---@param treasureTableItemsTable TreasureTableItem[] The items to refill the chests with.
function ISMailboxes:RefillTutorialChestsInMailbox(mailboxUUID, treasureTableItemsTable)
    local tutorialChestsInMailbox = VCHelpers.Inventory:GetAllItemsWithTemplateInInventory(self.TutChestTemplateUUID,
        mailboxUUID)

    if not tutorialChestsInMailbox then
        return
    end

    for _, tutorialChestInMailbox in pairs(tutorialChestsInMailbox) do
        VCHelpers.TreasureTable:RefillContainerWithTTItems(tutorialChestInMailbox.Guid, treasureTableItemsTable)
    end
end

--- Refills all mailboxes with items from the treasure table from shipments.
--- WIP
-- function ISMailboxes:RefillAllMailboxesWithItems()
--     local ISFModVars = Ext.Vars.GetModVariables(ModuleUUID)
--     for _, mailboxID in pairs(ISFModVars.Mailboxes) do
--         self:RefillMailboxWithItems(mailboxID)
--     end
-- end

-- function ISMailboxes:RefillMailboxWithItems(mailboxUUID)
--     local ISFModVars = Ext.Vars.GetModVariables(ModuleUUID)
--     local mailboxIndex = ISFModVars.Mailboxes[mailboxUUID]
--     ItemShipmentInstance:LoadShipments()
--     for _, mod in pairs(ItemShipmentInstance.mods) do
--         local shipmentItems = mod.Items[mailboxIndex]
--         if shipmentItems then
--             for _, item in pairs(shipmentItems) do
--                 VCHelpers.Inventory:RefillInventoryWithItem(item.TemplateUUID, item.Send.Quantity, mailboxUUID)
--             end
--         end
--     end
-- end

--- Refill containers in mailboxes with items from treasure tables if they have not been delivered yet.
---@return nil
--- Extremely WIP and broken, do not use.
-- function ISMailboxes:RefillContainersWithNewItems()
--     ISFDebug(1, "Entering RefillContainersWithNewItems")
--     local ISFModVars = Ext.Vars.GetModVariables(ModuleUUID)
--     ItemShipmentInstance:LoadShipments()

--     ISFDebug(2, "Iterating through mod data")
--     for modGUID, modData in pairs(ItemShipmentInstance.mods) do
--         for _, item in pairs(modData.Items) do
--             ISFDebug(2, "Processing item: " .. item.TemplateUUID)
--             local treasureTable = self:GetTreasureTableForItem(item.TemplateUUID)
--             if treasureTable then
--                 ISFPrint(2, "Found treasure table: " .. treasureTable)
--                 local treasureTableItems = VCHelpers.TreasureTable:GetTableOfItemsFromTreasureTable(treasureTable)
--                 if ISFModVars.Shipments[modGUID][item.TemplateUUID] then
--                     ISFPrint(2, "Item has not been delivered yet, refilling mailboxes")
--                     for _, mailboxUUID in pairs(ISFModVars.Mailboxes) do
--                         ISFDebug(2, "Refilling mailbox: " .. mailboxUUID)
--                         local itemInMailbox = VCHelpers.Inventory:GetItemTemplateInInventory(item.TemplateUUID,
--                             mailboxUUID, true)
--                             _D(VCHelpers.Loca:GetTranslatedStringFromTemplateUUID(item.TemplateUUID))
--                         if itemInMailbox then
--                             VCHelpers.TreasureTable:RefillContainerWithTTItems(itemInMailbox.Uuid.EntityUuid,
--                                 treasureTableItems)
--                         else
--                             ISFDebug(2, "No item found in mailbox: " .. mailboxUUID)
--                         end
--                     end
--                     ISFModVars.Shipments[modGUID][item.TemplateUUID] = true
--                 else
--                     ISFDebug(2, "Item has already been delivered, skipping")
--                 end
--             else
--                 ISFDebug(3, "No treasure table found for item: " .. item.TemplateUUID)
--             end
--         end
--     end

--     -- ISFDebug(1, "Syncing mod variables")
--     -- VCHelpers.ModVars:Sync(ModuleUUID)
-- end

-- --- Get the treasure table for a specific item UUID (stub, to be implemented).
-- ---@param itemUUID string The UUID of the item.
-- ---@return string|nil The treasure table name or nil if not found.
-- function ISMailboxes:GetTreasureTableForItem(itemUUID)
--     -- Placeholder for the actual implementation to get the treasure table for an item.
--     return "TUT_Chest_Potions" -- Example treasure table name.
-- end
