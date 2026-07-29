class_name AnimatedActorSprite
extends AnimatedSprite2D
const TextureLoader = preload("res://scripts/visuals/second_wave/second_wave_texture_loader.gd")


@export var actor_id: StringName
@export var asset_directory: String = "res://assets/art/player"
@export var frame_size: Vector2 = Vector2(96.0, 96.0)

var _controller: Node
var _last_facing := Vector2.DOWN
var _action_until_msec := 0
var _last_health := INF


func _ready() -> void:
	_controller = get_parent()
	_build_frames()
	play(&"idle_down")
	if _controller.has_signal(&"action_committed"):
		_controller.connect(&"action_committed", _on_action_committed)
	if _controller.has_signal(&"health_changed"):
		_controller.connect(&"health_changed", _on_health_changed)
	if visible:
		var legacy := _controller.get_node_or_null(^"PlayerVisual/Artwork") as CanvasItem
		if legacy != null:
			legacy.visible = false


func _process(_delta: float) -> void:
	if _controller == null:
		return
	if Time.get_ticks_msec() < _action_until_msec:
		return
	var velocity_value: Vector2 = _controller.get("velocity")
	var facing := velocity_value.normalized()
	if facing == Vector2.ZERO and _controller.has_method(&"get_facing_direction"):
		facing = _controller.call(&"get_facing_direction")
	if facing != Vector2.ZERO:
		_last_facing = facing
	var suffix := _direction_suffix(_last_facing)
	flip_h = suffix == "side" and _last_facing.x < 0.0
	var next_animation := StringName(("walk_" if velocity_value.length() > 2.0 else "idle_") + suffix)
	if sprite_frames != null and sprite_frames.has_animation(next_animation) and animation != next_animation:
		play(next_animation)


func play_action(action_id: StringName) -> void:
	if sprite_frames == null or not sprite_frames.has_animation(action_id):
		return
	play(action_id)
	_action_until_msec = Time.get_ticks_msec() + 360


func _on_action_committed(_action_id: StringName) -> void:
	play_action(&"interact")


func _on_health_changed(current: float, _maximum: float) -> void:
	if current < _last_health:
		play_action(&"hurt")
	_last_health = current


func _build_frames() -> void:
	var built := SpriteFrames.new()
	for animation_name: StringName in [&"idle_down", &"idle_up", &"idle_side", &"walk_down", &"walk_up", &"walk_side", &"interact", &"hurt"]:
		built.add_animation(animation_name)
		built.set_animation_loop(animation_name, animation_name not in [&"interact", &"hurt"])
		built.set_animation_speed(animation_name, 5.5 if String(animation_name).begins_with("walk") else 2.0)
	_add_single(built, &"idle_down", "idle_down")
	_add_single(built, &"idle_up", "idle_up")
	_add_single(built, &"idle_side", "idle_side")
	_add_pair(built, &"walk_down", "walk_down")
	_add_pair(built, &"walk_up", "walk_up")
	_add_pair(built, &"walk_side", "walk_side")
	_add_single(built, &"interact", "interact")
	_add_single(built, &"hurt", "hurt")
	sprite_frames = built
	centered = true
	position = Vector2(0.0, -16.0)
	var idle_texture := _load_texture("idle_down")
	if idle_texture != null and idle_texture.get_height() > 0:
		var scale_factor := frame_size.y / float(idle_texture.get_height())
		scale = Vector2(scale_factor, scale_factor)
	visible = idle_texture != null


func _add_single(frames: SpriteFrames, animation_name: StringName, suffix: String) -> void:
	var texture := _load_texture(suffix)
	if texture != null:
		frames.add_frame(animation_name, texture)


func _add_pair(frames: SpriteFrames, animation_name: StringName, suffix: String) -> void:
	for index: int in 2:
		var texture := _load_texture("%s_%d" % [suffix, index])
		if texture != null:
			frames.add_frame(animation_name, texture)


func _load_texture(suffix: String) -> Texture2D:
	var resource_path := "%s/%s_%s.svg" % [asset_directory, String(actor_id), suffix]
	return TextureLoader.load_texture(resource_path)


func _direction_suffix(direction: Vector2) -> String:
	if absf(direction.x) > absf(direction.y):
		return "side"
	return "up" if direction.y < 0.0 else "down"
