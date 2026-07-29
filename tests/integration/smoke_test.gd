extends Node

const MAP_SCENES: Array[Dictionary] = [
	{"label": "Map 1", "path": "res://scenes/maps/map1_awakening_forest.tscn"},
	{"label": "Map 2", "path": "res://scenes/maps/map2_tutorial_road.tscn"},
	{"label": "Map 3", "path": "res://scenes/maps/map3_ashen_town_hub.tscn"},
]
const MAIN_SCENE_PATH := "res://scenes/bootstrap/main.tscn"
const PLAYER_SCENE_PATH := "res://scenes/actors/player/player.tscn"
const HUD_SCENE_PATH := "res://scenes/ui/game_hud.tscn"
const REQUIRED_AUTOLOAD_FILES = [
	"res://autoload/game_ids.gd",
	"res://autoload/game_events.gd",
	"res://autoload/game_state.gd",
	"res://autoload/save_service.gd",
	"res://autoload/scene_router.gd",
]

var _failures := PackedStringArray()
var _checks_run := 0


func _ready() -> void:
	_check_required_autoload_files()
	_check_main_scene()
	_check_map_scenes()
	_check_player_scene()
	_check_hud_scene()
	_check_autoload_contracts()
	_finish()


func _check_main_scene() -> void:
	var main := _instantiate_scene(MAIN_SCENE_PATH, "Main")
	if main == null:
		return
	for required_path: String in PackedStringArray([
		"World/MapContainer", "Interface/HudSocket", "FadeLayer/FadeRect"
	]):
		_checks_run += 1
		if main.get_node_or_null(NodePath(required_path)) == null:
			_fail("Main", "missing required node %s" % required_path)
		else:
			_pass("Main", "required node %s exists" % required_path)
	var main_script: Script = main.get_script() as Script
	_checks_run += 1
	if main_script == null:
		_fail("Main", "root has no integration script")
	else:
		_pass("Main", "root integration script exists")
		var constants: Dictionary = main_script.get_script_constant_map()
		_check_constant_value(constants, "PLAYER_SCENE_PATH", PLAYER_SCENE_PATH, "Main")
		_check_constant_value(constants, "HUD_SCENE_PATH", HUD_SCENE_PATH, "Main")
	main.free()


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


func _check_player_scene() -> void:
	var player := _instantiate_scene(PLAYER_SCENE_PATH, "Player")
	if player == null:
		return
	_checks_run += 1
	if player is CharacterBody2D:
		_pass("Player", "scene root inherits CharacterBody2D")
	else:
		_fail("Player", "scene root must inherit CharacterBody2D, got %s" % player.get_class())
	_check_methods(player, "Player", PackedStringArray([
		"set_control_enabled", "grant_weapon", "restore_full", "receive_damage"
	]))
	_check_signals(player, "Player", PackedStringArray(["action_committed", "died"]))
	player.free()


func _check_hud_scene() -> void:
	var hud := _instantiate_scene(HUD_SCENE_PATH, "HUD")
	if hud == null:
		return
	_checks_run += 1
	if hud is CanvasLayer or hud is Control:
		_pass("HUD", "scene root is CanvasLayer or Control")
	else:
		_fail("HUD", "scene root must be CanvasLayer or Control, got %s" % hud.get_class())
	hud.free()


func _check_autoload_contracts() -> void:
	_check_autoload("GameIds", PackedStringArray(), PackedStringArray(), PackedStringArray([
		"MAP_1", "MAP_2", "MAP_3", "SPAWN_DEFAULT"
	]))
	_check_autoload("GameEvents", PackedStringArray(), PackedStringArray([
		"map_change_requested", "dialogue_requested", "tutorial_requested",
		"hub_panel_requested", "toast_requested"
	]), PackedStringArray())
	_check_autoload("GameState", PackedStringArray([
		"set_flag", "has_flag", "add_item", "add_currency", "gain_exp",
		"allocate_stat", "set_class"
	]), PackedStringArray(), PackedStringArray())
	_check_autoload("SaveService", PackedStringArray([
		"save_game", "load_game"
	]), PackedStringArray(), PackedStringArray())
	_check_autoload("SceneRouter", PackedStringArray([
		"change_map"
	]), PackedStringArray(), PackedStringArray())


