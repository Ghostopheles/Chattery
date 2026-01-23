---@class ChatteryUtils
local Utils = {};

function Utils.IsInCombatInstance()
    local inInstance, instanceType = IsInInstance();
    return inInstance and instanceType ~= "neighborhood" and instanceType ~= "interior";
end

------------

Chattery.Utils = Utils;
