extends Node

const MAP_SCENES: Array[Dictionary] = [
	{"label": "Map 1", "path": "res://scenes/maps/map1_awakening_forest.tscn"},
	{"label": "Map 2", "path": "res://scenes/maps/map2_tutorial_road.tscn"},
	{"label": "Map 3", "path": "res://scenes/maps/map3_ashen_town_hub.tscn"},
]
const PLAYER_SCENE_PATH := "res://scenes/actors/player/player.tscn"
const HUD_SCENE_PATH := "res://scenes/ui/hud.tscn"
const REQUIRED_AUTOLOAD_FILES := PackedStringArray([
	"res://autoload/game_ids.gd",
	"res://autoload/game_events.gd",
	"res://autoload/game_state.gd",
	"res://autoload/save_service.gd",
	"res://autoload/scene_router.gd",
])

var _failures := PackedStringArray()
var _checks_run := 0


func _ready() -> void:
	_check_required_autoload_files()
	_check_map_scenes()
	_check_player_scene()
	_check_hud_scene()
	_check_autoload_contracts()
	_finish()


func _check_required_autoload_files() -> void:
	for path: String in REQUIRED_AUTOLOAD_FILES:
		_checks_run += 1
		if FileAccess.file_exists(path):
			_pass("Resource", "%s exists" % path)
		else:
			_fail("Resource", "%s is missing" % path)


func _check_map_scenes() -> void:
	for definition: Dictionary in MAP_SCENES:
		var label: String = definition["label"]
		var path: String = definition["path"]
		var instance := _instantiate_scene(path, label)
		if instance == null:
			continue
		_checks_run += 1
		if instance is Node2D:
			_pass(label, "scene root inherits Node2D")
		else:
			_fail(label, "scene root must inherit Node2D, got %s" % instance.get_class())
		_checks_run += 1
		var spawn: Node = instance.get_node_or_null("SpawnPoints/default")
		if spawn == null:
			_fail(label, "missing required node SpawnPoints/default")
		elif spawn is Marker2D:
			_pass(label, "SpawnPoints/default is a Marker2D")
		else:
			_fail(label, "SpawnPoints/default must be Marker2D, got %s" % spawn.get_class())
		instance.free()
