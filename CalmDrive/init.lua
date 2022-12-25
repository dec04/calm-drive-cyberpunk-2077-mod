local config = require("modules/config")
local GameUI = require("modules/GameUI")
local Cron = require("modules/Cron")

CalmDrive = {
    description = "Calm drive by Dec04",
    version = "0.0.1",
    strings = {
        configLocation = "config/config.json"
    },
    runtimeData = {
        inGame = false,
        inMenu = false
    },
    settings = {},
    defaultSettings = {
        global = {
            active = true
        },
        cars = {
            active = true
        },
        bikes = {
            active = true
        }
    },
    GameUI = require("modules/GameUI"),
    utils = require("modules/utils"),
    Cron = require("modules/Cron"),
    settingsUI = require("modules/settingsUI"),
    config = require("modules/config")
}

function CalmDrive:doMainStuff()
    if Game.GetQuestsSystem():GetFactStr("q001_wakeup_scene_done") == 1 then
        -- Do main stuff
    else
        self.runtimeData.addCron = self.Cron.Every(5, function()
            if Game.GetQuestsSystem():GetFactStr("q001_wakeup_scene_done") == 1 then
                -- Do main stuff
                self.Cron.Halt(self.runtimeData.addCron)
            end
        end)
    end
end

function CalmDrive:new()

    registerForEvent("onInit", function()
        -- Load config
        self.config.tryCreateConfig(self.strings.configLocation, self.defaultSettings)
        self.settings = self.config.loadFile(self.strings.configLocation)

        -- Create menu
        self.settingsUI.setupNativeUI(self)

        -- Setup observer and GameUI to detect inGame / inMenu
        Observe('RadialWheelController', 'OnIsInMenuChanged', function(_, isInMenu)
            self.runtimeData.inMenu = isInMenu
        end)

        self.GameUI.OnSessionStart(function()
            self.runtimeData.inGame = true

            self:doMainStuff()
        end)

        self.GameUI.OnSessionEnd(function()
            self.runtimeData.inGame = false
            -- Clear data
            self.Cron.StopAll()
        end)

        self.runtimeData.inGame = not self.GameUI.IsDetached() -- Required to check if ingame after reloading all mods

        self:doMainStuff()
    end)

    registerForEvent("onShutdown", function()
        -- Clear data
    end)

    registerForEvent("onUpdate", function(dt)
        if (not self.runtimeData.inMenu) and self.runtimeData.inGame then
            self.Cron.Update(dt)
        end
    end)

    return self

end

return CalmDrive:new()




