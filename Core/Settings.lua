local Events = Chattery.Events;
local Registry = Chattery.EventRegistry;
local Strings = Chattery.Strings;

---@class ChatterySettings
local ChatterySettings = {};

---@enum ChatterySetting
local Setting = {
    SplitMarker = "SplitMarker",
    ShowMessageIndex = "ShowMessageIndex",
    HandleRPSyntax = "HandleRPSyntax",
	HandleNPCSpeech = "HandleNPCSpeech",
	HandleCapitalization = "HandleCapitalization",
	HandlePunctuation = "HandlePunctuation",
	EnableUndo = "EnableUndo"
};

local defaultConfig = {
    [Setting.SplitMarker] = "»",
    [Setting.ShowMessageIndex] = false,
    [Setting.HandleRPSyntax] = true,
	[Setting.HandleNPCSpeech] = true,
	[Setting.HandleCapitalization] = false,
	[Setting.HandlePunctuation] = false,
	[Setting.EnableUndo] = true
};

local configOrder = {
    Setting.SplitMarker,
    Setting.ShowMessageIndex,
    Setting.HandleRPSyntax,
	Setting.HandleNPCSpeech,
	Setting.HandleCapitalization,
	Setting.HandlePunctuation,
	Setting.EnableUndo
};

local settingText = {
    [Setting.SplitMarker] = {
		Label = Strings.SETTING_SPLIT_MARKER_LABEL,
		Hint = Strings.SETTING_SPLIT_MARKER_HINT
	},
    [Setting.ShowMessageIndex] = {
		Label = Strings.SETTING_SHOW_MESSAGE_INDEX_LABEL,
		Hint = Strings.SETTING_SHOW_MESSAGE_INDEX_HINT
	},
    [Setting.HandleRPSyntax] = {
		Label = Strings.SETTING_HANDLE_RP_SYNTAX_LABEL,
		Hint = Strings.SETTING_HANDLE_RP_SYNTAX_HINT
	},
	[Setting.HandleNPCSpeech] = {
		Label = Strings.SETTING_HANDLE_NPC_SPEECH_LABEL,
		Hint = Strings.SETTING_HANDLE_NPC_SPEECH_HINT
	},
	[Setting.HandleCapitalization] = {
		Label = Strings.SETTING_HANDLE_CAPITALIZATION_LABEL,
		Hint = Strings.SETTING_HANDLE_CAPITALIZATION_HINT
	},
	[Setting.HandlePunctuation] = {
		Label = Strings.SETTING_HANDLE_PUNCTUATION_LABEL,
		Hint = Strings.SETTING_HANDLE_PUNCTUATION_HINT
	},
	[Setting.EnableUndo] = {
		Label = Strings.SETTING_ENABLE_UNDO_LABEL,
		Hint = Strings.SETTING_ENABLE_UNDO_HINT
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
