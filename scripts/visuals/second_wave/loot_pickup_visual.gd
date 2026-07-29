class_name SecondWaveLootPickupVisual
extends Sprite2D
const TextureLoader = preload("res://scripts/visuals/second_wave/second_wave_texture_loader.gd")


@export var target_size := Vector2(42.0, 42.0)
var _origin_y := 0.0
var _elapsed := 0.0


func _ready() -> void:
	_origin_y = position.y
	var pickup := get_parent()
	var item_id := String(pickup.get("item_id"))
	var icon_path := "res://assets/art/items/%s.svg" % item_id
	texture = TextureLoader.load_texture(icon_path)
	if texture != null:
		if texture != null and texture.get_size().x > 0.0:
			scale = target_size / texture.get_size()


func _process(delta: float) -> void:
	_elapsed += delta
	position.y = _origin_y + sin(_elapsed * 3.2) * 4.0
	rotation = sin(_elapsed * 1.7) * 0.035
