local L = {
	SETTING_SPLIT_MARKER_LABEL = "Indicatore di divisione",
	SETTING_SPLIT_MARKER_HINT = "Indica dove un messaggio è stato diviso",

	SETTING_SHOW_MESSAGE_INDEX_LABEL = "Mostra indice messaggi",
	SETTING_SHOW_MESSAGE_INDEX_HINT = "Aggiunge l'indice all'inizio di ogni messaggio",

	SETTING_HANDLE_RP_SYNTAX_LABEL = "Abilita formattazione RP",
	SETTING_HANDLE_RP_SYNTAX_HINT = "Mantiene formattazione e colori RP tra i messaggi",

	SETTING_HANDLE_NPC_SPEECH_LABEL = "Abilita prefisso NPC",
	SETTING_HANDLE_NPC_SPEECH_HINT = "Aggiunge il token NPC ai messaggi quando si parla come NPC",

	SETTING_HANDLE_CAPITALIZATION_LABEL = "Maiuscole automatiche",
	SETTING_HANDLE_CAPITALIZATION_HINT = "Capitalizza il primo messaggio se necessario",

	SETTING_HANDLE_PUNCTUATION_LABEL = "Punteggiatura automatica",
	SETTING_HANDLE_PUNCTUATION_HINT = "Aggiunge un punto se l'ultimo messaggio non ha punteggiatura finale",

	SETTING_ENABLE_UNDO_LABEL = "Abilita annullamento con Ctrl+Z",
	SETTING_ENABLE_UNDO_HINT = "Premi Ctrl+Z per ripristinare un messaggio eliminato o chiuso",

	NOTIF_HW_PROMPT = "Premi [Invio] per continuare",
	NOTIF_MSG_THROTTLED = "Messaggio limitato",
	NOTIF_WAITING_FOR_THROTTLE = "In attesa...",
};

------------

Chattery.Strings:Register(L);
