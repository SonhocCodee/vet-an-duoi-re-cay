extends SceneTree

const CHAPTERS: Array[Dictionary] = [
	{
		&"scene": "res://scenes/maps/campaign/chapter_5_quartz_wastes.tscn",
		&"script": "res://scripts/campaign/chapters5_7/chapter_5_quartz_wastes.gd",
		&"definition": "res://resources/campaign/chapters/chapter_5_quartz_wastes.tres",
		&"decorator": "res://scripts/campaign/chapters5_7/chapter5_quartz_decorator.gd",
	},
	{
		&"scene": "res://scenes/maps/campaign/chapter_6_burning_root_garden.tscn",
		&"script": "res://scripts/campaign/chapters5_7/chapter_6_burning_root_garden.gd",
		&"definition": "res://resources/campaign/chapters/chapter_6_burning_root_garden.tres",
		&"decorator": "res://scripts/campaign/chapters5_7/chapter6_burning_root_decorator.gd",
	},
	{
		&"scene": "res://scenes/maps/campaign/chapter_7_black_resin_pass.tscn",
		&"script": "res://scripts/campaign/chapters5_7/chapter_7_black_resin_pass.gd",
		&"definition": "res://resources/campaign/chapters/chapter_7_black_resin_pass.tres",
		&"decorator": "res://scripts/campaign/chapters5_7/chapter7_black_resin_decorator.gd",
	},
]

var _failures: Array[String] = []


func _init() -> void:
	_check_required_files()
	_check_scene_contracts()
	_check_wrapper_contract()
	_check_hazard_contract()
	_finish()


func _check_required_files() -> void:
	for chapter: Dictionary in CHAPTERS:
		for key: StringName in [&"scene", &"script", &"definition", &"decorator"]:
			var required_path: String = str(chapter[key])
			_expect(FileAccess.file_exists(required_path), "Missing required file: %s" % required_path)


func _check_scene_contracts() -> void:
	for chapter: Dictionary in CHAPTERS:
		var scene_path: String = str(chapter[&"scene"])
		var definition_path: String = str(chapter[&"definition"])
		var scene_text: String = FileAccess.get_file_as_string(scene_path)
		_expect('[node name="default" type="Marker2D" parent="SpawnPoints"' in scene_text, "%s lacks SpawnPoints/default." % scene_path)
		_expect('[node name="chapter_start" type="Marker2D" parent="SpawnPoints"' in scene_text, "%s lacks chapter_start spawn." % scene_path)
		_expect(definition_path in scene_text, "%s references the wrong ChapterDefinition path." % scene_path)
		_expect("CampaignChapterMap/ChapterDefinition" in scene_text, "%s lacks campaign contract metadata." % scene_path)
		_expect('type="Area2D" parent="Triggers/Hazards"' in scene_text, "%s lacks a typed hazard area." % scene_path)
		_expect('name="Player"' not in scene_text and 'name="HUD"' not in scene_text, "%s must not instance Player or HUD." % scene_path)


func _check_wrapper_contract() -> void:
	var wrapper_path: String = "res://scripts/campaign/chapters5_7/mid_campaign_chapter_wrapper.gd"
	var wrapper_text: String = FileAccess.get_file_as_string(wrapper_path)
	_expect('CAMPAIGN_MAP_SCRIPT_PATH: String = "res://scripts/campaign/map/campaign_chapter_map.gd"' in wrapper_text, "Wrapper does not target CampaignChapterMap contract path.")
	_expect("_prepare_campaign_map(campaign_map)" in wrapper_text, "Wrapper does not configure CampaignChapterMap before insertion.")
	_expect('target.set(&"chapter_resource_path", definition_resource_path)' in wrapper_text, "Wrapper must bind the exact ChapterDefinition path before insertion.")
	for chapter: Dictionary in CHAPTERS:
		var script_text: String = FileAccess.get_file_as_string(str(chapter[&"script"]))
		_expect(str(chapter[&"definition"]) in script_text, "Chapter wrapper uses the wrong definition resource path.")


func _check_hazard_contract() -> void:
	var hazard_text: String = FileAccess.get_file_as_string("res://scripts/campaign/chapters5_7/chapter57_hazard_area.gd")
	_expect("extends Area2D" in hazard_text, "Campaign hazard must extend Area2D.")
	_expect("minimum_survivable_health" in hazard_text, "Campaign hazard lacks a nonlethal health floor.")
	_expect("current_health - minimum_survivable_health" in hazard_text, "Campaign hazard can bypass its nonlethal health floor.")


func _finish() -> void:
	if _failures.is_empty():
		print("Chapters 5-7 contract checks passed.")
		quit(0)
		return
	for failure: String in _failures:
		push_error(failure)
	quit(1)


func _expect(condition: bool, message: String) -> void:
	if not condition:
		_failures.append(message)
