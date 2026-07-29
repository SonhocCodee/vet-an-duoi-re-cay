class_name PixelBuilding
extends Node2D

@export var building_size := Vector2(240.0, 208.0)
@export_range(0, 5, 1) var style: int = 0
@export var title: String = "House"

const WALL_COLORS: Array[Color] = [
	Color("#c6a46c"), Color("#9f8761"), Color("#bc8b62"),
	Color("#8e9a79"), Color("#b9a98a"), Color("#9b785d"),
]
const ROOF_COLORS: Array[Color] = [
	Color("#6f3935"), Color("#4f5364"), Color("#775139"),
	Color("#3e5b55"), Color("#65434c"), Color("#5a4638"),
]


func _ready() -> void:
	add_to_group(&"pixel_building")
	set_meta(&"depth_anchor", position)
	_build_collision()
	queue_redraw()


func configure(size_value: Vector2, style_value: int, title_value: String) -> void:
	building_size = size_value
	style = posmod(style_value, WALL_COLORS.size())
	title = title_value
	queue_redraw()


func navigation_blocker() -> Rect2:
	return Rect2(
		position.x - building_size.x * 0.5 + 8.0,
		position.y - 44.0,
		building_size.x - 16.0,
		52.0
	)


func _build_collision() -> void:
	var body := StaticBody2D.new()
	body.name = "BuildingCollision"
	body.collision_layer = 1
	body.collision_mask = 0
	var shape_node := CollisionShape2D.new()
	shape_node.name = "Footprint"
	var shape := RectangleShape2D.new()
	shape.size = Vector2(building_size.x - 16.0, 44.0)
	shape_node.shape = shape
	shape_node.position = Vector2(0.0, -18.0)
	body.add_child(shape_node)
	add_child(body)


func _draw() -> void:
	var width := building_size.x
	var height := building_size.y
	var wall_top := -height * 0.55
	var roof_top := -height
	var wall_color := WALL_COLORS[posmod(style, WALL_COLORS.size())]
	var roof_color := ROOF_COLORS[posmod(style, ROOF_COLORS.size())]

	draw_rect(Rect2(-width * 0.5 + 8, -8, width, 14), Color(0.08, 0.1, 0.09, 0.35))
	draw_rect(Rect2(-width * 0.5, wall_top, width, -wall_top), Color("#4a3c32"))
	draw_rect(Rect2(-width * 0.5 + 6, wall_top + 5, width - 12, -wall_top - 10), wall_color)
	for beam_x in range(int(-width * 0.5 + 24), int(width * 0.5), 52):
		draw_rect(Rect2(beam_x, wall_top + 6, 7, -wall_top - 12), Color("#574331"))
	draw_rect(Rect2(-width * 0.5 + 8, -20, width - 16, 9), Color("#69513a"))

	var roof_points := PackedVector2Array([
		Vector2(-width * 0.5 - 18, wall_top + 6),
		Vector2(-width * 0.36, roof_top),
		Vector2(width * 0.34, roof_top),
		Vector2(width * 0.5 + 18, wall_top + 6),
	])
	draw_colored_polygon(roof_points, roof_color)
	draw_polyline(roof_points, Color("#352d30"), 7.0)
	for row in range(4):
		var row_y := roof_top + 24 + row * 20
		var inset := 10 + row * 11
		draw_line(Vector2(-width * 0.36 - 2 + inset, row_y), Vector2(width * 0.35 + 2 - inset, row_y), Color("#9b6950"), 4.0)

	var door_width := 38.0
	draw_rect(Rect2(-door_width * 0.5, -72, door_width, 72), Color("#3d2f2b"))
	draw_rect(Rect2(-door_width * 0.5 + 6, -64, door_width - 12, 64), Color("#6c4c37"))
	draw_rect(Rect2(9, -35, 5, 5), Color("#d3b45d"))
	for window_x in [-width * 0.31, width * 0.31]:
		draw_rect(Rect2(window_x - 19, -88, 38, 34), Color("#4b3b32"))
		draw_rect(Rect2(window_x - 14, -83, 28, 24), Color("#9ac0b1"))
		draw_line(Vector2(window_x, -83), Vector2(window_x, -59), Color("#ece2b4"), 3.0)
		draw_line(Vector2(window_x - 14, -71), Vector2(window_x + 14, -71), Color("#ece2b4"), 3.0)

	if style % 2 == 0:
		draw_rect(Rect2(width * 0.22, roof_top - 18, 30, 68), Color("#4a3e39"))
		draw_rect(Rect2(width * 0.22 - 4, roof_top - 20, 38, 10), Color("#302a2a"))
