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

end

function EHandlers.OnTemplateAddedTo(objectTemplate, object2, inventoryHolder)
  if objectTemplate == "CONT_ISF_Container_" .. ItemShipmentInstance.mailbox_templateUUID then
    local ISFModVars = VCHelpers.ModVars:Get(ModuleUUID)
    ISFModVars.Mailboxes = ISFModVars.Mailboxes or {}
    ISFModVars.Mailboxes["Player1"] = object2
  end
end

return EHandlers
