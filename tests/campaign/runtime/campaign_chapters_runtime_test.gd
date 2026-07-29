extends Node

const CHAPTERS: Array[Dictionary] = [
	{"number": 2, "id": &"chapter_2_drowned_bells", "wrapped": false},
	{"number": 3, "id": &"chapter_3_blind_procession", "wrapped": false},
	{"number": 4, "id": &"chapter_4_erased_archive", "wrapped": false},
	{"number": 5, "id": &"chapter_5_quartz_wastes", "wrapped": true},
	{"number": 6, "id": &"chapter_6_burning_root_garden", "wrapped": true},
	{"number": 7, "id": &"chapter_7_black_resin_pass", "wrapped": true},
	{"number": 8, "id": &"chapter_8_empty_monastery", "wrapped": true},
	{"number": 9, "id": &"chapter_9_false_sun_citadel", "wrapped": true},
	{"number": 10, "id": &"chapter_10_world_root", "wrapped": true},
]
const SECOND_FINAL_BOSS_ID: StringName = &"boss_corrupted_asterion"

var _failures: PackedStringArray = []
var _checks_run := 0
var _second_boss_spawn_count := 0
var _final_sequence_completion_count := 0


func _ready() -> void:
	call_deferred(&"_run")


func _run() -> void:
	for contract: Dictionary in CHAPTERS:
		await _check_chapter(contract)
	await _check_chapter_10_final_sequence()
	_finish()


func _check_chapter(contract: Dictionary) -> void:
	var chapter_number := int(contract["number"])
	var chapter_id := StringName(contract["id"])
	var label := "Chapter %d (%s)" % [chapter_number, String(chapter_id)]
	var scene_path := _chapter_scene_path(chapter_id)
	var definition_path := _chapter_definition_path(chapter_id)

	_expect(ResourceLoader.exists(scene_path), "%s scene is missing: %s" % [label, scene_path])
	var packed_scene := ResourceLoader.load(scene_path) as PackedScene
	_expect(packed_scene != null, "%s scene cannot be loaded: %s" % [label, scene_path])
	if packed_scene == null:
		return

	var chapter_root := packed_scene.instantiate() as Node2D
	_expect(chapter_root != null, "%s scene root is not Node2D" % label)
	if chapter_root == null:
		return
	add_child(chapter_root)
	await get_tree().process_frame
	await get_tree().process_frame

	var expects_wrapper := bool(contract["wrapped"])
	var campaign_map: Node = chapter_root
	if expects_wrapper:
		_expect(chapter_root.is_in_group(&"campaign_chapter_wrapper"), "%s wrapper did not join campaign_chapter_wrapper" % label)
		_expect(chapter_root.has_method(&"get_campaign_map"), "%s wrapper does not expose get_campaign_map()" % label)
		campaign_map = chapter_root.call(&"get_campaign_map") as Node if chapter_root.has_method(&"get_campaign_map") else null
		_expect(campaign_map != null, "%s wrapper did not instantiate CampaignChapterMap" % label)
	else:
		_expect(chapter_root is CampaignChapterMap, "%s must use CampaignChapterMap as its scene root" % label)

	_expect(chapter_root.get_node_or_null("SpawnPoints/default") is Marker2D, "%s scene lacks SpawnPoints/default" % label)
	if campaign_map == null:
		chapter_root.queue_free()
		await get_tree().process_frame
		return

	_expect(campaign_map.is_inside_tree(), "%s CampaignChapterMap is not active in the scene tree" % label)
	_expect(campaign_map.has_method(&"get_spawn_point"), "%s CampaignChapterMap lacks get_spawn_point()" % label)
	_expect(campaign_map.has_method(&"spawn_boss"), "%s CampaignChapterMap lacks spawn_boss()" % label)
	_expect(campaign_map.has_signal(&"chapter_completed"), "%s CampaignChapterMap lacks chapter_completed signal" % label)
	_expect(campaign_map.get_node_or_null("SpawnPoints/default") is Marker2D, "%s active CampaignChapterMap lacks SpawnPoints/default" % label)

	var definition := _resolve_runtime_definition(chapter_root, campaign_map)
	_expect(definition is ChapterDefinition, "%s did not load a real ChapterDefinition" % label)
	if definition is ChapterDefinition:
		var typed_definition := definition as ChapterDefinition
		var validation_errors := typed_definition.get_validation_errors()
		_expect(typed_definition.resource_path == definition_path, "%s loaded ChapterDefinition %s instead of %s" % [label, typed_definition.resource_path, definition_path])
		_expect(typed_definition.chapter_id == chapter_id, "%s definition chapter_id is %s" % [label, String(typed_definition.chapter_id)])
		_expect(typed_definition.chapter_number == chapter_number, "%s definition chapter_number is %d" % [label, typed_definition.chapter_number])
		_expect(validation_errors.is_empty(), "%s ChapterDefinition validation errors: %s" % [label, ", ".join(validation_errors)])
		_check_encounters(label, campaign_map, typed_definition)
		_check_boss_assets(label, typed_definition.boss_enemy_id)
		_expect(StringName(campaign_map.get("_boss_definition")) == typed_definition.boss_enemy_id, "%s map boss definition does not match %s" % [label, String(typed_definition.boss_enemy_id)])

	var map_definition: Variant = campaign_map.get("_chapter_definition")
	_expect(map_definition is ChapterDefinition, "%s CampaignChapterMap is not holding a real ChapterDefinition" % label)
	if map_definition is ChapterDefinition:
		_expect((map_definition as ChapterDefinition).resource_path == definition_path, "%s CampaignChapterMap holds the wrong ChapterDefinition" % label)

	print("[CAMPAIGN RUNTIME][CHAPTER PASS] %s instantiated and inspected." % label)
	chapter_root.queue_free()
	await get_tree().process_frame


