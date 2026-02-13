local Events = Chattery.Events;
local Registry = Chattery.EventRegistry;
local Tokenizer = Chattery.Tokenizer;
local Utils = Chattery.Utils;

local HARDWARE_INPUT = false;
local WAITING_FOR_HARDWARE_INPUT = false;

local MESSAGE_COUNTER = 0;
local HIDE_THROTTLE_MESSAGE = true; -- make this a setting probably

local THROTTLE_BYTES_PER_SECOND = 1000;
local THROTTLE_BURST_BYTES_PER_SECOND = 2000;
local TICK_PERIOD = 0.25;

local BANDWIDTH = 0;
local BANDWIDTH_TIME = GetTime();

local BNET_CHAT_TYPE = "BN_WHISPER";

---@enum
local HARDWARE_RESTRICTED_CHAT_TYPES = {
    SAY = true,
    YELL = true,
    CHANNEL = true
};

---@enum
local MESSAGE_SEND_ERR = {
    SUCCESS = 1,
    WAIT = 2,
    PROMPT = 3
};

---@class ChatteryQueueHandler
local QueueHandler = {
    MessageQueue = {},
};

function QueueHandler:Start()
    if self.Running then
        return;
    end

    self.Running = true;
    self.Ticker = C_Timer.NewTicker(TICK_PERIOD, function() self:Tick() end, #self.MessageQueue);
end

function QueueHandler:Tick()
    if not self.Running then
        return;
    end

    local entry = self.MessageQueue[1];
    if entry then
        local err = self:TrySendMessage(entry);
        if err == MESSAGE_SEND_ERR.SUCCESS then
            tremove(self.MessageQueue, 1);
            HARDWARE_INPUT = false;
            if WAITING_FOR_HARDWARE_INPUT then
                Registry:TriggerEvent(Events.HIDE_HARDWARE_INPUT_PROMPT);
                WAITING_FOR_HARDWARE_INPUT = false;
            end
        elseif err == MESSAGE_SEND_ERR.WAIT then

        elseif err == MESSAGE_SEND_ERR.PROMPT then
            Registry:TriggerEvent(Events.SHOW_HARDWARE_INPUT_PROMPT);
            self:Stop();
        end
    end

    if #self.MessageQueue == 0 then
        self:Stop();
    end
end

function QueueHandler:Stop()
    self.Running = false;
    self.Ticker:Cancel();
end

function QueueHandler:UpdateBandwidth()
    local time = GetTime();
    if time == BANDWIDTH_TIME then
        return;
    end

    BANDWIDTH = min(BANDWIDTH + THROTTLE_BYTES_PER_SECOND * (time - BANDWIDTH_TIME), THROTTLE_BURST_BYTES_PER_SECOND);
    BANDWIDTH_TIME = time;
end

function QueueHandler:DoesChatTypeRequireHardwareInput(chatType)
    return Utils.IsInCombatInstance() and HARDWARE_RESTRICTED_CHAT_TYPES[chatType];

end

function QueueHandler:TrySendMessage(entry)
    self:UpdateBandwidth();

    if not HARDWARE_INPUT and self:DoesChatTypeRequireHardwareInput(entry.ChatType) then
        WAITING_FOR_HARDWARE_INPUT = true;
        return MESSAGE_SEND_ERR.PROMPT;
    end

    local messageSize = entry.Message:len();
    if messageSize > BANDWIDTH and BANDWIDTH < THROTTLE_BURST_BYTES_PER_SECOND then
        return MESSAGE_SEND_ERR.WAIT;
    end

    BANDWIDTH = BANDWIDTH - messageSize;

    if entry.ChatType == BNET_CHAT_TYPE then
        C_BattleNet.SendWhisper(entry.Target, entry.Message);
    else
        C_ChatInfo.SendChatMessage(entry.Message, entry.ChatType, entry.LanguageOrClubID, entry.Target);
    end
    Registry:TriggerEvent(Events.MESSAGE_SENT, entry);
    return MESSAGE_SEND_ERR.SUCCESS;
end

function QueueHandler:QueueMessage(message, chatType, languageOrClubID, target)
    MESSAGE_COUNTER = MESSAGE_COUNTER + 1;

    local msgEntry = {
        Message = message,
        ChatType = chatType,
        LanguageOrClubID = languageOrClubID,
        Target = target,
        ID = MESSAGE_COUNTER,
        Priority = 1 --TODO: implement
    };

    local idx = #self.MessageQueue + 1;
    for i, msg in ipairs(self.MessageQueue) do
        if msg.Priority > msgEntry.Priority then
            idx = i;
            break
        end
    end
    tinsert(self.MessageQueue, idx, msgEntry);
end

------------

ChatFrameUtil.AddMessageEventFilter("CHAT_MSG_SYSTEM", function(_, _, message)
    if HIDE_THROTTLE_MESSAGE and message == ERR_CHAT_THROTTLED then
        return true;
    end
end);

------------

---@enum
local CHUNK_SIZES = {
    Default = 255,
    Extended = 400
};

---@enum
local CHAT_TYPE_TO_CHUNK_SIZE = {
    SAY = CHUNK_SIZES.Default,
    EMOTE = CHUNK_SIZES.Default,
    YELL = CHUNK_SIZES.Default,
    CHANNEL = CHUNK_SIZES.Default,
    PARTY = CHUNK_SIZES.Default,
    RAID = CHUNK_SIZES.Default,
    RAID_WARNING = CHUNK_SIZES.Default,
    INSTANCE_CHAT = CHUNK_SIZES.Default,
    GUILD = CHUNK_SIZES.Default,
    OFFICER = CHUNK_SIZES.Default,
    WHISPER = CHUNK_SIZES.Default,
    VOICE_TEXT = CHUNK_SIZES.Default,
    BN_WHISPER = CHUNK_SIZES.Extended
};

---@enum
local UNSUPPORTED_CHAT_TYPES = {
    CHANNEL = true,
    VOICE_TEXT = true,
};

local MSG_PREFIX, MSG_SUFFIX = "", "";

local RP_SYNTAX_SPECIAL_CHARS = {
    ['"'] = true
};

---@class ChatteryChatManager
local ChatManager = {};

function ChatManager.GetPaddingText()
    return MSG_PREFIX, MSG_SUFFIX;
end

function ChatManager.SetPadding(prefix, suffix)
    if prefix then
        MSG_PREFIX = prefix;
    end

    if suffix then
        MSG_SUFFIX = suffix;
    end
end

function ChatManager.ShouldHandleChat(chatType)
    if UNSUPPORTED_CHAT_TYPES[chatType] or Utils.IsInChatLockdown() then
        return false;
    end

    return true;
end

function ChatManager.GetMessageSplitMarker()
    return Chattery.Settings.GetSetting(Chattery.Setting.SplitMarker);
end

function ChatManager.ShouldShowMessageIndex()
    return Chattery.Settings.GetSetting(Chattery.Setting.ShowMessageIndex);
end

function ChatManager.ShouldHandleRPSyntax()
    return Chattery.Settings.GetSetting(Chattery.Setting.HandleRPSyntax);
end

function ChatManager.SplitMessageByWords(message)
    local parts = {};

    for word, spaces in message:gmatch("(%S+)(%s*)") do
        tinsert(parts, word .. spaces);
    end

    return parts;
end

function ChatManager.SplitMessage(message, chunkSize)
    chunkSize = chunkSize or CHUNK_SIZES.Default;

    local prefix, suffix = ChatManager.GetPaddingText();
    local suffixSize = #suffix;

    local prefixes = {};
    local rawChunks = {};
    local current = "";

    local splitMarker = ChatManager.GetMessageSplitMarker();
    local handleRPSyntax = ChatManager.ShouldHandleRPSyntax();

    local function maxOverhead()
        local index = #rawChunks + 1;
        local newPrefix;
        if ChatManager.ShouldShowMessageIndex() then
            newPrefix = format("[%d] ", index);
        else
            newPrefix = prefix;
        end

        tinsert(prefixes, index, newPrefix);
        local paddingSize = #newPrefix + suffixSize + (2 * #splitMarker) + 1;
        return paddingSize;
    end

    local function usableLength()
        local overhead = maxOverhead();
        return chunkSize - overhead;
    end

    local in_rp_syntax_context;
    local rp_syntax_active_char;
    local rp_syntax_reopen_next;

    local function resetRPSyntaxState()
        in_rp_syntax_context = false;
        rp_syntax_active_char = nil;
        rp_syntax_reopen_next = nil;
    end

    local function updateRPSyntaxState(text)
        if not handleRPSyntax then
            return;
        end

        for i = 1, #text do
            local c = text:sub(i, i)

            if RP_SYNTAX_SPECIAL_CHARS[c] then
                if not in_rp_syntax_context then
                    in_rp_syntax_context = true;
                    rp_syntax_active_char = c;
                elseif rp_syntax_active_char == c then
                    in_rp_syntax_context = false;
                    rp_syntax_active_char = nil;
                end
            end
        end
    end

    local function flushRaw()
        if #current == 0 then
            return;
        end

        local out = current;

        if in_rp_syntax_context then
            out = strtrim(out, " ") .. rp_syntax_active_char;
            rp_syntax_reopen_next = rp_syntax_active_char;
        else
            resetRPSyntaxState();
        end

        tinsert(rawChunks, out);

        current = "";
    end

    local function appendText(part, isLink)
        if rp_syntax_reopen_next and #current == 0 then
            current = rp_syntax_reopen_next;
        end

        current = current .. part;
        if not isLink then
            updateRPSyntaxState(part);
        end
    end

    local tokens = Tokenizer:Tokenize(message);
    for _, token in ipairs(tokens) do
        local text = token.Value;
        if token.Type == Tokenizer.TOKEN_TYPE.Link then
            local _, _, displayText = LinkUtil.ExtractLink(text);
            local visibleLength = #displayText;
            if #current + visibleLength > usableLength() then
                flushRaw();
            end
            local isLink = true;
            appendText(text, isLink);
        else
            local parts = ChatManager.SplitMessageByWords(token.Value);
            for _, part in ipairs(parts) do
                local partLength = #part;
                if #current + partLength <= usableLength() then
                    appendText(part);
                else
                    flushRaw();
                    if partLength <= usableLength() then
                        appendText(part);
                    else
                        local pos = 1;
                        while pos <= #part do
                            local take = min(usableLength(), #part - pos + 1);
                            local newPart = part:sub(pos, pos + take - 1);
                            appendText(newPart);
                            flushRaw();
                            pos = pos + take;
                        end
                    end
                end
            end
        end
    end

    flushRaw();

    local finalChunks = {};
    local numFinalChunks = #rawChunks;

    for i, content in ipairs(rawChunks) do
        local startMarker = (i > 1) and (splitMarker .. " ") or "";
        local endMarker = (i < numFinalChunks) and splitMarker or "";

        if strbyte(content, -1) ~= 32 then
            content = content .. " ";
        end

        local chunk = prefixes[i] .. startMarker .. content .. endMarker .. suffix;
        tinsert(finalChunks, chunk);
    end

    return finalChunks;
end

function ChatManager.ContinueFromPrompt()
    HARDWARE_INPUT = true;
    QueueHandler:Start();
end

function ChatManager.GetBNetAccountIDForTarget(targetName)
    for i=1, BNGetNumFriends() do
        local accountInfo = C_BattleNet.GetFriendAccountInfo(i);
        if accountInfo and (accountInfo.accountName == targetName) then
            return accountInfo.bnetAccountID;
        end
    end
end

local TARGET_EDIT_BOX, TEXT_BEFORE_PARSE;

---@param editBox EditBox
---@param send number
function ChatManager.OnEditBoxParseText(editBox, send)
    local message = editBox:GetText();
    if not message or message == "" or send ~= 1 then
        return;
    end

    local chatType = ChatFrameUtil.GetActiveChatType();
    chatType = chatType and chatType:upper() or "SAY";

    local chunkSize = CHAT_TYPE_TO_CHUNK_SIZE[chatType];
    if not ChatManager.ShouldHandleChat(chatType) or message:len() < chunkSize then
        return;
    end

    -- it's chattery'ing time
    TARGET_EDIT_BOX = editBox;
    TEXT_BEFORE_PARSE = message;

    HARDWARE_INPUT = true;

    local chatTarget;
    if chatType == BNET_CHAT_TYPE then
        chatTarget = ChatManager.GetBNetAccountIDForTarget(chatTarget);
    else
        chatTarget = editBox:GetTellTarget() or editBox:GetChannelTarget();
        if chatTarget == 0 then
            chatTarget = nil;
        end
    end

    local language = editBox.languageID;

    local chunks = ChatManager.SplitMessage(message, chunkSize);
    -- can just send the first chunk immediately by changing the editBox text
    editBox:SetText(chunks[1]);
    for i = 2, #chunks do -- skipping first index because of above
        local chunk = chunks[i];
        QueueHandler:QueueMessage(chunk, chatType, language, chatTarget);
    end
    QueueHandler:Start();
end

function ChatManager.OnSubstituteChatMessageBeforeSend()
    if not (TARGET_EDIT_BOX and TEXT_BEFORE_PARSE) then
        return;
    end

    TARGET_EDIT_BOX:SetText(TEXT_BEFORE_PARSE);
    TARGET_EDIT_BOX = nil;
    TEXT_BEFORE_PARSE = nil;
end

------------

for i = 1, Constants.ChatFrameConstants.MaxChatWindows do
    local name = "ChatFrame" .. i .. "EditBox";
    hooksecurefunc(_G[name], "ParseText", ChatManager.OnEditBoxParseText);
end

hooksecurefunc(ChatFrameUtil, "SubstituteChatMessageBeforeSend", ChatManager.OnSubstituteChatMessageBeforeSend);


Chattery.QueueHandler = QueueHandler;
Chattery.ChatManager = ChatManager;
