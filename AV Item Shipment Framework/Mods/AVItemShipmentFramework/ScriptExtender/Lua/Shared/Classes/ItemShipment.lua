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

-- TODO: add more level 2 debug messages to be able to track from user reports
---@class ItemShipment: MetaClass
ItemShipment = _Class:Create("ItemShipment", nil, {
  mods = {},
  shipmentTrigger = nil,
})

-- NOTE: When introducing new (breaking) versions of the config file, add a new function to parse the new version and update the version number in the config file
-- local versionHandlers = {
--   [1] = parseVersion1Config,
--   [2] = parseVersion2Config,
-- }


--- Submit the data to the ItemShipment instance
---@param data table The item data to submit
---@param modGUID string The UUID of the mod that the item data belongs to
function ItemShipment:SubmitData(data, modGUID)
  local preprocessedData = ISDataProcessing:PreprocessData(data, modGUID)
  if not preprocessedData then
    return
  end

  ISUtils:InitializeModVarsForMod(preprocessedData, modGUID)
  self.mods[modGUID] = preprocessedData
end

--- Load config files for each mod in the load order, if they exist. The config file should be named "ItemShipmentFrameworkConfig.jsonc" and be located in the mod's directory, alongside the mod's meta.lsx file.
function ItemShipment:LoadShipments()
  -- Ensure ModVars table is initialized
  -- self:InitializeModVars()

  for _, uuid in pairs(Ext.Mod.GetLoadOrder()) do
    local modData = Ext.Mod.GetMod(uuid)
    ISFDebug(3, "Checking mod: " .. modData.Info.Name)

    local filePath = ISJsonLoad.ConfigFilePathPatternJSONC:format(modData.Info.Directory)
    local config = Ext.IO.LoadFile(filePath, "data")
    if config == nil then
      filePath = ISJsonLoad.ConfigFilePathPatternJSON:format(modData.Info.Directory)
      config = Ext.IO.LoadFile(filePath, "data")
    end
    if config ~= nil and config ~= "" then
      ISFDebug(2, "Found config for mod: " .. Ext.Mod.GetMod(uuid).Info.Name)
      local data = ISJsonLoad:TryLoadConfig(config, uuid)
      if data ~= nil then
        self:SubmitData(data, uuid)
      end
    end
  end
end

-- Set the trigger for the shipment, e.g. "ConsoleCommand", "LevelGameplayStarted", "EndTheDayRequested"
--@param trigger string The trigger/reason to set
--@return nil
function ItemShipment:SetShipmentTrigger(trigger)
  self.shipmentTrigger = trigger
end

--- Notify the player that they have new items in their mailbox
---@param item table The item that was shipped
---@param modGUID string The UUID of the mod that shipped the item
function ItemShipment:NotifyPlayer(item, modGUID)
  -- TODO: slightly modularize this
  if Config:getCfg().FEATURES.notifications.enabled == true and item and item.Send.NotifyPlayer then
    for playerID, chestUUID in pairs(VCHelpers.Camp:GetAllCampChestsUUIDs()) do
      if item.Send.To.CampChest[ISMailboxes.PlayerIDMapping[playerID]] then
        if Config:getCfg().FEATURES.notifications.vfx == true then
          -- FIXME: only play once per shipment
          -- Osi.PlayEffect(Osi.GetHostCharacter(), "09ca988d-47dd-b10f-d8e4-b4744874a942")
        end
        Messages.UpdateLocalizedMessage(Messages.Handles.mod_shipped_item_to_mailbox, Ext.Mod.GetMod(modGUID).Info.Name)
        Osi.ShowNotification(Osi.GetHostCharacter(),
          Ext.Loca.GetTranslatedString(Messages.Handles.mod_shipped_item_to_mailbox))
        -- VCHelpers.Timer:OnTime(2500, function()
        --   Osi.ShowNotification(Osi.GetHostCharacter(),
        --     Ext.Loca.GetTranslatedString(Messages.Handles.mod_shipped_item_to_mailbox))
        -- end)
        if Config:getCfg().FEATURES.notifications.ping_chest == true then
          local chestPositionX, chestPositionY, chestPositionZ = Osi.GetPosition(chestUUID)
          if chestPositionX and chestPositionY and chestPositionZ then
            -- FIXME: only play once per shipment
            -- Osi.RequestPing(chestPositionX, chestPositionY, chestPositionZ, chestUUID, Osi.GetHostCharacter())
            -- Osi.PlayEffect(chestUUID, "00630e26-964d-c3e1-fcce-7f267c75e606")
          end
        end
      end
    end
  end
