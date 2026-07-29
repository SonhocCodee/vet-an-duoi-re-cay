class_name PixelNpcAnimation
extends AnimatedSprite2D

@export var npc_id: StringName

var _actor: CharacterBody2D
var _last_direction := Vector2.DOWN


func _ready() -> void:
	_actor = get_parent() as CharacterBody2D
	_build_frames()
	if sprite_frames != null and sprite_frames.has_animation(&"idle_down"):
		play(&"idle_down")


func _process(_delta: float) -> void:
	if _actor == null or sprite_frames == null:
		return
	var velocity_value := _actor.velocity
	if not velocity_value.is_zero_approx():
		_last_direction = velocity_value.normalized()
	var direction_name := _direction_name(_last_direction)
	var prefix := "walk" if velocity_value.length() > 2.0 else "idle"
	var next_animation := StringName("%s_%s" % [prefix, direction_name])
	if animation != next_animation:
		play(next_animation)


func _build_frames() -> void:
	var texture_path := "res://assets/art/pixel/npcs/%s.png" % String(npc_id)
	var sheet := load(texture_path) as Texture2D if ResourceLoader.exists(texture_path) else null
	if sheet == null:
		visible = false
		return
	var frames := SpriteFrames.new()
	frames.remove_animation(&"default")
	var directions: PackedStringArray = ["down", "left", "right", "up"]
	for row in directions.size():
		var direction := directions[row]
		var idle_name := StringName("idle_%s" % direction)
		var walk_name := StringName("walk_%s" % direction)
		frames.add_animation(idle_name)
		frames.set_animation_loop(idle_name, true)
		frames.set_animation_speed(idle_name, 3.0)
		frames.add_frame(idle_name, _atlas_frame(sheet, 0, row))
		frames.add_animation(walk_name)
		frames.set_animation_loop(walk_name, true)
		frames.set_animation_speed(walk_name, 6.0)
		frames.add_frame(walk_name, _atlas_frame(sheet, 1, row))
		frames.add_frame(walk_name, _atlas_frame(sheet, 0, row))
		frames.add_frame(walk_name, _atlas_frame(sheet, 2, row))
		frames.add_frame(walk_name, _atlas_frame(sheet, 0, row))
	sprite_frames = frames
	position = Vector2(0.0, -22.0)
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	visible = true


func _atlas_frame(sheet: Texture2D, column: int, row: int) -> AtlasTexture:
	var frame := AtlasTexture.new()
	frame.atlas = sheet
	frame.region = Rect2(column * 32, row * 48, 32, 48)
	return frame


func _direction_name(direction: Vector2) -> String:
	if absf(direction.x) > absf(direction.y):
		return "right" if direction.x > 0.0 else "left"
	return "down" if direction.y >= 0.0 else "up"
