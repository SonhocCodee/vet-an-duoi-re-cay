class_name PixelMapCanvas
extends Control

const PixelTheme = preload("res://scripts/ui/pixel/pixel_ui_theme.gd")

const WORLD_SIZE: Vector2 = Vector2(2200.0, 900.0)

var _markers: Dictionary = {}


func set_markers(markers: Dictionary) -> void:
	_markers = markers.duplicate(true)
	queue_redraw()


func get_marker_count() -> int:
	return _markers.size()


func _draw() -> void:
	var bounds := Rect2(Vector2.ZERO, size)
	draw_rect(bounds, Color("d7c28c"), true)
	draw_rect(Rect2(Vector2(4.0, 4.0), size - Vector2(8.0, 8.0)), Color("70452f"), false, 2.0)
	_draw_grid()
	_draw_city_plan()
	_draw_markers()


func _draw_grid() -> void:
	var grid_color := Color(0.44, 0.27, 0.18, 0.18)
	for x_value: int in range(24, int(size.x), 24):
		draw_line(Vector2(float(x_value), 0.0), Vector2(float(x_value), size.y), grid_color, 1.0)
	for y_value: int in range(24, int(size.y), 24):
		draw_line(Vector2(0.0, float(y_value)), Vector2(size.x, float(y_value)), grid_color, 1.0)


func _draw_city_plan() -> void:
	var road := Color("b88d55")
	var wall := Color("70452f")
	draw_polyline(PackedVector2Array([
		Vector2(size.x * 0.05, size.y * 0.66),
		Vector2(size.x * 0.28, size.y * 0.54),
		Vector2(size.x * 0.50, size.y * 0.58),
		Vector2(size.x * 0.72, size.y * 0.40),
		Vector2(size.x * 0.95, size.y * 0.46),
	]), road, 7.0)
	draw_polyline(PackedVector2Array([
		Vector2(size.x * 0.16, size.y * 0.18),
		Vector2(size.x * 0.30, size.y * 0.54),
		Vector2(size.x * 0.38, size.y * 0.86),
	]), road, 5.0)
	draw_rect(Rect2(size * Vector2(0.08, 0.10), size * Vector2(0.84, 0.78)), wall, false, 3.0)
	for rect: Rect2 in [
		Rect2(size * Vector2(0.16, 0.22), size * Vector2(0.14, 0.17)),
		Rect2(size * Vector2(0.40, 0.18), size * Vector2(0.18, 0.20)),
		Rect2(size * Vector2(0.65, 0.18), size * Vector2(0.16, 0.15)),
		Rect2(size * Vector2(0.18, 0.64), size * Vector2(0.13, 0.14)),
		Rect2(size * Vector2(0.54, 0.63), size * Vector2(0.20, 0.16)),
	]:
		draw_rect(rect, Color("c89258"), true)
		draw_rect(rect, Color("8a5639"), false, 2.0)


func _draw_markers() -> void:
	var index := 0
	for marker_value: Variant in _markers:
		var marker_id := StringName(str(marker_value))
		var marker_data: Dictionary = _markers.get(marker_value, {}) as Dictionary
		var marker_position := _marker_position(marker_id, marker_data, index)
		var color := PixelTheme.GOLD if String(marker_id).contains("quest") else PixelTheme.FOCUS
		draw_rect(Rect2(marker_position - Vector2(4.0, 4.0), Vector2(8.0, 8.0)), PixelTheme.INK, true)
		draw_rect(Rect2(marker_position - Vector2(2.0, 2.0), Vector2(4.0, 4.0)), color, true)
		index += 1


func _marker_position(marker_id: StringName, marker_data: Dictionary, index: int) -> Vector2:
	var raw_position: Variant = marker_data.get(&"position", marker_data.get("position", null))
	var world_position := Vector2.ZERO
	if raw_position is Vector2:
		world_position = raw_position as Vector2
	elif raw_position is Array and (raw_position as Array).size() >= 2:
		var values := raw_position as Array
		world_position = Vector2(float(values[0]), float(values[1]))
	else:
		var hash_value := absi(String(marker_id).hash()) + index * 97
		world_position = Vector2(float(160 + hash_value % 1860), float(100 + (hash_value / 13) % 700))
	var normalized := Vector2(clampf(world_position.x / WORLD_SIZE.x, 0.06, 0.94), clampf(world_position.y / WORLD_SIZE.y, 0.08, 0.92))
	return normalized * size
