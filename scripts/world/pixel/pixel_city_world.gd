class_name PixelCityWorld
extends Node2D

@export var layout: Resource

const BUILDING_SCENE := preload("res://scenes/city/pixel/pixel_building.tscn")
const PROP_SCENE := preload("res://scenes/city/pixel/pixel_prop.tscn")
const PROP_SCRIPT := preload("res://scripts/world/pixel/pixel_prop.gd")
const BUILDING_NAMES: PackedStringArray = [
	"Blacksmith", "Herbalist", "Old Chapel", "Bakery", "Guard House", "Cartographer",
	"Tavern", "Weaver", "Mason", "Archive", "Hunter Lodge", "Town Hall",
]

@onready var background: Node2D = $Ground/PixelCanvas
@onready var y_sort_world: Node2D = $YSortWorld
@onready var navigation_region: NavigationRegion2D = $NavigationRegion2D
@onready var npc_spawn_points: Node2D = $NpcSpawnPoints
@onready var patrol_points: Node2D = $PatrolPoints

var _navigation_blockers: Array[Rect2] = []
var _solid_prop_count := 0


func _ready() -> void:
	if layout == null or not layout.is_valid():
		push_error("PixelCityWorld requires a valid PixelCityLayout")
		return
	set_meta(&"projection", &"pixel_top_down_3_4")
	set_meta(&"world_size", layout.world_size)
	background.configure(layout)
	_build_buildings()
	_build_environment()
	_build_world_border()
	_build_navigation()
	_build_npc_points()


func _build_buildings() -> void:
	for index in layout.building_bases.size():
		var building := BUILDING_SCENE.instantiate()
		building.name = "Building_%02d_%s" % [index + 1, BUILDING_NAMES[index].replace(" ", "")]
		building.position = layout.building_bases[index]
		building.configure(layout.building_sizes[index], layout.building_styles[index], BUILDING_NAMES[index])
		y_sort_world.add_child(building)
		_navigation_blockers.append(building.navigation_blocker())


func _build_environment() -> void:
	for index in layout.tree_positions.size():
		_spawn_prop(PROP_SCRIPT.Kind.TREE, layout.tree_positions[index], index)
	for index in layout.market_positions.size():
		_spawn_prop(PROP_SCRIPT.Kind.MARKET_STALL, layout.market_positions[index], index)
	_spawn_prop(PROP_SCRIPT.Kind.WELL, Vector2(960, 824), 0)

	for x in range(96, 608, 64):
		if x < 288 or x > 416:
			_spawn_prop(PROP_SCRIPT.Kind.FENCE, Vector2(x, 1000), x / 64, true)
	for x in range(1344, 1824, 64):
		if x < 1536 or x > 1664:
			_spawn_prop(PROP_SCRIPT.Kind.FENCE, Vector2(x, 928), x / 64, true)
	for y in range(976, 1216, 64):
		_spawn_prop(PROP_SCRIPT.Kind.FENCE, Vector2(1296, y), y / 64, false)
		_spawn_prop(PROP_SCRIPT.Kind.FENCE, Vector2(1856, y), y / 64, false)

	for index in layout.market_positions.size():
		var stall_position: Vector2 = layout.market_positions[index]
		_spawn_prop(PROP_SCRIPT.Kind.CRATE, stall_position + Vector2(-58, 8), index)
	for lamp_position in [
		Vector2(600, 520), Vector2(760, 520), Vector2(1160, 520), Vector2(1320, 520),
		Vector2(600, 760), Vector2(760, 760), Vector2(1160, 760), Vector2(1320, 760),
	]:
		_spawn_prop(PROP_SCRIPT.Kind.LAMP, lamp_position)
	for sign_position in [Vector2(832, 640), Vector2(1088, 640), Vector2(960, 336), Vector2(960, 944)]:
		_spawn_prop(PROP_SCRIPT.Kind.SIGN, sign_position)
	for flower_index in 24:
		var column := flower_index % 8
		var row := flower_index / 8
		_spawn_prop(PROP_SCRIPT.Kind.FLOWER, Vector2(688 + column * 74, 430 + row * 190), flower_index)

	_navigation_blockers.append(Rect2(64, 1016, 560, 184))


