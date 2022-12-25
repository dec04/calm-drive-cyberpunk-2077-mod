local config = require("modules/config")
local lang = require("modules/lang")

ui = {}

function ui.setupNativeUI(modInstance)
    local nativeSettings = GetMod("nativeSettings")

    if not nativeSettings then
        print("[CalmDrive] Error: NativeSettings lib not found!")
        return
    end

    local cetVer = tonumber((GetVersion():gsub('^v(%d+)%.(%d+)%.(%d+)(.*)', function(major, minor, patch, wip) -- <-- This has been made by psiberx, all credits to him
        return ('%d.%02d%02d%d'):format(major, minor, patch, (wip == '' and 0 or 1))
    end)))

    if cetVer < 1.18 then
        return
    end

    if not nativeSettings.pathExists("/calmDrive") then
        nativeSettings.addTab("/calmDrive", lang.getText("settingsTabName"), function()
        end)
    end

    nativeSettings.addSubcategory("/calmDrive/global", lang.getText("settingsSubCategoryTitleGlobal"))
    nativeSettings.addSubcategory("/calmDrive/cars", lang.getText("settingsSubCategoryTitleCars"))
    nativeSettings.addSubcategory("/calmDrive/bikes", lang.getText("settingsSubCategoryTitleBikes"))

    nativeSettings.addSwitch("/calmDrive/global", lang.getText("settingsSwitchTitleGlobal"), lang.getText("settingsSwitchDescriptionsGlobal"), modInstance.settings.global.active, modInstance.defaultSettings.global.active, function(state)
        modInstance.settings.global.active = state
        config.saveFile(modInstance.strings.configLocation, modInstance.settings)
    end)

    nativeSettings.addSwitch("/calmDrive/cars", lang.getText("settingsSwitchTitleCars"), lang.getText("settingsSwitchDescriptionsCars"), modInstance.settings.cars.active, modInstance.defaultSettings.cars.active, function(state)
        modInstance.settings.cars.active = state
        config.saveFile(modInstance.strings.configLocation, modInstance.settings)
    end)

    nativeSettings.addSwitch("/calmDrive/bikes", lang.getText("settingsSwitchTitleBikes"), lang.getText("settingsSwitchDescriptionsBikes"), modInstance.settings.bikes.active, modInstance.defaultSettings.bikes.active, function(state)
        modInstance.settings.bikes.active = state
        config.saveFile(modInstance.strings.configLocation, modInstance.settings)
    end)
end

return ui
