---@class ChatteryEvents
local Events = {
    SHOW_HARDWARE_INPUT_PROMPT = "SHOW_HARDWARE_INPUT_PROMPT",
    HIDE_HARDWARE_INPUT_PROMPT = "HIDE_HARDWARE_INPUT_PROMPT",
    MESSAGE_SENT = "MESSAGE_SENT"
};

---@class ChatteryEventRegistry : CallbackRegistryMixin
local Registry = CreateFromMixins(CallbackRegistryMixin);
Registry:OnLoad();
Registry:GenerateCallbackEvents(GetKeysArray(Events));

------------

Chattery.Events = Events;
Chattery.EventRegistry = Registry;