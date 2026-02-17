local Events = Chattery.Events;
local Registry = Chattery.EventRegistry;
local Chunker = Chattery.Chunker;
local Utils = Chattery.Utils;

local HARDWARE_INPUT = false;
local WAITING_FOR_HARDWARE_INPUT = false;

local MESSAGE_COUNTER = 0;
local HIDE_THROTTLE_MESSAGE = true; -- make this a setting probably

local THROTTLE_BYTES_PER_SECOND = 1000;
local THROTTLE_BURST_BYTES_PER_SECOND = 2000;
local TICK_PERIOD = 1;

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

function QueueHandler:Start(forceTick)
    if self.Running or #self.MessageQueue < 1 then
        return;
    end

	self.Waiting = false;
    self.Running = true;
    self.Ticker = C_Timer.NewTicker(TICK_PERIOD, function() self:Tick() end);

	if forceTick then
		self:Tick();
	end
end

function QueueHandler:Tick()
    if not self.Running or self.Waiting then
        return;
    end

    local entry = self.MessageQueue[1];
    if entry then
        local err = self:TrySendMessage(entry);
        if err == MESSAGE_SEND_ERR.SUCCESS then
			self:Wait();
        elseif err == MESSAGE_SEND_ERR.WAIT then
			self:Wait(true);
        elseif err == MESSAGE_SEND_ERR.PROMPT then
            Registry:TriggerEvent(Events.SHOW_HARDWARE_INPUT_PROMPT);
            self:Wait();
        end
    end

    if #self.MessageQueue == 0 then
        self:Stop();
    end
end

function QueueHandler:OnMessageSent()
	tremove(self.MessageQueue, 1);
	if WAITING_FOR_HARDWARE_INPUT then
		WAITING_FOR_HARDWARE_INPUT = false;
	end
	self.Waiting = false;
end

Registry:RegisterCallback(Events.MESSAGE_SENT, QueueHandler.OnMessageSent, QueueHandler);

function QueueHandler:Wait(throttle)
	self.Waiting = true;

	local timeout = throttle and 2 or 1;
	Registry:TriggerEvent(Events.SHOW_WAITING_MESSAGE, timeout * #self.MessageQueue);
	C_Timer.After(timeout, function() self:Start(true) end);
end

function QueueHandler:Resume()
	if not self.Running then
		return;
	end

	self.Waiting = false;
	self:Tick();
end

function QueueHandler:Stop()
    self.Running = false;
    self.Ticker:Cancel();
	Registry:TriggerEvent(Events.HIDE_HARDWARE_INPUT_PROMPT);
	Registry:TriggerEvent(Events.HIDE_WAITING_MESSAGE);
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
    return Utils.IsInOpenWorld() and HARDWARE_RESTRICTED_CHAT_TYPES[chatType];
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
		local bnetAccountID = BNet_GetBNetIDAccount(entry.Target);
		if bnetAccountID then
        	C_BattleNet.SendWhisper(bnetAccountID, entry.Message);
		end
    else
        C_ChatInfo.SendChatMessage(entry.Message, entry.ChatType, entry.LanguageOrClubID, entry.Target);
    end
	HARDWARE_INPUT = false;
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
    };

    tinsert(self.MessageQueue, msgEntry);
end

function QueueHandler:OnChatMessageReceived(_, playerName)
	if #self.MessageQueue < 1 or not self.Waiting then
		return;
	end

	local name, realm = UnitFullName("player");
	if playerName == format("%s-%s", name, realm) then
		Registry:TriggerEvent(Events.MESSAGE_SENT);
	end
end

------------

local events = {
	"CHAT_MSG_SAY",
	"CHAT_MSG_EMOTE",
	"CHAT_MSG_YELL",
	"CHAT_MSG_PARTY",
	"CHAT_MSG_PARTY_LEADER",
	"CHAT_MSG_RAID",
	"CHAT_MSG_RAID_LEADER",
	"CHAT_MSG_RAID_WARNING",
	"CHAT_MSG_INSTANCE_CHAT",
	"CHAT_MSG_INSTANCE_CHAT_LEADER"
};

local eventFrame = CreateFrame("Frame");
eventFrame:SetScript("OnEvent", function(self, event, ...)
	QueueHandler:OnChatMessageReceived(...);
end);

FrameUtil.RegisterFrameForEvents(eventFrame, events);

------------

ChatFrameUtil.AddMessageEventFilter("CHAT_MSG_SYSTEM", function(_, _, message)
    if message == ERR_CHAT_THROTTLED and QueueHandler.Running then
		QueueHandler:Wait(true);
        return HIDE_THROTTLE_MESSAGE;
    end
end);

------------

local CHAT_TYPE_TO_CHUNK_SIZE = Chattery.Constants.CHAT_TYPE_TO_CHUNK_SIZE;
local UNSUPPORTED_CHAT_TYPES = Chattery.Constants.UNSUPPORTED_CHAT_TYPES;

---@class ChatteryChatManager
local ChatManager = {};

function ChatManager.ShouldHandleChat(chatType)
    if UNSUPPORTED_CHAT_TYPES[chatType] or Utils.IsInChatLockdown() or InCombatLockdown() then
        return false;
    end

    return true;
end

function ChatManager.ContinueFromPrompt()
    HARDWARE_INPUT = true;

	Registry:TriggerEvent(Events.HIDE_HARDWARE_INPUT_PROMPT);
	QueueHandler:Resume();
end

local TARGET_EDIT_BOX, TEXT_BEFORE_PARSE;

---@param editBox EditBox
function ChatManager.OnEditBoxParseText(_, editBox)
    local message = editBox:GetText();
    if not message or message == "" then
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

    local chatTarget = editBox:GetTellTarget() or editBox:GetChannelTarget();
    if chatTarget == 0 then
        chatTarget = nil;
    end

    local language = editBox.languageID;

    local chunks = Chunker.SplitMessage(message, chunkSize);
    -- can just send the first chunk immediately by changing the editBox text
    editBox:SetText(chunks[1]);

	-- cancel out the hardware input flag since it'll be consumed before the queue starts queuing
	if QueueHandler:DoesChatTypeRequireHardwareInput(chatType) then
		HARDWARE_INPUT = false;
	end

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

EventRegistry:RegisterCallback("ChatFrame.OnEditBoxPreSendText", ChatManager.OnEditBoxParseText);

C_Timer.After(2, function()
    hooksecurefunc(ChatFrameUtil, "SubstituteChatMessageBeforeSend", ChatManager.OnSubstituteChatMessageBeforeSend);
end);

Chattery.QueueHandler = QueueHandler;
Chattery.ChatManager = ChatManager;
