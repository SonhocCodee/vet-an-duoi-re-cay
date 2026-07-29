extends Node

const CAMPAIGN_DIRECTOR_SCRIPT := "res://autoload/campaign_director.gd"
const CHAPTER_DEFINITION_SCRIPT := "res://scripts/campaign/data/chapter_definition.gd"
const TRUE_ENDING_CONSTANT := "MAP_TRUE_ENDING"
const TRUE_ENDING_ID: StringName = &"true_ending"
const TRUE_ENDING_SCENE := "res://scenes/ending/true_ending.tscn"

const CHAPTERS: Array[Dictionary] = [
	{"number": 2, "constant": "MAP_CHAPTER_2", "map_id": &"chapter_2_drowned_bells", "scene": "res://scenes/maps/campaign/chapter_2_drowned_bells.tscn", "definition": "res://resources/campaign/chapters/chapter_2_drowned_bells.tres", "boss": &"boss_drowned_executioner", "next_map_id": &"chapter_3_blind_procession"},
	{"number": 3, "constant": "MAP_CHAPTER_3", "map_id": &"chapter_3_blind_procession", "scene": "res://scenes/maps/campaign/chapter_3_blind_procession.tscn", "definition": "res://resources/campaign/chapters/chapter_3_blind_procession.tres", "boss": &"boss_hollow_paladin", "next_map_id": &"chapter_4_erased_archive"},
	{"number": 4, "constant": "MAP_CHAPTER_4", "map_id": &"chapter_4_erased_archive", "scene": "res://scenes/maps/campaign/chapter_4_erased_archive.tscn", "definition": "res://resources/campaign/chapters/chapter_4_erased_archive.tres", "boss": &"boss_blind_archivist", "next_map_id": &"chapter_5_quartz_wastes"},
	{"number": 5, "constant": "MAP_CHAPTER_5", "map_id": &"chapter_5_quartz_wastes", "scene": "res://scenes/maps/campaign/chapter_5_quartz_wastes.tscn", "definition": "res://resources/campaign/chapters/chapter_5_quartz_wastes.tres", "boss": &"boss_quartz_matriarch", "next_map_id": &"chapter_6_burning_root_garden"},
	{"number": 6, "constant": "MAP_CHAPTER_6", "map_id": &"chapter_6_burning_root_garden", "scene": "res://scenes/maps/campaign/chapter_6_burning_root_garden.tscn", "definition": "res://resources/campaign/chapters/chapter_6_burning_root_garden.tres", "boss": &"boss_burning_root", "next_map_id": &"chapter_7_black_resin_pass"},
	{"number": 7, "constant": "MAP_CHAPTER_7", "map_id": &"chapter_7_black_resin_pass", "scene": "res://scenes/maps/campaign/chapter_7_black_resin_pass.tscn", "definition": "res://resources/campaign/chapters/chapter_7_black_resin_pass.tres", "boss": &"boss_betrayer_knight", "next_map_id": &"chapter_8_empty_monastery"},
	{"number": 8, "constant": "MAP_CHAPTER_8", "map_id": &"chapter_8_empty_monastery", "scene": "res://scenes/maps/campaign/chapter_8_empty_monastery.tscn", "definition": "res://resources/campaign/chapters/chapter_8_empty_monastery.tres", "boss": &"boss_empty_abbot", "next_map_id": &"chapter_9_false_sun_citadel"},
	{"number": 9, "constant": "MAP_CHAPTER_9", "map_id": &"chapter_9_false_sun_citadel", "scene": "res://scenes/maps/campaign/chapter_9_false_sun_citadel.tscn", "definition": "res://resources/campaign/chapters/chapter_9_false_sun_citadel.tres", "boss": &"boss_false_sun", "next_map_id": &"chapter_10_world_root"},
	{"number": 10, "constant": "MAP_CHAPTER_10", "map_id": &"chapter_10_world_root", "scene": "res://scenes/maps/campaign/chapter_10_world_root.tscn", "definition": "res://resources/campaign/chapters/chapter_10_world_root.tres", "boss": &"boss_papal_root_avatar", "next_map_id": TRUE_ENDING_ID},
]

const BOSS_IDS: Array[StringName] = [
	&"boss_drowned_executioner", &"boss_hollow_paladin",
	&"boss_blind_archivist", &"boss_quartz_matriarch",
	&"boss_burning_root", &"boss_betrayer_knight",
	&"boss_empty_abbot", &"boss_false_sun",
	&"boss_papal_root_avatar", &"boss_corrupted_asterion",
]

var _failures := PackedStringArray()
var _checks_run := 0