func _check_encounters(label: String, campaign_map: Node, definition: ChapterDefinition) -> void:
	_expect(definition.encounter_enemy_ids.size() == 3, "%s definition has %d encounters instead of 3" % [label, definition.encounter_enemy_ids.size()])
	var runtime_encounters: Array = campaign_map.get("_encounters") as Array
	_expect(runtime_encounters.size() == 3, "%s active map has %d encounters instead of 3" % [label, runtime_encounters.size()])
	for encounter_index: int in range(mini(3, mini(definition.encounter_enemy_ids.size(), runtime_encounters.size()))):
		var expected_enemy_id := definition.encounter_enemy_ids[encounter_index]
		var actual_enemy_id := StringName(runtime_encounters[encounter_index])
		_expect(actual_enemy_id == expected_enemy_id, "%s encounter %d uses %s instead of %s" % [label, encounter_index + 1, String(actual_enemy_id), String(expected_enemy_id)])
		_check_enemy_data(label, expected_enemy_id, "encounter %d" % (encounter_index + 1))


func _check_enemy_data(label: String, enemy_id: StringName, role: String) -> Resource:
	var data_path := "res://resources/enemies/campaign/%s.tres" % String(enemy_id)
	_expect(ResourceLoader.exists(data_path), "%s %s data is missing: %s" % [label, role, data_path])
	var enemy_data := ResourceLoader.load(data_path) as Resource
	_expect(enemy_data != null, "%s %s data cannot be loaded: %s" % [label, role, data_path])
	if enemy_data != null:
		_expect(StringName(enemy_data.get("enemy_id")) == enemy_id, "%s %s data ID is %s instead of %s" % [label, role, StringName(enemy_data.get("enemy_id")), String(enemy_id)])
	return enemy_data


func _check_boss_assets(label: String, boss_id: StringName) -> void:
	var boss_data := _check_enemy_data(label, boss_id, "boss")
	var scene_path := "res://scenes/actors/enemies/campaign/%s.tscn" % String(boss_id)
	_expect(ResourceLoader.exists(scene_path), "%s boss scene is missing: %s" % [label, scene_path])
	var packed_boss := ResourceLoader.load(scene_path) as PackedScene
	_expect(packed_boss != null, "%s boss scene cannot be loaded: %s" % [label, scene_path])
	if packed_boss == null:
		return
	var boss_instance := packed_boss.instantiate()
	_expect(boss_instance != null, "%s boss scene cannot be instantiated: %s" % [label, scene_path])
	if boss_instance == null:
		return
	var scene_data := boss_instance.get("data") as Resource
	_expect(scene_data != null, "%s boss scene does not expose loaded data" % label)
	if scene_data != null:
		_expect(StringName(scene_data.get("enemy_id")) == boss_id, "%s boss scene data ID is %s instead of %s" % [label, StringName(scene_data.get("enemy_id")), String(boss_id)])
		if boss_data != null:
			_expect(scene_data.resource_path == boss_data.resource_path, "%s boss scene references %s instead of %s" % [label, scene_data.resource_path, boss_data.resource_path])
	boss_instance.free()


