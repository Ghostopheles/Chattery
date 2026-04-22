local L = {
	SETTING_SPLIT_MARKER_LABEL = "Trennmarkierung",
	SETTING_SPLIT_MARKER_HINT = "Zeigt an, wo eine Nachricht geteilt wurde",

	SETTING_SHOW_MESSAGE_INDEX_LABEL = "Nachrichtenindex anzeigen",
	SETTING_SHOW_MESSAGE_INDEX_HINT = "Stellt jeder Nachricht den Index voran",

	SETTING_HANDLE_RP_SYNTAX_LABEL = "RP-Formatierung aktivieren",
	SETTING_HANDLE_RP_SYNTAX_HINT = "Behält RP-Formatierung und Farben über Nachrichten hinweg bei",

	SETTING_HANDLE_NPC_SPEECH_LABEL = "NPC-Sprachpräfix aktivieren",
	SETTING_HANDLE_NPC_SPEECH_HINT = "Fügt Nachrichten ein NPC-Sprachtoken hinzu, wenn als NPC gesprochen wird",

	SETTING_HANDLE_CAPITALIZATION_LABEL = "Automatische Großschreibung",
	SETTING_HANDLE_CAPITALIZATION_HINT = "Schreibt den ersten Buchstaben der ersten Nachricht groß, falls nötig",

	SETTING_HANDLE_PUNCTUATION_LABEL = "Automatische Zeichensetzung",
	SETTING_HANDLE_PUNCTUATION_HINT = "Fügt einen Punkt hinzu, wenn die letzte Nachricht kein Satzzeichen hat",

	SETTING_ENABLE_UNDO_LABEL = "Rückgängig mit Strg+Z aktivieren",
	SETTING_ENABLE_UNDO_HINT = "Drücke Strg+Z, um eine gelöschte oder geschlossene Nachricht wiederherzustellen",

	NOTIF_HW_PROMPT = "Drücke [Enter], um fortzufahren",
	NOTIF_MSG_THROTTLED = "Nachricht gedrosselt",
	NOTIF_WAITING_FOR_THROTTLE = "Warten...",
};

------------

Chattery.Strings:Register(L);
