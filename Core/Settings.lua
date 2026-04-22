local Events = Chattery.Events;
local Registry = Chattery.EventRegistry;

---@class ChatterySettings
local ChatterySettings = {};

---@enum ChatterySetting
local Setting = {
    SplitMarker = "SplitMarker",
    ShowMessageIndex = "ShowMessageIndex",
    HandleRPSyntax = "HandleRPSyntax",
	HandleNPCSpeech = "HandleNPCSpeech",
	HandleCapitalization = "HandleCapitalization",
	HandlePunctuation = "HandlePunctuation"
};

local defaultConfig = {
    [Setting.SplitMarker] = "»",
    [Setting.ShowMessageIndex] = false,
    [Setting.HandleRPSyntax] = true,
	[Setting.HandleNPCSpeech] = true,
	[Setting.HandleCapitalization] = false,
	[Setting.HandlePunctuation] = false,
};

local configOrder = {
    Setting.SplitMarker,
    Setting.ShowMessageIndex,
    Setting.HandleRPSyntax,
	Setting.HandleNPCSpeech,
	Setting.HandleCapitalization,
	Setting.HandlePunctuation
};

local settingText = {
    [Setting.SplitMarker] = {
		Label = "Split Marker",
		Hint = "Marker used to indicate a message has been split"
	},
    [Setting.ShowMessageIndex] = {
		Label = "Show Message Index",
		Hint = "Prepend message index to each message"
	},
    [Setting.HandleRPSyntax] = {
		Label = "Handle RP Syntax",
		Hint = "Preserves text formatting and coloring for RP syntax"
	},
	[Setting.HandleNPCSpeech] = {
		Label = "Handle NPC Speech",
		Hint = "Prepends the NPC speech token to the beginning of each message when speaking as an NPC"
	},
	[Setting.HandleCapitalization] = {
		Label = "Auto-capitalize the start of the first message",
		Hint = "Capitalizes the beginning of your first message if it's not already capitalized"
	},
	[Setting.HandlePunctuation] = {
		Label = "Automatically add punctuation to the last message",
		Hint = "Adds a period to the end of your last message if there's no punctuation present"
	}
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
            text = settingText[setting],
        });
    end
    return settings;
end

------------

Chattery.Setting = Setting;
Chattery.Settings = ChatterySettings;
