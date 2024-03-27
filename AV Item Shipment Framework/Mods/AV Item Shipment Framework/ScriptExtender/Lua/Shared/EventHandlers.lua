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

  -- Process shipments read from JSON files
  ItemShipmentInstance:ProcessShipments()
end

return EHandlers
