ChatterySettingResetButtonMixin = {};

function ChatterySettingResetButtonMixin:OnEnter()
	self.Glow:Show();
	self.GlowAnim:Play();
	self.MouseoverAnim:Play();

	GameTooltip:SetOwner(self, "ANCHOR_TOP");
	GameTooltip:AddLine(RESET_TO_DEFAULT);
	GameTooltip:Show();
end

function ChatterySettingResetButtonMixin:OnLeave()
	self.Glow:Hide();
	self.GlowAnim:Stop();
	self.MouseoverAnim:Stop();
	GameTooltip:Hide();
end

function ChatterySettingResetButtonMixin:OnMouseDown()
	self.ClickAnim:Play();
end

function ChatterySettingResetButtonMixin:OnMouseUp()
	self.ClickAnim:Stop();
end

function ChatterySettingResetButtonMixin:OnClick()
	self:GetParent():OnResetButtonClick();
end

------------

ChatterySettingContainerMixin = {};

function ChatterySettingContainerMixin:OnLoad()
	Chattery.EventRegistry:RegisterCallback(Chattery.Events.SETTING_CHANGED, self.OnSettingChanged, self);
end

function ChatterySettingContainerMixin:OnShow()
    local startDelay = 0.085 + (0.035 * (self.OrderIndex - 1));
    C_Timer.After(startDelay, function()
        self.Anim:SlideInFromBottom();
    end);

	self:UpdateResetButtonVisibility();
end

function ChatterySettingContainerMixin:OnHide()
    self:SetAlpha(0);
end

function ChatterySettingContainerMixin:UpdateResetButtonVisibility()
	if not self.Control then
		return;
	end

	local setting = self.Control.Setting;
	local current = Chattery.Settings.GetSetting(setting);
	local default = Chattery.Settings.GetSettingDefault(setting);
	self.ResetButton:SetShown(current ~= default);
end

function ChatterySettingContainerMixin:OnResetButtonClick()
	if not self.Control then
		return;
	end

	local setting = self.Control.Setting;
	local default = Chattery.Settings.GetSettingDefault(setting);
	Chattery.Settings.SetSetting(setting, default);
end

function ChatterySettingContainerMixin:OnSettingChanged(setting)
	if setting == self.Control.Setting then
		self:UpdateResetButtonVisibility();
	end
end

------------

ChatterySettingControlMixin = {};

function ChatterySettingControlMixin:OnLoad()
	Chattery.EventRegistry:RegisterCallback(Chattery.Events.SETTING_CHANGED, self.OnSettingChanged, self);
end

function ChatterySettingControlMixin:OnShow()
    if not self.Setting then
        return;
    end

    self:UpdateValueFromSetting();
end

function ChatterySettingControlMixin:OnHide()
    if not self.Setting then
        return;
    end

    self:SyncValueToSetting();
end

function ChatterySettingControlMixin:SetValue(value)
    --- override deez
end

function ChatterySettingControlMixin:GetValue()
    --- override deez
end

---@param setting ChatterySetting
function ChatterySettingControlMixin:Bind(setting)
    self.Setting = setting;
end

function ChatterySettingControlMixin:Unbind()
    self.Setting = nil;
end

function ChatterySettingControlMixin:SyncValueToSetting()
    if not self.Setting or not self.Dirty then
        return;
    end

    Chattery.Settings.SetSetting(self.Setting, self:GetValue());
    self.Dirty = false;
end

function ChatterySettingControlMixin:UpdateValueFromSetting()
    if not self.Setting then
        return;
    end

    local value = Chattery.Settings.GetSetting(self.Setting);
    self:SetValue(value);
end

function ChatterySettingControlMixin:OnSettingChanged(setting)
	if setting == self.Setting and not self.Dirty then
		self:UpdateValueFromSetting();
	end
end

------------

ChatterySettingControlEditboxMixin = {};

function ChatterySettingControlEditboxMixin:OnTextChanged(userInput)
    if userInput then
        self.Dirty = true;
    end
end

function ChatterySettingControlEditboxMixin:OnEnterPressed()
    self:SyncValueToSetting();
end

function ChatterySettingControlEditboxMixin:SetValue(value)
    if self.TrimText then
        value = strtrim(value);
    end

    self:SetText(value);
end

function ChatterySettingControlEditboxMixin:GetValue()
    return self:GetText();
end

------------

ChatterySettingControlCheckboxMixin = {};

function ChatterySettingControlCheckboxMixin:OnClick()
    self.Dirty = true;
    self:SyncValueToSetting();
end

function ChatterySettingControlCheckboxMixin:SetValue(value)
    self:SetChecked(value);
end

function ChatterySettingControlCheckboxMixin:GetValue()
    return self:GetChecked();
end
