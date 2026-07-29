class_name EnemyVisual
extends Node2D

signal directional_animation_changed(animation_name: StringName)

enum ShapeKind { SHADE, WOLF, MUSHROOM, STAG }
enum MotionAnimation { IDLE, WALK, TELEGRAPH, ATTACK, HURT, DEAD }

@export var shape_kind: ShapeKind = ShapeKind.SHADE
@export var body_color: Color = Color("7b86a8")
@export var accent_color: Color = Color("d6e2ff")
@export_range(8.0, 96.0, 1.0) var size: float = 22.0

var elite_aura_enabled := false
var telegraph_amount := 0.0
var facing_direction := Vector2.DOWN
var motion_animation: MotionAnimation = MotionAnimation.IDLE
var directional_animation: StringName = &"idle_down"
var animation_phase := 0.0


func _ready() -> void:
	var enemy := get_parent() as EnemyBase
	if enemy != null and not enemy.state_changed.is_connected(_on_enemy_state_changed):
		enemy.state_changed.connect(_on_enemy_state_changed)
	set_process(true)
	_refresh_animation_name()


func _process(delta: float) -> void:
	animation_phase += delta
	var enemy := get_parent() as EnemyBase
	if enemy == null:
		queue_redraw()
		return
	if enemy.velocity.length() > 1.0:
		set_facing_direction(enemy.velocity)
	match enemy.current_state:
		EnemyBase.EnemyState.IDLE:
			set_motion_animation(MotionAnimation.WALK if enemy.velocity.length() > 1.0 else MotionAnimation.IDLE)
		EnemyBase.EnemyState.CHASE:
			set_motion_animation(MotionAnimation.WALK)
		EnemyBase.EnemyState.TELEGRAPH:
			set_motion_animation(MotionAnimation.TELEGRAPH)
		EnemyBase.EnemyState.ATTACK:
			set_motion_animation(MotionAnimation.ATTACK)
		EnemyBase.EnemyState.STAGGER:
			set_motion_animation(MotionAnimation.HURT)
		EnemyBase.EnemyState.DEAD:
			set_motion_animation(MotionAnimation.DEAD)
	queue_redraw()


func set_elite_aura(enabled: bool) -> void:
	elite_aura_enabled = enabled
	queue_redraw()


func set_telegraph_progress(progress: float) -> void:
	telegraph_amount = clampf(progress, 0.0, 1.0)
	queue_redraw()


func set_facing_direction(direction: Vector2) -> void:
	if direction.is_zero_approx():
		return
	var cardinal := _cardinalize(direction)
	if cardinal.is_equal_approx(facing_direction):
		return
	facing_direction = cardinal
	_refresh_animation_name()


func set_motion_animation(value: MotionAnimation) -> void:
	if motion_animation == value:
		return
	motion_animation = value
	animation_phase = 0.0
	_refresh_animation_name()


func get_directional_animation() -> StringName:
	return directional_animation


func get_facing_direction() -> Vector2:
	return facing_direction


func _refresh_animation_name() -> void:
	var prefix: String = String(MotionAnimation.keys()[motion_animation]).to_lower()
	var next_name := StringName("%s_%s" % [prefix, _direction_suffix(facing_direction)])
	if next_name == directional_animation:
		return
	directional_animation = next_name
	directional_animation_changed.emit(directional_animation)


func _on_enemy_state_changed(_previous: EnemyBase.EnemyState, next: EnemyBase.EnemyState) -> void:
	match next:
		EnemyBase.EnemyState.IDLE:
			set_motion_animation(MotionAnimation.IDLE)
		EnemyBase.EnemyState.CHASE:
			set_motion_animation(MotionAnimation.WALK)
		EnemyBase.EnemyState.TELEGRAPH:
			set_motion_animation(MotionAnimation.TELEGRAPH)
		EnemyBase.EnemyState.ATTACK:
			set_motion_animation(MotionAnimation.ATTACK)
		EnemyBase.EnemyState.STAGGER:
			set_motion_animation(MotionAnimation.HURT)
		EnemyBase.EnemyState.DEAD:
			set_motion_animation(MotionAnimation.DEAD)


