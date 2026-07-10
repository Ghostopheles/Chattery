---@class ChatteryEvents
local Events = {
    SHOW_HARDWARE_INPUT_PROMPT = "SHOW_HARDWARE_INPUT_PROMPT",
    HIDE_HARDWARE_INPUT_PROMPT = "HIDE_HARDWARE_INPUT_PROMPT",
	SHOW_WAITING_MESSAGE = "SHOW_WAITING_MESSAGE",
	HIDE_WAITING_MESSAGE = "HIDE_WAITING_MESSAGE",
    MESSAGE_SENT = "MESSAGE_SENT",
    SETTING_CHANGED = "SETTING_CHANGED",
	ACTIVE_CHAT_TYPE_CHANGED = "ACTIVE_CHAT_TYPE_CHANGED",
	CHAT_EDIT_BOX_LIMITS_CHANGED = "CHAT_EDIT_BOX_LIMITS_CHANGED"
};

---@class ChatteryEventRegistry : CallbackRegistryMixin
local Registry = CreateFromMixins(CallbackRegistryMixin);
Registry:OnLoad();
Registry:GenerateCallbackEvents(GetKeysArray(Events));

------------

Chattery.Events = Events;
Chattery.EventRegistry = Registry;
