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

  -- Ensure PersistentVars table is initialized
  ItemShipmentInstance:InitializePVars()
  -- if Mods.AVItemShipmentFramework.PersistentVars == nil then
  --   Mods.AVItemShipmentFramework.PersistentVars = {}
  -- end

  -- Iterate through each mod and check if items need to be added
  for modGUID, modData in pairs(ItemShipmentInstance.mods) do
    if Ext.ModIsLoaded(modGUID) then
      if not Mods.AVItemShipmentFramework.PersistentVars.shipments[modGUID] then
        -- TODO: Add items according to the config
        ISFDebug(1, "Adding items for mod: " .. Ext.Mod.GetMod(modGUID).Info.Name)

        -- Update PersistentVars to track added items
        Mods.AVItemShipmentFramework.PersistentVars.shipments[modGUID] = true
      end
    end
  end
end

return EHandlers
