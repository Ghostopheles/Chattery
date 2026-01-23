local Events, Registry;

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

local EDITBOXES;
local function GetRelevantEditBoxes()
    if EDITBOXES then
        return EDITBOXES;
    end

    EDITBOXES = {};
    for i=1, NUM_CHAT_WINDOWS do
        local name = format("ChatFrame%dEditBox", i);
        local eb = _G[name];
        if eb then
            tinsert(EDITBOXES, eb);
        end
    end

    return EDITBOXES;
end

local function HookEditBoxes(script, callback)
    local editBoxes = GetRelevantEditBoxes();
    for _, eb in pairs(editBoxes) do
        eb:HookScript(script, callback);
    end
end

------------

local EDITBOX_DEFAULTS = {};

---@class Chattery
Chattery = {};

function Chattery.Init()
    HookEditBoxes("OnShow", Chattery.OnEditBoxShow);
    HookEditBoxes("OnEnterPressed", Chattery.OnEditBoxEnterPressed);

    Events, Registry = Chattery.Events, Chattery.EventRegistry;
    Registry:RegisterCallback(Events.SHOW_HARDWARE_INPUT_PROMPT, Chattery.PromptForHardwareInput);
    Registry:RegisterCallback(Events.HIDE_HARDWARE_INPUT_PROMPT, Chattery.HidePromptForHardwareInput);
end

function Chattery.ShouldHandleEditBox()
    return not IsInInstance();
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
function Chattery.OnEditBoxShow(editBox)
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

function Chattery.OnEditBoxEnterPressed(editBox)
    if HW_PROMPT_ACTIVE then
        if ACTIVE_CHAT_EDIT_BOX == editBox then
            if editBox:GetText() ~= "/" then
                editBox:Hide();
            end
        end

        if CHAT_FOCUS_OVERRIDE then
            CHAT_FOCUS_OVERRIDE:ClearFocus();
        end

        Chattery.ChatManager.ContinueFromPrompt();
    end
end

EventUtil.ContinueOnAddOnLoaded("Chattery", Chattery.Init);

function Chattery.PromptForHardwareInput()
    ShowHardwarePrompt();
    HW_PROMPT_ACTIVE = true;
end

function Chattery.HidePromptForHardwareInput()
    HideHardwarePrompt();
    HW_PROMPT_ACTIVE = false;
end