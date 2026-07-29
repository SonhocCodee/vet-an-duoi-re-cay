class_name PixelAnimationBridge
extends Node

signal animation_changed(animation_name: StringName)

@export var actor_path: NodePath = ^".."
@export var sprite_path: NodePath = ^"../AnimatedSprite2D"
@export_range(0.0, 32.0, 0.5) var moving_threshold: float = 2.0
@export_range(0.05, 2.0, 0.01) var action_hold_seconds: float = 0.28

var _actor: Node
var _sprite: AnimatedSprite2D
var _last_facing: Vector2 = Vector2.DOWN
var _locked_until_msec: int = 0
var _last_health: float = INF


func _ready() -> void:
	var actor_candidate := get_node_or_null(actor_path)
	var sprite_candidate := get_node_or_null(sprite_path)
	configure(actor_candidate, sprite_candidate as AnimatedSprite2D)


func _process(_delta: float) -> void:
	update_animation()


func configure(actor: Node, sprite: AnimatedSprite2D) -> bool:
	_disconnect_actor()
	_actor = actor
	_sprite = sprite
	if not is_instance_valid(_actor) or not is_instance_valid(_sprite):
		set_process(false)
		return false
	_connect_actor()
	set_process(true)
	update_animation(true)
	return true


func update_animation(force: bool = false) -> void:
	if not is_instance_valid(_actor) or not is_instance_valid(_sprite):
		return
	if not force and Time.get_ticks_msec() < _locked_until_msec:
		return
	var velocity := _read_velocity()
	var facing := _read_facing(velocity)
	if facing != Vector2.ZERO:
		_last_facing = facing.normalized()
	var suffix := _direction_suffix(_last_facing)
	var moving := velocity.length() > moving_threshold
	var candidates: Array[StringName] = []
	candidates.append(StringName(("walk_" if moving else "idle_") + suffix))
	if suffix == "side":
		candidates.append(StringName("walk_right" if moving else "idle_right"))
	candidates.append(&"walk" if moving else &"idle")
	_play_first_available(candidates, suffix == "side" and _last_facing.x < 0.0)


func play_action(action_id: StringName) -> bool:
	if not is_instance_valid(_sprite):
		return false
	var suffix := _direction_suffix(_last_facing)
	var base_name := _normalize_action(action_id)
	var candidates: Array[StringName] = [StringName(String(base_name) + "_" + suffix), base_name]
	var played := _play_first_available(candidates, suffix == "side" and _last_facing.x < 0.0)
	if played:
		_locked_until_msec = Time.get_ticks_msec() + roundi(action_hold_seconds * 1000.0)
	return played


func notify_hurt() -> void:
	play_action(&"hurt")


func notify_dead() -> void:
	_locked_until_msec = 2147483647
	_play_first_available([&"dead", &"hurt"], false)


func _read_velocity() -> Vector2:
	if _actor is CharacterBody2D:
		return (_actor as CharacterBody2D).velocity
	if _actor.has_method(&"get_animation_velocity"):
		var value: Variant = _actor.call(&"get_animation_velocity")
		return value as Vector2 if value is Vector2 else Vector2.ZERO
	if _actor.has_method(&"get_velocity"):
		var value: Variant = _actor.call(&"get_velocity")
		return value as Vector2 if value is Vector2 else Vector2.ZERO
	return Vector2.ZERO


func _read_facing(velocity: Vector2) -> Vector2:
	if velocity.length() > moving_threshold:
		return velocity
	if _actor.has_method(&"get_facing_direction"):
		var value: Variant = _actor.call(&"get_facing_direction")
		return value as Vector2 if value is Vector2 else _last_facing
	return _last_facing


func _normalize_action(action_id: StringName) -> StringName:
	var value := String(action_id).to_lower()
	if value.contains("attack") or value.contains("combo"):
		return &"attack"
	if value.contains("skill") or value.contains("cast"):
		return &"cast"
	if value.contains("dodge") or value.contains("roll"):
		return &"dodge"
	if value.contains("interact") or value.contains("use"):
		return &"interact"
	return action_id


func _play_first_available(candidates: Array[StringName], flip: bool) -> bool:
	if _sprite.sprite_frames == null:
		return false
	for candidate: StringName in candidates:
		if not _sprite.sprite_frames.has_animation(candidate):
			continue
		_sprite.flip_h = flip
		if _sprite.animation != candidate or not _sprite.is_playing():
			_sprite.play(candidate)
		animation_changed.emit(candidate)
		return true
	return false


func _direction_suffix(direction: Vector2) -> String:
	if absf(direction.x) > absf(direction.y):
		return "side"
	return "up" if direction.y < 0.0 else "down"


func _connect_actor() -> void:
	if _actor.has_signal(&"action_committed") and not _actor.is_connected(&"action_committed", _on_action_committed):
		_actor.connect(&"action_committed", _on_action_committed)
	if _actor.has_signal(&"health_changed") and not _actor.is_connected(&"health_changed", _on_health_changed):
		_actor.connect(&"health_changed", _on_health_changed)
	if _actor.has_signal(&"died") and not _actor.is_connected(&"died", notify_dead):
		_actor.connect(&"died", notify_dead)


func _disconnect_actor() -> void:
	if not is_instance_valid(_actor):
		return
	if _actor.has_signal(&"action_committed") and _actor.is_connected(&"action_committed", _on_action_committed):
		_actor.disconnect(&"action_committed", _on_action_committed)
	if _actor.has_signal(&"health_changed") and _actor.is_connected(&"health_changed", _on_health_changed):
		_actor.disconnect(&"health_changed", _on_health_changed)
	if _actor.has_signal(&"died") and _actor.is_connected(&"died", notify_dead):
		_actor.disconnect(&"died", notify_dead)


func _on_action_committed(action_id: StringName) -> void:
	play_action(action_id)


func _on_health_changed(current: float, _maximum: float) -> void:
	if current < _last_health:
		notify_hurt()
	_last_health = current
