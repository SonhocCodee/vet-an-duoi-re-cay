class_name BossAttackPlaceholder
extends Node2D

enum Kind {
	RADIAL,
	PROJECTILE,
}

var kind: Kind = Kind.RADIAL
var direction: Vector2 = Vector2.RIGHT
var speed: float = 260.0
var maximum_radius: float = 96.0
var lifetime: float = 0.45
var effect_color: Color = Color("ff7043")
var _elapsed: float = 0.0


func configure(
	p_kind: Kind,
	p_direction: Vector2 = Vector2.RIGHT,
	p_maximum_radius: float = 96.0,
	p_color: Color = Color("ff7043")
) -> void:
	kind = p_kind
	direction = p_direction.normalized()
	maximum_radius = maxf(p_maximum_radius, 8.0)
	effect_color = p_color


func _process(delta: float) -> void:
	_elapsed += delta
	if kind == Kind.PROJECTILE:
		global_position += direction * speed * delta
	queue_redraw()
	if _elapsed >= lifetime:
		queue_free()


func _draw() -> void:
	var progress: float = clampf(_elapsed / maxf(lifetime, 0.001), 0.0, 1.0)
	if kind == Kind.RADIAL:
		draw_arc(Vector2.ZERO, maximum_radius * progress, 0.0, TAU, 48, Color(effect_color, 1.0 - progress), 5.0)
	else:
		var length: float = 14.0
		draw_colored_polygon(PackedVector2Array([
			direction * length, direction.rotated(2.3) * 7.0,
			-direction * 5.0, direction.rotated(-2.3) * 7.0,]), Color(effect_color, 1.0 - progress * 0.7))