func _spawn_prop(kind: int, prop_position: Vector2, variant: int = 0, horizontal: bool = true) -> Node2D:
	var prop := PROP_SCENE.instantiate()
	prop.name = "%s_%03d" % [PROP_SCRIPT.Kind.keys()[kind], y_sort_world.get_child_count()]
	prop.position = prop_position
	prop.configure(kind, variant, horizontal)
	y_sort_world.add_child(prop)
	if prop.is_solid():
		_navigation_blockers.append(prop.navigation_blocker())
		_solid_prop_count += 1
	return prop


func _build_world_border() -> void:
	var body := StaticBody2D.new()
	body.name = "WorldBorder"
	body.collision_layer = 1
	body.collision_mask = 0
	var size := Vector2(layout.world_size)
	_add_border_shape(body, Vector2(size.x * 0.5, 8), Vector2(size.x, 16))
	_add_border_shape(body, Vector2(size.x * 0.5, size.y - 8), Vector2(size.x, 16))
	_add_border_shape(body, Vector2(8, size.y * 0.5), Vector2(16, size.y))
	_add_border_shape(body, Vector2(size.x - 8, size.y * 0.5), Vector2(16, size.y))
	$Collision.add_child(body)


func _add_border_shape(body: StaticBody2D, shape_position: Vector2, shape_size: Vector2) -> void:
	var shape_node := CollisionShape2D.new()
	var rectangle := RectangleShape2D.new()
	rectangle.size = shape_size
	shape_node.shape = rectangle
	shape_node.position = shape_position
	body.add_child(shape_node)


func _build_navigation() -> void:
	var cell_size: int = layout.navigation_cell_size
	var column_count: int = layout.world_size.x / cell_size
	var row_count: int = layout.world_size.y / cell_size
	var vertices := PackedVector2Array()
	var vertex_lookup: Dictionary = {}
	var polygons: Array[PackedInt32Array] = []

	for row in range(1, row_count - 1):
		for column in range(1, column_count - 1):
			var cell_rect := Rect2(column * cell_size, row * cell_size, cell_size, cell_size)
			if _is_blocked(cell_rect):
				continue
			var corners: Array[Vector2i] = [
				Vector2i(column, row), Vector2i(column + 1, row),
				Vector2i(column + 1, row + 1), Vector2i(column, row + 1),
			]
			var polygon := PackedInt32Array()
			for corner: Vector2i in corners:
				if not vertex_lookup.has(corner):
					vertex_lookup[corner] = vertices.size()
					vertices.append(Vector2(corner * cell_size))
				polygon.append(vertex_lookup[corner])
			polygons.append(polygon)

	var navigation_polygon := NavigationPolygon.new()
	navigation_polygon.vertices = vertices
	for polygon: PackedInt32Array in polygons:
		navigation_polygon.add_polygon(polygon)
	navigation_region.navigation_polygon = navigation_polygon
	navigation_region.set_meta(&"walkable_cell_count", polygons.size())
	navigation_region.set_meta(&"blocker_count", _navigation_blockers.size())


func _is_blocked(cell_rect: Rect2) -> bool:
	var inset_cell := cell_rect.grow(-3.0)
	for blocker: Rect2 in _navigation_blockers:
		if blocker.grow(5.0).intersects(inset_cell):
			return true
	return false


func _build_npc_points() -> void:
	for index in layout.npc_spawn_positions.size():
		var marker := Marker2D.new()
		marker.name = "NpcSpawn_%02d" % [index + 1]
		marker.position = layout.npc_spawn_positions[index]
		marker.add_to_group(&"pixel_npc_spawn")
		npc_spawn_points.add_child(marker)
	for index in layout.patrol_positions.size():
		var marker := Marker2D.new()
		marker.name = "Patrol_%02d" % [index + 1]
		marker.position = layout.patrol_positions[index]
		marker.add_to_group(&"pixel_patrol_point")
		patrol_points.add_child(marker)


func navigation_blockers() -> Array[Rect2]:
	return _navigation_blockers.duplicate()


func solid_prop_count() -> int:
	return _solid_prop_count
