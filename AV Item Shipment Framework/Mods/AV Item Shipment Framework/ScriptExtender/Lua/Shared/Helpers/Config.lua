Config = VCHelpers.Config:New({
  folderName = "AVItemShipmentFramework",
  configFilePath = "av_item_shipment_framework_config.json",
  defaultConfig = {
    GENERAL = {
      enabled = true, -- Toggle the mod on/off
    },
    FEATURES = {

    },
    DEBUG = {
      level = 0 -- 0 = no debug, 1 = minimal, 2 = verbose debug logs
    }
  },
  onConfigReloaded = {}
})

Config:UpdateCurrentConfig()

-- Config:AddConfigReloadedCallback(function(configInstance)
--   ISFPrinter.DebugLevel = configInstance:GetCurrentDebugLevel()
--   ISFPrint(0, "Config reloaded: " .. Ext.Json.Stringify(configInstance:getCfg(), { Beautify = true }))
-- end)
-- Config:RegisterReloadConfigCommand("isf")
