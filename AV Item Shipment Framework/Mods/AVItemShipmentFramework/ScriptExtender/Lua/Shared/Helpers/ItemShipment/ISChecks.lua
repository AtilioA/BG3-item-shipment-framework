---@class HelperISChecks: Helper
ISChecks = _Class:Create("HelperISChecks", Helper)

ISChecks.HasVisitedAct1Flag = "925c721d-686b-4fbe-8c3c-d1233bf863b7" -- "VISITEDREGION_WLD_Main_A"

-- Check if the character has finished the tutorial or if spawning during tutorial is allowed
function ISChecks:MandatoryShipmentsChecks()
  local allowDuringTutorial = Config:getCfg().FEATURES.spawning.allow_during_tutorial
  if allowDuringTutorial or Osi.GetFlag(self.HasVisitedAct1Flag, Osi.GetHostCharacter()) == 1 then
    ISFDebug(2, "Character has visited Act 1 or spawning during tutorial is allowed, shipments can be processed.")
    return true
  end

  return false
end

--- Check if the item already exists in the target inventories, based on the item's configuration for CheckExistence
---@param modGUID string The UUID of the mod being processed
---@param item table The item being processed
---@return boolean
function ISChecks:CheckExistence(modGUID, item)
  local ISFModVars = Ext.Vars.GetModVariables(ModuleUUID)

  -- Check if the item has already been added
  ISFDebug(2, "CHECKING MODVARS")
  if item.Send.CheckExistence.FrameworkCheck then
    if ISFModVars.Shipments[modGUID][item.TemplateUUID] == true then
      ISFDebug(1, "Item " .. item.TemplateUUID .. " has already been shipped and will not be shipped again.")
      return true
    end
  end

  -- Check if the item exists in the camp chests
  ISFDebug(2, "CHECKING CAMP CHESTS")
  if item.Send.CheckExistence.CampChest then
    if item.Send.CheckExistence.CampChest.Player1Chest then
      if VCHelpers.Inventory:GetItemTemplateInInventory(item.TemplateUUID, ISFModVars.Mailboxes["65537"]) ~= nil then
        ISFDebug(1, "Item already exists in the inventory of a camp chest and will not be shipped.")
        return true
      end
    end

    if item.Send.CheckExistence.CampChest.Player2Chest then
      if VCHelpers.Inventory:GetItemTemplateInInventory(item.TemplateUUID, ISFModVars.Mailboxes["65538"]) ~= nil then
        ISFDebug(1, "Item already exists in the inventory of a camp chest and will not be shipped.")
        return true
      end
    end

    if item.Send.CheckExistence.CampChest.Player3Chest then
      if VCHelpers.Inventory:GetItemTemplateInInventory(item.TemplateUUID, ISFModVars.Mailboxes["65539"]) ~= nil then
        ISFDebug(1, "Item already exists in the inventory of a camp chest and will not be shipped.")
        return true
      end
    end

    if item.Send.CheckExistence.CampChest.Player4Chest then
      if VCHelpers.Inventory:GetItemTemplateInInventory(item.TemplateUUID, ISFModVars.Mailboxes["65540"]) ~= nil then
        ISFDebug(1, "Item already exists in the inventory of a camp chest and will not be shipped.")
        return true
      end
    end
  end

  ISFDebug(2, "CHECKING PARTY MEMBERS")
  if item.Send.CheckExistence.PartyMembers ~= nil then
    local partyMembers = {}
    if item.Send.CheckExistence.PartyMembers.AtCamp == true then
      partyMembers = VCHelpers.Party:GetAllPartyMembers()
    elseif item.Send.CheckExistence.PartyMembers.ActiveParty == true then
      partyMembers = VCHelpers.Party:GetPartyMembers()
    end
    for _, partyMember in ipairs(partyMembers) do
      if VCHelpers.Inventory:GetItemTemplateInInventory(item.TemplateUUID, partyMember) ~= nil then
        ISFDebug(1,
          "Item " ..
          item.TemplateUUID ..
          " already exists in inventory " ..
          VCHelpers.Loca:GetDisplayName(partyMember) .. " for mod " .. modGUID .. " and will not be shipped.")
        return true
      end
    end
    ISFDebug(1, "Item " .. item.TemplateUUID .. " does not exist in any party member's inventory and may be shipped.")
  end

  return false
end
