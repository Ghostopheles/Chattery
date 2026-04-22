local L = {
	SETTING_SPLIT_MARKER_LABEL = "Marcador de divisão",
	SETTING_SPLIT_MARKER_HINT = "Indica onde uma mensagem foi dividida",

	SETTING_SHOW_MESSAGE_INDEX_LABEL = "Mostrar índice de mensagens",
	SETTING_SHOW_MESSAGE_INDEX_HINT = "Adiciona o índice no início de cada mensagem",

	SETTING_HANDLE_RP_SYNTAX_LABEL = "Ativar formatação RP",
	SETTING_HANDLE_RP_SYNTAX_HINT = "Mantém a formatação e cores RP entre mensagens",

	SETTING_HANDLE_NPC_SPEECH_LABEL = "Ativar prefixo de NPC",
	SETTING_HANDLE_NPC_SPEECH_HINT = "Adiciona o token de NPC às mensagens ao falar como NPC",

	SETTING_HANDLE_CAPITALIZATION_LABEL = "Capitalização automática",
	SETTING_HANDLE_CAPITALIZATION_HINT = "Capitaliza a primeira mensagem se necessário",

	SETTING_HANDLE_PUNCTUATION_LABEL = "Pontuação automática",
	SETTING_HANDLE_PUNCTUATION_HINT = "Adiciona um ponto se a última mensagem não tiver pontuação final",

	SETTING_ENABLE_UNDO_LABEL = "Ativar desfazer com Ctrl+Z",
	SETTING_ENABLE_UNDO_HINT = "Pressione Ctrl+Z para restaurar uma mensagem excluída ou fechada",

	NOTIF_HW_PROMPT = "Pressione [Enter] para continuar",
	NOTIF_MSG_THROTTLED = "Mensagem limitada",
	NOTIF_WAITING_FOR_THROTTLE = "Aguardando...",
};

------------

Chattery.Strings:Register(L);
