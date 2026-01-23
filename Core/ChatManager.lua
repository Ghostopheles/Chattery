local Events = Chattery.Events;
local Registry = Chattery.EventRegistry;
local Tokenizer = Chattery.Tokenizer;

local _SendChatMessage = C_ChatInfo.SendChatMessage;
local _SendBNetWhisper = C_BattleNet.SendWhisper;

local HARDWARE_INPUT = false;
local WAITING_FOR_HARDWARE_INPUT = false;

local MESSAGE_COUNTER = 0;
local HIDE_THROTTLE_MESSAGE = true;

local SEND_FAILURES = {};
local MAX_RETRIES = 5;

local SEND_TIMEOUT = 10;

local THROTTLE_BYTES_PER_SECOND = 1000;
local THROTTLE_BURST_BYTES_PER_SECOND = 2000;
local TICK_PERIOD = 0.25;

local BANDWIDTH = 0;
local BANDWIDTH_TIME = GetTime();

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
    self:Tick();
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

function QueueHandler:TrySendMessage(entry)
    self:UpdateBandwidth();

    if not HARDWARE_INPUT and HARDWARE_RESTRICTED_CHAT_TYPES[entry.ChatType] then
        WAITING_FOR_HARDWARE_INPUT = true;
        return MESSAGE_SEND_ERR.PROMPT;
    end

    local messageSize = entry.Message:len();
    if messageSize > BANDWIDTH and BANDWIDTH < THROTTLE_BURST_BYTES_PER_SECOND then
        return MESSAGE_SEND_ERR.WAIT;
    end

    BANDWIDTH = BANDWIDTH - messageSize;

    if entry.ChatType == "BNET" then
        _SendBNetWhisper(entry.Target, entry.Message);
    else
        _SendChatMessage(entry.Message, entry.ChatType, entry.LanguageOrClubID, entry.Target);
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

local FRAME_EVENTS = {
    "CHAT_MSG_SAY",
    "CHAT_MSG_EMOTE",
    "CHAT_MSG_YELL",
    "CHAT_MSG_GUILD",
    "CHAT_MSG_OFFICER",
    "CHAT_MSG_COMMUNITIES_CHANNEL",
    "CLUB_MESSAGE_ADDED",
    "CLUB_ERROR",
    "CLUB_MESSAGE_UPDATED",
    "CHAT_MSG_BN_WHISPER_INFORM",
    "CHAT_MSG_BN_WHISPER_PLAYER_OFFLINE",
    "CHAT_MSG_SYSTEM",
};

local eventFrame = CreateFrame("Frame");
FrameUtil.RegisterFrameForEvents(eventFrame, FRAME_EVENTS);

ChatFrameUtil.AddMessageEventFilter("CHAT_MSG_SYSTEM", function(_, _, message)
    if HIDE_THROTTLE_MESSAGE and message == ERR_CHAT_THROTTLED then
        return true;
    end
end);

function eventFrame:OnEvent(event, ...)
    if self[event] then
        self[event](self, ...);
    end
end

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
    BNET = CHUNK_SIZES.Extended
};

---@enum
local UNSUPPORTED_CHAT_TYPES = {
    CHANNEL = true,
    VOICE_TEXT = true,
};

local RESTRICTIONS = {
    Enum.AddOnRestrictionType.Combat,
    Enum.AddOnRestrictionType.Encounter
};

---@enum
local AREA_CHAT_TYPES = {
    SAY = true,
    EMOTE = true,
    YELL = true
};

local MSG_SPLIT_MARKER = "»";
local MSG_PREFIX, MSG_SUFFIX = "", "";

local function IsString(str)
    return type(str) == "string";
end

---@class ChatteryChatManager
local ChatManager = {};

function ChatManager.GetPaddingSize()
    return IsString(MSG_PREFIX) and MSG_PREFIX:len() or 0, IsString(MSG_SUFFIX) and MSG_SUFFIX:len() or 0;
