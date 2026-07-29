class_name CampaignBackdropVisual
extends Sprite2D

@export var art_paths: PackedStringArray
@export_dir var art_directory: String
@export var name_tokens: PackedStringArray
@export var fitted_size: Vector2 = Vector2.ZERO
@export var art_modulate: Color = Color.WHITE


func _ready() -> void:
	var art_texture: Texture2D = ArtTextureResolver.load_texture(art_paths, art_directory, name_tokens)
	if art_texture == null:
		return
	texture = art_texture
	modulate = art_modulate
	if fitted_size.x > 0.0 and fitted_size.y > 0.0:
		var texture_size: Vector2 = texture.get_size()
		if texture_size.x > 0.0 and texture_size.y > 0.0:
			scale = Vector2(fitted_size.x / texture_size.x, fitted_size.y / texture_size.y)