func _draw() -> void:
	if elite_aura_enabled:
		draw_circle(Vector2.ZERO, size * 0.9, Color(1.0, 0.72, 0.18, 0.15))
		draw_arc(Vector2.ZERO, size * 0.85, 0.0, TAU, 32, Color(1.0, 0.75, 0.25, 0.85), 2.0)
	_apply_animation_draw_transform()
	match shape_kind:
		ShapeKind.SHADE:
			_draw_shade()
		ShapeKind.WOLF:
			_draw_wolf()
		ShapeKind.MUSHROOM:
			_draw_mushroom()
		ShapeKind.STAG:
			_draw_stag()
	_reset_animation_draw_transform()
	if telegraph_amount > 0.0:
		var warning_color := Color(1.0, 0.16, 0.08, 0.25 + telegraph_amount * 0.55)
		draw_arc(Vector2.ZERO, size + 8.0, -PI * 0.5, -PI * 0.5 + TAU * telegraph_amount, 32, warning_color, 4.0)


func _apply_animation_draw_transform() -> void:
	var offset := Vector2.ZERO
	var rotation_value := 0.0
	var scale_value := Vector2.ONE
	match motion_animation:
		MotionAnimation.IDLE:
			offset.y = sin(animation_phase * 3.0) * 1.2
		MotionAnimation.WALK:
			offset.y = absf(sin(animation_phase * 8.0)) * -3.0
			rotation_value = sin(animation_phase * 8.0) * 0.045
		MotionAnimation.TELEGRAPH:
			scale_value = Vector2.ONE * (1.0 + sin(animation_phase * 10.0) * 0.05)
		MotionAnimation.ATTACK:
			offset = facing_direction * (4.0 + absf(sin(animation_phase * 16.0)) * 5.0)
			scale_value = Vector2(1.08, 0.94)
		MotionAnimation.HURT:
			offset = -facing_direction * 5.0
			rotation_value = sin(animation_phase * 22.0) * 0.08
		MotionAnimation.DEAD:
			rotation_value = 0.35 if facing_direction.x >= 0.0 else -0.35
	var mirror := -1.0 if facing_direction.x < 0.0 and absf(facing_direction.x) > absf(facing_direction.y) else 1.0
	scale_value.x *= mirror
	draw_set_transform(offset, rotation_value, scale_value)


func _reset_animation_draw_transform() -> void:
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)


func _view_mode() -> StringName:
	if absf(facing_direction.x) > absf(facing_direction.y):
		return &"side"
	return &"up" if facing_direction.y < 0.0 else &"down"


func _draw_shade() -> void:
	var view := _view_mode()
	var body_offset := Vector2(2.0, 0.0) if view == &"side" else Vector2.ZERO
	draw_circle(body_offset + Vector2(0.0, -size * 0.1), size * 0.55, body_color)
	var tail := PackedVector2Array([
		Vector2(-size * 0.5, size * 0.1), Vector2(-size * 0.2, size * 0.75),
		Vector2(0.0, size * 0.55), Vector2(size * 0.2, size * 0.75), Vector2(size * 0.5, size * 0.1),
	])
	draw_colored_polygon(tail, body_color)
	if view == &"down":
		draw_circle(Vector2(-size * 0.2, -size * 0.15), 2.5, accent_color)
		draw_circle(Vector2(size * 0.2, -size * 0.15), 2.5, accent_color)
	elif view == &"side":
		draw_circle(Vector2(size * 0.28, -size * 0.15), 3.0, accent_color)
	else:
		draw_line(Vector2(-size * 0.25, -size * 0.2), Vector2(size * 0.25, -size * 0.2), accent_color, 3.0)


