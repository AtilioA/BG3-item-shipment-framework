Config = VCHelpers.Config:New({
    folderName = "AVItemShipmentFramework",
    configFilePath = "av_item_shipment_framework_config.json",
    defaultConfig = {
        GENERAL = {
            enabled = true,               -- Toggle the mod on/off
        },
        FEATURES = {                      -- Options that can override values set by mod authors
            shipment = {
                only_send_to_host = false -- Set to true to always and only send items to the host
            },
            notifications = {
                enabled = true,    -- Set to false to disable all item shipment notifications, regardless of mod author settings
                ping_chest = true, -- Set to false to disable the ping on chest upon item shipment
                vfx = true,        -- Set to false to disable the VFX on receiving items in the mailbox
            },
            spawning = {
                tutorial_chest = true,        -- Set to false to disable the tutorial chest integration
                allow_during_tutorial = true, -- Set to true to allow item spawning during the tutorial
            },
        },
        DEBUG = {
            level = 0 -- 0 = no debug, 1 = minimal, 2 = verbose debug logs
        },
        onConfigReloaded = {}
    }
})

Config:UpdateCurrentConfig()

-- Config:AddConfigReloadedCallback(function(configInstance)
--   ISFPrinter.DebugLevel = configInstance:GetCurrentDebugLevel()
--   ISFPrint(0, "Config reloaded: " .. Ext.Json.Stringify(configInstance:getCfg(), { Beautify = true }))
-- end)
-- Config:RegisterReloadConfigCommand("isf")
