SubscribedEvents = {}

function SubscribedEvents.SubscribeToEvents()
  if Config:getCfg().GENERAL.enabled == true then
    Ext.Osiris.RegisterListener("LevelGameplayStarted", 2, "before", EHandlers.OnLevelGameplayStarted)
  end
end

return SubscribedEvents
