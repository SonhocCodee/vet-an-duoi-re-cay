class_name EnemyVisual
extends Node2D

enum ShapeKind {
	SHADE,
	WOLF,
	MUSHROOM,
	STAG,
}

@export var shape_kind: ShapeKind = ShapeKind.SHADE
@export var body_color: Color = Color("7b86a8")
@export var accent_color: Color = Color("d6e2ff")
@export_range(8.0, 96.0, 1.0) var size: float = 22.0

var elite_aura_enabled: bool = false
var telegraph_amount: float = 0.0


func set_elite_aura(enabled: bool) -> void:
	elite_aura_enabled = enabled
	queue_redraw()


func set_telegraph_progress(progress: float) -> void:
	telegraph_amount = clampf(progress, 0.0, 1.0)
	queue_redraw()


func _draw() -> void:
	if elite_aura_enabled:
		draw_circle(Vector2.ZERO, size * 0.9, Color(1.0, 0.72, 0.18, 0.15))
		draw_arc(Vector2.ZERO, size * 0.85, 0.0, TAU, 32, Color(1.0, 0.75, 0.25, 0.85), 2.0)

	match shape_kind:
		ShapeKind.SHADE:
			_draw_shade()
		ShapeKind.WOLF:
			_draw_wolf()
		ShapeKind.MUSHROOM:
			_draw_mushroom()
		ShapeKind.STAG:
			_draw_stag()

	if telegraph_amount > 0.0:
		var warning_color: Color = Color(1.0, 0.16, 0.08, 0.25 + telegraph_amount * 0.55)
		draw_arc(Vector2.ZERO, size + 8.0, -PI * 0.5, -PI * 0.5 + TAU * telegraph_amount, 32, warning_color, 4.0)


func _draw_shade() -> void:
	draw_circle(Vector2(0.0, -size * 0.1), size * 0.55, body_color)
	var tail: PackedVector2Array = PackedVector2Array([
		Vector2(-size * 0.5, size * 0.1),
		Vector2(-size * 0.2, size * 0.75),
		Vector2.ZERO,
		Vector2(size * 0.2, size * 0.75),
		Vector2(size * 0.5, size * 0.1),
	])
	draw_colored_polygon(tail, body_color)
	draw_circle(Vector2(-size * 0.2, -size * 0.15), 2.5, accent_color)
	draw_circle(Vector2(size * 0.2, -size * 0.15), 2.5, accent_color)


func _draw_wolf() -> void:
	var body: PackedVector2Array = PackedVector2Array([
		Vector2(-size * 0.7, size * 0.3),
		Vector2(-size * 0.35, -size * 0.45),
		Vector2(0.0, -size * 0.2),
		Vector2(size * 0.4, -size * 0.5),
		Vector2(size * 0.72, size * 0.25),
		Vector2(0.0, size * 0.55),
	])
	draw_colored_polygon(body, body_color)
	draw_line(Vector2(-size * 0.55, size * 0.05), Vector2(size * 0.5, -size * 0.1), accent_color, 3.0)
	draw_circle(Vector2(size * 0.28, -size * 0.12), 2.5, Color("f4d35e"))


func _draw_mushroom() -> void:
	draw_rect(Rect2(-size * 0.22, -size * 0.05, size * 0.44, size * 0.75), body_color, true)
	draw_circle(Vector2(0.0, -size * 0.15), size * 0.68, accent_color)
	draw_circle(Vector2(-size * 0.3, -size * 0.25), size * 0.1, body_color)
	draw_circle(Vector2(size * 0.25, -size * 0.05), size * 0.08, body_color)
	draw_circle(Vector2(-size * 0.08, size * 0.18), 2.0, Color("1a1026"))
	draw_circle(Vector2(size * 0.08, size * 0.18), 2.0, Color("1a1026"))


func _draw_stag() -> void:
	draw_circle(Vector2.ZERO, size * 0.52, body_color)
	draw_rect(Rect2(-size * 0.18, size * 0.35, size * 0.36, size * 0.7), accent_color, true)
	draw_line(Vector2(-size * 0.25, -size * 0.35), Vector2(-size * 0.65, -size * 0.95), accent_color, 4.0)
	draw_line(Vector2(size * 0.25, -size * 0.35), Vector2(size * 0.65, -size * 0.95), accent_color, 4.0)
	draw_line(Vector2(-size * 0.5, -size * 0.7), Vector2(-size * 0.85, -size * 0.7), accent_color, 3.0)
	draw_line(Vector2(size * 0.5, -size * 0.7), Vector2(size * 0.85, -size * 0.7), accent_color, 3.0)
	draw_circle(Vector2(-size * 0.18, -size * 0.08), 3.0, Color("f7c948"))
	draw_circle(Vector2(size * 0.18, -size * 0.08), 3.0, Color("f7c948"))
