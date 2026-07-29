class_name ArtTextureResolver
extends RefCounted

const SUPPORTED_EXTENSIONS: PackedStringArray = ["svg", "png", "webp", "jpg", "jpeg"]


static func load_texture(
	preferred_paths: PackedStringArray,
	directory_path: String = "",
	name_tokens: PackedStringArray = PackedStringArray()
) -> Texture2D:
	for path_value: String in preferred_paths:
		var texture: Texture2D = _load_texture_path(path_value)
		if texture != null:
			return texture
	if directory_path.is_empty() or not DirAccess.dir_exists_absolute(directory_path):
		return null
	var best_path: String = ""
	var best_score: int = 0
	for file_name: String in DirAccess.get_files_at(directory_path):
		if not _is_supported(file_name):
			continue
		var score: int = _match_score(file_name, name_tokens)
		if score > best_score:
			best_score = score
			best_path = directory_path.path_join(file_name)
	if best_path.is_empty():
		return null
	return _load_texture_path(best_path)


static func _load_texture_path(path_value: String) -> Texture2D:
	if path_value.is_empty() or not ResourceLoader.exists(path_value, "Texture2D"):
		return null
	return load(path_value) as Texture2D


static func _is_supported(file_name: String) -> bool:
	return file_name.get_extension().to_lower() in SUPPORTED_EXTENSIONS


static func _match_score(file_name: String, name_tokens: PackedStringArray) -> int:
	if name_tokens.is_empty():
		return 1
	var normalized_name: String = file_name.get_basename().to_lower()
	var score: int = 0
	for token: String in name_tokens:
		var normalized_token: String = token.strip_edges().to_lower()
		if not normalized_token.is_empty() and normalized_token in normalized_name:
			score += 1
	return score
