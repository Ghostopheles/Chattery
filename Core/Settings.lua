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

if not ChatteryConfig then
    ChatteryConfig = CopyTable(defaultConfig);
else
    for setting, value in pairs(defaultConfig) do
        if ChatteryConfig[setting] == nil then
            ChatteryConfig[setting] = value
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

------------

local SettingsFrame = CreateFrame("Frame", "ChatterySettingsFrame", UIParent, "PortraitFrameFlatTemplate");
SettingsFrame:SetSize(300, 400);
SettingsFrame:SetPoint("CENTER");
SettingsFrame:SetTitle("Chattery Settings");
SettingsFrame:SetMovable(true);
SettingsFrame:EnableMouse(true);
SettingsFrame:RegisterForDrag("LeftButton");
SettingsFrame:SetScript("OnDragStart", function(self)
    self:StartMoving();
end);
SettingsFrame:SetScript("OnDragStop", function(self)
    self:StopMovingOrSizing();
end);

tinsert(UISpecialFrames, SettingsFrame:GetName());

ButtonFrameTemplate_HidePortrait(SettingsFrame);

local function AddEditBoxForSetting(setting, displayText)
    local f = CreateFrame("Frame", nil, SettingsFrame);
    f:SetHeight(20);
    f:SetWidth(SettingsFrame:GetWidth() - 75);
    f.Setting = setting;

    local str = f:CreateFontString(nil, "ARTWORK");
    str:SetFontObject(GameFontWhite);
    str:SetPoint("LEFT");
    str:SetTextToFit(displayText);

    local eb = CreateFrame("EditBox", nil, f, "InputBoxTemplate");
    eb:SetPoint("TOPRIGHT");
    eb:SetSize(100, 20);
    eb:SetAutoFocus(false);
    eb:SetText(ChatterySettings.GetSetting(setting));
    eb:SetScript("OnEnterPressed", function()
        ChatterySettings.SetSetting(setting, eb:GetText());
    end);

    return f;
end

local function AddCheckboxForSetting(setting, displayText)
    local f = CreateFrame("Frame", nil, SettingsFrame);
    f:SetHeight(20);
    f:SetWidth(SettingsFrame:GetWidth() - 75);
    f.Setting = setting;

    local str = f:CreateFontString(nil, "ARTWORK");
    str:SetFontObject(GameFontWhite);
    str:SetPoint("LEFT");
    str:SetTextToFit(displayText);

    local cb = CreateFrame("CheckButton", nil, f, "UICheckButtonTemplate");
    cb:SetPoint("TOPRIGHT");
    cb:SetChecked(ChatterySettings.GetSetting(setting));
    cb:SetScript("OnClick", function()
        ChatterySettings.SetSetting(setting, cb:GetChecked());
    end);

    return f;
end

------
--- settings

local splitMarkerFrame = AddEditBoxForSetting(Setting.SplitMarker, "Split Marker");
splitMarkerFrame:SetPoint("TOP", SettingsFrame, "TOP", 0, -32);

local messageIndexFrame = AddCheckboxForSetting(Setting.ShowMessageIndex, "Show Message Index");
messageIndexFrame:SetPoint("TOP", splitMarkerFrame, "BOTTOM", 0, -8);

local handleRPSyntaxFrame = AddCheckboxForSetting(Setting.HandleRPSyntax, "Handle Special RP Syntax");
handleRPSyntaxFrame:SetPoint("TOP", messageIndexFrame, "BOTTOM", 0, -8);

------

SettingsFrame:Hide();

function Chattery_ToggleSettingsFrame()
    SettingsFrame:SetShown(not SettingsFrame:IsShown());
end

SLASH_CHATTERY1 = "/chattery";
SlashCmdList["CHATTERY"] = Chattery_ToggleSettingsFrame;

------------

Chattery.Setting = Setting;
Chattery.Settings = ChatterySettings;