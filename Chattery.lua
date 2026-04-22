local addonName = ...;
local Utils;

local ADDON_COLOR = CreateColorFromHexString("ff5865F2");

------------

local EDITBOX_DEFAULTS = {};
local UNDO_BUFFER = {};
local UNDO_HOOKED = {};

---@class Chattery
Chattery = {};

function Chattery.Init()
	EventRegistry:RegisterCallback("ChatFrame.OnEditBoxFocusGained", Chattery.OnEditBoxFocusGained);

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

local function ShouldHandleUndo()
	return Chattery.Settings.GetSetting(Chattery.Setting.EnableUndo);
end

local function HookEditBoxUndo(editBox)
    if UNDO_HOOKED[editBox] then
		return;
	end
    UNDO_HOOKED[editBox] = true;

    local prevText = "";

    editBox:HookScript("OnTextChanged", function(self, userInput)
        if not userInput or not ShouldHandleUndo() then
			return;
		end
        local current = self:GetText();
        if current == "" and prevText ~= "" then
            UNDO_BUFFER[self] = prevText;
        end
        prevText = current;
    end);

    editBox:HookScript("OnKeyDown", function(self, key)
		if not ShouldHandleUndo() then
			return;
		end
        if key == "Z" and IsControlKeyDown() and self:GetText() == "" then
            local buf = UNDO_BUFFER[self];
            if buf then
                self:SetText(buf);
                self:SetCursorPosition(#buf);
                UNDO_BUFFER[self] = nil;
            end
        end
    end);

	editBox:HookScript("OnEscapePressed", function(self)
		if not ShouldHandleUndo() then
			return;
		end
		local text = self:GetText();
		if #text > 0 then
			UNDO_BUFFER[self] = text;
		end
		prevText = "";
	end);
end

---@param editBox EditBox
function Chattery.OnEditBoxFocusGained(_, editBox)
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

	HookEditBoxUndo(editBox);

	if ChatteryNotificationFrame:IsShown() then
		editBox:Hide();
		return;
	end

    editBox:SetMaxLetters(0);
    editBox:SetMaxBytes(0);
    editBox:SetVisibleTextByteLimit(0);
end

EventUtil.ContinueOnAddOnLoaded(addonName, Chattery.Init);

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

--@alpha@
	Chattery.Debug = true;
--@end-alpha@
