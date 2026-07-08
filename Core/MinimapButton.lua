local addonName = ...;

local Events = Chattery.Events;
local Registry = Chattery.EventRegistry;
local Setting = Chattery.Setting;
local Settings = Chattery.Settings;
local Strings = Chattery.Strings;

------------

local TOOLTIP_TITLE_COLOR = Chattery.GetAddonColor();
local TOOLTIP_TITLE = TOOLTIP_TITLE_COLOR:WrapTextInColorCode(addonName);
local ADDON_VERSION = C_AddOns.GetAddOnMetadata(addonName, "Version");
ADDON_VERSION = WHITE_FONT_COLOR:WrapTextInColorCode(tostring(ADDON_VERSION));

local TOOLTIP_HELP_TEXT = GREEN_FONT_COLOR:WrapTextInColorCode(Strings.MINIMAP_BUTTON_TOOLTIP_HELP_TEXT);

---@param tooltip GameTooltip
local function OnMinimapButtonTooltipShow(tooltip)
	tooltip:AddDoubleLine(TOOLTIP_TITLE, ADDON_VERSION);
	tooltip:AddLine(TOOLTIP_HELP_TEXT);
end

local function OnMinimapButtonClick(_, button)
	if button ~= "LeftButton" then
		return;
	end

	if IsShiftKeyDown() then
		Settings.SetSetting(Setting.ShowMinimapButton, false);
	else
		Chattery_ToggleSettingsFrame();
	end
end

------------

local LibDataBroker = LibStub("LibDataBroker-1.1");
local LDB = LibDataBroker:NewDataObject(addonName, {
	type = "data source",
	icon = "Interface/ChatFrame/UIChatIcon",
	iconCoords = {
		0.53515625,
		0.66015625,
		0.00390625,
		0.12890625
	},
	OnClick = OnMinimapButtonClick,
	OnTooltipShow = OnMinimapButtonTooltipShow,
});

if not ChatteryConfig.Minimap then
	ChatteryConfig.Minimap = {
		hide = false,
	};
end

local button = LibStub("LibDBIcon-1.0");
button:Register(addonName, LDB, ChatteryConfig.Minimap);

local function OnSettingChanged(_, variable, value)
    if variable == Setting.ShowMinimapButton then
        ChatteryConfig.Minimap.hide = not value;
        button:Refresh(addonName, ChatteryConfig.Minimap);
    end
end

Registry:RegisterCallback(Events.SETTING_CHANGED, OnSettingChanged);
