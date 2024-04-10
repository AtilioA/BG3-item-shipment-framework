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
            ISFDebug(2, "Adding mailbox " .. self.MailboxTemplateUUID .. " to chest " .. chestUUID .. ".")
            Osi.TemplateAddTo(self.MailboxTemplateUUID, chestUUID, 1)
            Osi.ShowNotification(Osi.GetHostCharacter(), Messages.ResolvedMessages.mailbox_added_to_camp_chest)
            -- NOTE: Assignment to Mailboxes table is done in the OnTemplateAddedTo event handler
        end
    end

    -- Check if the utilities case exists, and add it if it doesn't
    self:InitializeUtilitiesCase()
end

--- Initialize the utilities case if it doesn't exist
function ISMailboxes:InitializeUtilitiesCase()
    local ISFModVars = Ext.Vars.GetModVariables(ModuleUUID)
    local utilitiesCaseUUID = self.UtilitiesCaseUUID

    -- Check if the utilities case exists in any of the mailboxes
    for _, mailboxUUID in pairs(ISFModVars.Mailboxes) do
        ISFWarn(0, "Checking if mailbox " .. mailboxUUID .. " has the utilities case.")
        local utilityCaseInsideMailbox = VCHelpers.Inventory:GetItemTemplateInInventory(utilitiesCaseUUID, mailboxUUID)
        if utilityCaseInsideMailbox == nil then
            ISFDebug(2, "Utilities case " .. utilitiesCaseUUID .. " not found in mailbox " .. mailboxUUID)
            ISFDebug(2, "Adding utilities case " .. utilitiesCaseUUID .. " to mailbox " .. mailboxUUID)
            Osi.TemplateAddTo(utilitiesCaseUUID, mailboxUUID, 1, 0)
        end
    end

    -- Add items to the utilities case
    self:RefillUtilitiesCase()
end

--- Refill the utilities case with the scrolls, if missing
function ISMailboxes:RefillUtilitiesCase()
    local ISFModVars = Ext.Vars.GetModVariables(ModuleUUID)
    local utilitiesCaseUUID = self.UtilitiesCaseUUID

    ISFDebug(1, "Refilling utilities case with items.")

--- Refill the utilities case for a specific mailbox
---@param mailboxUUID string The UUID of the mailbox
---@return nil
function ISMailboxes:RefillUtilitiesCaseForMailbox(mailboxUUID)
    -- Items that the utilities case is supposed to have
    local refillMailbox1 = "fa088082-2fc1-4710-8ba3-ff497f5229c3"
    local refillMailbox2 = "7bf93529-26dc-4c38-9341-97147926147b"
    local refillMailbox3 = "42b7bffb-0d8d-4a54-9261-6aa130eb5493"
    local refillMailbox4 = "48608d58-00e0-405c-af2a-cc520519b194"
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
    for modGUID, modData in pairs(ItemShipmentInstance.mods) do
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

--- Update the host's mailbox with a new Tutorial Chest instance
function ISMailboxes:UpdateHostMailboxTutorialChest()
    local ISFModVars = Ext.Vars.GetModVariables(ModuleUUID)
    local hostMailboxUUID = ISFModVars.Mailboxes[1]
    if hostMailboxUUID then
        self:IntegrateTutorialChest(hostMailboxUUID)
    end
end

--- Update the remaining mailboxes with a new Tutorial Chest instance
function ISMailboxes:UpdateRemainingMailboxesTutorialChests()
    local ISFModVars = Ext.Vars.GetModVariables(ModuleUUID)
    for i = 2, #ISFModVars.Mailboxes do
        local mailboxUUID = ISFModVars.Mailboxes[i]
        self:IntegrateTutorialChest(mailboxUUID)
    end
end

--- Update all mailboxes with a new Tutorial Chest instance
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
        ISFDebug(3, "Removing Tutorial Chest from mailbox: " .. mailboxUUID)
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
    ISFDebug(3, "Adding Tutorial Chest to mailbox: " .. mailboxUUID)
    Osi.TemplateAddTo(self.TutChestTemplateUUID, mailboxUUID, 1, 0)
end
