--[[
    This file has code adapted from sources originally licensed under the MIT License. The terms of the MIT License are as follows:

    MIT License

    Copyright (c) 2023 BG3-Community-Library-Team

    Permission is hereby granted, free of charge, to any person obtaining a copy
    of this software and associated documentation files (the "Software"), to deal
    in the Software without restriction, including without limitation the rights
    to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
    copies of the Software, and to permit persons to whom the Software is
    furnished to do so, subject to the following conditions:

    The above copyright notice and this permission notice shall be included in all
    copies or substantial portions of the Software.

    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
    IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
    FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
    AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
    LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
    OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
    SOFTWARE.
--]]

---@class ItemShipment: MetaClass
ItemShipment = _Class:Create("ItemShipment", nil, {
  mods = {},
})
local configFilePathPattern = string.gsub("Mods/%s/ScriptExtender/ItemDeliveryFrameworkConfig.json", "'", "\'")

function ItemShipment:SubmitData(data, modGUID)
  self.mods[modGUID] = data
end

---@param configStr string
---@param modGUID GUIDSTRING
function ItemShipment:TryLoadConfig(configStr, modGUID)
  ISFDebug(2, "Entering TryLoadConfig")
  local success, data = pcall(function()
    return Ext.Json.Parse(configStr)
  end)
  if success then
    if data ~= nil then
      self:SubmitData(data, modGUID)
    end
  else
    ISFWarn(0, "Failed to parse config for mod: " .. Ext.Mod.GetMod(modGUID).Info.Name)
  end
end

function ItemShipment:LoadConfigFiles()
  ISFDebug(2, "Entering LoadConfigFiles")
  for _, uuid in pairs(Ext.Mod.GetLoadOrder()) do
    local modData = Ext.Mod.GetMod(uuid)
    local filePath = configFilePathPattern:format(modData.Info.Directory)

    local config = Ext.IO.LoadFile(filePath, "data")
    if config ~= nil and config ~= "" then
      ISFPrint(1, "Found config for mod: " .. Ext.Mod.GetMod(uuid).Info.Name)
      local success, err = xpcall(self.TryLoadConfig, debug.traceback, config, uuid)
      if not success then
        ISFWarn(0, err)
      end
    end
  end
end