func _ready() -> void:
	_check_required_scripts()
	_check_game_ids_and_router()
	_check_game_state()
	_check_campaign_director()
	_check_chapters()
	_check_bosses()
	_check_ending()
	_finish()


func _check_required_scripts() -> void:
	_check_file(CAMPAIGN_DIRECTOR_SCRIPT, "CampaignDirector script")
	_check_file(CHAPTER_DEFINITION_SCRIPT, "ChapterDefinition script")


func _check_game_ids_and_router() -> void:
	var game_ids: Node = _autoload("GameIds")
	var router: Node = _autoload("SceneRouter")
	var id_constants := _script_constants(game_ids, "GameIds")
	var router_constants := _script_constants(router, "SceneRouter")
	var map_paths: Dictionary = {}
	var map_paths_value: Variant = router_constants.get(
		"MAP_PATHS",
		router_constants.get(&"MAP_PATHS", null)
	)
	if map_paths_value is Dictionary:
		map_paths = map_paths_value
	else:
		_fail("SceneRouter", "missing Dictionary constant MAP_PATHS")
	for chapter: Dictionary in CHAPTERS:
		_check_constant_value(id_constants, String(chapter["constant"]), chapter["map_id"], "GameIds")
		_check_route(map_paths, chapter["map_id"], String(chapter["scene"]))
	_check_constant_value(id_constants, TRUE_ENDING_CONSTANT, TRUE_ENDING_ID, "GameIds")
	_check_route(map_paths, TRUE_ENDING_ID, TRUE_ENDING_SCENE)


func _check_game_state() -> void:
	var state: Node = _autoload("GameState")
	if state == null:
		return
	_check_property(state, &"current_chapter", "GameState")
	_check_methods(state, "GameState", PackedStringArray([
		"record_choice", "complete_chapter", "is_chapter_complete",
		"to_save_data", "load_save_data"
	]))
	var state_constants := _script_constants(state, "GameState")
	_check_constant_value(state_constants, "SAVE_VERSION", 3, "GameState")


func _check_campaign_director() -> void:
	var director: Node = _autoload("CampaignDirector")
	if director == null:
		return
	_check_methods(director, "CampaignDirector", PackedStringArray([
		"start_from_hub", "go_to_chapter", "complete_chapter", "get_chapter_map"
	]))
	var events: Node = _autoload("GameEvents")
	if events == null:
		return
	_check_signals(events, "GameEvents", PackedStringArray([
		"moral_choice_requested", "moral_choice_resolved",
		"chapter_completed", "campaign_completed"
	]))


func _check_chapters() -> void:
	for chapter: Dictionary in CHAPTERS:
		var number: int = int(chapter["number"])
		var label := "Chapter %d" % number
		var definition := _load_resource(String(chapter["definition"]), "%s definition" % label)
		if definition != null:
			_check_resource_class(definition, &"ChapterDefinition", "%s definition" % label)
			_check_resource_property(definition, &"chapter_number", number, "%s definition" % label)
			_check_resource_property(definition, &"chapter_id", chapter["map_id"], "%s definition" % label)
			_check_resource_property(definition, &"boss_enemy_id", chapter["boss"], "%s definition" % label)
			_check_resource_property(definition, &"next_map_id", chapter["next_map_id"], "%s definition" % label)
		var map_instance := _instantiate_scene(String(chapter["scene"]), "%s map" % label)
		if map_instance != null:
			add_child(map_instance)
			_check_spawn(map_instance, label)
			map_instance.free()


func _check_bosses() -> void:
	for boss_id: StringName in BOSS_IDS:
		var label := "Boss %s" % boss_id
		var boss_resource_path := "res://resources/enemies/campaign/%s.tres" % boss_id
		var boss_scene_path := "res://scenes/actors/enemies/campaign/%s.tscn" % boss_id
		var boss_resource := _load_resource(boss_resource_path, "%s resource" % label)
		if boss_resource != null:
			_check_resource_property(boss_resource, &"enemy_id", boss_id, "%s resource" % label)
		var boss_instance := _instantiate_scene(boss_scene_path, "%s scene" % label)
		if boss_instance != null:
			boss_instance.free()


func _check_ending() -> void:
	var ending := _instantiate_scene(TRUE_ENDING_SCENE, "True Ending")
	if ending != null:
		ending.free()


func _check_file(path: String, label: String) -> void:
	_checks_run += 1
	if FileAccess.file_exists(path):
		_pass(label, "%s exists" % path)
	else:
		_fail(label, "%s is missing" % path)


func _autoload(autoload_name: String) -> Node:
	_checks_run += 1
	var singleton: Node = get_node_or_null(NodePath("/root/%s" % autoload_name))
	if singleton == null:
		_fail("Autoload", "%s is not registered" % autoload_name)
	else:
		_pass("Autoload", "%s is registered" % autoload_name)
	return singleton


