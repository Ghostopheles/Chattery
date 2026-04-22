local mt = {
	__index = function(_, key)
		if Chattery.Debug then
			CallErrorHandler("Missing string for key: " .. key);
		end
		return key;
	end
};

local Strings = {};

---@param strings table<string, string>
function Strings:Register(strings)
	Mixin(Strings, strings);
end

Chattery.Strings = setmetatable(Strings, mt);
