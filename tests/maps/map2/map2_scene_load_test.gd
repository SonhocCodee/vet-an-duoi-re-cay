extends SceneTree

const MAP_SCENE_PATH: String = "res://scenes/maps/map2_tutorial_road.tscn"


func _init() -> void:
	call_deferred(&"_run")


func _run() -> void:
	var map_scene: PackedScene = load(MAP_SCENE_PATH) as PackedScene
	assert(map_scene != null)
	var map_instance: Node = map_scene.instantiate()
	assert(map_instance != null)
	root.add_child(map_instance)
	await process_frame
	assert(map_instance.get_node_or_null("SpawnPoints/default") != null)
	assert(map_instance.get_node_or_null("EncounterZones/BossEncounterZone") != null)
	assert(map_instance.get_node_or_null("Map3ExitGate") != null)
	map_instance.queue_free()
	await process_frame
	quit(0)
