-- TODO: modularize and add more comments

--[[
    This file has code adapted from sources originally licensed under the MIT License. The terms of the MIT License are as follows:

    MIT License

    Copyright (c) 2023 BG3-Community-Library-Team

    Permission is hereby granted, free of charge, to any person obtaining a copy
    of this software and associated documentation files (the "Software"), to deal
    in the Software without restriction, including without limitation the rights
    to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
    copies of the Software, and to permit persons to whom the Software is
    furnished to do so, subject to the following conditions:

    The above copyright notice and this permission notice shall be included in all
    copies or substantial portions of the Software.

    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
    IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
    FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
    AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
    LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
    OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
    SOFTWARE.
--]]

--- TODO: review this class to be less encompassing?
---@class ItemShipment: MetaClass
ItemShipment = _Class:Create("ItemShipment", nil, {
  mods = {},
  mailboxTemplateUUID = "b99474ea-43f9-4dbb-9917-e0a6daa3b9e3",
  playerIDMapping = {
    ["65537"] = "Player1Chest",
    ["65538"] = "Player2Chest",
    ["65539"] = "Player3Chest",
    ["65540"] = "Player4Chest"
  },
  shipmentTrigger = nil,
})

-- TODO: move these to somewhere else
local configFilePathPatternJSON = string.gsub("Mods/%s/ItemShipmentFrameworkConfig.json", "'", "\'")
-- Lua can't handle optional characters smh
local configFilePathPatternJSONC = string.gsub("Mods/%s/ItemShipmentFrameworkConfig.jsonc", "'", "\'")
hasVisitedAct1Flag = "925c721d-686b-4fbe-8c3c-d1233bf863b7" -- "VISITEDREGION_WLD_Main_A"

-- NOTE: When introducing new (breaking) versions of the config file, add a new function to parse the new version and update the version number in the config file
-- local versionHandlers = {
--   [1] = parseVersion1Config,
--   [2] = parseVersion2Config,
-- }

-- TODO: manage per-campaign; currently shares data across campaigns/save files I think
--- Initialize the mod vars for the mod, if they don't already exist. Might be redundant, but it's here for now.
---@param data table The item data to submit
---@param modGUID string The UUID of the mod that the item data belongs to
function ItemShipment:InitializeModVarsForMod(data, modGUID)
  local ISFModVars = VCHelpers.ModVars:Get(ModuleUUID)
  if not ISFModVars.Shipments[modGUID] then
    ISFModVars.Shipments[modGUID] = {}
  end

  -- For each templateUUID in the data, create a key in the persistentVars table with a boolean value of false
  for _, item in pairs(data.Items) do
    ISFModVars.Shipments[modGUID][item.TemplateUUID] = false
  end
end

--- Remove elements in the table that do not have a FileVersions, Items table, and any elements in the Items table that do not have a TemplateUUID
---@param data table The item data to sanitize
function ItemShipment:SanitizeData(data, modGUID)
  -- Remove elements in the table that do not have a FileVersions table
  if not data.FileVersion then
    ISFWarn(0, "No 'FileVersion' section found in data for mod: " .. Ext.Mod.GetMod(modGUID).Info.Name)
    return
  end

  -- Remove elements in the table that do not have an Items table
  if not data.Items then
    ISFWarn(0, "No 'Items' section found in data for mod: " .. Ext.Mod.GetMod(modGUID).Info.Name)
    return
  end

  -- Remove any elements in the Items table that do not have a TemplateUUID
  for i = #data.Items, 1, -1 do
    if not data.Items[i].TemplateUUID then
      ISFWarn(0,
        "ISF config file for mod " ..
        Ext.Mod.GetMod(modGUID).Info.Name ..
        " contains an item that does not have a TemplateUUID and will be removed. Please contact " ..
        Ext.Mod.GetMod(modGUID).Info.Author .. " about this issue.")
      table.remove(data.Items, i)
    end
  end

  return data
end

