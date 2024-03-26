EHandlers = {}

function EHandlers.OnLevelGameplayStarted(levelName, isEditorMode)
  ISFDebug(2, "Entering OnLevelGameplayStarted, levelName: " .. levelName .. ", isEditorMode: " .. tostring(isEditorMode))
  if isEditorMode == true then
    return
  end

  if levelName == 'SYS_CC_I' then
    -- TODO: Set variable to deliver on Act 1
    return
  end
end

return EHandlers
