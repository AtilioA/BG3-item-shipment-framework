---@class HelperISMailboxes: Helper
ISMailboxes = _Class:Create("HelperISMailboxes", Helper)

ISMailboxes.MailboxTemplateUUID = "b99474ea-43f9-4dbb-9917-e0a6daa3b9e3"
ISMailboxes.PlayerIDMapping = {
  ["65537"] = "Player1Chest",
  ["65538"] = "Player2Chest",
  ["65539"] = "Player3Chest",
  ["65540"] = "Player4Chest"
}

--- Initialize mailboxes for each player in the campaign
function ISMailboxes:InitializeMailboxes()
  local ISFModVars = Ext.Vars.GetModVariables(ModuleUUID)

  local campChestUUIDs = VCHelpers.Camp:GetAllCampChestsUUIDs()

  for playerID, chestUUID in pairs(campChestUUIDs) do
    ISFDebug(2, "Initializing mailbox for playerID: " .. playerID .. ", chestUUID: " .. chestUUID)
    ISFDebug(2, "Mailboxes: " .. Ext.Json.Stringify(ISFModVars.Mailboxes), { Beautify = true })
    if chestUUID and ISFModVars.Mailboxes[tostring(playerID)] == nil then
      ISFDebug(2, "Adding mailbox .. " .. self.MailboxTemplateUUID .. " .. to chest .. " .. chestUUID .. ".")
      Osi.TemplateAddTo(self.MailboxTemplateUUID, chestUUID, 1)
      -- TODO: use string handles
      Osi.ShowNotification(Osi.GetHostCharacter(), Messages.ResolvedMessages.mailbox_added_to_camp_chest)
      -- NOTE: Assignment to Mailboxes table is done in the OnTemplateAddedTo event handler
    end
  end
end

--- Move mailboxes inside camp chests if they exist and are not already inside.
function ISMailboxes:MakeSureMailboxesAreInsideChests()
  local ISFModVars = Ext.Vars.GetModVariables(ModuleUUID)
  if ISFModVars.Mailboxes then
    local campChestUUIDs = VCHelpers.Camp:GetAllCampChestsUUIDs()
    for playerID, mailboxUUID in pairs(ISFModVars.Mailboxes) do
      local campChestUUID = campChestUUIDs[tostring(playerID)]
      if campChestUUID then
        local campChestInventory = VCHelpers.Inventory:GetInventory(campChestUUID, false, false)
        if Osi.IsInInventoryOf(mailboxUUID, campChestUUID) == 0 then
          Osi.ToInventory(mailboxUUID, campChestUUID, 1, 1, 1)
          -- TODO: use string handles
          Osi.ShowNotification(Osi.GetHostCharacter(), Messages.ResolvedMessages.mailbox_moved_to_camp_chest)
        end
      end
    end
  end
end
