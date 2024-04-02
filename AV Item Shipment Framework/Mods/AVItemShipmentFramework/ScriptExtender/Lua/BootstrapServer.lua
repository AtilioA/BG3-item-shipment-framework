Ext.Vars.RegisterModVariable(ModuleUUID, "Shipments", {
  Server = true,
  Persistent = true,
  SyncOnWrite = true,
  SyncOnTick = true,
  DontCache = true,
})

Ext.Vars.RegisterModVariable(ModuleUUID, "Mailboxes", {
  Server = true,
  Persistent = true,
  SyncOnWrite = true,
  SyncOnTick = true,
  DontCache = true,
})

Ext.Require("Shared/_Init.lua")
Ext.Require("Server/_Init.lua")
