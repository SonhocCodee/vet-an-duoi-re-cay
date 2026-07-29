class_name PixelNpcAnimation
extends AnimatedSprite2D

@export var npc_id: StringName

var _actor: CharacterBody2D
var _last_direction := Vector2.DOWN
var _action_until_msec := 0
var _base_position := Vector2(0.0, -22.0)
var _phase := 0.0


func _ready() -> void:
	_actor = get_parent() as CharacterBody2D
	_build_frames()
	if _actor != null and _actor.has_signal(&"interaction_requested"):
		_actor.connect(&"interaction_requested", _on_interaction_requested)
	if sprite_frames != null and sprite_frames.has_animation(&"idle_down"):
		play(&"idle_down")


func _process(delta: float) -> void:
	if _actor == null or sprite_frames == null:
		return
	_phase += delta
	var velocity_value := _actor.velocity
	if not velocity_value.is_zero_approx():
		_last_direction = velocity_value.normalized()
	var action_locked := Time.get_ticks_msec() < _action_until_msec
	var bob_amount := 1.0 if velocity_value.length() <= 2.0 else 2.0
	position = _base_position + Vector2(0.0, sin(_phase * (3.0 if velocity_value.length() <= 2.0 else 9.0)) * bob_amount)
	if action_locked:
		return
	var direction_name := _direction_name(_last_direction)
	var prefix := "walk" if velocity_value.length() > 2.0 else "idle"
	_play_if_changed(StringName("%s_%s" % [prefix, direction_name]))


func set_facing_direction(direction: Vector2) -> void:
	if direction.is_zero_approx():
		return
	_last_direction = direction.normalized()
	if Time.get_ticks_msec() >= _action_until_msec:
		_play_if_changed(StringName("idle_%s" % _direction_name(_last_direction)))


func play_action(action: StringName = &"interact", hold_seconds: float = 0.42) -> void:
	if sprite_frames == null:
		return
	var animation_name := StringName("%s_%s" % [String(action), _direction_name(_last_direction)])
	if not sprite_frames.has_animation(animation_name):
		return
	play(animation_name)
	_action_until_msec = Time.get_ticks_msec() + roundi(hold_seconds * 1000.0)


func play_hurt() -> void:
	play_action(&"hurt", 0.32)


func get_directional_animation() -> StringName:
	return animation


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
		_add_animation(frames, StringName("idle_%s" % direction), sheet, row, [0, 0, 0], 3.0, true)
		_add_animation(frames, StringName("walk_%s" % direction), sheet, row, [1, 0, 2, 0], 7.0, true)
		_add_animation(frames, StringName("interact_%s" % direction), sheet, row, [0, 1, 0], 8.0, false)
		_add_animation(frames, StringName("hurt_%s" % direction), sheet, row, [2, 0], 9.0, false)
	sprite_frames = frames
	_base_position = Vector2(0.0, -22.0)
	position = _base_position
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	visible = true


func _add_animation(frames: SpriteFrames, animation_name: StringName, sheet: Texture2D, row: int, columns: Array[int], speed: float, looped: bool) -> void:
	frames.add_animation(animation_name)
	frames.set_animation_loop(animation_name, looped)
	frames.set_animation_speed(animation_name, speed)
	for column: int in columns:
		frames.add_frame(animation_name, _atlas_frame(sheet, column, row))


func _atlas_frame(sheet: Texture2D, column: int, row: int) -> AtlasTexture:
	var frame := AtlasTexture.new()
	frame.atlas = sheet
	frame.region = Rect2(column * 32, row * 48, 32, 48)
	return frame


func _play_if_changed(next_animation: StringName) -> void:
	if sprite_frames.has_animation(next_animation) and animation != next_animation:
		play(next_animation)


func _on_interaction_requested(_npc: Node, _actor_node: Node) -> void:
	play_action(&"interact")


func _direction_name(direction: Vector2) -> String:
	if absf(direction.x) > absf(direction.y):
		return "right" if direction.x > 0.0 else "left"
	return "down" if direction.y >= 0.0 else "up"
