extends SceneTree

const MAP_SCRIPT := "res://scripts/campaign/map/campaign_chapter_map.gd"
const SHRINE_SCRIPT := "res://scripts/campaign/map/campaign_moral_shrine.gd"
const WRAPPERS: Dictionary = {
	"res://scenes/maps/campaign/chapter_2_drowned_bells.tscn": &"chapter_2_drowned_bells",
	"res://scenes/maps/campaign/chapter_3_blind_procession.tscn": &"chapter_3_blind_procession",
	"res://scenes/maps/campaign/chapter_4_erased_archive.tscn": &"chapter_4_erased_archive",
}

var _failures: Array[String] = []


func _init() -> void:
	_check_base_contract()
	_check_wrapper_contracts()
	_check_assets()
	if _failures.is_empty():
		print("Campaign chapter 2-4 map contract checks passed.")
		quit(0)
		return
	for failure: String in _failures:
		push_error(failure)
	quit(1)


func _check_base_contract() -> void:
	_expect(FileAccess.file_exists(MAP_SCRIPT), "Missing CampaignChapterMap script.")
	_expect(FileAccess.file_exists(SHRINE_SCRIPT), "Missing moral shrine script.")
	var map_text := FileAccess.get_file_as_string(MAP_SCRIPT)
	_expect("class_name CampaignChapterMap" in map_text, "CampaignChapterMap class_name is required.")
	_expect("MAP_SIZE := Vector2(2200.0, 900.0)" in map_text, "Campaign map must be 2200x900.")
	_expect("@export_file(\"*.tres\") var chapter_resource_path" in map_text, "chapter_resource_path export is missing.")
	_expect("var _chapter_definition: ChapterDefinition" in map_text, "Map must load ChapterDefinition.")
	_expect("for index: int in range(3)" in map_text, "Exactly three procedural encounter zones are required.")
	_expect("completed_index == 1" in map_text, "Moral shrine must unlock after wave 2.")
	_expect("GameState.call(&\"record_choice\"" in map_text, "Moral choice must use GameState.record_choice.")
	_expect("GameState.call(&\"gain_exp\"" in map_text, "Completion reward must grant EXP.")
	_expect("GameState.call(&\"set_flag\"" in map_text, "Completion and moral flags must use GameState.set_flag.")
	_expect("GameEvents.moral_choice_requested.emit" in map_text, "Moral choice must use GameEvents.")
	_expect("GameEvents.dialogue_requested.emit" in map_text, "Narrative must use GameEvents dialogue.")
	_expect("CampaignDirector.complete_chapter(_chapter_number, chapter_id, _next_map_id)" in map_text, "Completion must delegate progression and routing to CampaignDirector.")
	_expect("GENERIC_CAMPAIGN_ENEMY_PATH" in map_text, "Generic campaign enemy fallback is required.")
	for fallback_path: String in [
		"res://scenes/actors/enemies/mist_shade.tscn",
		"res://scenes/actors/enemies/root_wolf.tscn",
		"res://scenes/actors/enemies/weeping_mushroom.tscn",
		"res://scenes/actors/enemies/root_antler_stag.tscn",
	]:
		_expect(fallback_path in map_text, "Missing legacy enemy fallback: %s" % fallback_path)


func _check_wrapper_contracts() -> void:
	for path: String in WRAPPERS:
		_expect(FileAccess.file_exists(path), "Missing wrapper scene: %s" % path)
		var scene_text := FileAccess.get_file_as_string(path)
		var expected_id := String(WRAPPERS[path])
		_expect("[node name=\"%s\" type=\"Node2D\"]" % expected_id in scene_text, "Wrapper root ID mismatch: %s" % path)
		_expect("chapter_id = &\"%s\"" % expected_id in scene_text, "Wrapper chapter_id mismatch: %s" % path)
		_expect("PlayerController" not in scene_text, "Wrapper must not contain Player: %s" % path)
		_expect("HUD" not in scene_text, "Wrapper must not contain HUD: %s" % path)


func _check_assets() -> void:
	for chapter_id_value: StringName in WRAPPERS.values():
		var asset_path := "res://assets/placeholder/world/campaign/chapter2_4/%s.svg" % String(chapter_id_value)
		_expect(FileAccess.file_exists(asset_path), "Missing campaign landmark: %s" % asset_path)


func _expect(condition: bool, message: String) -> void:
	if not condition:
		_failures.append(message)
