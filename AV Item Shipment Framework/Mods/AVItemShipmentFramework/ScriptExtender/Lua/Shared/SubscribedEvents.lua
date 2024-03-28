SubscribedEvents = {}

function SubscribedEvents.SubscribeToEvents()
  if Config:getCfg().GENERAL.enabled == true then
    Ext.Osiris.RegisterListener("LevelGameplayStarted", 2, "before", EHandlers.OnLevelGameplayStarted)

    Ext.Osiris.RegisterListener("TemplateAddedTo", 4, "after", EHandlers.OnTemplateAddedTo)
  end
end

return SubscribedEvents
