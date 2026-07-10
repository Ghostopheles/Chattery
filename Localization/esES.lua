local L = {
	SETTING_SPLIT_MARKER_LABEL = "Marcador de división",
	SETTING_SPLIT_MARKER_HINT = "Indica dónde se ha dividido un mensaje",

	SETTING_SHOW_MESSAGE_INDEX_LABEL = "Mostrar índice de mensajes",
	SETTING_SHOW_MESSAGE_INDEX_HINT = "Añade el índice al inicio de cada mensaje",

	SETTING_HANDLE_RP_SYNTAX_LABEL = "Activar formato RP",
	SETTING_HANDLE_RP_SYNTAX_HINT = "Mantiene el formato y los colores RP entre mensajes",

	SETTING_HANDLE_NPC_SPEECH_LABEL = "Activar prefijo de NPC",
	SETTING_HANDLE_NPC_SPEECH_HINT = "Añade el token de NPC a los mensajes al hablar como NPC",

	SETTING_HANDLE_CAPITALIZATION_LABEL = "Auto-capitalización",
	SETTING_HANDLE_CAPITALIZATION_HINT = "Capitaliza el primer mensaje si es necesario",

	SETTING_HANDLE_PUNCTUATION_LABEL = "Puntuación automática",
	SETTING_HANDLE_PUNCTUATION_HINT = "Añade un punto si el último mensaje no tiene puntuación final",

	SETTING_ENABLE_UNDO_LABEL = "Activar deshacer con Ctrl+Z",
	SETTING_ENABLE_UNDO_HINT = "Pulsa Ctrl+Z para restaurar un mensaje eliminado o cerrado",

	SETTING_SHOW_MINIMAP_BUTTON_LABEL = "Mostrar botón del minimapa",
	SETTING_SHOW_MINIMAP_BUTTON_HINT = "Muestra el botón de Chattery en el minimapa",

	SETTING_SHOW_CHARACTER_COUNT_LABEL = "Mostrar recuento de caracteres del mensaje",
	SETTING_SHOW_CHARACTER_COUNT_HINT = "Muestra la longitud actual y máxima del mensaje en el cuadro de chat",

	NOTIF_HW_PROMPT = "Pulsa [Enter] para continuar",
	NOTIF_MSG_THROTTLED = "Mensaje limitado",
	NOTIF_WAITING_FOR_THROTTLE = "Esperando...",

	MINIMAP_BUTTON_TOOLTIP_HELP_TEXT = "Clic izquierdo: Abrir/cerrar los ajustes\nMayús+clic: Ocultar este botón"
};

------------

Chattery.Strings:Register(L);
