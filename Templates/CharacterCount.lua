local Registry = Chattery.EventRegistry;
local Events = Chattery.Events;
local Settings = Chattery.Settings;
local Setting = Chattery.Setting;

local HOOKED = {};

------------

ChatteryCharacterCountMixin = {};

function ChatteryCharacterCountMixin:OnLoad()
	Registry:RegisterCallback(Events.ACTIVE_CHAT_TYPE_CHANGED, self.OnActiveChatTypeChanged, self);
	Registry:RegisterCallback(Events.SETTING_CHANGED, self.OnSettingChanged, self);
end

function ChatteryCharacterCountMixin:OnSettingChanged(setting, newValue)
	if setting == Chattery.Setting.ShowCharacterCount then
		self:SetShown(newValue);
	end
end

function ChatteryCharacterCountMixin:OnEditBoxTextChanged(editBox)
	if not editBox:IsShown() then
		return;
	end

	local current = #editBox:GetText();
	self:UpdateCount(current, {
		MaxLetters = editBox:GetMaxLetters(),
		MaxBytes = editBox:GetMaxBytes(),
		MaxVisibleTextByteLimit = editBox:GetVisibleTextByteLimit()
	});
end

function ChatteryCharacterCountMixin:OnActiveChatTypeChanged(editBox, chatType)
	if not editBox or not editBox:IsShown() then
		return;
	end

	local l, r, t, b = editBox:GetTextInsets();
	r = r + self:GetWidth();
	editBox:SetTextInsets(l, r, t, b);
end

function ChatteryCharacterCountMixin:OnChatEditBoxLimitsChanged(editBox, newMax)
	local current = #editBox:GetText();
	self:UpdateCount(current, newMax);
end

function ChatteryCharacterCountMixin:UpdateCount(current, max)
	local text;
	if max.MaxLetters == 0 and max.MaxBytes == 0 then
		text = tostring(current);
	else
		text = format("%d/%d", current, max.MaxVisibleTextByteLimit);
	end

	self.Text:SetTextToFit(text);
end

function ChatteryCharacterCountMixin:AttachTo(editBox)
	if not HOOKED[editBox] then
		editBox:HookScript("OnTextChanged", function()
			if not editBox:IsShown() then
				return;
			end

			self:OnEditBoxTextChanged(editBox);
		end);
		HOOKED[editBox] = true;
	end

	self:ClearAllPoints();
	self:SetPoint("RIGHT", editBox, "RIGHT", -12, 0);
	self:SetParent(editBox);

	local enabled = Settings.GetSetting(Setting.ShowCharacterCount);
	self:SetShown(enabled);
end
