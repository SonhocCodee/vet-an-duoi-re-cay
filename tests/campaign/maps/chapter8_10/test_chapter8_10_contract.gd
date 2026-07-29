extends SceneTree

const CHAPTER_SCENES: PackedStringArray = [
    "res://scenes/maps/campaign/chapter_8_empty_monastery.tscn",
    "res://scenes/maps/campaign/chapter_9_false_sun_citadel.tscn",
    "res://scenes/maps/campaign/chapter_10_world_root.tscn",
]
const ENDING_SCENE: String = "res://scenes/ending/true_ending.tscn"

var _failures: Array[String] = []

func _init() -> void:
    _check_chapter_scenes()
    _check_contract_adapter()
    _check_final_sequence()
    _check_ending()
    _finish()

func _check_chapter_scenes() -> void:
    for scene_path: String in CHAPTER_SCENES:
        _expect(FileAccess.file_exists(scene_path), "Missing chapter scene: %s" % scene_path)
        var scene_text: String = FileAccess.get_file_as_string(scene_path)
        _expect('[node name="default" type="Marker2D" parent="SpawnPoints"' in scene_text, "%s must expose SpawnPoints/default." % scene_path)
        _expect("CampaignChapterMap/ChapterDefinition" in scene_text, "%s is missing campaign contract metadata." % scene_path)
        _expect("player.tscn" not in scene_text.to_lower(), "%s must not instance Player." % scene_path)

func _check_contract_adapter() -> void:
    var adapter_path: String = "res://scripts/campaign/chapters8_10/late_campaign_chapter_wrapper.gd"
    _expect(FileAccess.file_exists(adapter_path), "Missing CampaignChapterMap adapter.")
    var adapter_text: String = FileAccess.get_file_as_string(adapter_path)
    _expect('CAMPAIGN_MAP_CLASS: StringName = &"CampaignChapterMap"' in adapter_text, "Adapter does not target CampaignChapterMap.")
    _expect('CHAPTER_DEFINITION_CLASS: StringName = &"ChapterDefinition"' in adapter_text, "Adapter does not target ChapterDefinition.")
    _expect("ProjectSettings.get_global_class_list()" in adapter_text, "Adapter must discover campaign contracts at runtime.")

func _check_final_sequence() -> void:
    var sequence_text: String = FileAccess.get_file_as_string("res://scripts/campaign/chapters8_10/final_sequence_decorator.gd")
    _expect("spawn_boss" in sequence_text and "spawn_chapter_boss" in sequence_text, "Chapter 10 does not probe generic boss hooks.")
    _expect("_spawn_placeholder_boss" in sequence_text, "Chapter 10 lacks second-boss decorator fallback.")
    _expect("boss_corrupted_asterion" in FileAccess.get_file_as_string(CHAPTER_SCENES[2]), "Chapter 10 second boss ID is missing.")

func _check_ending() -> void:
    _expect(FileAccess.file_exists(ENDING_SCENE), "Missing true ending scene.")
    var scene_text: String = FileAccess.get_file_as_string(ENDING_SCENE)
    var script_text: String = FileAccess.get_file_as_string("res://scripts/ending/true_ending.gd")
    _expect('type="Control"' in scene_text, "True ending root must be Control.")
    _expect("MoralSummary" in scene_text, "True ending must display moral statistics.")
    _expect("Kẻ Giữ Rễ" in script_text, "Vietnamese true-ending epilogue is missing.")
    _expect("return_to_title" in script_text and "return_to_hub" in script_text, "Ending return actions are incomplete.")

func _finish() -> void:
    if _failures.is_empty():
        print("Chapters 8-10 contract checks passed.")
        quit(0)
        return
    for failure: String in _failures:
        push_error(failure)
    quit(1)

func _expect(condition: bool, message: String) -> void:
    if not condition:
        _failures.append(message)
