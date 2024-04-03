---@class HelperISUtils: Helper
ISUtils = _Class:Create("HelperISUtils", Helper)

-- REVIEW: manage per-campaign; currently shares data across campaigns/save files I think (no, seems like it doesn't)
--- Initialize the mod vars for the mod, if they don't already exist. Might be redundant, but it's here for now.
---@param data table The item data to submit
---@param modGUID string The UUID of the mod that the item data belongs to
function ISUtils:InitializeModVarsForMod(data, modGUID)
    local ISFModVars = Ext.Vars.GetModVariables(ModuleUUID)

    -- Initialize Shipments table
    if not ISFModVars.Shipments then
        ISFModVars.Shipments = {}
    end
    -- Initialize the modGUID key in the Shipments table
    if not ISFModVars.Shipments[modGUID] then
        ISFModVars.Shipments[modGUID] = {}
    end
    -- For each TemplateUUID in the data, create a key in the mod table with a boolean value of false
    for _, item in pairs(data.Items) do
        ISFModVars.Shipments[modGUID][item.TemplateUUID] = false
    end

    -- Initialize Mailboxes table
    if not ISFModVars.Mailboxes then
        ISFModVars.Mailboxes = {
            ["1"] = nil,
            ["2"] = nil,
            ["3"] = nil,
            ["4"] = nil
        }
    end

    -- Sync the mod vars
    -- TODO: reduce the redundancy of these syncs
    if ISFModVars then
        for varName, data in pairs(ISFModVars) do
            ISFModVars[varName] = ISFModVars[varName]
        end
        Ext.Vars.DirtyModVariables(ModuleUUID)
        Ext.Vars.SyncModVariables(ModuleUUID)
    end
end

--- Notify the player that they have new items in their mailbox
---@param item table The item that was shipped
---@param modGUID string The UUID of the mod that shipped the item
function ISUtils:NotifyPlayer(item, modGUID)
    local isNotificationEnabled = config.FEATURES.notifications.enabled
    local shouldNotifyPlayer = item and item.Send.NotifyPlayer

    if not (isNotificationEnabled and shouldNotifyPlayer) then
        return
    end

    for index, chestUUID in pairs(VCHelpers.Camp:GetAllCampChestUUIDs()) do
        local isItemForThisChest = item.Send.To.CampChest[ISMailboxes.PlayerChestIndexMapping[index]]
        if isItemForThisChest then
            self:HandleNotifications(chestUUID, Ext.Mod.GetMod(modGUID).Info.Name)
        end
    end
end

--- Handle the notifications to be sent to the player
---@param chestUUID GUIDSTRING The UUID of the chest that the item was shipped to
---@param modName string The name of the mod that shipped the item
---@return nil
function ISUtils:HandleNotifications(chestUUID, modName)
    local config = Config:getCfg()

    if config.FEATURES.notifications.vfx then
        -- FIXME: only play once per shipment
        -- Osi.PlayEffect(Osi.GetHostCharacter(), "09ca988d-47dd-b10f-d8e4-b4744874a942")
    end

    -- Notify player that they have new items in their mailbox
    Messages.UpdateLocalizedMessage(Messages.Handles.mod_shipped_item_to_mailbox, modName)
    Osi.ShowNotification(Osi.GetHostCharacter(),
        Ext.Loca.GetTranslatedString(Messages.Handles.mod_shipped_item_to_mailbox))
    -- VCHelpers.Timer:OnTime(2500, function()
    --   Osi.ShowNotification(Osi.GetHostCharacter(),
    --     Ext.Loca.GetTranslatedString(Messages.Handles.mod_shipped_item_to_mailbox))
    -- end)

    if config.FEATURES.notifications.ping_chest then
        self:PingChest(chestUUID)
    end
end

-- TODO: move to VC
--- Ping a chest (actually, any object) and play an effect on it
---@param chestUUID GUIDSTRING The UUID of the chest
---@return nil
function ISUtils:PingChest(chestUUID)
    local chestPositionX, chestPositionY, chestPositionZ = Osi.GetPosition(chestUUID)
    -- FIXME: only play once per shipment
    if chestPositionX and chestPositionY and chestPositionZ then
        -- Osi.RequestPing(chestPositionX, chestPositionY, chestPositionZ, chestUUID, Osi.GetHostCharacter())
        -- Osi.PlayEffect(chestUUID, "00630e26-964d-c3e1-fcce-7f267c75e606")
    end
end
