---@class HelperISDataProcessing: Helper
ISDataProcessing = _Class:Create("HelperISDataProcessing", Helper)

--- Remove elements in the table that do not have a FileVersions, Items table, and any elements in the Items table that do not have a TemplateUUID
---@param data table The item data to sanitize
function ISDataProcessing:SanitizeData(data, modGUID)
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
        " contains an item that does not have a TemplateUUID and will be ignored. Please contact " ..
        Ext.Mod.GetMod(modGUID).Info.Author .. " about this issue.")
      table.remove(data.Items, i)
    end
  end

  return data
end

--- ApplyDefaultValues ensures that any missing fields in the JSON data are assigned default values.
---@param data table The item data to process
function ISDataProcessing:ApplyDefaultValues(data)
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

function ISDataProcessing:PreprocessData(data, modGUID)
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
