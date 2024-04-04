---@class HelperISChecks: Helper
ISChecks = _Class:Create("HelperISChecks", Helper)

ISChecks.HasVisitedAct1Flag = "925c721d-686b-4fbe-8c3c-d1233bf863b7" -- "VISITEDREGION_WLD_Main_A"
-- TODO: look for flags for act 2 and 3
-- TODO: understand how to fetch player level

-- Check if the character has finished the tutorial or if spawning during tutorial is allowed
function ISChecks:PassesMandatoryShipmentChecks()
    local allowDuringTutorial = Config:getCfg().FEATURES.spawning.allow_during_tutorial
    local hasVisitedAct1 = Osi.GetFlag(self.HasVisitedAct1Flag, Osi.GetHostCharacter()) == 1

    if not allowDuringTutorial and not hasVisitedAct1 then
        ISFDebug(1,
            "Character has not visited Act 1 and spawning during tutorial is not allowed, shipments will not be processed.")
        return false
    end

    ISFDebug(2, "Character has visited Act 1 or spawning during tutorial is allowed, shipments can be processed.")
    return true
end

--- Check if the item already exists in the target inventories, based on the item's configuration for CheckExistence
---@param modGUID string The UUID of the mod being processed
---@param item table The item being processed
---@return boolean True if the item already exists in the target inventories to be checked, false otherwise
function ISChecks:CheckExistence(modGUID, item)
    if self:CheckFrameworkExistence(item, modGUID) then
        return true
    end

    if self:CheckCampChests(item, modGUID) then
        return true
    end

    if self:CheckPartyMembers(item, modGUID) then
        return true
    end

    return false
end

--- Check if the item has alreaby been shipped by ISF using ModVars
---@param item table The item being processed
---@param modGUID string The UUID of the mod being processed
---@return boolean True if the item has already been shipped, false otherwise
function ISChecks:CheckFrameworkExistence(item, modGUID)
    local ISFModVars = Ext.Vars.GetModVariables(ModuleUUID)
    ISFDebug(2, "=== Checking ModVars ===")
    if not item.Send.Check.ItemExistence.FrameworkCheck then
        ISFDebug(2, "FrameworkCheck is disabled. Skipping ModVars check for item " .. item.TemplateUUID .. ".")
        return false
    end

    if ISFModVars.Shipments[modGUID][item.TemplateUUID] == true then
        ISFDebug(1, "Item " .. item.TemplateUUID .. " has already been shipped and will not be shipped again.")
        return true
    else
        ISFDebug(2, "ModVars check passed. Item " .. item.TemplateUUID .. " has not been shipped by ISF yet.")
        return false
    end
end

-- TODO: extract main logic to VC
--- Check if the item already exists in the camp chest
---@param item table The item being processed
---@param chestIndex integer The index of the camp chest
---@return boolean True if the item already exists in a camp chest, false otherwise
function ISChecks:CheckCampChestForItem(item, chestIndex)
    local ISFModVars = Ext.Vars.GetModVariables(ModuleUUID)

    local shouldCheckChest = item.Send.Check.ItemExistence.CampChest["Player" .. chestIndex .. "Chest"]
    if not shouldCheckChest then
        return false
    end

    -- FIXME: this is checking the mailbox, not the chest
    local chestUUID = VCHelpers.Camp:GetAllCampChestUUIDs()[chestIndex]
    if VCHelpers.Inventory:GetItemTemplateInInventory(item.TemplateUUID, chestUUID) ~= nil then
        ISFDebug(1,
            "Item already exists in the inventory of camp chest " ..
            chestIndex .. " and will not be shipped.")
        return true
    end

    return false
end

--- Check if the item already exists in any existing camp chests
---@param item table The item being processed
---@param modGUID string The UUID of the mod being processed
---@return boolean True if the item already exists in any camp chest available, false otherwise
function ISChecks:CheckCampChests(item, modGUID)
    -- local ISFModVars = Ext.Vars.GetModVariables(ModuleUUID)
    local shouldCheckCampChests = item.Send.Check.ItemExistence.CampChest

    ISFDebug(2, "=== Checking camp chests ===")
    if not shouldCheckCampChests then
        ISFDebug(2, "Camp chests check passed. Camp chests checks are not enabled for item " .. item.TemplateUUID .. ".")
        return false
    end

    for chestIndex = 1, 4 do
        if self:CheckCampChestForItem(item, chestIndex) then
            return true
        end
    end

    ISFDebug(2,
        "Camp chests check passed. Item " ..
        item.TemplateUUID .. " does not exist in any camp chest that must be checked.")
    return false
end

--- Check if the item already exists in the party members' inventories
---@param item table The item being processed
---@param modGUID string The UUID of the mod being processed
---@return boolean True if the item already exists in any party member's inventory, false otherwise
function ISChecks:CheckPartyMembers(item, modGUID)
    ISFDebug(2, "=== Checking party members ===")
    if not item.Send.Check.ItemExistence.PartyMembers then
        ISFPrint(1, "Party members check skipped for item " .. item.TemplateUUID)
        return false
    end

    -- Get party members table based on the configuration
    local partyMembers = {}
    if item.Send.Check.ItemExistence.PartyMembers.AtCamp == true then
        ISFPrint(2, "Checking party members at camp for item " .. item.TemplateUUID)
        partyMembers = VCHelpers.Party:GetAllPartyMembers()
    elseif item.Send.Check.ItemExistence.PartyMembers.ActiveParty == true then
        ISFPrint(2, "Checking active party members for item " .. item.TemplateUUID)
        partyMembers = VCHelpers.Party:GetPartyMembers()
    end

    for _, partyMember in ipairs(partyMembers) do
        if VCHelpers.Inventory:GetItemTemplateInInventory(item.TemplateUUID, partyMember) ~= nil then
            ISFDebug(1,
                "Item " ..
                item.TemplateUUID ..
                " already exists in the inventory of " ..
                VCHelpers.Loca:GetDisplayName(partyMember) ..
                " for mod " .. Ext.Mod.GetMod(modGUID).Info.Name .. " and will not be shipped.")
            return true
        end
    end

    ISFDebug(1,
        "Item " ..
        item.TemplateUUID .. " does not exist in any party member's inventory to be checked and may be shipped.")
    return false
end
