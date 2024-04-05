EHandlers = {}

EHandlers.moveItems = false

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
    -- _D(Ext.Template.GetAllLocalTemplates("813c005f-72ab-4806-ad7e-2e3135e41d27"))
    -- _D(VCHelpers.Inventory:GetInventory("813c005f-72ab-4806-ad7e-2e3135e41d27"))
    -- VCHelpers.Object:DumpObjectEntity(item, "isf")
    -- local entity = Ext.Entity.Get(item):GetAllComponents()
    -- if entity.InventoryMember == nil then
    --   return
    -- end
    -- _D(Ext.Entity.Get(item):GetAllComponents().InventoryMember.Inventory.InventoryIsOwned.Owner:GetAllComponents())
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
    VCHelpers.ModVars:Sync(ModuleUUID)

    local campChestName = VCHelpers.Format:GetTemplateName(inventoryHolder)
    if campChestName == nil then
        return
    end

    -- TODO: clean up this godawful mess
    local campChestIndex = VCHelpers.Camp:GetIndexFromCampChestName(campChestName)
    if campChestIndex == nil then
        ISFWarn(1, "Unexpected camp chest name: " .. campChestName)
        return
    end
    ISFModVars.Mailboxes[campChestIndex] = object2
    VCHelpers.ModVars:Sync(ModuleUUID)

    ISFDebug(2, "Mailboxes after initialization: " .. Ext.Json.Stringify(ISFModVars.Mailboxes), { Beautify = true })

    -- if campChestName ~= nil then
    --     ISFModVars.Mailboxes[campChestName] = object2
    --     VCHelpers.ModVars:Sync(ModuleUUID)
    --     ISFDebug(2, "Mailboxes after initialization: " .. Ext.Json.Stringify(ISFModVars.Mailboxes), { Beautify = true })
    -- end
end

function EHandlers.OnEndTheDayRequested(character)
    ISFDebug(2, "Entering OnEndTheDayRequested, character: " .. character)
    local trigger = "DayEnd"
    ItemShipmentInstance:SetShipmentTrigger(trigger)
    ItemShipmentInstance:ProcessShipments(false)
end

function EHandlers.OnReadyCheckFailed(eventId)
    ISFDebug(2,
        "Entering OnReadyCheckFailed, eventId: " .. eventId)

    if eventId == "isf_uninstall_move_items" then
        ISFDebug(1, "May uninstall ISF without moving items")
        EHandlers.moveItems = false
    end
end

function EHandlers.OnReadyCheckPassed(eventId)
    ISFDebug(2,
        "Entering OnReadyCheckPassed, eventId: " .. eventId)

    if eventId == "isf_uninstall_move_items" then
        EHandlers.moveItems = true
        DustyMessageBox('isf_uninstall_confirmation',
            "Are you sure you want to uninstall the mod?\nYou can instead disable it through its JSON configuration file, as explained in the mod page.\nYou are aware that reinstalling this mod later on may cause a minority of mods to resend their items.")
    elseif eventId == "isf_uninstall_confirmation" then
        ISFWarn(0, "Uninstalling Item Shipment Framework")
        -- TODO: implement this and modularize
        -- Step 1: Move all items from mailboxes to their camp chests
        -- Get all camp chests and their mailboxes
        local ISFModVars = Ext.Vars.GetModVariables(ModuleUUID)
        local campChestUUIDs = VCHelpers.Camp:GetAllCampChestUUIDs()

        -- Iterate mailboxes
        _D(ISFModVars.Mailboxes)
        for index, mailboxUUID in pairs(ISFModVars.Mailboxes) do
            _D(index, mailboxUUID)
            local campChestUUID = campChestUUIDs[index]
            ISFDebug(2, "Checking mailbox " .. mailboxUUID .. " in camp chest " .. campChestUUID)
            if campChestUUID then
                -- Move items from mailbox to camp chest
                -- Get items in mailbox
                if EHandlers.moveItems then
                    local mailboxItems = VCHelpers.Inventory:GetInventory(mailboxUUID, true, false)
                    for _, item in pairs(mailboxItems) do
                        -- Only move non-ISF items
                        if not string.match(item.TemplateName, "^ISF_") then
                            local amount, total = Osi.GetStackAmount(item.Guid)
                            Osi.ToInventory(item.Guid, campChestUUID, total, 0, 1)
                        end
                    end
                end

                ISFPrint(0, "Moved items from mailbox " .. mailboxUUID .. " to camp chest " .. campChestUUID)
            end

            VCHelpers.Timer:OnTime(2000, function()
                -- Delete mailbox
                Osi.RequestDelete(mailboxUUID)
                ISFPrint(0, "Deleted mailbox " .. mailboxUUID)
            end)
        end
        VCHelpers.Timer:OnTime(2000, function()
            ISFPrint(0,
                "Item Shipment Framework has been uninstalled.\nYou may now safely remove the mod from your load order.")
            Osi.OpenMessageBox(Osi.GetHostCharacter(),
                "Item Shipment Framework has been uninstalled.\nYou may now safely remove the mod from your load order.")
        end)
    end
end

return EHandlers
