---@class HelperISDataPreprocessing: Helper
ISDataPreprocessing = _Class:Create("HelperISDataPreprocessing", Helper)

--- Remove elements in the table that do not have a FileVersions, Items table, and any elements in the Items table that do not have a TemplateUUID
---@param data table The item data to sanitize
function ISDataPreprocessing:SanitizeData(data, modGUID)
    -- Remove elements in the table that do not have a FileVersions table
    if not data.FileVersion then
        ISFWarn(0,
            "No 'FileVersion' section found in data for mod: " ..
            Ext.Mod.GetMod(modGUID).Info.Name ..
            ". Please contact " .. Ext.Mod.GetMod(modGUID).Info.Author .. " about this issue.")
        return
    end

    -- Remove elements in the table that do not have an Items table
    if not data.Items then
        ISFWarn(0,
            "No 'Items' section found in data for mod: " ..
            Ext.Mod.GetMod(modGUID).Info.Name ..
            ". Please contact " .. Ext.Mod.GetMod(modGUID).Info.Author .. " about this issue.")
        return
    end

    -- Remove any elements in the Items table that do not have a TemplateUUID
    for i = #data.Items, 1, -1 do
        if not data.Items[i].TemplateUUID then
            ISFWarn(1,
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
function ISDataPreprocessing:ApplyDefaultValues(data)
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

        -- Set default values for Send.Check
        item.Send.Check = item.Send.Check or {}

        -- Set default values for Send.Check.ItemExistence
        item.Send.Check.ItemExistence = item.Send.Check.ItemExistence or {}
        item.Send.Check.ItemExistence.CampChest = item.Send.Check.ItemExistence.CampChest or {}
        if item.Send.Check.ItemExistence.CampChest.Player1Chest == nil then
            item.Send.Check.ItemExistence.CampChest.Player1Chest = true
        end
        if item.Send.Check.ItemExistence.CampChest.Player2Chest == nil then
            item.Send.Check.ItemExistence.CampChest.Player2Chest = true
        end
        if item.Send.Check.ItemExistence.CampChest.Player3Chest == nil then
            item.Send.Check.ItemExistence.CampChest.Player3Chest = true
        end
        if item.Send.Check.ItemExistence.CampChest.Player4Chest == nil then
            item.Send.Check.ItemExistence.CampChest.Player4Chest = true
        end

        item.Send.Check.ItemExistence.PartyMembers = item.Send.Check.ItemExistence.PartyMembers or {}
        if item.Send.Check.ItemExistence.PartyMembers.AtCamp == nil then
            item.Send.Check.ItemExistence.PartyMembers.AtCamp = true
        end
        if item.Send.Check.ItemExistence.FrameworkCheck == nil then
            item.Send.Check.ItemExistence.FrameworkCheck = true
        end

        if item.Send.Check.ItemExistence.FrameworkCheck == nil then
            item.Send.Check.ItemExistence.FrameworkCheck = true
        end

        -- Set default values for Send.Check.PlayerProgression
        item.Send.Check.PlayerProgression = item.Send.Check.PlayerProgression or {}
        if item.Send.Check.PlayerProgression.Act == nil then
            item.Send.Check.PlayerProgression.Act = 1
        end
        if item.Send.Check.PlayerProgression.Level == nil then
            item.Send.Check.PlayerProgression.Level = 1
        end
    end

    return data
end

--- PreprocessData is a wrapper function that calls the SanitizeData and ApplyDefaultValues functions.
---@param data table The item data to process
---@param modGUID string The GUID of the mod that the data belongs to
---@return table|nil The processed item data, or nil if the data could not be processed (e.g. if it failed sanitization due to invalid data)
function ISDataPreprocessing:PreprocessData(data, modGUID)
    local sanitizedData = self:SanitizeData(data, modGUID)
    if not sanitizedData then
        ISFWarn(0,
            "Failed to sanitize data for mod: " ..
            Ext.Mod.GetMod(modGUID).Info.Name ..
            ". Please contact " .. Ext.Mod.GetMod(modGUID).Info.Author .. " about this issue.")
        return
    end

    return self:ApplyDefaultValues(data)
end