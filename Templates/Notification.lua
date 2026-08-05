ChatteryNotificationFrameMixin = {};

function ChatteryNotificationFrameMixin:OnLoad()
	self.Anim.HideOnAnimFinish = true;
	self.Anim:SetDuration(0.15);
end

function ChatteryNotificationFrameMixin:OnHide()
	ClearOverrideBindings(self);
	self:ClearTimeout();
end

function ChatteryNotificationFrameMixin:ShowNotification(message, color, showSpinner, hardwarePrompt, duration)
	self.Text:SetText(message);
	self.Lines:SetVertexColor(color:GetRGBA());

	self.Anim:SlideInFromLeft();

	if showSpinner then
		self.Spinner:Show();
		self.Spinner.Anim:Play();
	else
		self.Spinner:Hide();
	end

	if duration then
		self:SetTimeout(duration);
	end

	if hardwarePrompt then
		SetOverrideBindingClick(self, true, "ENTER", "ChatteryHardwareButton");
	end
end

function ChatteryNotificationFrameMixin:HideNotification()
	self.Anim:SlideOutToLeft();
	self.Spinner.Anim:Stop();
end

function ChatteryNotificationFrameMixin:OnHardwareButtonClick()
	ClearOverrideBindings(self);
	Chattery.ChatManager.ContinueFromPrompt();
end

function ChatteryNotificationFrameMixin:SetTimeout(timeout)
	self.TimeoutCallback = C_FunctionContainers.CreateCallback(function() self:HideNotification() end);
	C_Timer.After(timeout, self.TimeoutCallback);
end

function ChatteryNotificationFrameMixin:ClearTimeout()
	if not self.TimeoutCallback then
		return;
	end

	if not self.TimeoutCallback:IsCancelled() then
		self.TimeoutCallback:Cancel();
	end

	self.TimeoutCallback = nil;
end
