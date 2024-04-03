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
---@param mailboxIndex integer|string
---@return string|nil
function ISMailboxes:GetPlayerMailbox(mailboxIndex)
    local ISFModVars = Ext.Vars.GetModVariables(ModuleUUID)
    -- -- FIXME: fix this mess (it was supposed to work with both as strings, but it doesn't fml)
    return ISFModVars.Mailboxes[tostring(mailboxIndex)] or ISFModVars.Mailboxes[tonumber(mailboxIndex)]
end

--- Initialize mailboxes for each player in the campaign
---@return nil
function ISMailboxes:InitializeMailboxes()
    local ISFModVars = Ext.Vars.GetModVariables(ModuleUUID)

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