end

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
    if UNSUPPORTED_CHAT_TYPES[chatType] then
        return false;
    end

    if IsInInstance() then
        return false;
    end

    for _, restriction in pairs(RESTRICTIONS) do
        if C_RestrictedActions.IsAddOnRestrictionActive(restriction) then
            return false;
        end
    end

    return true;
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
    local prefixSize, suffixSize = ChatManager.GetPaddingSize();
    local totalPaddingSize = prefixSize + suffixSize;

    local maxOverhead = totalPaddingSize + (2 * MSG_SPLIT_MARKER:len()) + 2;
    local usableLength = chunkSize - maxOverhead;
    local rawChunks = {};
    local current = "";

    local function flushRaw()
        if current:len() > 0 then
            tinsert(rawChunks, current);
            current = ""
        end
    end

    local tokens = Tokenizer:Tokenize(message);
    for _, token in ipairs(tokens) do
        local text = token.Value;
        if token.Type == Tokenizer.TOKEN_TYPE.Link then
            local _, _, displayText = LinkUtil.ExtractLink(text);
            local visibleLength = displayText:len();
            if #current + visibleLength > usableLength then
                flushRaw();
            end
            current = current .. text;
        else
            local parts = ChatManager.SplitMessageByWords(token.Value);
            for _, part in ipairs(parts) do
                local partLength = part:len();
                if partLength <= usableLength - current:len() then
                    current = current .. part;
                else
                    flushRaw();
                    if partLength <= usableLength then
                        current = part;
                    else
                        local pos = 1;
                        while pos <= part:len() do
                            local take = min(usableLength, part:len() - pos + 1);
                            current = part:sub(pos, pos + take - 1);
                            pos = pos + take;
                            flushRaw();
                        end
                    end
                end
            end
        end
    end

    flushRaw();

    local finalChunks = {};
    local numChunks = #rawChunks;

    for i, content in ipairs(rawChunks) do
        local startMarker = (i > 1) and (MSG_SPLIT_MARKER .. " ") or "";
        local endMarker = (i < numChunks) and MSG_SPLIT_MARKER or "";

        if strbyte(content, -1) ~= 32 then
            content = content .. " ";
        end

        local chunk = tostring(i) .. startMarker .. content .. endMarker .. suffix;
        tinsert(finalChunks, chunk);
    end

    return finalChunks;
end

function ChatManager.ContinueFromPrompt()
    HARDWARE_INPUT = true;
    QueueHandler:Start();
end

---@param message string
---@param chatType SendChatMessageType | "BNET"?
---@param languageOrClubID number?
---@param targetOrChannel string?
function ChatManager.OnSendChatMessage(message, chatType, languageOrClubID, targetOrChannel)
    chatType = chatType and chatType:upper() or "SAY";

    if UnitIsDeadOrGhost("player") and AREA_CHAT_TYPES[chatType] then
        UIErrorsFrame:AddMessage(ERR_CHAT_WHILE_DEAD);
        return;
    end

    if message == "" then
        return;
    end

    local chunkSize = CHAT_TYPE_TO_CHUNK_SIZE[chatType];
    if not ChatManager.ShouldHandleChat(chatType) or message:len() < chunkSize then
        if chatType == "BNET" then
            _SendBNetWhisper(targetOrChannel, message);
        else
            _SendChatMessage(message, chatType, languageOrClubID, targetOrChannel);
        end
        return;
    end

    HARDWARE_INPUT = true;

    local chunks = ChatManager.SplitMessage(message, chunkSize);
    for _, chunk in ipairs(chunks) do
        QueueHandler:QueueMessage(chunk, chatType, languageOrClubID, targetOrChannel);
    end
    QueueHandler:Start();
end

function ChatManager.OnSendBattleNetWhisper(bnetAccountID, message)
    ChatManager.OnSendChatMessage(message, "BNET", nil, bnetAccountID);
end

C_ChatInfo.SendChatMessage = ChatManager.OnSendChatMessage;
C_BattleNet.SendWhisper = ChatManager.OnSendBattleNetWhisper;

------------

Chattery.QueueHandler = QueueHandler;
Chattery.ChatManager = ChatManager;
