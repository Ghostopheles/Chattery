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

	SETTING_HANDLE_CAPITALIZATION_LABEL = "Auto-capitalization",
	SETTING_HANDLE_CAPITALIZATION_HINT = "Capitalizes the first message if needed",

	SETTING_HANDLE_PUNCTUATION_LABEL = "Auto Punctuation",
	SETTING_HANDLE_PUNCTUATION_HINT = "Adds a period if the last message has no ending punctuation",

	SETTING_ENABLE_UNDO_LABEL = "Enable Undo with Ctrl+Z",
	SETTING_ENABLE_UNDO_HINT = "Press Ctrl+Z to restore a deleted or closed message",

	NOTIF_HW_PROMPT = "Press [Enter] to continue",
	NOTIF_MSG_THROTTLED = "Message throttled",
	NOTIF_WAITING_FOR_THROTTLE = "Waiting...",
};

------------

Chattery.Strings:Register(L);
