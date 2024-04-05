---@class HelperISMailboxes: Helper
ISMailboxes = _Class:Create("HelperISMailboxes", Helper)

ISMailboxes.MailboxTemplateUUID = "b99474ea-43f9-4dbb-9917-e0a6daa3b9e3"
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
        if not string.match(item.TemplateName, "^ISF_") then
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
