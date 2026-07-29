class_name Chapter7BlackResinDecorator
extends Node2D

@export var map_size: Vector2 = Vector2(1600.0, 900.0)
var _resin_time: float = 0.0


func _process(delta: float) -> void:
	_resin_time += delta
	queue_redraw()


func _draw() -> void:
	var pool_positions: Array[Vector2] = [
		Vector2(260.0, 690.0), Vector2(520.0, 180.0), Vector2(870.0, 720.0),
		Vector2(1160.0, 210.0), Vector2(1410.0, 650.0),
	]
	for pool_index: int in range(pool_positions.size()):
		var pulse: float = 1.0 + sin(_resin_time * 1.4 + pool_index) * 0.06
		var radius: Vector2 = Vector2(105.0, 42.0) * pulse
		draw_set_transform(pool_positions[pool_index], 0.0, Vector2.ONE)
		draw_ellipse(Vector2.ZERO, radius, Color(0.025, 0.035, 0.028, 0.88))
		draw_arc(Vector2.ZERO, radius.x, 0.0, TAU, 48, Color(0.18, 0.34, 0.22, 0.72), 3.0)
		draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
	for marker_index: int in range(9):
		var marker_position: Vector2 = Vector2(110.0 + marker_index * 175.0, 430.0 + sin(marker_index * 1.7) * 90.0)
		draw_line(marker_position + Vector2(0.0, -32.0), marker_position + Vector2(0.0, 32.0), Color(0.3, 0.22, 0.13, 0.9), 9.0)
		draw_circle(marker_position + Vector2(0.0, -35.0), 7.0, Color(0.42, 0.74, 0.38, 0.62))


func draw_ellipse(center: Vector2, radius: Vector2, color: Color) -> void:
	var points: PackedVector2Array = PackedVector2Array()
	for point_index: int in range(48):
		var angle: float = TAU * float(point_index) / 48.0
		points.append(center + Vector2(cos(angle) * radius.x, sin(angle) * radius.y))
	draw_colored_polygon(points, color)
