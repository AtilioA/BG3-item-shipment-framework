Ext.Vars.RegisterModVariable(ModuleUUID, "Shipments", {
  Server = true,
  Client = true,
  Persistent = true,
  SyncToServer = true,
  SyncToClient = true,
  WriteableOnServer = true,
  WriteableOnClient = true,
  SyncOnWrite = false,
  SyncOnTick = true,
  DontCache = false,
})

Ext.Vars.RegisterModVariable(ModuleUUID, "Mailboxes", {
  Server = true,
  Client = true,
  Persistent = true,
  SyncToServer = true,
  SyncToClient = true,
  WriteableOnServer = true,
  WriteableOnClient = true,
  SyncOnWrite = false,
  SyncOnTick = true,
  DontCache = false,
})

Ext.Require("Shared/_Init.lua")
Ext.Require("Server/_Init.lua")
