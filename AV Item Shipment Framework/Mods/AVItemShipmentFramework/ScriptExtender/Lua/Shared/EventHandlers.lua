EHandlers = {}

function EHandlers.OnLevelGameplayStarted(levelName, isEditorMode)
  ISFDebug(2, "Entering OnLevelGameplayStarted, levelName: " .. levelName .. ", isEditorMode: " .. tostring(isEditorMode))

  -- Ignore Editor Mode
  if isEditorMode == true then
    return
  end

  -- Ignore Character Creation level
  if levelName == 'SYS_CC_I' then
    -- TODO: Set variable to deliver on Act 1
    return
  end

  -- Scan for mod JSON files to load
  ItemShipmentInstance:LoadConfigFiles()

  -- Add small delay to ensure camp chests are loaded and that notifications can be read by the player
  VCHelpers.Timer:OnTime(3000, function()
    -- Make sure mailboxes are inside chests, if not, move them
    ItemShipmentInstance:MakeSureMailboxesAreInsideChests()
    -- Process shipments read from JSON files
    ItemShipmentInstance:ProcessShipments(false)
  end)
end

function EHandlers.OnTemplateAddedTo(objectTemplate, object2, inventoryHolder)
  ISFDebug(2,
    "Entering OnTemplateAddedTo, objectTemplate: " ..
    objectTemplate .. ", object2: " .. object2 .. ", inventoryHolder: " .. inventoryHolder)
  if objectTemplate == "CONT_ISF_Container_" .. ItemShipmentInstance.mailbox_templateUUID then
    local ISFModVars = VCHelpers.ModVars:Get(ModuleUUID)
    ISFModVars.Mailboxes = ISFModVars.Mailboxes or {}

    local campChestName = VCHelpers.Format:GetTemplateName(inventoryHolder)
    if campChestName == nil then
      return
    end

    ISFModVars.Mailboxes[VCHelpers.Camp:GetPlayerIDFromCampChestName(campChestName)] = object2
  end
end

return EHandlers
