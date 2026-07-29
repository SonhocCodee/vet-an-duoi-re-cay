extends SceneTree

const MAP_SCENE: String = "res://scenes/maps/map2_tutorial_road.tscn"
const MAP_SCRIPT: String = "res://scripts/maps/map2/map2_tutorial_road.gd"
const ARIA_SCENE: String = "res://scenes/npcs/aria/aria_map2.tscn"
const ARIA_DIALOGUE: String = "res://resources/story/map2/aria_after_stag.tres"
const TUTORIAL_DIRECTORY: String = "res://resources/tutorial/map2"

var _failures: Array[String] = []


func _init() -> void:
	_check_required_files()
	_check_scene_contract()
	_check_runtime_contract()
	_check_story_contract()
	if _failures.is_empty():
		print("Map 2 contract checks passed.")
		quit(0)
		return
	for failure: String in _failures:
		push_error(failure)
	quit(1)


func _check_required_files() -> void:
	var required_paths: Array[String] = [
		MAP_SCENE,
		MAP_SCRIPT,
		ARIA_SCENE,
		ARIA_DIALOGUE,
		TUTORIAL_DIRECTORY + "/combo_finisher.tres",
		TUTORIAL_DIRECTORY + "/dodge_telegraph.tres",
		TUTORIAL_DIRECTORY + "/skill_1.tres",
		TUTORIAL_DIRECTORY + "/root_antler_stag.tres",
	]
	for required_path: String in required_paths:
		_expect(FileAccess.file_exists(required_path), "Missing Map 2 file: %s" % required_path)


func _check_scene_contract() -> void:
	var scene_text: String = FileAccess.get_file_as_string(MAP_SCENE)
	_expect('metadata/map_size = Vector2(2200, 900)' in scene_text, "Map 2 must remain 2200x900.")
	_expect('[node name="default" type="Marker2D" parent="SpawnPoints"]' in scene_text, "Missing default spawn point.")
	_expect('[node name="from_map1" type="Marker2D" parent="SpawnPoints"]' in scene_text, "Missing from_map1 spawn point.")
	_expect(scene_text.count('script = ExtResource("2_zone")') == 4, "Map 2 must contain four encounter zones.")
	_expect('name="Player"' not in scene_text, "Map 2 must not instance PlayerController.")
	_expect('name="HUD"' not in scene_text, "Map 2 must not contain HUD.")


func _check_runtime_contract() -> void:
	var script_text: String = FileAccess.get_file_as_string(MAP_SCRIPT)
	_expect('preload("res://scenes/actors/enemies/mist_shade.tscn")' in script_text, "Mist Shade scene must be preloaded.")
	_expect('preload("res://scenes/actors/enemies/root_wolf.tscn")' in script_text, "Root Wolf scene must be preloaded.")
	_expect('preload("res://scenes/actors/enemies/weeping_mushroom.tscn")' in script_text, "Mushroom scene must be preloaded.")
	_expect('preload("res://scenes/actors/enemies/root_antler_stag.tscn")' in script_text, "Root Antler Stag scene must be preloaded.")
	_expect('player_controller.connect(&"action_committed"' in script_text, "Map 2 must track PlayerController.action_committed.")
	_expect('enemy.connect(&"telegraph_started"' in script_text, "Map 2 must track EnemyBase.telegraph_started.")
	_expect('enemy.connect(&"died"' in script_text, "Map 2 must track EnemyBase.died.")
	_expect('game_events.emit_signal(&"tutorial_requested"' in script_text, "Tutorial UI must route through GameEvents.")
	_expect('game_events.emit_signal(&"dialogue_requested"' in script_text, "Aria dialogue must route through GameEvents.")
	_expect('GameEvents.map_change_requested.emit(destination_map_id, spawn_id)' in script_text, "Map 3 transition must use the shared router event.")


func _check_story_contract() -> void:
	var dialogue_text: String = FileAccess.get_file_as_string(ARIA_DIALOGUE)
	_expect("map2_aria_after_root_antler_stag" in dialogue_text, "Aria post-boss dialogue ID is missing.")
	_expect("Cổng thị trấn ở phía đông" in dialogue_text, "Aria dialogue must lead the player toward Map 3.")


func _expect(condition: bool, message: String) -> void:
	if not condition:
		_failures.append(message)
