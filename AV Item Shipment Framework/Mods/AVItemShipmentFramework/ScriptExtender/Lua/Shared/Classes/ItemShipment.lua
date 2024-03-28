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

---@class ItemShipment: MetaClass
ItemShipment = _Class:Create("ItemShipment", nil, {
  mods = {},
  mailbox_templateUUID = "b99474ea-43f9-4dbb-9917-e0a6daa3b9e3"
})

local configFilePathPattern = string.gsub("Mods/%s/ScriptExtender/ItemShipmentFrameworkConfig.jsonc", "'", "\'")

-- function ItemShipment:InitializeModVars()
--   -- REFACTOR: make this global or something
--   local ISFModVars = VCHelpers.ModVars:Get(ModuleUUID)
--   VCHelpers.ModVars:Register("Shipments", ModuleUUID, {})
--   VCHelpers.ModVars:Register("Mailboxes", ModuleUUID, {
--     Player1 = nil,
--     Player2 = nil,
--     Player3 = nil,
--     Player4 = nil
--   })
-- end

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

function ItemShipment:SubmitData(data, modGUID)
  self:InitializeModVarsForMod(data, modGUID)
  self.mods[modGUID] = data
end

---@param configStr string
---@param modGUID GUIDSTRING
function ItemShipment:TryLoadConfig(configStr, modGUID)
  ISFDebug(2, "Entering TryLoadConfig with parameters: " .. configStr .. ", " .. modGUID)
  local success, data = pcall(Ext.Json.Parse, configStr)
  if success then
    if data ~= nil then
      self:SubmitData(data, modGUID)
    end
  elseif modGUID ~= nil then
    ISFWarn(0, "Failed to parse config for mod: " .. Ext.Mod.GetMod(modGUID).Info.Name)
  else
    ISFWarn(0, "Failed to parse config for mod: " .. modGUID)
  end
end

function ItemShipment:LoadConfigFiles()
  -- Ensure ModVars table is initialized
  -- self:InitializeModVars()

  ISFDebug(2, "Entering LoadConfigFiles")
  for _, uuid in pairs(Ext.Mod.GetLoadOrder()) do
    local modData = Ext.Mod.GetMod(uuid)
    ISFDebug(3, "Checking mod: " .. modData.Info.Name)
    local filePath = configFilePathPattern:format(modData.Info.Directory)
    -- ISFDebug(2, "Checking file path: " .. filePath)
    local config = Ext.IO.LoadFile(filePath, "data")
    if config ~= nil and config ~= "" then
      ISFDebug(2, "Found config for mod: " .. Ext.Mod.GetMod(uuid).Info.Name)
      self:TryLoadConfig(config, uuid)
    end
  end
end

function ItemShipment:InitializeMailbox()
  local ISFModVars = VCHelpers.ModVars:Get(ModuleUUID)
  local campChestUUIDs = VCHelpers.Camp:GetAllCampChestsUUIDs()
  
  for _, chestUUID in ipairs(campChestUUIDs) do
    if chestUUID and ISFModVars.Mailboxes.Player1 == nil then
      Osi.TemplateAddTo(self.mailbox_templateUUID, chestUUID, 1, 1)
      Osi.ShowNotification(Osi.GetHostCharacter(), "A mailbox has been added to your camp chest.")
    end
  end
end

function ItemShipment:ProcessShipments()
  self:InitializeMailbox()
  local ISFModVars = VCHelpers.ModVars:Get(ModuleUUID)

  -- Iterate through each mod and check if items need to be added
  for modGUID, modData in pairs(ItemShipmentInstance.mods) do
    if Ext.Mod.IsModLoaded(modGUID) then
      ISFPrint(1, "Checking items to add from mod " .. Ext.Mod.GetMod(modGUID).Info.Name)
      for _, item in pairs(modData.Items) do
        if ItemShipment:ShouldAddItem(ISFModVars, modGUID, item) then
          ItemShipment:AddItem(ISFModVars, modGUID, item)
          -- NOTE: this is not accounting for multiplayer characters/mailboxes
          if Config:getCfg().FEATURES.disable_notifications == false and item.Send.Notify then
            Osi.ShowNotification(Osi.GetHostCharacter(), "You have new items in your mailbox.")
          end
        end
      end
    end
  end
end

function ItemShipment:ShouldAddItem(ISFModVars, modGUID, item)
  return not self:CheckExistence(ISFModVars, modGUID, item)
end

function ItemShipment:GetCampChestsUUIDs(item)
  local campChestUUIDs = {}

  local campChests = Osi.DB_Camp_UserCampChest:Get(nil, nil)
  _D(campChests)
  if campChests then
    if item.Send.To.CampChest.Player1Chest then
      if campChests[1] then
        table.insert(campChestUUIDs, campChests[1][2])
      end
    end

    if item.Send.To.CampChest.Player2Chest then
      if campChests[2] then
        table.insert(campChestUUIDs, campChests[2][2])
      end
    end

    if item.Send.To.CampChest.Player3Chest then
      if campChests[3] then
        table.insert(campChestUUIDs, campChests[3][2])
      end
    end

    if item.Send.To.CampChest.Player4Chest then
      if campChests[4] then
        table.insert(campChestUUIDs, campChests[4][2])
      end
    end
  end

  return campChestUUIDs
end

function ItemShipment:AddItem(ISFModVars, modGUID, item)
  local targetInventories = {}
  local quantity = item.Send.Quantity or 1
  local notify = 0
  if item.Send.Notify == true then
    notify = 1
  end

  ISFPrint(1, "Adding item: " .. item.TemplateUUID)

  -- Check each option in the Send.To field
  _D(item)
  if item.Send.To.Host then
    table.insert(targetInventories, Osi.GetHostCharacter())
  end

  -- FIXME
  local campChestUUIDs = self:GetCampChestsUUIDs(item)
  for _, campChestUUID in ipairs(campChestUUIDs) do
    table.insert(targetInventories, campChestUUID)
  end

  -- _D(targetInventories)
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

function ItemShipment:CheckExistence(ISFModVars, modGUID, item)
  -- Check if the item has already been added
  if item.Send.CheckExistence.FrameworkCheck then
    if ISFModVars.Shipments[modGUID][item.TemplateUUID] == true then
      return true
    end
  end

  -- -- Implement additional checks based on the config
  -- if item.Send.CheckExistence.PartyMembers.Followers then
  --   -- TODO: Check if party members have the item, for each party member
  -- end

  if item.Send.CheckExistence.CampChest.Player1Chest then
    -- VCHelpers.Inventory:GetInventory()
    if VCHelpers.Inventory:IsItemInCampChest(item.TemplateUUID) then
      return true
    end
  end

  return false
end
