EHandlers = {}

function EHandlers.OnLevelGameplayStarted(levelName, isEditorMode)
    ISFDebug(2,
        "Entering OnLevelGameplayStarted, levelName: " .. levelName .. ", isEditorMode: " .. tostring(isEditorMode))

    -- Ignore Editor Mode
    if isEditorMode == true then
        return
    end

    -- Ignore Character Creation level
    if levelName == 'SYS_CC_I' then
        -- TODO: Set variable to deliver on Act 1
        return
    end

    -- Scan for mod JSON files to load
    ItemShipmentInstance:LoadShipments()

    local trigger = "SaveLoad"
    -- Add small delay to ensure camp chests are loaded and that notifications can be read by the player
    VCHelpers.Timer:OnTime(2500, function()
        ItemShipmentInstance:SetShipmentTrigger(trigger)
        -- Process shipments read from JSON files
        ItemShipmentInstance:ProcessShipments(false)
    end)
end

function EHandlers.OnUseStarted(character, item)
    -- VCHelpers.Object:DumpObjectEntity(item, "isf")
    -- local entity = Ext.Entity.Get(item):GetAllComponents()
    -- if entity.InventoryMember == nil then
    --   return
    -- end
    -- _D(Ext.Entity.Get(item):GetAllComponents().InventoryMember.Inventory.InventoryIsOwned.Owner:GetAllComponents())
end

local function UpdateModVars()
    local ISFModVars = Ext.Vars.GetModVariables(ModuleUUID)
    if ISFModVars then
        for varName, data in pairs(ISFModVars) do
            ISFModVars[varName] = ISFModVars[varName]
        end
        Ext.Vars.DirtyModVariables(ModuleUUID)
        Ext.Vars.SyncModVariables(ModuleUUID)
    end
end

function EHandlers.OnTemplateAddedTo(objectTemplate, object2, inventoryHolder)
    if objectTemplate ~= "CONT_ISF_Container_" .. ISMailboxes.MailboxTemplateUUID then
        return
    end

    local ISFModVars = Ext.Vars.GetModVariables(ModuleUUID)
    ISFDebug(2,
        "Entering OnTemplateAddedTo, objectTemplate: " ..
        objectTemplate .. ", object2: " .. object2 .. ", inventoryHolder: " .. inventoryHolder)
    ISFModVars.Mailboxes = ISFModVars.Mailboxes or {}
    Ext.Vars.SyncModVariables(ModuleUUID)

    local campChestName = VCHelpers.Format:GetTemplateName(inventoryHolder)
    if campChestName == nil then
        return
    end

    -- TODO: clean up this godawful mess
    local campChestIndex = VCHelpers.Camp:GetIndexFromCampChestName(campChestName)
    ISFModVars.Mailboxes[campChestIndex] = object2
    Ext.Vars.SyncModVariables(ModuleUUID)
    UpdateModVars()

    ISFDebug(2, "Mailboxes after initialization: " .. Ext.Json.Stringify(ISFModVars.Mailboxes), { Beautify = true })
end

function EHandlers.OnEndTheDayRequested(character)
    ISFDebug(2, "Entering OnEndTheDayRequested, character: " .. character)
    local trigger = "DayEnd"
    ItemShipmentInstance:SetShipmentTrigger(trigger)
    ItemShipmentInstance:ProcessShipments(false)
end

return EHandlers
