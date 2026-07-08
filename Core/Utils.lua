---@class ChatteryUtils
local Utils = {};

function Utils.IsInOpenWorld()
    return not IsInInstance();
end

function Utils.IsInCombatInstance()
    local inInstance, instanceType = IsInInstance();
    return inInstance and instanceType ~= "neighborhood" and instanceType ~= "interior";
end

function Utils.IsInChatLockdown()
    local isRestricted = C_ChatInfo.InChatMessagingLockdown();
    return isRestricted;
end

function Utils.IsDelving()
	return select(4, GetInstanceInfo()) == "Delves";
end

function Utils.IsInGarrison()
	return C_Garrison.IsOnGarrisonMap() or C_Garrison.IsOnShipyardMap();
end

-- returns true if the user is in a situation in which /say (and friends) will require hardware input, probably
function Utils.IsInPrecariousSituation()
	return Utils.IsInOpenWorld() or (Utils.IsDelving() or Utils.IsInGarrison());
end

------------

Chattery.Utils = Utils;