--- ApplyDefaultValues ensures that any missing fields in the JSON data are assigned default values.
---@param data table The item data to process
function ItemShipment:ApplyDefaultValues(data)
  for _, item in ipairs(data.Items) do
    -- Set default value for Send
    item.Send = item.Send or {}
    -- Set default value for Send.Quantity
    if item.Send.Quantity == nil then
      item.Send.Quantity = 1
    end

    -- Set default values for Send.To
    item.Send.To = item.Send.To or {}
    if item.Send.To.Host == nil then
      item.Send.To.Host = false
    end

    item.Send.To.CampChest = item.Send.To.CampChest or {}
    if item.Send.To.CampChest.Player1Chest == nil then
      item.Send.To.CampChest.Player1Chest = true
    end
    if item.Send.To.CampChest.Player2Chest == nil then
      item.Send.To.CampChest.Player2Chest = true
    end
    if item.Send.To.CampChest.Player3Chest == nil then
      item.Send.To.CampChest.Player3Chest = true
    end
    if item.Send.To.CampChest.Player4Chest == nil then
      item.Send.To.CampChest.Player4Chest = true
    end

    -- Set default values for Send.On
    item.Send.On = item.Send.On or {}
    if item.Send.On.SaveLoad == nil then
      item.Send.On.SaveLoad = true
    end
    if item.Send.On.DayEnd == nil then
      item.Send.On.DayEnd = false
    end

    -- Set default value for Send.NotifyPlayer
    if item.Send.NotifyPlayer == nil then
      item.Send.NotifyPlayer = true
    end

    -- Set default values for Send.CheckExistence
    item.Send.CheckExistence = item.Send.CheckExistence or {}
    item.Send.CheckExistence.CampChest = item.Send.CheckExistence.CampChest or {}
    if item.Send.CheckExistence.CampChest.Player1Chest == nil then
      item.Send.CheckExistence.CampChest.Player1Chest = true
    end
    if item.Send.CheckExistence.CampChest.Player2Chest == nil then
      item.Send.CheckExistence.CampChest.Player2Chest = true
    end
    if item.Send.CheckExistence.CampChest.Player3Chest == nil then
      item.Send.CheckExistence.CampChest.Player3Chest = true
    end
    if item.Send.CheckExistence.CampChest.Player4Chest == nil then
      item.Send.CheckExistence.CampChest.Player4Chest = true
    end

    item.Send.CheckExistence.PartyMembers = item.Send.CheckExistence.PartyMembers or {}
    if item.Send.CheckExistence.PartyMembers.AtCamp == nil then
      item.Send.CheckExistence.PartyMembers.AtCamp = true
    end
    if item.Send.CheckExistence.FrameworkCheck == nil then
      item.Send.CheckExistence.FrameworkCheck = true
    end

    if item.Send.CheckExistence.FrameworkCheck == nil then
      item.Send.CheckExistence.FrameworkCheck = true
    end
  end

  return data
end

function ItemShipment:PreprocessData(data, modGUID)
  local sanitizedData = self:SanitizeData(data, modGUID)
  if not sanitizedData then
    ISFWarn(0,
      "Failed to sanitize data for mod: " ..
      Ext.Mod.GetMod(modGUID).Info.Name ..
      ". Please contact " .. Ext.Mod.GetMod(modGUID).Info.Author .. " for assistance.")
    return
  end

  return self:ApplyDefaultValues(data)
end

--- Submit the data to the ItemShipment instance
---@param data table The item data to submit
---@param modGUID string The UUID of the mod that the item data belongs to
function ItemShipment:SubmitData(data, modGUID)
  local preprocessedData = self:PreprocessData(data, modGUID)
  if not preprocessedData then
    return
  end

  self:InitializeModVarsForMod(preprocessedData, modGUID)
  self.mods[modGUID] = preprocessedData
end

-- TODO: modularize CF code into different files
--- Load the JSONc file for the mod and submit the data to the ItemShipment instance
---@param configStr string The string representation of the JSONc file
---@param modGUID GUIDSTRING The UUID of the mod that the config file belongs to
function ItemShipment:TryLoadConfig(configStr, modGUID)
  ISFDebug(2, "Entering TryLoadConfig with parameters: " .. configStr .. ", " .. modGUID)
  local success, data = pcall(Ext.Json.Parse, configStr)
  if success then
    if data ~= nil then
      self:SubmitData(data, modGUID)
    end
  elseif modGUID ~= nil then
    ISFWarn(0,
      "Invalid config for mod " ..
      Ext.Mod.GetMod(modGUID).Info.Name ..
      ". Please contact " .. Ext.Mod.GetMod(modGUID).Info.Author .. " for assistance.")
  else
    ISFWarn(0, "Invalid config for mod " .. modGUID .. ". Please contact the mod author for assistance.")
  end
