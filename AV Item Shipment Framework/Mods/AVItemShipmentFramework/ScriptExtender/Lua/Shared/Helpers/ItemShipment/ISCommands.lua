---@class HelperISCommands: Helper
ISCommands = _Class:Create("HelperISCommands", Helper)

--- Register console commands for shipping items from all mods.
---@param modUUID string The UUID of the mod being processed
---@param skipChecks boolean Whether to skip checking if the item already exists
---@return void
Ext.RegisterConsoleCommand('isf_ship_all', function(cmd, skipChecks)
  skipChecks = skipChecks or true
  local trigger = "ConsoleCommand"
  ItemShipmentInstance:SetShipmentTrigger(trigger)

  ItemShipmentInstance:LoadShipments()
  ItemShipmentInstance:ProcessShipments(skipChecks)
end)

--- Register console commands for shipping items for a specific mod.
---@param modUUID string The UUID of the mod being processed
---@param skipChecks boolean Whether to skip checking if the item already exists
---@return void
Ext.RegisterConsoleCommand('isf_ship_mod', function(cmd, modUUID, skipChecks)
  skipChecks = skipChecks or true
  local trigger = "ConsoleCommand"
  ItemShipmentInstance:SetShipmentTrigger(trigger)

  ItemShipmentInstance:LoadShipments()
  ItemShipmentInstance:ProcessModShipments(modUUID, skipChecks)
end)
