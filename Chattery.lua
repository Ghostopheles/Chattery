local addonName = ...;
local Utils;

local ADDON_COLOR = CreateColorFromHexString("ff5865F2");

------------

local EDITBOX_DEFAULTS = {};
local UNDO_BUFFER = {};
local UNDO_HOOKED = {};

---@class Chattery
Chattery = {};

function Chattery.ShouldHandleEditBox()
    return not InCombatLockdown() and not Utils.IsInChatLockdown();
end

local function ShouldHandleUndo()
	return Chattery.Settings.GetSetting(Chattery.Setting.EnableUndo);
end

local function UpdateEditBoxLimits(editBox, chatType, newMax)
	chatType = chatType or editBox:GetChatType();
	newMax = newMax or Chattery.Constants.CHAT_TYPE_TO_EDIT_BOX_LIMITS[chatType];
	local oldMax = editBox:GetMaxBytes();
	if oldMax ~= newMax.MaxBytes then
		editBox:SetMaxLetters(newMax.MaxLetters);
		editBox:SetMaxBytes(newMax.MaxBytes);
		editBox:SetVisibleTextByteLimit(newMax.MaxVisibleTextByteLimit);
		Chattery.EventRegistry:TriggerEvent(Chattery.Events.CHAT_EDIT_BOX_LIMITS_CHANGED, editBox, newMax);
	end
end

local function HookEditBox(editBox)
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

	hooksecurefunc(editBox, "UpdateHeader", function()
		if not Chattery.ShouldHandleEditBox() or not editBox:IsShown() then
			return;
		end

		local chatType = editBox:GetChatType();
		Chattery.EventRegistry:TriggerEvent(Chattery.Events.ACTIVE_CHAT_TYPE_CHANGED, editBox, chatType);
	end);
end

---@param editBox EditBox
function Chattery.OnEditBoxFocusGained(_, editBox)
    if not Chattery.ShouldHandleEditBox() then
        Chattery.SetEditBoxToDefaults(editBox);
        return;
    end

	if ChatteryNotificationFrame:IsShown() then
		editBox.disableActivate = true;
		editBox:Hide();
		return;
	end

	if not EDITBOX_DEFAULTS[editBox] then
        EDITBOX_DEFAULTS[editBox] = {
            MaxLetters = editBox:GetMaxLetters(),
            MaxBytes = editBox:GetMaxBytes(),
            MaxVisibleTextByteLimit = editBox:GetVisibleTextByteLimit()
        };
    end

	HookEditBox(editBox);
    UpdateEditBoxLimits(editBox);
	ChatteryCharacterCountFrame:AttachTo(editBox);
end

function Chattery.SetEditBoxToDefaults(editBox)
    local defaults = EDITBOX_DEFAULTS[editBox];
    if not defaults then
        return;
    end

	UpdateEditBoxLimits(editBox, nil, defaults);
end

function Chattery.Init()
	EventRegistry:RegisterCallback("ChatFrame.OnEditBoxFocusGained", Chattery.OnEditBoxFocusGained);

	Utils = Chattery.Utils;

	local function OnMessageSent()
		if Chattery.QueueHandler.Running then
			return;
		end
		local editBox = ChatFrameUtil.GetLastActiveWindow();
		editBox.disableActivate = false;
	end

	Chattery.EventRegistry:RegisterCallback(Chattery.Events.MESSAGE_SENT, OnMessageSent);
	Chattery.EventRegistry:RegisterCallback(Chattery.Events.ACTIVE_CHAT_TYPE_CHANGED, function(_, editBox, chatType)
		UpdateEditBoxLimits(editBox, chatType);
	end);
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
