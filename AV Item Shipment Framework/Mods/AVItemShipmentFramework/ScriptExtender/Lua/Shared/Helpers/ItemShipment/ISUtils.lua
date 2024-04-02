---@class HelperISUtils: Helper
ISUtils = _Class:Create("HelperISUtils", Helper)

-- TODO: manage per-campaign; currently shares data across campaigns/save files I think
--- Initialize the mod vars for the mod, if they don't already exist. Might be redundant, but it's here for now.
---@param data table The item data to submit
---@param modGUID string The UUID of the mod that the item data belongs to
function ISUtils:InitializeModVarsForMod(data, modGUID)
  local ISFModVars = Ext.Vars.GetModVariables(ModuleUUID)
  if not ISFModVars.Shipments then
    ISFModVars.Shipments = {}
  end
  if not ISFModVars.Shipments[modGUID] then
    ISFModVars.Shipments[modGUID] = {}
  end

  -- For each templateUUID in the data, create a key in the persistentVars table with a boolean value of false
  for _, item in pairs(data.Items) do
    ISFModVars.Shipments[modGUID][item.TemplateUUID] = false
  end

  if not ISFModVars.Mailboxes then
    ISFModVars.Mailboxes = {
      ["65537"] = nil,
      ["65538"] = nil,
      ["65539"] = nil,
      ["65540"] = nil
    }
  end

  -- Sync the mod vars
  if ISFModVars then
    for varName, data in pairs(ISFModVars) do
      ISFModVars[varName] = ISFModVars[varName]
    end
    Ext.Vars.DirtyModVariables(ModuleUUID)
    Ext.Vars.SyncModVariables(ModuleUUID)
  end
end
