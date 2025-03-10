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

        -- TODO: Reintroduce this with container refills after SE updates with TreasureTable fixes
        if Config:getCfg().FEATURES.spawning.tutorial_chest and Config:getCfg().FEATURES.spawning.refill_tutorial_chest then
            ISMailboxes:RefillTutorialChestsInHostMailbox()
        end
    end)
end

function EHandlers.OnUserConnected(userID, userName, userProfileID)
    ISFDebug(2, "User connected: " .. userName .. ", ID: " .. userID .. ", profileID: " .. userProfileID)
    ISFPrint(1, "Reprocessing shipments due to user connection.")
    ItemShipmentInstance:LoadShipments()
    ItemShipmentInstance:ProcessShipments(false)
    -- TODO: Reintroduce this with container refills after SE updates with TreasureTable fixes
    if Config:getCfg().FEATURES.spawning.tutorial_chest and Config:getCfg().FEATURES.spawning.refill_tutorial_chest then
        ISMailboxes:RefillTutorialChestsInRemainingMailboxes()
        ISFDebug(1, "Updated remaining mailboxes with Tutorial Chests.")
    end
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

--- Used to catch the event when a mailbox is added to a camp chest, so that the mailbox can be stored in the ModVars
function EHandlers.OnTemplateAddedTo(objectTemplate, object2, inventoryHolder)
    if objectTemplate ~= "CONT_ISF_Container_" .. ISMailboxes.MailboxTemplateUUID then
        return
    end

    local ISFModVars = Ext.Vars.GetModVariables(ModuleUUID)
    ISFDebug(2,
        "Entering OnTemplateAddedTo, objectTemplate: " ..
        objectTemplate .. ", object2: " .. object2 .. ", inventoryHolder: " .. inventoryHolder)

    -- Ensure the Mailboxes table is initialized
    ISFModVars.Mailboxes = ISFModVars.Mailboxes or {}
    VCHelpers.ModVars:Sync(ModuleUUID)

    -- Get the camp chest name
    local campChestName = VCHelpers.Format:GetTemplateName(inventoryHolder)
    if campChestName == nil then
        return
    end

    -- Get the camp chest index
    local campChestIndex = VCHelpers.Camp:GetIndexFromCampChestName(campChestName)
    if campChestIndex == nil then
        ISFWarn(0, "Unexpected camp chest name: " .. campChestName)
        return
    end

    -- Store the mailbox UUID in the Mailboxes table
    ISFModVars.Mailboxes[campChestIndex] = object2
    VCHelpers.ModVars:Sync(ModuleUUID)

    ISFDebug(2, "Mailboxes after initialization: " .. Ext.Json.Stringify(ISFModVars.Mailboxes), { Beautify = true })

    -- Only integrate tutorial chests if it's the first camp chest. We don't need to preload the others since most users play 'offline'
    if campChestName == "CONT_PlayerCampChest_A" and Config:getCfg().FEATURES.spawning.tutorial_chest then
        ISMailboxes:IntegrateTutorialChest(object2)
    end

    -- Add utilities to the mailbox if it has been added only now
    ISMailboxes:InitializeUtilitiesCaseForMailbox(object2)
end

--- Used to handle DayEnd for ISF configs
function EHandlers.OnEndTheDayRequested(character)
    ISFDebug(2, "Entering OnEndTheDayRequested, character: " .. character)
    local trigger = "DayEnd"
    ItemShipmentInstance:SetShipmentTrigger(trigger)
    ItemShipmentInstance:ProcessShipments(false)
end

function EHandlers.OnReset()
    ISFDebug(1, "'reset' command was called in the SE console, reloading shipments.")
    ItemShipmentInstance:LoadShipments()
end

--- Handle the event when the player declines a ReadyCheck
function EHandlers.OnReadyCheckFailed(eventId)
    ISFDebug(2,
        "Entering OnReadyCheckFailed, eventId: " .. eventId)

    if eventId == "isf_uninstall_move_items" then
        ISFWarn(0, "May uninstall ISF without moving items")
        EHandlers.moveItems = false
        VCHelpers.MessageBox:DustyMessageBox('isf_uninstall_confirmation',
            Messages.ResolvedMessages.uninstall_confirmation_prompt)
    end
