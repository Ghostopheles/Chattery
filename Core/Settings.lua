local Events = Chattery.Events;
local Registry = Chattery.EventRegistry;

if not ChatteryConfig then
    ChatteryConfig = {};
end

---@class ChatterySettings
local ChatterySettings = {};

---@enum ChatterySetting
local Setting = {
    SplitMarker = "SplitMarker"
};
