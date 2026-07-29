class_name PixelPlayerAnimation
extends AnimatedSprite2D

var _controller: PlayerController
var _locked_action := false
var _last_health := INF
var _last_direction := Vector2.DOWN


func _ready() -> void:
	_controller = get_parent() as PlayerController
	animation_finished.connect(_on_animation_finished)
	if _controller != null:
		_controller.action_committed.connect(_on_action_committed)
		_controller.health_changed.connect(_on_health_changed)
		_last_health = _controller.get_health()
	play(&"idle_down")


func _process(_delta: float) -> void:
	if _controller == null or _locked_action:
		return
	var velocity_value := _controller.velocity
	var facing := _controller.get_facing_direction()
	if not velocity_value.is_zero_approx():
		facing = velocity_value.normalized()
	if not facing.is_zero_approx():
		_last_direction = facing
	var prefix := "walk" if velocity_value.length() > 3.0 else "idle"
	_play_if_changed(StringName("%s_%s" % [prefix, _direction_name(_last_direction)]))


func _on_action_committed(action_id: StringName) -> void:
	if _controller == null:
		return
	if action_id == &"attack" or action_id == &"combo_finisher" or action_id == &"skill_1":
		var direction := _controller.get_attack_direction() if _controller.has_method(&"get_attack_direction") else _controller.get_facing_direction()
		_last_direction = direction
		_locked_action = true
		play(StringName("attack_%s" % _direction_name(direction)))


func _on_health_changed(current: float, _maximum: float) -> void:
	if current < _last_health and current > 0.0:
		_locked_action = true
		play(StringName("hurt_%s" % _direction_name(_last_direction)))
	_last_health = current


func _on_animation_finished() -> void:
	if String(animation).begins_with("attack_") or String(animation).begins_with("hurt_"):
		_locked_action = false
		play(StringName("idle_%s" % _direction_name(_last_direction)))


func _play_if_changed(next_animation: StringName) -> void:
	if sprite_frames != null and sprite_frames.has_animation(next_animation) and animation != next_animation:
		play(next_animation)


func _direction_name(direction: Vector2) -> String:
	if absf(direction.x) > absf(direction.y):
		return "right" if direction.x > 0.0 else "left"
	return "down" if direction.y >= 0.0 else "up"