func _draw_wolf() -> void:
	var view := _view_mode()
	if view == &"side":
		var side_body := PackedVector2Array([
			Vector2(-size * 0.7, size * 0.25), Vector2(-size * 0.45, -size * 0.25),
			Vector2(size * 0.25, -size * 0.35), Vector2(size * 0.72, -size * 0.05),
			Vector2(size * 0.55, size * 0.38), Vector2(-size * 0.25, size * 0.5),
		])
		draw_colored_polygon(side_body, body_color)
		draw_circle(Vector2(size * 0.45, -size * 0.12), 2.5, Color("f4d35e"))
		draw_line(Vector2(-size * 0.55, 0.0), Vector2(-size * 0.9, -size * 0.25), accent_color, 4.0)
		return
	var body := PackedVector2Array([
		Vector2(-size * 0.62, size * 0.28), Vector2(-size * 0.38, -size * 0.42),
		Vector2(0.0, -size * 0.2), Vector2(size * 0.38, -size * 0.42),
		Vector2(size * 0.62, size * 0.28), Vector2(0.0, size * 0.55),
	])
	draw_colored_polygon(body, body_color)
	if view == &"down":
		draw_circle(Vector2(-size * 0.2, -size * 0.12), 2.4, Color("f4d35e"))
		draw_circle(Vector2(size * 0.2, -size * 0.12), 2.4, Color("f4d35e"))
	else:
		draw_line(Vector2(-size * 0.32, 0.0), Vector2(size * 0.32, 0.0), accent_color, 4.0)


func _draw_mushroom() -> void:
	var view := _view_mode()
	draw_rect(Rect2(-size * 0.22, -size * 0.05, size * 0.44, size * 0.75), body_color, true)
	draw_circle(Vector2(0.0, -size * 0.15), size * (0.62 if view == &"side" else 0.68), accent_color)
	draw_circle(Vector2(-size * 0.3, -size * 0.25), size * 0.1, body_color)
	draw_circle(Vector2(size * 0.25, -size * 0.05), size * 0.08, body_color)
	if view == &"down":
		draw_circle(Vector2(-size * 0.08, size * 0.18), 2.0, Color("1a1026"))
		draw_circle(Vector2(size * 0.08, size * 0.18), 2.0, Color("1a1026"))
	elif view == &"side":
		draw_circle(Vector2(size * 0.15, size * 0.16), 2.2, Color("1a1026"))
	else:
		draw_rect(Rect2(-size * 0.18, size * 0.08, size * 0.36, 4.0), body_color.darkened(0.2))


func _draw_stag() -> void:
	var view := _view_mode()
	if view == &"side":
		draw_colored_polygon(PackedVector2Array([
			Vector2(-size * 0.65, size * 0.25), Vector2(-size * 0.45, -size * 0.25),
			Vector2(size * 0.2, -size * 0.3), Vector2(size * 0.6, 0.0),
			Vector2(size * 0.48, size * 0.42), Vector2(-size * 0.35, size * 0.5),
		]), body_color)
		draw_line(Vector2(size * 0.25, -size * 0.2), Vector2(size * 0.65, -size * 0.85), accent_color, 4.0)
		draw_circle(Vector2(size * 0.38, -size * 0.08), 3.0, Color("f7c948"))
		return
	draw_circle(Vector2.ZERO, size * 0.52, body_color)
	draw_rect(Rect2(-size * 0.18, size * 0.35, size * 0.36, size * 0.7), accent_color, true)
	draw_line(Vector2(-size * 0.25, -size * 0.35), Vector2(-size * 0.65, -size * 0.95), accent_color, 4.0)
	draw_line(Vector2(size * 0.25, -size * 0.35), Vector2(size * 0.65, -size * 0.95), accent_color, 4.0)
	if view == &"down":
		draw_circle(Vector2(-size * 0.18, -size * 0.08), 3.0, Color("f7c948"))
		draw_circle(Vector2(size * 0.18, -size * 0.08), 3.0, Color("f7c948"))
	else:
		draw_line(Vector2(-size * 0.28, -size * 0.04), Vector2(size * 0.28, -size * 0.04), accent_color.darkened(0.25), 5.0)


func _direction_suffix(direction: Vector2) -> String:
	if absf(direction.x) > absf(direction.y):
		return "right" if direction.x > 0.0 else "left"
	return "down" if direction.y >= 0.0 else "up"


func _cardinalize(direction: Vector2) -> Vector2:
	if absf(direction.x) > absf(direction.y):
		return Vector2.RIGHT if direction.x > 0.0 else Vector2.LEFT
	return Vector2.DOWN if direction.y >= 0.0 else Vector2.UP
