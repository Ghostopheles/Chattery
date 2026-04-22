local L = {
	SETTING_SPLIT_MARKER_LABEL = "분할 표시",
	SETTING_SPLIT_MARKER_HINT = "메시지가 분할된 위치를 표시합니다",

	SETTING_SHOW_MESSAGE_INDEX_LABEL = "메시지 인덱스 표시",
	SETTING_SHOW_MESSAGE_INDEX_HINT = "각 메시지 앞에 인덱스를 추가합니다",

	SETTING_HANDLE_RP_SYNTAX_LABEL = "RP 형식 활성화",
	SETTING_HANDLE_RP_SYNTAX_HINT = "메시지 간 RP 형식과 색상을 유지합니다",

	SETTING_HANDLE_NPC_SPEECH_LABEL = "NPC 접두사 활성화",
	SETTING_HANDLE_NPC_SPEECH_HINT = "NPC로 말할 때 메시지에 NPC 토큰을 추가합니다",

	SETTING_HANDLE_CAPITALIZATION_LABEL = "자동 대문자화",
	SETTING_HANDLE_CAPITALIZATION_HINT = "필요한 경우 첫 메시지를 대문자로 시작합니다",

	SETTING_HANDLE_PUNCTUATION_LABEL = "자동 구두점",
	SETTING_HANDLE_PUNCTUATION_HINT = "마지막 메시지에 문장부호가 없으면 마침표를 추가합니다",

	SETTING_ENABLE_UNDO_LABEL = "Ctrl+Z로 실행 취소 활성화",
	SETTING_ENABLE_UNDO_HINT = "Ctrl+Z를 눌러 삭제되거나 닫힌 메시지를 복원합니다",

	NOTIF_HW_PROMPT = "[Enter] 키를 눌러 계속",
	NOTIF_MSG_THROTTLED = "메시지 제한됨",
	NOTIF_WAITING_FOR_THROTTLE = "대기 중...",
};

------------

Chattery.Strings:Register(L);
