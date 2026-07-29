class_name Chapter5QuartzDecorator
extends Node2D

@export var map_size: Vector2 = Vector2(1600.0, 900.0)
var _shimmer_time: float = 0.0


func _process(delta: float) -> void:
	_shimmer_time += delta
	queue_redraw()


func _draw() -> void:
	var crystal_positions: Array[Vector2] = [
		Vector2(210.0, 210.0), Vector2(430.0, 680.0), Vector2(760.0, 235.0),
		Vector2(1040.0, 700.0), Vector2(1320.0, 220.0), Vector2(1480.0, 610.0),
	]
	for crystal_index: int in range(crystal_positions.size()):
		var position: Vector2 = crystal_positions[crystal_index]
		var shimmer: float = 0.72 + sin(_shimmer_time * 2.2 + crystal_index) * 0.2
		var crystal_color: Color = Color(0.72, 0.82, 0.94, shimmer)
		var crystal: PackedVector2Array = PackedVector2Array([
			position + Vector2(-18.0, 28.0),
			position + Vector2(0.0, -42.0),
			position + Vector2(20.0, 28.0),
		])
		draw_colored_polygon(crystal, crystal_color)
		draw_polyline(crystal, Color(0.92, 0.96, 1.0, shimmer), 3.0)
	for streak_index: int in range(7):
		var streak_y: float = 120.0 + streak_index * 105.0
		var offset: float = fmod(_shimmer_time * (30.0 + streak_index * 4.0), map_size.x + 260.0) - 130.0
		draw_line(Vector2(offset, streak_y), Vector2(offset + 150.0, streak_y - 24.0), Color(0.9, 0.84, 0.68, 0.22), 2.0)
