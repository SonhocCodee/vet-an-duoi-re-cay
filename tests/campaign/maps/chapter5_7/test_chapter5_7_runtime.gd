extends SceneTree

class HazardTestPlayer extends CharacterBody2D:
	var health: float = 10.0

	func get_health() -> float:
		return health

	func receive_damage(packet: DamagePacket) -> Variant:
		health = maxf(health - packet.amount, 0.0)
		return null


const CHAPTERS: Array[Dictionary] = [
	{
		&"scene": "res://scenes/maps/campaign/chapter_5_quartz_wastes.tscn",
		&"definition": "res://resources/campaign/chapters/chapter_5_quartz_wastes.tres",
		&"chapter_id": &"chapter_5_quartz_wastes",
	},
	{
		&"scene": "res://scenes/maps/campaign/chapter_6_burning_root_garden.tscn",
		&"definition": "res://resources/campaign/chapters/chapter_6_burning_root_garden.tres",
		&"chapter_id": &"chapter_6_burning_root_garden",
	},
	{
		&"scene": "res://scenes/maps/campaign/chapter_7_black_resin_pass.tscn",
		&"definition": "res://resources/campaign/chapters/chapter_7_black_resin_pass.tres",
		&"chapter_id": &"chapter_7_black_resin_pass",
	},
]

var _failures: Array[String] = []


func _init() -> void:
	call_deferred(&"_run")


func _run() -> void:
	Engine.time_scale = 100.0
	for chapter_contract: Dictionary in CHAPTERS:
		await _check_chapter_runtime(chapter_contract)
	await _check_nonlethal_hazard()
	_finish()


func _check_chapter_runtime(chapter_contract: Dictionary) -> void:
	var scene_path: String = str(chapter_contract[&"scene"])
	var packed_scene: PackedScene = load(scene_path) as PackedScene
	_expect(packed_scene != null, "Could not load %s." % scene_path)
	if packed_scene == null:
		return
	var chapter: Node2D = packed_scene.instantiate() as Node2D
	root.add_child(chapter)
	await process_frame
	_expect(chapter.get_node_or_null("SpawnPoints/default") is Marker2D, "%s has no SpawnPoints/default." % scene_path)
	_expect(chapter.has_method(&"get_chapter_definition"), "%s lacks ChapterDefinition access." % scene_path)
	var definition: Resource = chapter.call(&"get_chapter_definition") as Resource
	_expect(definition != null, "%s did not load a ChapterDefinition." % scene_path)
	if definition != null:
		_expect(definition.resource_path == str(chapter_contract[&"definition"]), "%s loaded the wrong ChapterDefinition path." % scene_path)
		_expect(StringName(definition.get(&"chapter_id")) == chapter_contract[&"chapter_id"], "%s loaded the wrong chapter ID." % scene_path)
	var campaign_map: Node = chapter.call(&"get_campaign_map") as Node
	_expect(campaign_map != null and campaign_map.has_method(&"get_spawn_point") and campaign_map.has_signal(&"chapter_completed"), "%s did not instantiate CampaignChapterMap." % scene_path)
	if campaign_map != null:
		var actual_chapter_id: StringName = StringName(campaign_map.get(&"chapter_id"))
		_expect(actual_chapter_id == chapter_contract[&"chapter_id"], "%s configured CampaignChapterMap as %s instead of %s." % [scene_path, actual_chapter_id, chapter_contract[&"chapter_id"]])
		_expect(str(campaign_map.get_meta(&"source_chapter_resource_path", "")) == str(chapter_contract[&"definition"]), "%s lost the source ChapterDefinition path." % scene_path)
		_check_runtime_content(campaign_map, definition, scene_path)
	await create_timer(0.3, true, false, true).timeout
	root.remove_child(chapter)
	chapter.free()
	await process_frame


func _check_runtime_content(campaign_map: Node, definition: Resource, scene_path: String) -> void:
	var runtime_encounters: Array = campaign_map.get(&"_encounters") as Array
	var source_enemy_ids: Array = definition.get(&"encounter_enemy_ids") as Array
	_expect(runtime_encounters.size() == 3, "%s did not adapt three encounter waves." % scene_path)
	if runtime_encounters.is_empty() or source_enemy_ids.is_empty():
		return
	var first_enemy_id: StringName = StringName(runtime_encounters[0])
	_expect(first_enemy_id == source_enemy_ids[0], "%s first wave does not match ChapterDefinition." % scene_path)
	var runtime_boss_id: StringName = StringName(campaign_map.get(&"_boss_definition"))
	_expect(runtime_boss_id == StringName(definition.get(&"boss_enemy_id")), "%s boss does not match ChapterDefinition." % scene_path)


func _check_nonlethal_hazard() -> void:
	var hazard_script: Script = load("res://scripts/campaign/chapters5_7/chapter57_hazard_area.gd") as Script
	var hazard: Area2D = hazard_script.new() as Area2D
	var player: HazardTestPlayer = HazardTestPlayer.new()
	root.add_child(hazard)
	root.add_child(player)
	hazard.damage_per_tick = 100.0
	hazard.minimum_survivable_health = 1.0
	hazard.call(&"_apply_hazard_tick", player)
	_expect(is_equal_approx(player.health, 1.0), "Hazard must stop at one health instead of one-shotting the player.")
	root.remove_child(hazard)
	root.remove_child(player)
	hazard.free()
	player.free()
	await process_frame


func _finish() -> void:
	Engine.time_scale = 1.0
	if _failures.is_empty():
		print("Chapters 5-7 runtime checks passed.")
		quit(0)
		return
	for failure: String in _failures:
		push_error(failure)
	quit(1)


func _expect(condition: bool, message: String) -> void:
	if not condition:
		_failures.append(message)
