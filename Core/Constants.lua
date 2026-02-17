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

------------

Chattery.Constants = ChatteryConstants;
