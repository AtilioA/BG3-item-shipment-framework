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
  ISFDebug(2, "== Checking ModVars ==")
  if item.Send.Check.ItemExistence.FrameworkCheck then
    if ISFModVars.Shipments[modGUID][item.TemplateUUID] == true then
      ISFDebug(1, "Item " .. item.TemplateUUID .. " has already been shipped and will not be shipped again.")
      return true
    end
  end
  ISFDebug(2, "ModVars check passed. Item " .. item.TemplateUUID .. " has not been shipped by ISF yet.")

  -- Check if the item exists in the camp chests
  ISFDebug(2, "== Checking camp chests ==")
  if item.Send.Check.ItemExistence.CampChest then
    for chestIndex = 1, 4 do
      if item.Send.Check.ItemExistence.CampChest["Player" .. chestIndex .. "Chest"] then
        if VCHelpers.Inventory:GetItemTemplateInInventory(item.TemplateUUID, ISFModVars.Mailboxes[tostring(chestIndex)]) ~= nil then
          ISFDebug(1,
            "Item already exists in the inventory of camp chest .. " .. chestIndex .. " and will not be shipped.")
          return true
        end
      end
    end
  end
  ISFDebug(2, "Camp chests check passed. Item " .. item.TemplateUUID .. " does not exist in any camp chest that must be checked.")

  ISFDebug(2, "== Checking party members ==")
  if item.Send.Check.ItemExistence.PartyMembers ~= nil then
    local partyMembers = {}
    if item.Send.Check.ItemExistence.PartyMembers.AtCamp == true then
      partyMembers = VCHelpers.Party:GetAllPartyMembers()
    elseif item.Send.Check.ItemExistence.PartyMembers.ActiveParty == true then
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
    ISFDebug(1, "Item " .. item.TemplateUUID .. " does not exist in any party member's inventory to be checked and may be shipped.")
  end

  return false
end