end

--- Handle the event when the player confirms a ReadyCheck
function EHandlers.OnReadyCheckPassed(eventId)
    ISFDebug(2,
        "Entering OnReadyCheckPassed, eventId: " .. eventId)

    if eventId == "isf_uninstall_move_items" then
        EHandlers.moveItems = true
        VCHelpers.MessageBox:DustyMessageBox('isf_uninstall_confirmation',
            Messages.ResolvedMessages.uninstall_confirmation_prompt)
    elseif eventId == "isf_uninstall_confirmation" then
        ISFWarn(0, "Uninstalling Item Shipment Framework")
        EHandlers.UninstallISF()
    elseif eventId == "ReadyCheckContent_GoToNight" then
        -- ReadyCheck for RequestGatherAtCampSuccess, used by the camp button and bonfire interaction
        local trigger = "DayEnd"
        ItemShipmentInstance:SetShipmentTrigger(trigger)
        ItemShipmentInstance:ProcessShipments(false)
    end
end

--- Handle the event when a spell is cast
function EHandlers.OnCastedSpell(caster, spell, spellType, spellElement, storyActionID)
    local ISFModVars = Ext.Vars.GetModVariables(ModuleUUID)
    ISFDebug(2,
        "CastedSpell: " .. caster .. " " .. spell .. " " .. spellType .. " " .. spellElement .. " " .. storyActionID)

    if Osi.IsInPartyWith(caster, Osi.GetHostCharacter()) then
        EHandlers.HandleCastedSpell(spell, ISFModVars)
    end
end

function EHandlers.HandleCastedSpell(spell, ISFModVars)
    if spell == "ISF_Refill_PlayerChest_1" then
        ISMailboxes:RefillMailbox(1, ISFModVars.Mailboxes[1])
    elseif spell == "ISF_Refill_PlayerChest_2" then
        ISMailboxes:RefillMailbox(2, ISFModVars.Mailboxes[2])
    elseif spell == "ISF_Refill_PlayerChest_3" then
        ISMailboxes:RefillMailbox(3, ISFModVars.Mailboxes[3])
    elseif spell == "ISF_Refill_PlayerChest_4" then
        ISMailboxes:RefillMailbox(4, ISFModVars.Mailboxes[4])
    elseif spell == "ISF_Reset_TutorialChest" then
        ISMailboxes:IntegrateTutorialChest(ISFModVars.Mailboxes[1])
    elseif spell == "ISF_Uninstall" then
        EHandlers.HandleUninstallSpell()
    end
end

function EHandlers.HandleUninstallSpell()
    VCHelpers.MessageBox:DustyMessageBox('isf_uninstall_move_items',
        Messages.ResolvedMessages.uninstall_should_move_out_of_mailboxes)
end

--- Uninstall ISF, moving all items from mailboxes to camp chests and deleting mailboxes
function EHandlers.UninstallISF()
    --- Open a message box to inform the player that the uninstallation is complete
    local function notifyUninstallComplete()
        VCHelpers.Timer:OnTime(1000, function()
            ISFPrint(0, Messages.ResolvedMessages.uninstall_completed)
            Osi.OpenMessageBox(Osi.GetHostCharacter(), Messages.ResolvedMessages.uninstall_completed)
        end)
    end

    -- Delete Tutorial Chest (not modded, but also not from the user)
    -- Even if spawning is disabled, because the user might have disabled it after it was created
    ISMailboxes:RemoveTutorialChestsFromAllMailboxes()

    -- Move all items from mailboxes to their camp chests (if enabled)
    if EHandlers.moveItems then
        ISMailboxes:MoveItemsFromMailboxesToCampChests()
    end

    -- Delete mailboxes (will include ISF items such as the scroll case)
    ISMailboxes:DeleteMailboxes()

    -- Delete all items with ISF in their template name from all camp chests and party members
    ItemShipmentInstance:DeleteAllISFItems()

    -- Notify the player that the uninstall is complete
    notifyUninstallComplete()
end

return EHandlers