end

--- Process shipments for a specific mod.
---@param modGUID string The UUID of the mod being processed
---@param skipChecks boolean Whether to skip checking if the item already exists
---@return nil
function ItemShipment:ProcessModShipments(modGUID, skipChecks)
  if Ext.Mod.IsModLoaded(modGUID) then
    ISFPrint(1, "Checking items to add from mod " .. Ext.Mod.GetMod(modGUID).Info.Name)
    for _, item in pairs(ItemShipmentInstance.mods[modGUID].Items) do
      if skipChecks or self:ShouldShipItem(modGUID, item) then
        ItemShipment:ShipItem(modGUID, item)
        -- NOTE: this is not accounting for multiplayer characters/mailboxes, and will likely never be
        ItemShipment:NotifyPlayer(item, modGUID)
      end
    end
  end
end

--- Process shipments for each mod that has been loaded.
---@param skipChecks boolean Whether to skip the existence check for the item in inventories, etc. before adding it to the destination
---@return nil
function ItemShipment:ProcessShipments(skipChecks)
  -- Mandatory checks before processing shipments/mailboxes/camp chests
  if not ISChecks:MandatoryShipmentsChecks() then
    return
  end

  -- Make sure mailboxes are inside chests, if not, move them
  ISMailboxes:MakeSureMailboxesAreInsideChests()

  skipChecks = skipChecks or false
  ISMailboxes:InitializeMailboxes()

  VCHelpers.Timer:OnTime(3000, function()
    ISFDebug(2, "Processing shipments for all mods.")


    -- Iterate through each mod and process shipments
    for modGUID, modData in pairs(ItemShipmentInstance.mods) do
      self:ProcessModShipments(modGUID, skipChecks)
    end

    self:SetShipmentTrigger(nil)
  end)
end

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
---@param modGUID string The UUID of the mod being processed
---@param item table The item being processed
---@return boolean
function ItemShipment:ShouldShipItem(modGUID, item)
  local IsTriggerCompatible = self:IsTriggerCompatible(item)
  local itemExists = ISChecks:CheckExistence(modGUID, item)

  return IsTriggerCompatible and not itemExists
end

--- Add the item to the target inventory, based on the item's configuration for Send.To
---@param modGUID string The UUID of the mod being processed
---@param item table The item being processed
---@return nil
function ItemShipment:ShipItem(modGUID, item)
  local ISFModVars = Ext.Vars.GetModVariables(ModuleUUID)

  local targetInventories = {}
  local quantity = item.Send.Quantity or 1
  local notify = 0
  if item.Send.NotifyPlayer == true then
    notify = 1
  end

  ISFPrint(1, "Adding item: " .. Ext.Json.Stringify(item), { Beautify = true })
  ISFPrint(1, "Mailboxes: " .. Ext.Json.Stringify(ISFModVars.Mailboxes), { Beautify = true })

  -- Check each option in the Send.To field
  if item.Send.To.Host then
    table.insert(targetInventories, Osi.GetHostCharacter())
  end

  -- Check each camp chest and add the corresponding mailbox to the targetInventories
  local campChestUUIDs = VCHelpers.Camp:GetAllCampChestsUUIDs()

  for playerID, campChestUUID in pairs(campChestUUIDs) do
    local mailboxUUID = ISMailboxes:GetPlayerMailbox(playerID)
    if mailboxUUID and item.Send.To.CampChest[ISMailboxes.PlayerIDMapping[tostring(playerID)]] then
      ISFDebug(2, "Adding mailbox to delivery list: " .. item.TemplateUUID)
      table.insert(targetInventories, mailboxUUID)
    else
      ISFDebug(2, "Skipping mailbox: " .. item.TemplateUUID .. " for playerID: " .. playerID)
    end
  end

  ISFDebug(2, "Target inventories: " .. Ext.Json.Stringify(targetInventories), { Beautify = true })

  for _, targetInventory in ipairs(targetInventories) do
    if targetInventory ~= nil then
      ISFPrint(0, "Adding item: " .. item.TemplateUUID .. " to inventory: " .. targetInventory)
      Osi.TemplateAddTo(item.TemplateUUID, targetInventory, quantity, notify)
    else
      ISFPrint(1, "No valid target inventory found for item: " .. item.TemplateUUID)
    end
  end

  -- Update ModVars to track added items
  ISFModVars.Shipments[modGUID][item.TemplateUUID] = true
  -- VCHelpers.ModVars:Sync(ModuleUUID)
end
