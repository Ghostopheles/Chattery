-- default locale

local L = {
	SETTING_SPLIT_MARKER_LABEL = "Split Marker",
	SETTING_SPLIT_MARKER_HINT = "Indicates where a message has been split",

	SETTING_SHOW_MESSAGE_INDEX_LABEL = "Show Message Index",
	SETTING_SHOW_MESSAGE_INDEX_HINT = "Prepends the message index to each message",

	SETTING_HANDLE_RP_SYNTAX_LABEL = "Enable RP Formatting",
	SETTING_HANDLE_RP_SYNTAX_HINT = "Preserves RP formatting and colors across messages",

	SETTING_HANDLE_NPC_SPEECH_LABEL = "Enable NPC Speech Prefix",
	SETTING_HANDLE_NPC_SPEECH_HINT = "Adds the NPC speech token to messages when speaking as an NPC",

	SETTING_HANDLE_CAPITALIZATION_LABEL = "Auto Capitalization",
	SETTING_HANDLE_CAPITALIZATION_HINT = "Capitalizes the first message if needed",

	SETTING_HANDLE_PUNCTUATION_LABEL = "Auto Punctuation",
	SETTING_HANDLE_PUNCTUATION_HINT = "Adds a period if the last message has no ending punctuation",

	SETTING_ENABLE_UNDO_LABEL = "Enable Undo with Ctrl+Z",
	SETTING_ENABLE_UNDO_HINT = "Press Ctrl+Z to restore a deleted or closed message",

	SETTING_SHOW_MINIMAP_BUTTON_LABEL = "Show Minimap Button",
	SETTING_SHOW_MINIMAP_BUTTON_HINT = "Show the Chattery minimap button",

	SETTING_SHOW_CHARACTER_COUNT_LABEL = "Show Message Character count",
	SETTING_SHOW_CHARACTER_COUNT_HINT = "Show the current and max message length on the chat editbox",

	NOTIF_HW_PROMPT = "Press [Enter] to continue",
	NOTIF_MSG_THROTTLED = "Message throttled",
	NOTIF_WAITING_FOR_THROTTLE = "Waiting...",

	MINIMAP_BUTTON_TOOLTIP_HELP_TEXT = "Left-click: Toggle settings frame\nShift-click: Hide this button"
};

------------

Chattery.Strings:Register(L);
