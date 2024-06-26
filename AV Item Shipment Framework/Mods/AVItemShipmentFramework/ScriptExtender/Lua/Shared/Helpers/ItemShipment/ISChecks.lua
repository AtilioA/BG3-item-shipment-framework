---@class HelperISChecks: Helper
ISChecks = _Class:Create("HelperISChecks", Helper)

ISChecks.HasVisitedAct1Flag = "925c721d-686b-4fbe-8c3c-d1233bf863b7" -- "VISITEDREGION_WLD_Main_A"
ISChecks.HasVisitedAct2Flag = "f6e72539-9bc6-42e1-a20f-390f3a17ad8d" -- "VISITEDREGION_SCL_Main_A"
ISChecks.HasVisitedAct3Flag = "11239767-48ad-4879-8312-b9164b6e4978" -- "VISITEDREGION_BGO_Main_A"
-- TODO: understand how to properly fetch player level

-- Check if the character has finished the tutorial or if spawning during tutorial is allowed
function ISChecks:ProgressionShipmentChecks(item)
    -- TODO: add level check
    local allowDuringTutorial = Config:getCfg().FEATURES.spawning.allow_during_tutorial
    local shouldShipDuringTutorial = item.Send.Check.PlayerProgression.Act == 0
    local shouldShipFromAct1 = item.Send.Check.PlayerProgression.Act == 1
    local shouldShipFromAct2 = item.Send.Check.PlayerProgression.Act == 2
    local shouldShipFromAct3 = item.Send.Check.PlayerProgression.Act == 3
    local hasVisitedAct1 = Osi.GetFlag(self.HasVisitedAct1Flag, Osi.GetHostCharacter()) == 1
    local hasVisitedAct2 = Osi.GetFlag(self.HasVisitedAct2Flag, Osi.GetHostCharacter()) == 1
    local hasVisitedAct3 = Osi.GetFlag(self.HasVisitedAct3Flag, Osi.GetHostCharacter()) == 1
    local isPlayerLevelHighEnough = Osi.GetLevel(Osi.GetHostCharacter()) >= item.Send.Check.PlayerProgression.Level

    if not isPlayerLevelHighEnough then
        ISFPrint(1,
            "Character level is not high enough to receive the item, shipment will not be processed.")
        return false
    end

    -- If spawning during tutorial is not allowed, and the item is not set for 'Act 0', and the character has not visited Act 1, shipments cannot be processed.
    -- User config takes precedence over item config
    if shouldShipDuringTutorial and (not allowDuringTutorial and not hasVisitedAct1) then
        ISFPrint(1,
            "Item is set to spawn during tutorial but user config does not allow it, shipment will not be processed.")
        return false
    elseif shouldShipFromAct1 and not hasVisitedAct1 then
        ISFPrint(1,
            "Character has not visited Act 1 yet, shipment will not be processed.")
        return false
    elseif shouldShipFromAct2 and not hasVisitedAct2 then
        ISFPrint(1,
            "Character has not visited Act 2 yet, shipment will not be processed.")
        return false
    elseif shouldShipFromAct3 and not hasVisitedAct3 then
        ISFPrint(1,
            "Character has not visited Act 3 yet, shipment will not be processed.")
        return false
    end

    -- In all other cases, shipments can be processed.
    ISFPrint(2, "Shipments can be processed.")
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
        ISFPrint(2, "FrameworkCheck is disabled. Skipping ModVars check for item " .. item.TemplateUUID .. ".")
        return false
    end

    if ISFModVars.Shipments[modGUID][item.TemplateUUID] == true then
        ISFPrint(1, "Item " .. item.TemplateUUID .. " has already been shipped and will not be shipped again.")
        return true
    else
        ISFPrint(2, "ModVars check passed. Item " .. item.TemplateUUID .. " has not been shipped by ISF yet.")
        return false
    end
end

--- Check if the item already exists in the camp chest, excluding the ISF tutorial chest
---@param item table The item being processed
---@param chestIndex integer The index of the camp chest
---@return boolean True if the item already exists in a camp chest, false otherwise
function ISChecks:CheckCampChestForItem(item, chestIndex)
    local shouldCheckChest = item.Send.Check.ItemExistence.CampChest["Player" .. chestIndex .. "Chest"]
    if not shouldCheckChest then
        return false
    end

    local chestUUID = VCHelpers.Camp:GetAllCampChestUUIDs()[chestIndex]
    local itemsWithTemplate = VCHelpers.Inventory:GetAllItemsWithTemplateInInventory(item.TemplateUUID, chestUUID)
    for _, itemData in ipairs(itemsWithTemplate) do
        local holder = VCHelpers.Inventory:GetHolder(itemData.Entity)
        if holder and holder.ServerItem and holder.ServerItem.Template and holder.ServerItem.Template.Name ~= ISMailboxes.TutChestTemplateName then
            ISFPrint(1,
                "Item already exists in the inventory of camp chest " ..
                chestIndex ..
                " (inside " .. VCHelpers.Loca:GetDisplayName(holder.Uuid.EntityUuid) .. ") and will not be shipped.")
            return true
        end
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
        ISFPrint(2, "Camp chests check passed. Camp chests checks are not enabled for item " .. item.TemplateUUID .. ".")
        return false
    end

    for chestIndex = 1, 4 do
        if self:CheckCampChestForItem(item, chestIndex) then
            return true
        end
    end

    ISFPrint(2,
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
        ISFDebug(2, "Checking party members at camp for item " .. item.TemplateUUID)
        partyMembers = VCHelpers.Party:GetAllPartyMembers()
    elseif item.Send.Check.ItemExistence.PartyMembers.ActiveParty == true then
        ISFDebug(2, "Checking active party members for item " .. item.TemplateUUID)
        partyMembers = VCHelpers.Party:GetPartyMembers()
    end

    for _, partyMember in ipairs(partyMembers) do
        if VCHelpers.Inventory:GetItemTemplateInInventory(item.TemplateUUID, partyMember) ~= nil then
            ISFPrint(1,
                "Item " ..
                item.TemplateUUID ..
                " already exists in the inventory of " ..
                VCHelpers.Loca:GetDisplayName(partyMember) ..
                " for mod " .. Ext.Mod.GetMod(modGUID).Info.Name .. " and will not be shipped.")
            return true
        end
    end

    ISFPrint(1,
        "Item " ..
        item.TemplateUUID .. " does not exist in any party member's inventory to be checked and may be shipped.")
    return false
end
