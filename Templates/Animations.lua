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

-- helpers

function ChatterySlideInAnimMixin:SlideInFromBottom()
    local offsetX, offsetY = 0, -25;
    self.TranslateAnim:SetOffset(offsetX, offsetY);

    -- reversed
    self.AlphaAnim:SetFromAlpha(1);
    self.AlphaAnim:SetToAlpha(0);

    self:GetParent():Show();

    local reversed = true;
    self:Play(reversed);
end

function ChatterySlideInAnimMixin:SlideOutToBottom()
    local offsetX, offsetY = 0, -25;
    self.TranslateAnim:SetOffset(offsetX, offsetY);

    self.AlphaAnim:SetFromAlpha(1);
    self.AlphaAnim:SetToAlpha(0);

    self:Play();
    self.Hiding = true;
end