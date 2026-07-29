class_name PixelWorldCanvas
extends Node2D

var layout: Resource

const GRASS_COLORS: Array[Color] = [Color("#496b3f"), Color("#4f7444"), Color("#557a48")]
const ROAD_BASE := Color("#a98658")
const ROAD_LIGHT := Color("#b69565")
const ROAD_DARK := Color("#806642")


func configure(city_layout: Resource) -> void:
	layout = city_layout
	queue_redraw()


func _draw() -> void:
	if layout == null:
		return
	_draw_grass()
	_draw_roads()
	_draw_water_and_fields()
	_draw_edge_shadows()


func _draw_grass() -> void:
	var tile_size := 32
	for y in range(0, layout.world_size.y, tile_size):
		for x in range(0, layout.world_size.x, tile_size):
			var color_index := posmod((x / tile_size) * 3 + (y / tile_size) * 5, GRASS_COLORS.size())
			draw_rect(Rect2(x, y, tile_size, tile_size), GRASS_COLORS[color_index])
			if posmod(x + y * 3, 160) == 0:
				draw_rect(Rect2(x + 7, y + 10, 3, 7), Color("#789052"))
				draw_rect(Rect2(x + 11, y + 14, 3, 5), Color("#688346"))


func _draw_roads() -> void:
	for road: Rect2 in layout.road_rects:
		_draw_pixel_road_shape(road, ROAD_DARK, 0.0)
		_draw_pixel_road_shape(road, ROAD_BASE, 6.0)
		_draw_road_shoulders(road)
		var start_x := int(road.position.x) + 14
		var start_y := int(road.position.y) + 14
		for y in range(start_y, int(road.end.y) - 8, 24):
			for x in range(start_x, int(road.end.x) - 8, 32):
				var offset := 12 if posmod(y / 24, 2) == 0 else 0
				draw_rect(Rect2(x + offset, y, 10, 4), ROAD_LIGHT)
				draw_rect(Rect2(x + offset + 4, y + 5, 6, 3), ROAD_DARK)


func _draw_water_and_fields() -> void:
	draw_rect(Rect2(64, 1016, 560, 184), Color("#304d50"))
	draw_rect(Rect2(72, 1024, 544, 168), Color("#3f6970"))
	for y in range(1040, 1180, 24):
		for x in range(88, 600, 64):
			draw_rect(Rect2(x, y, 28, 3), Color("#79a0a0"))
	draw_rect(Rect2(1312, 944, 528, 256), Color("#6e5939"))
	for y in range(960, 1192, 32):
		draw_rect(Rect2(1324, y, 504, 5), Color("#493d2d"))
		for x in range(1340, 1820, 48):
			draw_rect(Rect2(x, y - 8, 4, 12), Color("#9a9a50"))


func _draw_edge_shadows() -> void:
	draw_rect(Rect2(0, 0, layout.world_size.x, 16), Color("#27382d"))
	draw_rect(Rect2(0, layout.world_size.y - 16, layout.world_size.x, 16), Color("#27382d"))
	draw_rect(Rect2(0, 0, 16, layout.world_size.y), Color("#27382d"))
	draw_rect(Rect2(layout.world_size.x - 16, 0, 16, layout.world_size.y), Color("#27382d"))


func _draw_pixel_road_shape(road: Rect2, color: Color, inset: float) -> void:
	var rect := road.grow(-inset)
	var corner := minf(32.0, minf(rect.size.x, rect.size.y) * 0.18)
	var points := PackedVector2Array([
		Vector2(rect.position.x + corner, rect.position.y),
		Vector2(rect.end.x - corner, rect.position.y),
		Vector2(rect.end.x, rect.position.y + corner),
		Vector2(rect.end.x, rect.end.y - corner),
		Vector2(rect.end.x - corner, rect.end.y),
		Vector2(rect.position.x + corner, rect.end.y),
		Vector2(rect.position.x, rect.end.y - corner),
		Vector2(rect.position.x, rect.position.y + corner),
	])
	draw_colored_polygon(points, color)


func _draw_road_shoulders(road: Rect2) -> void:
	var horizontal := road.size.x > road.size.y
	if horizontal:
		for x in range(int(road.position.x + 48), int(road.end.x - 32), 96):
			var offset := 8 if posmod(x / 96, 2) == 0 else 0
			draw_rect(Rect2(x, road.position.y - 8 + offset, 16, 8), ROAD_DARK)
			draw_rect(Rect2(x + 32, road.end.y - offset, 16, 8), ROAD_DARK)
	else:
		for y in range(int(road.position.y + 48), int(road.end.y - 32), 96):
			var offset := 8 if posmod(y / 96, 2) == 0 else 0
			draw_rect(Rect2(road.position.x - 8 + offset, y, 8, 16), ROAD_DARK)
			draw_rect(Rect2(road.end.x - offset, y + 32, 8, 16), ROAD_DARK)
