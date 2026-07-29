extends SceneTree

const CHAPTER_PATHS: PackedStringArray = [
	"res://resources/campaign/chapters/chapter_2_drowned_bells.tres",
	"res://resources/campaign/chapters/chapter_3_blind_procession.tres",
	"res://resources/campaign/chapters/chapter_4_erased_archive.tres",
	"res://resources/campaign/chapters/chapter_5_quartz_wastes.tres",
	"res://resources/campaign/chapters/chapter_6_burning_root_garden.tres",
	"res://resources/campaign/chapters/chapter_7_black_resin_pass.tres",
	"res://resources/campaign/chapters/chapter_8_empty_monastery.tres",
	"res://resources/campaign/chapters/chapter_9_false_sun_citadel.tres",
	"res://resources/campaign/chapters/chapter_10_world_root.tres",
]

const EXPECTED_CHAPTER_IDS: Array[StringName] = [
	&"chapter_2_drowned_bells",
	&"chapter_3_blind_procession",
	&"chapter_4_erased_archive",
	&"chapter_5_quartz_wastes",
	&"chapter_6_burning_root_garden",
	&"chapter_7_black_resin_pass",
	&"chapter_8_empty_monastery",
	&"chapter_9_false_sun_citadel",
	&"chapter_10_world_root",
]

const EXPECTED_UNLOCKS: Array[StringName] = [
	&"guardian", &"", &"spellblade", &"", &"priest", &"", &"", &"", &"",
]

const EXPECTED_CHAPTER_BOSS_IDS: Array[StringName] = [
	&"boss_drowned_executioner",
	&"boss_hollow_paladin",
	&"boss_blind_archivist",
	&"boss_quartz_matriarch",
	&"boss_burning_root",
	&"boss_betrayer_knight",
	&"boss_empty_abbot",
	&"boss_false_sun",
	&"boss_papal_root_avatar",
]

const EXPECTED_NEXT_MAP_IDS: Array[StringName] = [
	&"chapter_3_blind_procession",
	&"chapter_4_erased_archive",
	&"chapter_5_quartz_wastes",
	&"chapter_6_burning_root_garden",
	&"chapter_7_black_resin_pass",
	&"chapter_8_empty_monastery",
	&"chapter_9_false_sun_citadel",
	&"chapter_10_world_root",
	&"true_ending",
]

const CAMPAIGN_ENEMY_IDS: Array[StringName] = [
	&"bone_crow",
	&"drowned_axeman",
	&"soulless_holy_guard",
	&"blind_battlemage",
	&"night_mist_owl",
	&"white_sand_scorpion",
	&"betrayer_masked_knight",
	&"quartz_mummy",
	&"burning_root_flower",
	&"black_faith_hunter",
	&"empty_former_monk",
	&"white_bark_treant",
	&"soul_black_eagle",
	&"false_sun_knight",
	&"faceless_nun",
	&"ulcerated_light_wyrmling",
]

const CAMPAIGN_BOSS_IDS: Array[StringName] = [
	&"boss_drowned_executioner",
	&"boss_hollow_paladin",
	&"boss_blind_archivist",
	&"boss_quartz_matriarch",
	&"boss_burning_root",
	&"boss_betrayer_knight",
	&"boss_empty_abbot",
	&"boss_false_sun",
	&"boss_papal_root_avatar",
	&"boss_corrupted_asterion",
]

const TRUE_ENDING_PATH: String = "res://resources/campaign/endings/true_ending.tres"

var failures: Array[String] = []


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	_expect(CHAPTER_PATHS.size() == 9, "Campaign must contain Chapter 2 through Chapter 10")
	_validate_campaign_enemy_assets()
	_validate_campaign_boss_assets()
	for index: int in range(CHAPTER_PATHS.size()):
		_validate_chapter(CHAPTER_PATHS[index], index)
	_validate_true_ending()
	if failures.is_empty():
		print("Campaign data tests passed")
		quit(0)
		return
	for failure: String in failures:
		push_error(failure)
	quit(1)


func _validate_campaign_enemy_assets() -> void:
	for enemy_id: StringName in CAMPAIGN_ENEMY_IDS:
		var data_path: String = "res://resources/enemies/campaign/%s.tres" % enemy_id
		var data: CampaignEnemyData = ResourceLoader.load(data_path) as CampaignEnemyData
		_expect(data != null, "Campaign enemy resource loads: %s" % data_path)
		if data != null:
			_expect(data.enemy_id == enemy_id, "Campaign enemy resource ID matches %s" % enemy_id)


func _validate_campaign_boss_assets() -> void:
	for boss_id: StringName in CAMPAIGN_BOSS_IDS:
		var data_path: String = "res://resources/enemies/campaign/%s.tres" % boss_id
		var scene_path: String = "res://scenes/actors/enemies/campaign/%s.tscn" % boss_id
		var data: CampaignEnemyData = ResourceLoader.load(data_path) as CampaignEnemyData
		var scene: PackedScene = ResourceLoader.load(scene_path) as PackedScene
		_expect(data != null, "Campaign boss resource loads: %s" % data_path)
		_expect(scene != null, "Campaign boss scene loads: %s" % scene_path)
		if data != null:
			_expect(data.enemy_id == boss_id, "Campaign boss resource ID matches %s" % boss_id)


func _validate_chapter(path: String, index: int) -> void:
	var resource: Resource = ResourceLoader.load(path)
	_expect(resource is ChapterDefinition, "%s loads as ChapterDefinition" % path)
	if not resource is ChapterDefinition:
		return
	var chapter := resource as ChapterDefinition
	_expect(chapter.chapter_id == EXPECTED_CHAPTER_IDS[index], "%s has the exact chapter ID" % path)
	_expect(chapter.chapter_number == index + 2, "%s has the expected chapter number" % path)
	_expect(chapter.is_valid_definition(), "%s passes ChapterDefinition validation: %s" % [path, chapter.get_validation_errors()])
	_expect(chapter.encounter_enemy_ids.size() == ChapterDefinition.REQUIRED_WAVE_COUNT, "%s contains exactly three waves" % path)
	for enemy_id: StringName in chapter.encounter_enemy_ids:
		_expect(enemy_id in CAMPAIGN_ENEMY_IDS, "%s references loadable campaign enemy ID %s" % [path, enemy_id])
	_expect(chapter.boss_enemy_id == EXPECTED_CHAPTER_BOSS_IDS[index], "%s uses expected boss ID" % path)
	_expect(chapter.boss_enemy_id in CAMPAIGN_BOSS_IDS, "%s references a loadable campaign boss" % path)
	_expect(chapter.next_map_id == EXPECTED_NEXT_MAP_IDS[index], "%s uses canonical next map ID" % path)
	_expect(chapter.moral_option_a_flag != chapter.moral_option_b_flag, "%s moral choice flags are distinct" % path)
	_expect(chapter.unlock_class_id == EXPECTED_UNLOCKS[index], "%s has the expected optional class unlock" % path)


func _validate_true_ending() -> void:
	var resource: Resource = ResourceLoader.load(TRUE_ENDING_PATH)
	_expect(resource is EndingDialogueDefinition, "True ending loads as EndingDialogueDefinition")
	if not resource is EndingDialogueDefinition:
		return
	var ending := resource as EndingDialogueDefinition
	_expect(ending.ending_id == &"true_ending_silent_rootkeeper", "True ending has the canonical ID")
	_expect(ending.required_choice_flags.size() == 9, "True ending requires one moral flag per campaign chapter")
	_expect(ending.is_valid_definition(), "True ending definition is complete")


func _expect(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)
