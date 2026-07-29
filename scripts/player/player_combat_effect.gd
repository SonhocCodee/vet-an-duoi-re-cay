class_name PlayerCombatEffect
extends Area2D

enum EffectShape {
	PROJECTILE,
	CIRCLE,
	CONE,
}

var packet: DamagePacket
var direction: Vector2 = Vector2.RIGHT
var speed: float = 0.0
var lifetime: float = 0.4
var elapsed: float = 0.0
var effect_shape: EffectShape = EffectShape.CIRCLE
var effect_color: Color = Color.WHITE
var radius: float = 32.0
var cone_angle: float = deg_to_rad(70.0)
var heal_fraction_per_second: float = 0.0
var tick_interval: float = 0.0
var tick_elapsed: float = 0.0
var source_player: PlayerController
var hit_once: bool = true
var hit_targets: Dictionary = {}
var collision_shape: CollisionShape2D


func _ready() -> void:
	collision_layer = 0
	monitorable = false
	body_entered.connect(_on_body_entered)
	area_entered.connect(_on_area_entered)
	queue_redraw()


func configure_projectile(
	p_packet: DamagePacket,
	p_direction: Vector2,
	p_speed: float,
	p_lifetime: float,
	p_size: Vector2,
	p_color: Color,
	p_collision_mask: int
) -> void:
	packet = p_packet
	direction = p_direction.normalized()
	speed = p_speed
	lifetime = p_lifetime
	effect_shape = EffectShape.PROJECTILE
	effect_color = p_color
	collision_mask = p_collision_mask
	rotation = direction.angle()
	var rectangle := RectangleShape2D.new()
	rectangle.size = p_size
	_set_shape(rectangle)
	radius = p_size.x * 0.5


func configure_circle(
	p_packet: DamagePacket,
	p_radius: float,
	p_lifetime: float,
	p_color: Color,
	p_collision_mask: int,
	p_tick_interval: float = 0.0,
	p_heal_fraction_per_second: float = 0.0,
	p_source_player: PlayerController = null
) -> void:
	packet = p_packet
	radius = p_radius
	lifetime = p_lifetime
	effect_shape = EffectShape.CIRCLE
	effect_color = p_color
	collision_mask = p_collision_mask
	tick_interval = p_tick_interval
	heal_fraction_per_second = p_heal_fraction_per_second
	source_player = p_source_player
	hit_once = is_zero_approx(tick_interval)
	var circle := CircleShape2D.new()
	circle.radius = p_radius
	_set_shape(circle)


func configure_cone(
	p_packet: DamagePacket,
	p_direction: Vector2,
	p_range: float,
	p_angle: float,
	p_lifetime: float,
	p_color: Color,
	p_collision_mask: int
) -> void:
	packet = p_packet
	direction = p_direction.normalized()
	radius = p_range
	cone_angle = p_angle
	lifetime = p_lifetime
	effect_shape = EffectShape.CONE
	effect_color = p_color
	collision_mask = p_collision_mask
	rotation = direction.angle()
	var polygon := ConvexPolygonShape2D.new()
	polygon.points = _build_cone_points(p_range, p_angle)
	_set_shape(polygon)


func _physics_process(delta: float) -> void:
	elapsed += delta
	if speed > 0.0:
		global_position += direction * speed * delta
	if tick_interval > 0.0:
		tick_elapsed += delta
		if tick_elapsed >= tick_interval:
			tick_elapsed = fmod(tick_elapsed, tick_interval)
			hit_targets.clear()
			_apply_to_current_overlaps()
			if source_player != null and heal_fraction_per_second > 0.0:
				source_player.restore_health(
					source_player.get_max_health() * heal_fraction_per_second * tick_interval
				)
	if elapsed >= lifetime:
		queue_free()


func _draw() -> void:
	match effect_shape:
		EffectShape.PROJECTILE:
			draw_rect(Rect2(Vector2(-radius, -8.0), Vector2(radius * 2.0, 16.0)), effect_color)
			draw_line(Vector2(-radius - 14.0, 0.0), Vector2(-radius, 0.0), effect_color.darkened(0.25), 5.0, true)
		EffectShape.CIRCLE:
			draw_circle(Vector2.ZERO, radius, Color(effect_color, 0.18))
			draw_arc(Vector2.ZERO, radius, 0.0, TAU, 48, effect_color, 4.0, true)
		EffectShape.CONE:
			var points: PackedVector2Array = _build_cone_points(radius, cone_angle)
			draw_colored_polygon(points, Color(effect_color, 0.35))
			draw_polyline(points, effect_color, 4.0, true)


func _set_shape(shape: Shape2D) -> void:
	collision_shape = CollisionShape2D.new()
	collision_shape.shape = shape
	add_child(collision_shape)


func _build_cone_points(p_range: float, p_angle: float) -> PackedVector2Array:
	var points := PackedVector2Array([Vector2.ZERO])
	var segments: int = 8
	for index: int in range(segments + 1):
		var ratio: float = float(index) / float(segments)
		var angle: float = lerpf(-p_angle * 0.5, p_angle * 0.5, ratio)
		points.append(Vector2.RIGHT.rotated(angle) * p_range)
	return points


func _on_body_entered(body: Node2D) -> void:
	_apply_damage(body)


func _on_area_entered(area: Area2D) -> void:
	_apply_damage(_find_damage_receiver(area))


func _apply_to_current_overlaps() -> void:
	for body: Node2D in get_overlapping_bodies():
		_apply_damage(body)
	for area: Area2D in get_overlapping_areas():
		_apply_damage(_find_damage_receiver(area))


func _apply_damage(target: Node) -> void:
	if target == null or target == source_player or packet == null:
		return
	var target_id: int = target.get_instance_id()
	if hit_targets.has(target_id):
		return
	if not target.has_method("receive_damage"):
		return
	hit_targets[target_id] = true
	target.call("receive_damage", packet)
	if hit_once and effect_shape == EffectShape.PROJECTILE:
		queue_free()


func _find_damage_receiver(node: Node) -> Node:
	var current: Node = node
	while current != null:
		if current.has_method("receive_damage"):
			return current
		current = current.get_parent()
	return null
