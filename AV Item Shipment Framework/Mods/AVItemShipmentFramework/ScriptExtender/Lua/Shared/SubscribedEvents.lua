SubscribedEvents = {}

function SubscribedEvents.SubscribeToEvents()
    if Config:getCfg().GENERAL.enabled == true then
        Ext.Osiris.RegisterListener("LevelGameplayStarted", 2, "before", EHandlers.OnLevelGameplayStarted)

        Ext.Osiris.RegisterListener("TemplateAddedTo", 4, "after", EHandlers.OnTemplateAddedTo)

        Ext.Osiris.RegisterListener("EndTheDayRequested", 1, "after", EHandlers.OnEndTheDayRequested)
        -- Ext.Osiris.RegisterListener("UseStarted", 2, "before", EHandlers.OnUseStarted)
    end
end

return SubscribedEvents
