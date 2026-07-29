class_name SecondWaveTextureLoader
extends RefCounted

static var _cache: Dictionary = {}


static func load_texture(resource_path: String, scale: float = 1.0) -> Texture2D:
	if _cache.has(resource_path):
		return _cache[resource_path] as Texture2D
	var texture: Texture2D
	if ResourceLoader.exists(resource_path):
		texture = ResourceLoader.load(resource_path) as Texture2D
	elif FileAccess.file_exists(resource_path) and resource_path.get_extension().to_lower() == "svg":
		var source := FileAccess.get_file_as_string(resource_path)
		var image := Image.new()
		var error := image.load_svg_from_string(source, scale)
		if error == OK:
			texture = ImageTexture.create_from_image(image)
	if texture != null:
		_cache[resource_path] = texture
	return texture


static func clear_cache() -> void:
	_cache.clear()
