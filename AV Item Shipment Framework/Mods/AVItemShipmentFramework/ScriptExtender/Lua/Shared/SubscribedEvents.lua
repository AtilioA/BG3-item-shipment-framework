SubscribedEvents = {}

function SubscribedEvents.SubscribeToEvents()
    if Config:getCfg().GENERAL.enabled == true then
        Ext.Osiris.RegisterListener("LevelGameplayStarted", 2, "before", EHandlers.OnLevelGameplayStarted)

        Ext.Osiris.RegisterListener("TemplateAddedTo", 4, "after", EHandlers.OnTemplateAddedTo)

        Ext.Osiris.RegisterListener("UseStarted", 2, "before", EHandlers.OnUseStarted)
        Ext.Osiris.RegisterListener("ReadyCheckFailed", 1, "after", EHandlers.OnReadyCheckFailed)
        Ext.Osiris.RegisterListener("ReadyCheckPassed", 1, "after", EHandlers.OnReadyCheckPassed)
        Ext.Osiris.RegisterListener("UserConnected", 3, "after", EHandlers.OnUserConnected)
        Ext.Osiris.RegisterListener("CastedSpell", 5, "after", EHandlers.OnCastedSpell)

        -- Reload the shipments when resetting Lua states
        Ext.Events.ResetCompleted:Subscribe(EHandlers.OnReset)
    end
end

return SubscribedEvents
