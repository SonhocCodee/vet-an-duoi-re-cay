extends Node

const CITY_NPC_SCENE := preload("res://scenes/npcs/city_npc.tscn")
const ARIA_SCENE := preload("res://scenes/npcs/aria/aria_map2.tscn")
const BASE_ENEMY_SCENES: PackedStringArray = [
	"res://scenes/actors/enemies/mist_shade.tscn",
	"res://scenes/actors/enemies/root_wolf.tscn",
	"res://scenes/actors/enemies/weeping_mushroom.tscn",
	"res://scenes/actors/enemies/root_antler_stag.tscn",
]
const BOSS_SCENES: PackedStringArray = [
	"res://scenes/actors/enemies/campaign/boss_betrayer_knight.tscn",
	"res://scenes/actors/enemies/campaign/boss_blind_archivist.tscn",
	"res://scenes/actors/enemies/campaign/boss_burning_root.tscn",
	"res://scenes/actors/enemies/campaign/boss_corrupted_asterion.tscn",
	"res://scenes/actors/enemies/campaign/boss_drowned_executioner.tscn",
	"res://scenes/actors/enemies/campaign/boss_empty_abbot.tscn",
	"res://scenes/actors/enemies/campaign/boss_false_sun.tscn",
	"res://scenes/actors/enemies/campaign/boss_hollow_paladin.tscn",
	"res://scenes/actors/enemies/campaign/boss_papal_root_avatar.tscn",
	"res://scenes/actors/enemies/campaign/boss_quartz_matriarch.tscn",
]
const NPC_IDS: PackedStringArray = [
	"alden_blacksmith", "mira_apothecary", "father_oren", "lysa_baker", "tomas_guard",
	"neris_cartographer", "gareth_stablemaster", "maela_weaver", "borin_mason", "ivy_orphan",
	"cedric_archivist", "helena_innkeeper", "oswin_fisher", "rosalind_midwife", "silas_gravedigger",
	"yvette_jeweler", "damian_scribe", "freya_hunter", "rowan_watch_captain", "elric_beggar_prophet",
]
const DIRECTIONS := {
	"down": Vector2.DOWN,
	"left": Vector2.LEFT,
	"right": Vector2.RIGHT,
	"up": Vector2.UP,
}

var checks := 0
var failures: Array[String] = []


func _ready() -> void:
	await _test_all_city_npcs()
	await _test_aria()
	await _test_base_enemies()
	await _test_campaign_resources()
	await _test_boss_scenes()
	_finish()


func _test_all_city_npcs() -> void:
	for npc_id: String in NPC_IDS:
		var npc := CITY_NPC_SCENE.instantiate()
		var sprite := npc.get_node(^"AnimatedSprite2D") as AnimatedSprite2D
		sprite.set("npc_id", StringName(npc_id))
		add_child(npc)
		await get_tree().process_frame
		_check_directional_sprite(sprite, "NPC %s" % npc_id)
		npc.queue_free()
		await get_tree().process_frame


func _test_aria() -> void:
	var aria := ARIA_SCENE.instantiate() as AriaMap2Npc
	add_child(aria)
	await get_tree().process_frame
	var sprite := aria.get_node(^"Sprite") as AnimatedSprite2D
	_check_directional_sprite(sprite, "Aria")
	var target := Node2D.new()
	add_child(target)
	target.global_position = aria.global_position + Vector2.RIGHT * 40.0
	aria.face_target(target)
	aria.mark_boss_defeated()
	target.queue_free()
	_check(String(sprite.animation).begins_with("hurt_"), "Aria hurt state uses directional animation")
	aria.queue_free()
	await get_tree().process_frame


func _check_directional_sprite(sprite: AnimatedSprite2D, label: String) -> void:
	_check(sprite != null and sprite.visible, "%s sprite is visible" % label)
	for direction_name: String in DIRECTIONS:
		for state_name: String in ["idle", "walk", "interact", "hurt"]:
			var animation_name := StringName("%s_%s" % [state_name, direction_name])
			_check(sprite.sprite_frames.has_animation(animation_name), "%s has %s" % [label, animation_name])
			_check(sprite.sprite_frames.get_frame_count(animation_name) >= 2, "%s %s has multiple frames" % [label, animation_name])
		sprite.call(&"set_facing_direction", DIRECTIONS[direction_name])
		_check(sprite.call(&"get_directional_animation") == StringName("idle_%s" % direction_name), "%s faces %s while idle" % [label, direction_name])


