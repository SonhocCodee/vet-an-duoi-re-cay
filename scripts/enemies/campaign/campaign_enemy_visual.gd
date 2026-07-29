class_name CampaignEnemyVisual
extends EnemyVisual

const ROOT_DIRECTIONS: Array[Vector2] = [Vector2.UP, Vector2.RIGHT, Vector2.DOWN, Vector2.LEFT]

@export_range(0, 4, 1) var campaign_style: int = 0


func _draw() -> void:
	if elite_aura_enabled:
		draw_circle(Vector2.ZERO, size * 1.05, Color(1.0, 0.72, 0.18, 0.14))
		draw_arc(Vector2.ZERO, size, 0.0, TAU, 40, Color(1.0, 0.75, 0.25, 0.82), 2.0)
	match campaign_style:
		0:
			_draw_humanoid()
		1:
			_draw_beast()
		2:
			_draw_caster()
		3:
			_draw_winged()
		_:
			_draw_rooted()
	if telegraph_amount > 0.0:
		var warning: Color = Color(1.0, 0.12, 0.06, 0.3 + telegraph_amount * 0.55)
		draw_arc(Vector2.ZERO, size + 9.0, -PI * 0.5, -PI * 0.5 + TAU * telegraph_amount, 40, warning, 4.0)


func _draw_humanoid() -> void:
	draw_circle(Vector2(0.0, -size * 0.48), size * 0.28, accent_color)
	draw_rect(Rect2(-size * 0.38, -size * 0.2, size * 0.76, size), body_color, true)
	draw_line(Vector2(-size * 0.38, size * 0.05), Vector2(-size * 0.72, size * 0.55), accent_color, 4.0)
	draw_line(Vector2(size * 0.38, size * 0.05), Vector2(size * 0.72, size * 0.55), accent_color, 4.0)


func _draw_beast() -> void:
	var points: PackedVector2Array = PackedVector2Array([
		Vector2(-size * 0.8, size * 0.35), Vector2(-size * 0.5, -size * 0.35),
		Vector2(0.0, -size * 0.58), Vector2(size * 0.72, -size * 0.12),
		Vector2(size * 0.82, size * 0.42), Vector2.ZERO,])
	draw_colored_polygon(points, body_color)
	draw_circle(Vector2(size * 0.4, -size * 0.17), 3.0, accent_color)


func _draw_caster() -> void:
	draw_colored_polygon(PackedVector2Array([
		Vector2.ZERO, Vector2(-size * 0.65, size), Vector2(size * 0.65, size),]), body_color)
	draw_circle(Vector2.ZERO, size * 0.42, accent_color)
	draw_arc(Vector2.ZERO, size * 0.68, PI, TAU, 20, body_color, 5.0)


func _draw_winged() -> void:
	draw_circle(Vector2.ZERO, size * 0.38, body_color)
	draw_colored_polygon(PackedVector2Array([
		Vector2(-size * 0.25, 0.0), Vector2(-size, -size * 0.55), Vector2(-size * 0.72, size * 0.5),]), accent_color)
	draw_colored_polygon(PackedVector2Array([
		Vector2(size * 0.25, 0.0), Vector2(size, -size * 0.55), Vector2(size * 0.72, size * 0.5),]), accent_color)
	draw_circle(Vector2(size * 0.12, -size * 0.1), 2.5, Color.WHITE)


func _draw_rooted() -> void:
	draw_circle(Vector2.ZERO, size * 0.52, body_color)
	for direction: Vector2 in ROOT_DIRECTIONS:
		draw_line(direction * size * 0.35, direction * size, accent_color, 5.0)
	draw_circle(Vector2.ZERO, size * 0.2, accent_color)
