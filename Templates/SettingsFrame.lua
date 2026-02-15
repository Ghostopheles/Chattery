local SETTING_TYPE_TO_CONTROL_TEMPLATE = {
    string = {
        name = "ChatterySettingControlEditboxTemplate",
        type = "EditBox"
    },
    boolean = {
        name = "ChatterySettingControlCheckboxTemplate",
        type = "CheckButton"
    }
};

------------

ChatterySettingsFrameMixin = {};

function ChatterySettingsFrameMixin:OnLoad()
    ButtonFrameTemplate_HidePortrait(self);

    tinsert(UISpecialFrames, self:GetName());

    local titleText = _G[self:GetName() .. "TitleText"];
    titleText:SetFontObject(GameFontWhite);

    local iconAtlas = C_AddOns.GetAddOnMetadata("Chattery", "IconAtlas");
    local atlasMarkup = CreateAtlasMarkup(iconAtlas, 16, 16);

    local name = Chattery.GetColoredAddonName();
    self:SetTitle(atlasMarkup .. " " .. name .. " Settings");

    self.CloseButton:SetScript("OnClick", function()
        self:ToggleShown();
    end);

    -- content layout stuff
    self.ContentInitialAnchor = AnchorUtil.CreateAnchor("TOPLEFT", self.Content, "TOPLEFT", 25, 0);

    local direction = GridLayoutMixin.Direction.BottomToTop;
    local stride = 20;
    local paddingX = 5;
    local paddingY = 5;
    self.ContentGridLayout = AnchorUtil.CreateGridLayout(direction, stride, paddingX, paddingY);

    self.Anim.HideOnAnimFinish = true;

    self:Setup();
end

function ChatterySettingsFrameMixin:ToggleShown()
    if self:IsShown() then
        self.Anim:SlideOutToBottom();
    else
        self.Anim:SlideInFromBottom();
    end
end

function ChatterySettingsFrameMixin:Setup()
    if self.IsSetup then
        return;
    end

    self.Controls = {};

    local function MakeContainer(labelText, control, index)
        local f = CreateFrame("Frame", nil, self.Content, "ChatterySettingContainerTemplate");
        f:SetAlpha(0);
        f:SetHeight(32);
        f:SetWidth(self:GetWidth() - 50);
        f.OrderIndex = index;

        local str = f:CreateFontString(nil, "ARTWORK", "GameFontWhite");
        str:SetPoint("LEFT", 5, 0);
        str:SetText(labelText);
        f.Label = str;

        control:SetParent(f);
        control:SetPoint("RIGHT", f, "RIGHT", -5, 0);
        f.Control = control;

        return f;
    end

    local allSettings = Chattery.Settings.GetAllSettings();
    for i, setting in ipairs(allSettings) do
        local template = SETTING_TYPE_TO_CONTROL_TEMPLATE[setting.type];

        local control = CreateFrame(template.type, nil, nil, template.name);
        control:Bind(setting.name);

        local container = MakeContainer(setting.label, control, i);
        tinsert(self.Controls, container);
    end

    AnchorUtil.GridLayout(self.Controls, self.ContentInitialAnchor, self.ContentGridLayout);

    self.IsSetup = true;
end

------------

function Chattery_ToggleSettingsFrame()
    ChatterySettingsFrame:ToggleShown();
end

SLASH_CHATTERY1 = "/chattery";
SlashCmdList["CHATTERY"] = Chattery_ToggleSettingsFrame;