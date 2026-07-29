class_name Chapter6BurningRootDecorator
extends Node2D

@export var map_size: Vector2 = Vector2(1600.0, 900.0)
var _ember_time: float = 0.0


func _process(delta: float) -> void:
	_ember_time += delta
	queue_redraw()


func _draw() -> void:
	var root_lines: Array[PackedVector2Array] = [
		PackedVector2Array([Vector2(0.0, 720.0), Vector2(280.0, 590.0), Vector2(530.0, 650.0), Vector2(790.0, 500.0)]),
		PackedVector2Array([Vector2(1600.0, 180.0), Vector2(1320.0, 300.0), Vector2(1120.0, 250.0), Vector2(860.0, 410.0)]),
		PackedVector2Array([Vector2(160.0, 80.0), Vector2(390.0, 230.0), Vector2(620.0, 180.0), Vector2(920.0, 330.0)]),
	]
	for root_line: PackedVector2Array in root_lines:
		draw_polyline(root_line, Color(0.22, 0.07, 0.035, 0.95), 34.0, true)
		draw_polyline(root_line, Color(0.74, 0.19, 0.06, 0.75), 8.0, true)
	for ember_index: int in range(24):
		var base_x: float = fmod(ember_index * 173.0, map_size.x)
		var rise: float = fmod(_ember_time * (28.0 + ember_index % 5 * 7.0) + ember_index * 41.0, map_size.y)
		var ember_position: Vector2 = Vector2(base_x, map_size.y - rise)
		var ember_radius: float = 2.0 + float(ember_index % 3)
		draw_circle(ember_position, ember_radius, Color(1.0, 0.42, 0.12, 0.72))