func _script_constants(target: Object, label: String) -> Dictionary:
	if target == null:
		return {}
	var script: Script = target.get_script() as Script
	_checks_run += 1
	if script == null:
		_fail(label, "has no script for constant inspection")
		return {}
	_pass(label, "script constants are inspectable")
	return script.get_script_constant_map()


func _check_constant_value(constants: Dictionary, name: String, expected: Variant, label: String) -> void:
	_checks_run += 1
	var actual: Variant = constants.get(name, constants.get(StringName(name), null))
	if actual == expected:
		_pass(label, "%s = %s" % [name, expected])
	else:
		_fail(label, "%s expected %s, got %s" % [name, expected, actual])


func _check_route(map_paths: Dictionary, map_id: StringName, expected_path: String) -> void:
	_checks_run += 1
	var actual := String(map_paths.get(map_id, ""))
	if actual == expected_path:
		_pass("SceneRouter", "%s routes to %s" % [map_id, expected_path])
	else:
		_fail("SceneRouter", "%s expected route %s, got %s" % [map_id, expected_path, actual])


func _check_property(target: Object, property_name: StringName, label: String) -> void:
	_checks_run += 1
	if _has_property(target, property_name):
		_pass(label, "property %s exists" % property_name)
	else:
		_fail(label, "missing property %s" % property_name)


func _has_property(target: Object, property_name: StringName) -> bool:
	for property: Dictionary in target.get_property_list():
		if StringName(property.get("name", "")) == property_name:
			return true
	return false


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


func _load_resource(path: String, label: String) -> Resource:
	_checks_run += 1
	if not ResourceLoader.exists(path):
		_fail(label, "%s is missing" % path)
		return null
	var resource: Resource = ResourceLoader.load(path)
	if resource == null:
		_fail(label, "%s exists but failed to load" % path)
		return null
	_pass(label, "%s loads" % path)
	return resource


func _check_resource_class(resource: Resource, expected_class: StringName, label: String) -> void:
	_checks_run += 1
	var script: Script = resource.get_script() as Script
	var actual_class: StringName = script.get_global_name() if script != null else &""
	if actual_class == expected_class:
		_pass(label, "uses script class %s" % expected_class)
	else:
		_fail(label, "expected script class %s, got %s" % [expected_class, actual_class])


func _check_resource_property(resource: Resource, property_name: StringName, expected: Variant, label: String) -> void:
	_checks_run += 1
	if not _has_property(resource, property_name):
		_fail(label, "missing property %s" % property_name)
		return
	var actual: Variant = resource.get(property_name)
	if actual == expected:
		_pass(label, "%s matches %s" % [property_name, expected])
	else:
		_fail(label, "%s expected %s, got %s" % [property_name, expected, actual])


func _instantiate_scene(path: String, label: String) -> Node:
	_checks_run += 1
	if not ResourceLoader.exists(path, "PackedScene"):
		_fail(label, "%s is missing or is not a PackedScene" % path)
		return null
	var resource: Resource = ResourceLoader.load(path, "PackedScene")
	if not resource is PackedScene:
		_fail(label, "%s failed to load as PackedScene" % path)
		return null
	var instance: Node = (resource as PackedScene).instantiate()
	if instance == null:
		_fail(label, "%s loaded but could not instantiate" % path)
		return null
	_pass(label, "%s loads and instantiates" % path)
	return instance


func _check_spawn(map_instance: Node, label: String) -> void:
	_checks_run += 1
	var spawn: Node = map_instance.get_node_or_null("SpawnPoints/default")
	if spawn == null:
		_fail(label, "missing SpawnPoints/default")
	elif spawn is Marker2D:
		_pass(label, "SpawnPoints/default is Marker2D")
	else:
		_fail(label, "SpawnPoints/default must be Marker2D, got %s" % spawn.get_class())


func _pass(scope: String, message: String) -> void:
	print("[CAMPAIGN_SMOKE][PASS][%s] %s" % [scope, message])


func _fail(scope: String, message: String) -> void:
	var failure := "[%s] %s" % [scope, message]
	_failures.append(failure)
	push_error("[CAMPAIGN_SMOKE][FAIL]%s" % failure)


func _finish() -> void:
	if _failures.is_empty():
		print("[CAMPAIGN_SMOKE][PASS] %d checks completed." % _checks_run)
		get_tree().quit(0)
		return
	print("[CAMPAIGN_SMOKE][SUMMARY] %d of %d checks failed:" % [_failures.size(), _checks_run])
	for failure: String in _failures:
		print("  - %s" % failure)
	get_tree().quit(1)
