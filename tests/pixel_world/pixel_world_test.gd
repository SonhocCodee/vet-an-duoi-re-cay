extends Node

const BUILDING_SCRIPT := preload("res://scripts/world/pixel/pixel_building.gd")
const PROP_SCRIPT := preload("res://scripts/world/pixel/pixel_prop.gd")

var checks := 0
var failures: Array[String] = []


func _ready() -> void:
	await _run()
	if failures.is_empty():
		print("[PIXEL_WORLD] PASS %d/%d" % [checks, checks])
		get_tree().quit(0)
	else:
		for failure: String in failures:
			push_error("[PIXEL_WORLD] " + failure)
		print("[PIXEL_WORLD] FAIL %d issue(s), %d checks" % [failures.size(), checks])
		get_tree().quit(1)


func _run() -> void:
	var packed := load("res://scenes/maps/pixel/ashenvale_city_world.tscn") as PackedScene
	_check(packed != null, "pixel world scene loads")
	if packed == null:
		return
	var world := packed.instantiate()
	add_child(world)
	await get_tree().process_frame
	await get_tree().physics_frame

	_check(world.is_in_group(&"pixel_world"), "map root identifies as pixel world")
	var camera := world.get_node_or_null(^"ExplorationCamera") as Camera2D
	_check(camera != null, "world provides exploration camera")
	_check(camera != null and camera.zoom == Vector2(2, 2), "camera uses 2x pixel zoom")
	_check(camera != null and camera.limit_right == 1920 and camera.limit_bottom == 1280, "camera limits match world")

	var city := world.get_node_or_null(^"CityCore")
	_check(city != null, "city core instantiates")
	if city == null:
		world.queue_free()
		return
	_check(city.get_meta(&"projection") == &"pixel_top_down_3_4", "world declares top-down 3/4 projection")
	_check(city.layout.navigation_cell_size == 32, "world uses 32px navigation tiles")
	_check(city.layout.road_rects.size() >= 7, "village has connected road hierarchy")
	_check(city.layout.environment_asset_root == "res://assets/art/pixel/environment/", "future pixel asset root is reserved")

	var y_sort_world := city.get_node(^"YSortWorld") as Node2D
	_check(y_sort_world.y_sort_enabled, "world object layer enables Y-sort")
	var buildings: Array[Node] = []
	var props: Array[Node] = []
	for child: Node in y_sort_world.get_children():
		if child.get_script() == BUILDING_SCRIPT:
			buildings.append(child)
		elif child.get_script() == PROP_SCRIPT:
			props.append(child)
	_check(buildings.size() == 12, "12 explorable village buildings exist")
	_check(props.size() >= 80, "village has dense trees, fences, market and decoration")

	var tree_count := 0
	var stall_count := 0
	var fence_count := 0
	var solid_prop_count := 0
	for prop: Node in props:
		_check(prop.get_parent() == y_sort_world, "%s participates directly in Y-sort" % prop.name)
		_check(prop.has_meta(&"depth_anchor"), "%s has a foot depth anchor" % prop.name)
		if prop.kind == PROP_SCRIPT.Kind.TREE:
			tree_count += 1
		elif prop.kind == PROP_SCRIPT.Kind.MARKET_STALL:
			stall_count += 1
		elif prop.kind == PROP_SCRIPT.Kind.FENCE:
			fence_count += 1
		if prop.is_solid():
			solid_prop_count += 1
			_check(prop.get_node_or_null(^"PropCollision") != null, "%s has collision" % prop.name)
	_check(tree_count >= 28, "tree canopy population supports natural occlusion")
	_check(stall_count == 4, "market square has four stalls")
	_check(fence_count >= 15, "pond and farm have readable fence boundaries")
	_check(solid_prop_count == city.solid_prop_count(), "solid prop registry is consistent")

	for building: Node in buildings:
		_check(building.get_parent() == y_sort_world, "%s participates directly in Y-sort" % building.name)
		_check(building.get_node_or_null(^"BuildingCollision") != null, "%s has footprint collision" % building.name)
		_check(building.building_size.y >= 192.0, "%s has roof/body depth" % building.name)
		_check(building.position.y - building.building_size.y >= 0.0, "%s stays inside upper world bound" % building.name)

	var spawn_points: Array[Node] = city.get_node(^"NpcSpawnPoints").get_children()
	var patrol_points: Array[Node] = city.get_node(^"PatrolPoints").get_children()
	_check(spawn_points.size() == 20, "exactly 20 NPC spawn points exist")
	_check(patrol_points.size() >= 30, "NPCs have a broad patrol network")
	var blockers: Array = city.navigation_blockers()
	for spawn: Node2D in spawn_points:
		_check(not _point_in_blockers(spawn.position, blockers), "%s starts outside collision" % spawn.name)

	var region := city.get_node(^"NavigationRegion2D") as NavigationRegion2D
	_check(region.navigation_polygon != null, "navigation polygon exists")
	_check(region.navigation_polygon.get_polygon_count() > 1200, "navigation covers the village at 32px resolution")
	_check(int(region.get_meta(&"blocker_count", 0)) == blockers.size(), "navigation records every blocker")
	_check(city.get_node(^"Collision/WorldBorder") != null, "world has four-sided collision boundary")

	for landmark_name in [&"MarketSquare", &"NorthGate", &"SouthGate", &"WestGate", &"EastGate"]:
		var landmark := city.get_node(^"Landmarks").get_node_or_null(NodePath(String(landmark_name))) as Marker2D
		_check(landmark != null, "%s landmark exists" % landmark_name)
		_check(landmark != null and not _point_in_blockers(landmark.position, blockers), "%s remains approachable" % landmark_name)

	world.queue_free()
	await get_tree().process_frame


func _point_in_blockers(point: Vector2, blockers: Array) -> bool:
	for blocker: Rect2 in blockers:
		if blocker.grow(4.0).has_point(point):
			return true
	return false


func _check(condition: bool, message: String) -> void:
	checks += 1
	if not condition:
		failures.append(message)
