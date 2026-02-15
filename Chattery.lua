local addonName = ...;
local Events, Registry, Utils;

local ADDON_COLOR = CreateColorFromHexString("ff5865F2");

------------

local HW_PROMPT_ACTIVE = false;

local prompt = RED_FONT_COLOR:WrapTextInColorCode("Press enter to send the next message");

local promptFrame = CreateFrame("Frame", nil, UIParent);
promptFrame:SetFrameStrata("FULLSCREEN_DIALOG");

local promptText = promptFrame:CreateFontString("ChatteryPromptString", "OVERLAY", "GameFontWhite");
promptText:SetAllPoints();
promptText:SetTextScale(1.5);
promptText:SetTextToFit(prompt);

local function ShowHardwarePrompt()
    promptFrame:ClearAllPoints();
    promptFrame:SetAllPoints(LAST_ACTIVE_CHAT_EDIT_BOX);
    promptFrame:Show();
end

local function HideHardwarePrompt()
    promptFrame:Hide();
end

------------

local EDITBOX_DEFAULTS = {};

---@class Chattery
Chattery = {};

function Chattery.Init()
	EventRegistry:RegisterCallback("ChatFrame.OnEditBoxShow", Chattery.OnEditBoxShow);
	EventRegistry:RegisterCallback("ChatFrame.OnEditBoxHide", Chattery.OnEditBoxHide);

    Events, Registry, Utils = Chattery.Events, Chattery.EventRegistry, Chattery.Utils;
    Registry:RegisterCallback(Events.SHOW_HARDWARE_INPUT_PROMPT, Chattery.PromptForHardwareInput);
    Registry:RegisterCallback(Events.HIDE_HARDWARE_INPUT_PROMPT, Chattery.HidePromptForHardwareInput);
end

function Chattery.ShouldHandleEditBox()
    return not Utils.IsInChatLockdown();
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

    editBox:SetMaxLetters(0);
    editBox:SetMaxBytes(0);
    editBox:SetVisibleTextByteLimit(0);
end

function Chattery.OnEditBoxHide()
    if HW_PROMPT_ACTIVE then
        Chattery.ChatManager.ContinueFromPrompt();
    end
end

EventUtil.ContinueOnAddOnLoaded("Chattery", Chattery.Init);

function Chattery.PromptForHardwareInput()
    if HW_PROMPT_ACTIVE then
        print("Chattery: There's a problem here and it's not properly handled, too bad!");
        Chattery.HidePromptForHardwareInput();
        return;
    end

    ShowHardwarePrompt();
    HW_PROMPT_ACTIVE = true;
end

function Chattery.HidePromptForHardwareInput()
    HideHardwarePrompt();
    HW_PROMPT_ACTIVE = false;
end

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
