ChatterySettingContainerMixin = {};

function ChatterySettingContainerMixin:OnShow()
    local startDelay = 0.085 + (0.035 * (self.OrderIndex - 1));
    C_Timer.After(startDelay, function()
        self.Anim:SlideInFromBottom();
    end);
end

function ChatterySettingContainerMixin:OnHide()
    self:SetAlpha(0);
end

------------

ChatterySettingControlMixin = {};

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
end

function ChatterySettingControlCheckboxMixin:SetValue(value)
    self:SetChecked(value);
end

function ChatterySettingControlCheckboxMixin:GetValue()
    return self:GetChecked();
end