end

--- Load config files for each mod in the load order, if they exist. The config file should be named "ItemShipmentFrameworkConfig.jsonc" and be located in the mod's directory, alongside the mod's meta.lsx file.
function ItemShipment:LoadConfigFiles()
  -- Ensure ModVars table is initialized
  -- self:InitializeModVars()

  for _, uuid in pairs(Ext.Mod.GetLoadOrder()) do
    local modData = Ext.Mod.GetMod(uuid)
    ISFDebug(3, "Checking mod: " .. modData.Info.Name)

    local filePath = configFilePathPatternJSONC:format(modData.Info.Directory)
    local config = Ext.IO.LoadFile(filePath, "data")
    if config == nil then
      filePath = configFilePathPatternJSON:format(modData.Info.Directory)
      config = Ext.IO.LoadFile(filePath, "data")
    end
    if config ~= nil and config ~= "" then
      ISFDebug(2, "Found config for mod: " .. Ext.Mod.GetMod(uuid).Info.Name)
      self:TryLoadConfig(config, uuid)
    end
  end
end

-- Set the trigger for the shipment, e.g. "ConsoleCommand", "LevelGameplayStarted", "EndTheDayRequested"
--@param trigger string The trigger/reason to set
--@return void
function ItemShipment:SetShipmentTrigger(trigger)
  self.shipmentTrigger = trigger
end

-- Check if the character has finished the tutorial or if spawning during tutorial is allowed
function ItemShipment:MandatoryShipmentsChecks()
  local allowDuringTutorial = Config:getCfg().FEATURES.spawning.allow_during_tutorial
  if allowDuringTutorial or Osi.GetFlag(hasVisitedAct1Flag, Osi.GetHostCharacter()) then
    ISFDebug(2, "Character has visited Act 1 or spawning during tutorial is allowed, shipments can be processed.")
    return true
  end

  return false
end

--- Initialize mailboxes for each player in the campaign
function ItemShipment:InitializeMailbox()
  local ISFModVars = VCHelpers.ModVars:Get(ModuleUUID)
  local campChestUUIDs = VCHelpers.Camp:GetAllCampChestsUUIDs()

  for playerID, chestUUID in pairs(campChestUUIDs) do
    ISFDebug(2, "Initializing mailbox for playerID: " .. playerID .. ", chestUUID: " .. chestUUID)
    ISFDebug(2, "Mailboxes: " .. Ext.Json.Stringify(ISFModVars.Mailboxes), { Beautify = true })
    if chestUUID and ISFModVars.Mailboxes[tostring(playerID)] == nil then
      Osi.TemplateAddTo(self.mailboxTemplateUUID, chestUUID, 1, 1)
      Osi.ShowNotification(Osi.GetHostCharacter(), "A mailbox has been added to your camp chest.")
      -- NOTE: Assignment to Mailboxes table is done in the OnTemplateAddedTo event handler
    end
  end
end

--- Move mailboxes inside camp chests if they exist and are not already inside.
function ItemShipment:MakeSureMailboxesAreInsideChests()
  local ISFModVars = VCHelpers.ModVars:Get(ModuleUUID)
  local campChestUUIDs = VCHelpers.Camp:GetAllCampChestsUUIDs()

  for playerID, mailboxUUID in pairs(ISFModVars.Mailboxes) do
    local campChestUUID = campChestUUIDs[tostring(playerID)]
    if campChestUUID then
      local campChestInventory = VCHelpers.Inventory:GetInventory(campChestUUID, false, false)
      if Osi.IsInInventoryOf(mailboxUUID, campChestUUID) == 0 then
        Osi.ToInventory(mailboxUUID, campChestUUID, 1, 1, 1)
        Osi.ShowNotification(Osi.GetHostCharacter(), "A mailbox has been moved to the camp chest.")
      end
    end
  end
end

