local Events = Chattery.Events;
local Registry = Chattery.EventRegistry;

---@class ChatterySettings
local ChatterySettings = {};

---@enum ChatterySetting
local Setting = {
    SplitMarker = "SplitMarker",
    ShowMessageIndex = "ShowMessageIndex",
    HandleRPSyntax = "HandleRPSyntax"
};

local defaultConfig = {
    [Setting.SplitMarker] = "»",
    [Setting.ShowMessageIndex] = false,
    [Setting.HandleRPSyntax] = true,
};

local configOrder = {
    Setting.SplitMarker,
    Setting.ShowMessageIndex,
    Setting.HandleRPSyntax
};

local settingLabel = {
    [Setting.SplitMarker] = "Split Marker",
    [Setting.ShowMessageIndex] = "Show Message Index";
    [Setting.HandleRPSyntax] = "Handle RP Syntax";
};

if not ChatteryConfig then
    ChatteryConfig = CopyTable(defaultConfig);
else
    for setting, value in pairs(defaultConfig) do
        if ChatteryConfig[setting] == nil then
            ChatteryConfig[setting] = value;
        end
    end
end

------------

function ChatterySettings.GetSetting(setting)
    return ChatteryConfig[setting];
end

function ChatterySettings.SetSetting(setting, value)
    ChatteryConfig[setting] = value;
    Registry:TriggerEvent(Events.SETTING_CHANGED, setting, value);
end

function ChatterySettings.GetAllSettings()
    local settings = {};
    for _, setting in ipairs(configOrder) do
        local defaultValueType = type(defaultConfig[setting]);
        tinsert(settings, {
            name = setting,
            type = defaultValueType,
            label = settingLabel[setting]
        });
    end
    return settings;
end

------------

Chattery.Setting = Setting;
Chattery.Settings = ChatterySettings;