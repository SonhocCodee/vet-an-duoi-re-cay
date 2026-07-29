extends Node

const SAVE_PATH_TEMPLATE: String = "user://save_%d.json"

func save_game(slot: int = 0) -> Error:
	var file: FileAccess = FileAccess.open(SAVE_PATH_TEMPLATE % maxi(slot, 0), FileAccess.WRITE)
	if file == null:
		return FileAccess.get_open_error()
	file.store_string(JSON.stringify(GameState.to_save_data(), "\t"))
	file.close()
	GameEvents.toast_requested.emit("Đã lưu hành trình.")
	return OK

func load_game(slot: int = 0) -> Error:
	var path: String = SAVE_PATH_TEMPLATE % maxi(slot, 0)
	if not FileAccess.file_exists(path):
		return ERR_FILE_NOT_FOUND
	var file: FileAccess = FileAccess.open(path, FileAccess.READ)
	if file == null:
		return FileAccess.get_open_error()
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	file.close()
	if parsed is not Dictionary:
		return ERR_PARSE_ERROR
	if not GameState.load_save_data(parsed):
		return ERR_INVALID_DATA
	GameEvents.map_change_requested.emit(GameState.current_map, GameState.current_spawn)
	GameEvents.toast_requested.emit("Đã tải hành trình.")
	return OK

func has_save(slot: int = 0) -> bool:
	return FileAccess.file_exists(SAVE_PATH_TEMPLATE % maxi(slot, 0))