--- Notify the player that they have new items in their mailbox
---@param item table The item that was shipped
---@param modGUID string The UUID of the mod that shipped the item
function ItemShipment:NotifyPlayer(item, modGUID)
  -- --- Ping the chests receiving items to notify the player that they have new items in their mailbox
  function ItemShipment:PingChestsReceivingItems()
    for playerID, chestUUID in pairs(VCHelpers.Camp:GetAllCampChestsUUIDs()) do
      if item.Send.To.CampChest[self.playerIDMapping[playerID]] then
        local chestPositionX, chestPositionY, chestPositionZ = Osi.GetPosition(chestUUID)
        if chestPositionX and chestPositionY and chestPositionZ then
          Osi.RequestPing(chestPositionX, chestPositionY, chestPositionZ, chestUUID, Osi.GetHostCharacter())
        end
      end
    end
  end

  if Config:getCfg().FEATURES.notifications.enabled == true and item and item.Send.NotifyPlayer then
    if Config:getCfg().FEATURES.notifications.ping_chest == true then
      self:PingChestsReceivingItems()
    end
    Osi.ShowNotification(Osi.GetHostCharacter(),
      "You have new items in your mailbox from the mod " .. Ext.Mod.GetMod(modGUID).Info.Name)
    VCHelpers.Timer:OnTime(2800, function()
      Osi.ShowNotification(Osi.GetHostCharacter(),
        "You have new items in your mailbox from the mod " .. Ext.Mod.GetMod(modGUID).Info.Name)
    end)
  end
end

--- Process shipments for a specific mod.
---@param ISFModVars table The ISF ModVars table
---@param modGUID string The UUID of the mod being processed
---@param skipChecks boolean Whether to skip checking if the item already exists
---@return void
function ItemShipment:ProcessModShipments(ISFModVars, modGUID, skipChecks)
  if Ext.Mod.IsModLoaded(modGUID) then
    ISFPrint(1, "Checking items to add from mod " .. Ext.Mod.GetMod(modGUID).Info.Name)
    for _, item in pairs(ItemShipmentInstance.mods[modGUID].Items) do
      if skipChecks or self:ShouldShipItem(ISFModVars, modGUID, item) then
        ItemShipment:ShipItem(ISFModVars, modGUID, item)
        -- NOTE: this is not accounting for multiplayer characters/mailboxes, and will likely never be
        ItemShipment:NotifyPlayer(item, modGUID)
      end
    end
  end
end

--- Process shipments for each mod that has been loaded.
---@param skipChecks boolean Whether to skip the existence check for the item in inventories, etc. before adding it to the destination
---@return void
function ItemShipment:ProcessShipments(skipChecks)
  -- Mandatory checks before processing shipments/mailboxes/camp chests
  if not ItemShipment:MandatoryShipmentsChecks() then
    return
  end

  -- Make sure mailboxes are inside chests, if not, move them
  ItemShipmentInstance:MakeSureMailboxesAreInsideChests()

  skipChecks = skipChecks or false
  self:InitializeMailbox()
  local ISFModVars = VCHelpers.ModVars:Get(ModuleUUID)

  -- Iterate through each mod and process shipments
  for modGUID, modData in pairs(ItemShipmentInstance.mods) do
    self:ProcessModShipments(ISFModVars, modGUID, skipChecks)
  end

  self:SetShipmentTrigger(nil)
end

-- FIXME: not working for some reason
function ItemShipment:IsTriggerCompatible(item)
  local triggerIsCompatible = self.shipmentTrigger == "ConsoleCommand"

  for trigger, shouldShip in pairs(item.Send.On) do
    if shouldShip == true and self.shipmentTrigger == trigger then
      triggerIsCompatible = true
      break
    end
  end

  return triggerIsCompatible
end

--- Check if the item should be shipped based on the item's configuration for trigger and existence checks
---@param ISFModVars table The ISF ModVars table
---@param modGUID string The UUID of the mod being processed
---@param item table The item being processed
---@return boolean
function ItemShipment:ShouldShipItem(ISFModVars, modGUID, item)
  local IsTriggerCompatible = self:IsTriggerCompatible(item)
  local itemExists = self:CheckExistence(ISFModVars, modGUID, item)

  return IsTriggerCompatible and not itemExists
