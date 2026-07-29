class_name PixelWorldPresenter
extends Node2D

const TILE_SIZE := 32

var map_id: StringName
var world_size := Vector2(2200.0, 900.0)
var _seed := 1


func configure(value: StringName, size: Vector2) -> void:
	map_id = value
	world_size = size
	_seed = abs(String(map_id).hash())
	z_index = -5
	queue_redraw()


func _draw() -> void:
	_draw_ground()
	_draw_paths()
	_draw_water()
	_draw_landmarks()
	_draw_foliage()


func _draw_ground() -> void:
	var columns := ceili(world_size.x / TILE_SIZE)
	var rows := ceili(world_size.y / TILE_SIZE)
	var base := _palette_color(0)
	var alternate := _palette_color(1)
	for row in rows:
		for column in columns:
			var color := alternate if (column + row + _seed) % 5 == 0 else base
			draw_rect(Rect2(column * TILE_SIZE, row * TILE_SIZE, TILE_SIZE, TILE_SIZE), color)


func _draw_paths() -> void:
	var path_color := _palette_color(2)
	var edge_color := path_color.darkened(0.22)
	var id := String(map_id)
	var center_y := world_size.y * (0.72 if id.begins_with("map") else 0.56)
	draw_rect(Rect2(0.0, center_y - 72.0, world_size.x, 144.0), edge_color)
	draw_rect(Rect2(0.0, center_y - 60.0, world_size.x, 120.0), path_color)
	for x in range(0, roundi(world_size.x), TILE_SIZE * 2):
		draw_rect(Rect2(x + 8, center_y - 44.0 + (int(x / TILE_SIZE) % 3) * 12.0, 18, 8), path_color.lightened(0.08))
	var branch_x := world_size.x * 0.5
	draw_rect(Rect2(branch_x - 58.0, 0.0, 116.0, center_y), edge_color)
	draw_rect(Rect2(branch_x - 48.0, 0.0, 96.0, center_y), path_color)


func _draw_water() -> void:
	if not _uses_water():
		return
	var water_rect := Rect2(world_size.x * 0.72, 0.0, world_size.x * 0.28, world_size.y * 0.36)
	draw_rect(water_rect, Color("284f63"))
	for y in range(18, roundi(water_rect.size.y), 28):
		for x in range(roundi(water_rect.position.x) + 12, roundi(world_size.x), 72):
			draw_rect(Rect2(x, y, 34, 4), Color("4b7b86"))


func _draw_landmarks() -> void:
	var count := 7 if String(map_id).contains("map3") else 4
	for index in count:
		var x := 220.0 + index * ((world_size.x - 440.0) / maxf(count - 1, 1))
		var y := 210.0 + float((index + _seed) % 2) * 95.0
		_draw_building(Vector2(x, y), index)


func _draw_building(origin: Vector2, variant: int) -> void:
	var width := 128.0 + float(variant % 3) * 24.0
	var body_rect := Rect2(origin.x - width * 0.5, origin.y, width, 92.0)
	var shadow_rect := body_rect.grow_individual(8.0, 4.0, 10.0, 12.0)
	draw_rect(shadow_rect, Color(0.08, 0.09, 0.10, 0.35))
	draw_rect(body_rect, Color("9b7452"))
	var roof := PackedVector2Array([
		Vector2(origin.x - width * 0.62, origin.y + 8.0),
		Vector2(origin.x, origin.y - 58.0),
		Vector2(origin.x + width * 0.62, origin.y + 8.0),
	])
	draw_colored_polygon(roof, Color("593c48") if variant % 2 == 0 else Color("425261"))
	draw_rect(Rect2(origin.x - 16.0, origin.y + 42.0, 32.0, 50.0), Color("352b2d"))
	draw_rect(Rect2(origin.x - width * 0.34, origin.y + 24.0, 24.0, 24.0), Color("d5b06d"))
	draw_rect(Rect2(origin.x + width * 0.18, origin.y + 24.0, 24.0, 24.0), Color("d5b06d"))


func _draw_foliage() -> void:
	var count := maxi(18, roundi(world_size.x / 90.0))
	for index in count:
		var x := float((_seed * 31 + index * 173) % maxi(roundi(world_size.x - 80.0), 1)) + 40.0
		var y_band := float((_seed * 17 + index * 97) % 170)
		var y := y_band + 36.0 if index % 2 == 0 else world_size.y - y_band - 48.0
		_draw_tree(Vector2(x, y), index)


func _draw_tree(origin: Vector2, variant: int) -> void:
	draw_rect(Rect2(origin.x - 7.0, origin.y + 14.0, 14.0, 34.0), Color("654936"))
	var leaf := Color("315744") if variant % 3 else Color("3e664c")
	draw_rect(Rect2(origin.x - 28.0, origin.y - 12.0, 56.0, 42.0), leaf)
	draw_rect(Rect2(origin.x - 19.0, origin.y - 30.0, 38.0, 24.0), leaf.lightened(0.06))
	draw_rect(Rect2(origin.x - 23.0, origin.y + 30.0, 46.0, 8.0), Color(0.05, 0.08, 0.07, 0.28))


func _palette_color(index: int) -> Color:
	var id := String(map_id)
	if "quartz" in id or "false_sun" in id:
		return [Color("7d7057"), Color("887a5d"), Color("aa8f63")][index]
	if "drowned" in id or "monastery" in id:
		return [Color("40545a"), Color("475d60"), Color("69716b")][index]
	if "burning" in id or "world_root" in id:
		return [Color("4a4136"), Color("55483a"), Color("796048")][index]
	return [Color("466247"), Color("506c4d"), Color("927557")][index]


func _uses_water() -> bool:
	var id := String(map_id)
	return "drowned" in id or "map3" in id or "monastery" in id
