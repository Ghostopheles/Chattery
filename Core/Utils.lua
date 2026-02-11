---@class ChatteryUtils
local Utils = {};

function Utils.IsInCombatInstance()
    local inInstance, instanceType = IsInInstance();
    return inInstance and instanceType ~= "neighborhood" and instanceType ~= "interior";
end

function Utils.IsInChatLockdown()
    local isRestricted = C_ChatInfo.InChatMessagingLockdown();
    return isRestricted;
end

------------

Chattery.Utils = Utils;