func _check_chapter_10_final_sequence() -> void:
	var chapter_id: StringName = &"chapter_10_world_root"
	var scene_path := _chapter_scene_path(chapter_id)
	var packed_scene := ResourceLoader.load(scene_path) as PackedScene
	_expect(packed_scene != null, "Chapter 10 final-sequence scene cannot load")
	if packed_scene == null:
		return
	var chapter_root := packed_scene.instantiate() as Node2D
	add_child(chapter_root)
	await get_tree().process_frame
	await get_tree().process_frame

	var campaign_map := chapter_root.call(&"get_campaign_map") as Node if chapter_root.has_method(&"get_campaign_map") else null
	_expect(not bool(chapter_root.get("auto_complete_on_boss_defeated")), "Chapter 10 wrapper auto_complete_on_boss_defeated must be false")
	_expect(campaign_map != null, "Chapter 10 final sequence has no active CampaignChapterMap")
	if campaign_map != null:
		_expect(not bool(campaign_map.get("auto_complete_on_boss_defeated")), "Chapter 10 CampaignChapterMap auto_complete_on_boss_defeated must be false")

	var sequence := chapter_root.get_node_or_null("FinalSequence")
	_expect(sequence != null, "Chapter 10 lacks FinalSequence")
	if sequence == null:
		chapter_root.queue_free()
		await get_tree().process_frame
		return

	var definition := chapter_root.call(&"get_chapter_definition") as ChapterDefinition
	_expect(definition != null, "Chapter 10 final sequence lacks ChapterDefinition")
	var first_boss_id := StringName(sequence.get("first_boss_id"))
	var second_boss_id := StringName(sequence.get("second_boss_id"))
	_expect(definition != null and first_boss_id == definition.boss_enemy_id, "Chapter 10 first boss must match ChapterDefinition boss_enemy_id")
	_expect(second_boss_id == SECOND_FINAL_BOSS_ID, "Chapter 10 second boss is %s instead of %s" % [String(second_boss_id), String(SECOND_FINAL_BOSS_ID)])
	_check_boss_assets("Chapter 10 first final boss", first_boss_id)
	_check_boss_assets("Chapter 10 second final boss", second_boss_id)

	_second_boss_spawn_count = 0
	_final_sequence_completion_count = 0
	sequence.connect(&"second_boss_spawned", _on_second_boss_spawned)
	sequence.connect(&"sequence_completed", _on_final_sequence_completed)
	chapter_root.call(&"notify_boss_defeated", first_boss_id)
	await get_tree().process_frame
	await get_tree().process_frame
	var second_boss := sequence.call(&"get_second_boss") as Node
	_expect(int(sequence.get("phase")) == 1, "Chapter 10 did not enter second-boss phase after the first boss")
	_expect(_second_boss_spawn_count == 1, "Chapter 10 emitted second_boss_spawned %d times instead of once" % _second_boss_spawn_count)
	_expect(second_boss != null, "Chapter 10 did not instantiate the second boss at runtime")
	if second_boss != null:
		var second_boss_data := second_boss.get("data") as Resource
		_expect(second_boss_data != null, "Chapter 10 runtime second boss has no data resource")
		if second_boss_data != null:
			_expect(StringName(second_boss_data.get("enemy_id")) == second_boss_id, "Chapter 10 runtime second boss data ID does not match %s" % String(second_boss_id))

	sequence.call(&"notify_boss_defeated", second_boss_id)
	await get_tree().process_frame
	_expect(int(sequence.get("phase")) == 2, "Chapter 10 final sequence did not reach completed phase")
	_expect(_final_sequence_completion_count == 1, "Chapter 10 emitted sequence_completed %d times instead of once" % _final_sequence_completion_count)

	chapter_root.queue_free()
	await get_tree().process_frame


func _resolve_runtime_definition(chapter_root: Node, campaign_map: Node) -> Resource:
	if chapter_root.has_method(&"get_chapter_definition"):
		return chapter_root.call(&"get_chapter_definition") as Resource
	return campaign_map.get("_chapter_definition") as Resource


func _chapter_scene_path(chapter_id: StringName) -> String:
	return "res://scenes/maps/campaign/%s.tscn" % String(chapter_id)


func _chapter_definition_path(chapter_id: StringName) -> String:
	return "res://resources/campaign/chapters/%s.tres" % String(chapter_id)


func _on_second_boss_spawned(_boss: Node) -> void:
	_second_boss_spawn_count += 1


func _on_final_sequence_completed() -> void:
	_final_sequence_completion_count += 1


func _expect(condition: bool, message: String) -> void:
	_checks_run += 1
	if condition:
		return
	_failures.append(message)
	push_error("[CAMPAIGN RUNTIME][CONTRACT FAIL] %s" % message)


func _finish() -> void:
	if _failures.is_empty():
		print("[CAMPAIGN RUNTIME][PASS] %d checks passed across Chapters 2-10." % _checks_run)
		get_tree().quit(0)
		return
	print("[CAMPAIGN RUNTIME][SUMMARY] %d of %d checks failed." % [_failures.size(), _checks_run])
	for failure: String in _failures:
		print("  - %s" % failure)
	get_tree().quit(1)
