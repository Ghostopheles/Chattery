local L = {
	SETTING_SPLIT_MARKER_LABEL = "Маркер разделения",
	SETTING_SPLIT_MARKER_HINT = "Указывает, где сообщение было разделено",

	SETTING_SHOW_MESSAGE_INDEX_LABEL = "Показывать индекс сообщений",
	SETTING_SHOW_MESSAGE_INDEX_HINT = "Добавляет индекс в начало каждого сообщения",

	SETTING_HANDLE_RP_SYNTAX_LABEL = "Включить форматирование RP",
	SETTING_HANDLE_RP_SYNTAX_HINT = "Сохраняет форматирование и цвета RP между сообщениями",

	SETTING_HANDLE_NPC_SPEECH_LABEL = "Включить префикс NPC",
	SETTING_HANDLE_NPC_SPEECH_HINT = "Добавляет токен NPC к сообщениям при речи от имени NPC",

	SETTING_HANDLE_CAPITALIZATION_LABEL = "Автозаглавные буквы",
	SETTING_HANDLE_CAPITALIZATION_HINT = "Делает первую букву первого сообщения заглавной при необходимости",

	SETTING_HANDLE_PUNCTUATION_LABEL = "Автоматическая пунктуация",
	SETTING_HANDLE_PUNCTUATION_HINT = "Добавляет точку, если последнее сообщение не заканчивается знаком пунктуации",

	SETTING_ENABLE_UNDO_LABEL = "Включить отмену с Ctrl+Z",
	SETTING_ENABLE_UNDO_HINT = "Нажмите Ctrl+Z, чтобы восстановить удалённое или закрытое сообщение",

	NOTIF_HW_PROMPT = "Нажмите [Enter], чтобы продолжить",
	NOTIF_MSG_THROTTLED = "Сообщение ограничено",
	NOTIF_WAITING_FOR_THROTTLE = "Ожидание...",
};

------------

Chattery.Strings:Register(L);
