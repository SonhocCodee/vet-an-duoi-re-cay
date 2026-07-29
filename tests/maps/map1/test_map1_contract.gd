extends SceneTree

const MAP_SCENE := "res://scenes/maps/map1_awakening_forest.tscn"
const MAP_SCRIPT := "res://scripts/maps/map1/map1_awakening_forest.gd"
const WORLD_SCRIPT := "res://scripts/maps/map1/map1_world.gd"
const PILLAR_SCRIPT := "res://scripts/maps/map1/map1_rune_pillar.gd"
const GATE_SCRIPT := "res://scripts/maps/map1/map1_exit_gate.gd"
const DIRECTOR_SCRIPT := "res://scripts/maps/map1/map1_story_director.gd"
const STORY_RESOURCE := "res://resources/story/map1/map1_story_vi.tres"

var _failures: Array[String] = []


func _init() -> void:
	_check_required_files()
	_check_scene_contract()
	_check_gameplay_contracts()
	_check_story_contract()

	if _failures.is_empty():
		print("Map 1 contract checks passed.")
		quit(0)
		return

	for failure: String in _failures:
		push_error(failure)
	quit(1)


func _check_required_files() -> void:
	for path: String in [MAP_SCENE, MAP_SCRIPT, WORLD_SCRIPT, PILLAR_SCRIPT, GATE_SCRIPT, DIRECTOR_SCRIPT, STORY_RESOURCE]:
		_expect(FileAccess.file_exists(path), "Missing required Map 1 file: %s" % path)


func _check_scene_contract() -> void:
	var scene_text := FileAccess.get_file_as_string(MAP_SCENE)
	_expect("[node name=\"default\" type=\"Marker2D\" parent=\"SpawnPoints\"]" in scene_text, "Missing default spawn Marker2D.")
	_expect("[node name=\"from_map2\" type=\"Marker2D\" parent=\"SpawnPoints\"]" in scene_text, "Missing from_map2 spawn Marker2D.")
	_expect("[node name=\"RunePillar\" type=\"Area2D\"" in scene_text, "Missing Rune Pillar interaction area.")
	_expect("collision_layer = 32" in scene_text, "Rune Pillar must use the Interactables layer.")
	_expect("[node name=\"ExitGate\" type=\"Area2D\"" in scene_text, "Missing Map 2 exit gate.")
	_expect("type=\"PlayerController\"" not in scene_text, "Map root must not instance PlayerController.")
	_expect("name=\"HUD\"" not in scene_text, "Map root must not contain HUD.")


func _check_gameplay_contracts() -> void:
	var world_text := FileAccess.get_file_as_string(WORLD_SCRIPT)
	var pillar_text := FileAccess.get_file_as_string(PILLAR_SCRIPT)
	var gate_text := FileAccess.get_file_as_string(GATE_SCRIPT)
	var director_text := FileAccess.get_file_as_string(DIRECTOR_SCRIPT)
	_expect("MAP_SIZE := Vector2(1600.0, 900.0)" in world_text, "Map size contract must remain 1600x900.")
	_expect("_build_boundary_collisions()" in world_text, "Boundary collisions are missing.")
	_expect("_build_tree_collisions()" in world_text, "Tree collisions are missing.")
	_expect("extends Interactable" in pillar_text, "Rune Pillar must use the shared Interactable contract.")
	_expect("player.grant_weapon()" in pillar_text, "Rune Pillar must call PlayerController.grant_weapon().")
	_expect("SceneRouter.get_player()" in director_text, "Story director must resolve the persistent PlayerController.")
	_expect("_player.set_control_enabled(false)" in director_text, "Opening cutscene must lock PlayerController controls.")
	_expect("GameEvents.tutorial_requested.emit(tutorial_id, text)" in director_text, "Tutorial must use the shared GameEvents signature.")
	_expect("GameEvents.dialogue_requested.emit(dialogue_id)" in director_text, "Dialogue must use the shared GameEvents signature.")
	_expect("GameEvents.map_change_requested.emit(GameIds.MAP_2, GameIds.SPAWN_DEFAULT)" in gate_text, "Exit gate must request Map 2 at default spawn.")


func _check_story_contract() -> void:
	var story_text := FileAccess.get_file_as_string(STORY_RESOURCE)
	_expect("WASD" in story_text, "Vietnamese movement tutorial must mention WASD.")
	_expect("Bàn Thạch Rêu Cổ" in story_text, "Rune Pillar dialogue is missing.")
	_expect("Thanh kiếm" in story_text, "Weapon awakening dialogue is missing.")


func _expect(condition: bool, message: String) -> void:
	if not condition:
		_failures.append(message)