func _check_autoload(
	autoload_name: String,
	methods: PackedStringArray,
	signals: PackedStringArray,
	constants: PackedStringArray
) -> void:
	_checks_run += 1
	var singleton: Node = get_node_or_null(NodePath("/root/%s" % autoload_name))
	if singleton == null:
		_fail("Autoload", "%s is not registered at /root/%s" % [autoload_name, autoload_name])
		return
	_pass("Autoload", "%s is registered" % autoload_name)
	_check_methods(singleton, autoload_name, methods)
	_check_signals(singleton, autoload_name, signals)
	_check_script_constants(singleton, autoload_name, constants)


func _check_methods(target: Object, label: String, methods: PackedStringArray) -> void:
	for method_name: String in methods:
		_checks_run += 1
		if target.has_method(StringName(method_name)):
			_pass(label, "method %s() exists" % method_name)
		else:
			_fail(label, "missing method %s()" % method_name)


func _check_signals(target: Object, label: String, signals: PackedStringArray) -> void:
	for signal_name: String in signals:
		_checks_run += 1
		if target.has_signal(StringName(signal_name)):
			_pass(label, "signal %s exists" % signal_name)
		else:
			_fail(label, "missing signal %s" % signal_name)


func _check_script_constants(target: Object, label: String, constants: PackedStringArray) -> void:
	if constants.is_empty():
		return
	var script_value: Variant = target.get_script()
	if not script_value is Script:
		for constant_name: String in constants:
			_checks_run += 1
			_fail(label, "cannot inspect %s because autoload has no script" % constant_name)
		return
	var constant_map: Dictionary = (script_value as Script).get_script_constant_map()
	for constant_name: String in constants:
		_checks_run += 1
		if constant_map.has(constant_name) or constant_map.has(StringName(constant_name)):
			_pass(label, "constant %s exists" % constant_name)
		else:
			_fail(label, "missing script constant %s" % constant_name)


func _check_constant_value(
	constant_map: Dictionary,
	constant_name: String,
	expected: Variant,
	label: String
) -> void:
	_checks_run += 1
	var actual: Variant = constant_map.get(
		constant_name,
		constant_map.get(StringName(constant_name), null)
	)
	if actual == expected:
		_pass(label, "constant %s points to %s" % [constant_name, expected])
	else:
		_fail(label, "constant %s expected %s, got %s" % [constant_name, expected, actual])


func _instantiate_scene(path: String, label: String) -> Node:
	_checks_run += 1
	if not ResourceLoader.exists(path, "PackedScene"):
		_fail(label, "%s does not exist or is not a PackedScene" % path)
		return null
	var resource: Resource = ResourceLoader.load(path, "PackedScene")
	if not resource is PackedScene:
		_fail(label, "%s could not be loaded as PackedScene" % path)
		return null
	var instance: Node = (resource as PackedScene).instantiate()
	if instance == null:
		_fail(label, "%s loaded but could not be instantiated" % path)
		return null
	_pass(label, "%s loads and instantiates" % path)
	return instance


func _pass(scope: String, message: String) -> void:
	print("[SMOKE][PASS][%s] %s" % [scope, message])


func _fail(scope: String, message: String) -> void:
	var failure := "[%s] %s" % [scope, message]
	_failures.append(failure)
	push_error("[SMOKE][FAIL]%s" % failure)


func _finish() -> void:
	if _failures.is_empty():
		print("[SMOKE][PASS] %d checks completed with no failures." % _checks_run)
		get_tree().quit(0)
		return
	print("[SMOKE][SUMMARY] %d of %d checks failed:" % [_failures.size(), _checks_run])
	for failure: String in _failures:
		print("  - %s" % failure)
	get_tree().quit(1)
