local addonName = ...;
local Utils;

local ADDON_COLOR = CreateColorFromHexString("ff5865F2");

------------

local EDITBOX_DEFAULTS = {};

---@class Chattery
Chattery = {};

function Chattery.Init()
	EventRegistry:RegisterCallback("ChatFrame.OnEditBoxShow", Chattery.OnEditBoxShow);

   Utils = Chattery.Utils;
end

function Chattery.ShouldHandleEditBox()
    return not InCombatLockdown() and not Utils.IsInChatLockdown();
end

function Chattery.SetEditBoxToDefaults(editBox)
    local defaults = EDITBOX_DEFAULTS[editBox];
    if not defaults then
        return;
    end

    editBox:SetMaxLetters(defaults.MaxLetters);
    editBox:SetMaxBytes(defaults.MaxBytes);
    editBox:SetVisibleTextByteLimit(defaults.VisibleTextByteLimit);
end

---@param editBox EditBox
function Chattery.OnEditBoxShow(_, editBox)
    if not Chattery.ShouldHandleEditBox() then
        Chattery.SetEditBoxToDefaults(editBox);
        return;
    end

	if not EDITBOX_DEFAULTS[editBox] then
        EDITBOX_DEFAULTS[editBox] = {
            MaxLetters = editBox:GetMaxLetters(),
            MaxBytes = editBox:GetMaxBytes(),
            VisibleTextByteLimit = editBox:GetVisibleTextByteLimit()
        };
    end

	if ChatteryNotificationFrame:IsShown() then
		ChatFrameUtil.DeactivateChat(editBox);
		return;
	end

    editBox:SetMaxLetters(0);
    editBox:SetMaxBytes(0);
    editBox:SetVisibleTextByteLimit(0);
end

EventUtil.ContinueOnAddOnLoaded("Chattery", Chattery.Init);

function Chattery.GetAddonColor()
    return ADDON_COLOR;
end

function Chattery.GetColoredAddonName()
    local color = Chattery.GetAddonColor();
    if not color then
        return addonName;
    end
    return color:WrapTextInColorCode(addonName);
end
