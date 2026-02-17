local Events = Chattery.Events;
local Registry = Chattery.EventRegistry;
local Constants = Chattery.Constants;

------------

local function UpdateNotificationFrameAnchors()
	ChatteryNotificationFrame:ClearAllPoints();
	ChatteryNotificationFrame:SetAllPoints(LAST_ACTIVE_CHAT_EDIT_BOX);
end

local function ShowNotificationFrame(...)
	UpdateNotificationFrameAnchors();
	ChatteryNotificationFrame:ShowNotification(...);
end

local function HideNotificationFrame(immediately)
	if immediately then
		ChatteryNotificationFrame:Hide();
	else
		ChatteryNotificationFrame:HideNotification();
	end
end

------------

local NOTIF_TYPE = Constants.NOTIFICATION_TYPE;

local NOTIF_TYPE_TO_MESSAGE = {
	[NOTIF_TYPE.HARDWARE_PROMPT] = "Press [Enter] to continue",
	[NOTIF_TYPE.MESSAGE_THROTTLED] = "Message throttled",
	[NOTIF_TYPE.WAITING_FOR_THROTTLE] = "Waiting...",
};

local NOTIF_TYPE_TO_COLOR = {
	[NOTIF_TYPE.HARDWARE_PROMPT] = RED_FONT_COLOR,
	[NOTIF_TYPE.MESSAGE_THROTTLED] = WARNING_FONT_COLOR,
	[NOTIF_TYPE.WAITING_FOR_THROTTLE] = WHITE_FONT_COLOR,
};

---@class ChatteryNotifications
local Notifications = {};

function Notifications.ShowNotification(notifType, duration)
	if ChatteryNotificationFrame:IsShown() then
		return;
	end

	if ACTIVE_CHAT_EDIT_BOX then
		ChatFrameUtil.DeactivateChat(ACTIVE_CHAT_EDIT_BOX);
	end

	local message = NOTIF_TYPE_TO_MESSAGE[notifType];
	if not message then
		return;
	end

	local color = NOTIF_TYPE_TO_COLOR[notifType];
	local showSpinner = notifType == NOTIF_TYPE.WAITING_FOR_THROTTLE;
	local hardwarePrompt = notifType == NOTIF_TYPE.HARDWARE_PROMPT;
	ShowNotificationFrame(message, color, showSpinner, hardwarePrompt, duration);
end

function Notifications.HideNotification(immediately)
	if not ChatteryNotificationFrame:IsShown() then
		return;
	end

	HideNotificationFrame(immediately);
end

function Notifications.OnShowHardwarePrompt()
	local notifType = NOTIF_TYPE.HARDWARE_PROMPT;
	Notifications.ShowNotification(notifType);
end

function Notifications.OnHideHardwarePrompt()
	Notifications.HideNotification();
end

function Notifications.OnShowWaitingMessage(_, duration)
	duration = duration or 5;

	local notifType = NOTIF_TYPE.WAITING_FOR_THROTTLE;
	Notifications.ShowNotification(notifType, duration);
end

function Notifications.OnHideWaitingMessage()
	Notifications.HideNotification();
end

Registry:RegisterCallback(Events.SHOW_HARDWARE_INPUT_PROMPT, Notifications.OnShowHardwarePrompt, Notifications);
Registry:RegisterCallback(Events.HIDE_HARDWARE_INPUT_PROMPT, Notifications.OnHideHardwarePrompt, Notifications);
Registry:RegisterCallback(Events.SHOW_WAITING_MESSAGE, Notifications.OnShowWaitingMessage, Notifications);
Registry:RegisterCallback(Events.HIDE_WAITING_MESSAGE, Notifications.OnHideWaitingMessage, Notifications);

------------

Chattery.Notifications = Notifications;
