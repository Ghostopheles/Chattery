local L = {
	SETTING_SPLIT_MARKER_LABEL = "Marqueur de séparation",
	SETTING_SPLIT_MARKER_HINT = "Indique où un message a été scindé",

	SETTING_SHOW_MESSAGE_INDEX_LABEL = "Afficher l'index des messages",
	SETTING_SHOW_MESSAGE_INDEX_HINT = "Ajoute l'index au début de chaque message",

	SETTING_HANDLE_RP_SYNTAX_LABEL = "Activer le format RP",
	SETTING_HANDLE_RP_SYNTAX_HINT = "Préserve le format et les couleurs RP entre les messages",

	SETTING_HANDLE_NPC_SPEECH_LABEL = "Activer le préfixe NPC",
	SETTING_HANDLE_NPC_SPEECH_HINT = "Ajoute le token NPC aux messages lorsque vous parlez en tant que NPC",

	SETTING_HANDLE_CAPITALIZATION_LABEL = "Capitalisation automatique",
	SETTING_HANDLE_CAPITALIZATION_HINT = "Met en majuscule le premier message si nécessaire",

	SETTING_HANDLE_PUNCTUATION_LABEL = "Ponctuation automatique",
	SETTING_HANDLE_PUNCTUATION_HINT = "Ajoute un point si le dernier message n'a pas de ponctuation finale",

	SETTING_ENABLE_UNDO_LABEL = "Activer l'annulation avec Ctrl+Z",
	SETTING_ENABLE_UNDO_HINT = "Appuyez sur Ctrl+Z pour restaurer un message supprimé ou fermé",

	NOTIF_HW_PROMPT = "Appuyez sur [Entrée] pour continuer",
	NOTIF_MSG_THROTTLED = "Message limité",
	NOTIF_WAITING_FOR_THROTTLE = "En attente...",
};

------------

Chattery.Strings:Register(L);
