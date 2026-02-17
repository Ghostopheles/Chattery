ChatterySlideInAnimMixin = {};

function ChatterySlideInAnimMixin:OnLoad()
    self.AlphaAnim:SetTargetParent();
    self.TranslateAnim:SetTargetParent();
end

function ChatterySlideInAnimMixin:OnFinished()
    if not self.HideOnAnimFinish then
        return;
    end

    if self.Hiding then
        self:GetParent():Hide();
        self.Hiding = false;
    end
end

function ChatterySlideInAnimMixin:SetDuration(duration)
	self.AlphaAnim:SetDuration(duration);
	self.TranslateAnim:SetDuration(duration);
end

-- helpers

function ChatterySlideInAnimMixin:SlideInFromBottom(offsetX, offsetY)
    offsetX, offsetY = offsetX or 0, offsetY or -25;
    self.TranslateAnim:SetOffset(offsetX, offsetY);

    -- reversed
    self.AlphaAnim:SetFromAlpha(1);
    self.AlphaAnim:SetToAlpha(0);

    self:GetParent():Show();

    local reversed = true;
    self:Play(reversed);
end

function ChatterySlideInAnimMixin:SlideOutToBottom(offsetX, offsetY)
    offsetX, offsetY = offsetX or 0, offsetY or -25;
    self.TranslateAnim:SetOffset(offsetX, offsetY);

    self.AlphaAnim:SetFromAlpha(1);
    self.AlphaAnim:SetToAlpha(0);

    self:Play();
    self.Hiding = true;
end

function ChatterySlideInAnimMixin:SlideInFromLeft(offsetX, offsetY)
    offsetX, offsetY = offsetX or -25, offsetY or 0;
    self.TranslateAnim:SetOffset(offsetX, offsetY);

    -- reversed
    self.AlphaAnim:SetFromAlpha(1);
    self.AlphaAnim:SetToAlpha(0);

    self:GetParent():Show();

    local reversed = true;
    self:Play(reversed);
end

function ChatterySlideInAnimMixin:SlideOutToLeft(offsetX, offsetY)
    offsetX, offsetY = offsetX or -25, offsetY or 0;
    self.TranslateAnim:SetOffset(offsetX, offsetY);

    self.AlphaAnim:SetFromAlpha(1);
    self.AlphaAnim:SetToAlpha(0);

    self:Play();
	self.Hiding = true;
end

------------

ChatterySpinnerAnimMixin = {};

function ChatterySpinnerAnimMixin:OnLoad()
	self.Target = self:GetParent();
end

function ChatterySpinnerAnimMixin:OnUpdate()
	if not self:IsPlaying() then
		return;
	end

	local progress = self.RotationAnim:GetSmoothProgress();
	local degrees = self.RotationAnim:GetDegrees();
	self.Target:SetRotation(rad(degrees * progress));
end

function ChatterySpinnerAnimMixin:OnPlay()
	self.Target:SetRotation(0);
end