func _test_base_enemies() -> void:
	for scene_path: String in BASE_ENEMY_SCENES:
		var enemy := (load(scene_path) as PackedScene).instantiate() as EnemyBase
		enemy.elite_roll_enabled = false
		add_child(enemy)
		await get_tree().process_frame
		_check_enemy_visual(enemy, scene_path.get_file())
		_test_state_signal_bridge(enemy, scene_path.get_file())
		enemy.queue_free()
		await get_tree().process_frame


func _test_campaign_resources() -> void:
	var directory := DirAccess.open("res://resources/enemies/campaign")
	_check(directory != null, "campaign enemy resource directory opens")
	if directory == null:
		return
	var resource_count := 0
	for file_name: String in directory.get_files():
		if not file_name.ends_with(".tres"):
			continue
		resource_count += 1
		var data := load("res://resources/enemies/campaign/%s" % file_name) as CampaignEnemyData
		_check(data != null and data.enemy_id != &"", "campaign resource %s has enemy ID" % file_name)
		var enemy := CampaignEnemyFactory.create(data.enemy_id)
		_check(enemy != null, "factory creates %s" % data.enemy_id)
		if enemy == null:
			continue
		enemy.elite_roll_enabled = false
		add_child(enemy)
		await get_tree().process_frame
		_check_enemy_visual(enemy, String(data.enemy_id))
		enemy.queue_free()
		await get_tree().process_frame
	_check(resource_count >= 26, "all campaign enemy resources are covered")


func _test_boss_scenes() -> void:
	for scene_path: String in BOSS_SCENES:
		var enemy := (load(scene_path) as PackedScene).instantiate() as EnemyBase
		add_child(enemy)
		await get_tree().process_frame
		_check_enemy_visual(enemy, scene_path.get_file())
		_test_state_signal_bridge(enemy, scene_path.get_file())
		enemy.queue_free()
		await get_tree().process_frame


func _check_enemy_visual(enemy: EnemyBase, label: String) -> void:
	var visual := enemy.get_node_or_null(^"Visual") as EnemyVisual
	_check(visual != null, "%s has EnemyVisual" % label)
	if visual == null:
		return
	for direction_name: String in DIRECTIONS:
		visual.set_facing_direction(DIRECTIONS[direction_name])
		for state_index: int in [0, 1, 3, 4]:
			visual.set_motion_animation(state_index as EnemyVisual.MotionAnimation)
			var state_name: String = ["idle", "walk", "telegraph", "attack", "hurt"][state_index]
			_check(visual.get_directional_animation() == StringName("%s_%s" % [state_name, direction_name]), "%s exposes %s_%s" % [label, state_name, direction_name])


func _test_state_signal_bridge(enemy: EnemyBase, label: String) -> void:
	var visual := enemy.get_node(^"Visual") as EnemyVisual
	enemy.call(&"_change_state", EnemyBase.EnemyState.ATTACK, 0.2)
	_check(String(visual.get_directional_animation()).begins_with("attack_"), "%s attack state drives animation" % label)
	enemy.call(&"_change_state", EnemyBase.EnemyState.STAGGER, 0.2)
	_check(String(visual.get_directional_animation()).begins_with("hurt_"), "%s stagger state drives hurt animation" % label)


func _check(condition: bool, message: String) -> void:
	checks += 1
	if not condition:
		failures.append(message)
		push_error("[FOUR_DIRECTION][FAIL] " + message)


func _finish() -> void:
	if failures.is_empty():
		print("[FOUR_DIRECTION] PASS %d/%d" % [checks, checks])
		get_tree().quit(0)
		return
	print("[FOUR_DIRECTION] FAIL %d issue(s), %d checks" % [failures.size(), checks])
	get_tree().quit(1)
