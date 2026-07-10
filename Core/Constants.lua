---@class ChatteryConstants
local ChatteryConstants = {};

---@enum ChatteryChunkSizes
ChatteryConstants.CHUNK_SIZES = {
    Default = 255,
    Extended = 400
};

---@enum ChatteryChatTypeToChunkSize
ChatteryConstants.CHAT_TYPE_TO_CHUNK_SIZE = {
    SAY = ChatteryConstants.CHUNK_SIZES.Default,
    EMOTE = ChatteryConstants.CHUNK_SIZES.Default,
    YELL = ChatteryConstants.CHUNK_SIZES.Default,
    CHANNEL = ChatteryConstants.CHUNK_SIZES.Default,
    PARTY = ChatteryConstants.CHUNK_SIZES.Default,
    RAID = ChatteryConstants.CHUNK_SIZES.Default,
    RAID_WARNING = ChatteryConstants.CHUNK_SIZES.Default,
    INSTANCE_CHAT = ChatteryConstants.CHUNK_SIZES.Default,
    GUILD = ChatteryConstants.CHUNK_SIZES.Default,
    OFFICER = ChatteryConstants.CHUNK_SIZES.Default,
    WHISPER = ChatteryConstants.CHUNK_SIZES.Default,
    VOICE_TEXT = ChatteryConstants.CHUNK_SIZES.Default,
    BN_WHISPER = ChatteryConstants.CHUNK_SIZES.Extended
};

---@enum ChatteryUnsupportedChatTypes
ChatteryConstants.UNSUPPORTED_CHAT_TYPES = {
    CHANNEL = true,
    VOICE_TEXT = true,
};

---@enum ChatteryNotificationType
ChatteryConstants.NOTIFICATION_TYPE = {
	HARDWARE_PROMPT = 1,
	WAITING_FOR_THROTTLE = 2,
	MESSAGE_THROTTLED = 3,
};

---@enum ChatteryNPCChatTypes
ChatteryConstants.NPC_CHAT_TYPES = {
	EMOTE = 1
};

---@enum ChatteryEditBoxLimits
ChatteryConstants.EDIT_BOX_LIMITS = {
	NONE = {
		MaxLetters = 0,
		MaxBytes = 0,
		MaxVisibleTextByteLimit = 0
	},
	DEFAULT = {
		MaxLetters = 255,
		MaxBytes = 1280,
		MaxVisibleTextByteLimit = 255
	},
};

---@enum ChatteryChatTypeToEditBoxLimits
ChatteryConstants.CHAT_TYPE_TO_EDIT_BOX_LIMITS = {
    SAY = ChatteryConstants.EDIT_BOX_LIMITS.NONE,
    EMOTE = ChatteryConstants.EDIT_BOX_LIMITS.NONE,
    YELL = ChatteryConstants.EDIT_BOX_LIMITS.NONE,
    CHANNEL = ChatteryConstants.EDIT_BOX_LIMITS.DEFAULT,
    PARTY = ChatteryConstants.EDIT_BOX_LIMITS.NONE,
    RAID = ChatteryConstants.EDIT_BOX_LIMITS.NONE,
    RAID_WARNING = ChatteryConstants.EDIT_BOX_LIMITS.NONE,
    INSTANCE_CHAT = ChatteryConstants.EDIT_BOX_LIMITS.NONE,
    GUILD = ChatteryConstants.EDIT_BOX_LIMITS.NONE,
    OFFICER = ChatteryConstants.EDIT_BOX_LIMITS.NONE,
    WHISPER = ChatteryConstants.EDIT_BOX_LIMITS.NONE,
    VOICE_TEXT = ChatteryConstants.EDIT_BOX_LIMITS.DEFAULT,
    BN_WHISPER = ChatteryConstants.EDIT_BOX_LIMITS.NONE
};

------------

Chattery.Constants = ChatteryConstants;
