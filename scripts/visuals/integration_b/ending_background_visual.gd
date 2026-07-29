class_name EndingBackgroundVisual
extends TextureRect

@export var art_paths: PackedStringArray
@export_dir var art_directory: String
@export var name_tokens: PackedStringArray


func _ready() -> void:
	var art_texture: Texture2D = ArtTextureResolver.load_texture(art_paths, art_directory, name_tokens)
	if art_texture != null:
		texture = art_texture