end

--- Add the item to the target inventory, based on the item's configuration for Send.To
---@param ISFModVars table The ISF ModVars table
---@param modGUID string The UUID of the mod being processed
---@param item table The item being processed
---@return void
function ItemShipment:ShipItem(ISFModVars, modGUID, item)
  local targetInventories = {}
  local quantity = item.Send.Quantity or 1
  local notify = 0
  if item.Send.NotifyPlayer == true then
    notify = 1
  end

  ISFPrint(1, "Adding item: " .. item.TemplateUUID)

  -- Check each option in the Send.To field
  if item.Send.To.Host then
    table.insert(targetInventories, Osi.GetHostCharacter())
  end

  -- Check each camp chest and add the corresponding mailbox to the targetInventories
  local campChestUUIDs = VCHelpers.Camp:GetAllCampChestsUUIDs()

  for playerID, campChestUUID in pairs(campChestUUIDs) do
    local mailboxUUID = ISFModVars.Mailboxes[playerID]
    if mailboxUUID and item.Send.To.CampChest[self.playerIDMapping[playerID]] then
      table.insert(targetInventories, mailboxUUID)
    end
  end

  ISFDebug(2, "Target inventories: " .. Ext.Json.Stringify(targetInventories), { Beautify = true })

  for _, targetInventory in ipairs(targetInventories) do
    if targetInventory ~= nil then
      ISFPrint(1, "Adding item: " .. item.TemplateUUID)
      -- _D(targetInventory)
      Osi.TemplateAddTo(item.TemplateUUID, targetInventory, quantity, notify)
      -- Osi.TemplateAddTo("398e7328-ce90-4c02-94a2-93341fac499a", "CONT_PlayerCampChest_A_00cb696b-2e5b-2927-cd35-a580b570f400", 10, 1)
    else
      ISFPrint(1, "No valid target inventory found for item: " .. item.TemplateUUID)
    end
  end

  -- Update ModVars to track added items
  ISFModVars.Shipments[modGUID][item.TemplateUUID] = true
  -- VCHelpers.ModVars:Sync(ModuleUUID)
end

--- Check if the item already exists in the target inventories, based on the item's configuration for CheckExistence
---@param ISFModVars table The ISF ModVars table
---@param modGUID string The UUID of the mod being processed
---@param item table The item being processed
---@return boolean
function ItemShipment:CheckExistence(ISFModVars, modGUID, item)
  -- Check if the item has already been added
  ISFDebug(2, "CHECKING MODVARS")
  if item.Send.CheckExistence.FrameworkCheck then
    if ISFModVars.Shipments[modGUID][item.TemplateUUID] == true then
      return true
    end
  end

  -- Check if the item exists in the camp chests
  ISFDebug(2, "CHECKING CAMP CHESTS")
  if item.Send.CheckExistence.CampChest then
    if item.Send.CheckExistence.CampChest.Player1Chest then
      -- FIXME: check mailbox instead
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

--- Register console commands for shipping items from all mods.
---@param modUUID string The UUID of the mod being processed
---@param skipChecks boolean Whether to skip checking if the item already exists
---@return void
Ext.RegisterConsoleCommand('isf_ship_all', function(cmd, skipChecks)
  skipChecks = skipChecks or true
  local trigger = "ConsoleCommand"
  self:SetShipmentTrigger(trigger)

  ItemShipmentInstance:LoadConfigFiles()
  ItemShipmentInstance:ProcessShipments(skipChecks)
end)

--- Register console commands for shipping items for a specific mod.
---@param modUUID string The UUID of the mod being processed
---@param skipChecks boolean Whether to skip checking if the item already exists
---@return void
Ext.RegisterConsoleCommand('isf_ship_mod', function(cmd, modUUID, skipChecks)
  local ISFModVars = VCHelpers.ModVars:Get(ModuleUUID)
  skipChecks = skipChecks or true
  local trigger = "ConsoleCommand"
  self:SetShipmentTrigger(trigger)

  ItemShipmentInstance:LoadConfigFiles()
  ItemShipment:ProcessModShipments(ISFModVars, modUUID, skipChecks)
end)
