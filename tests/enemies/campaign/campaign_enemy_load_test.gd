extends Node

const ENEMY_IDS: Array[StringName] = [
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

const BOSS_IDS: Array[StringName] = [
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

const GENERIC_SCENE_PATH: String = "res://scenes/actors/enemies/campaign/generic_campaign_enemy.tscn"

var _failures: PackedStringArray = []
var _checks_run: int = 0


func _ready() -> void:
	_check_generic_scene()
	_check_enemy_resources()
	_check_enemy_factory()
	_check_boss_resources_and_scenes()
	_check_boss_phase_transition()
	_finish()


func _check_generic_scene() -> void:
	var packed: PackedScene = load(GENERIC_SCENE_PATH) as PackedScene
	_expect(packed != null, "generic campaign enemy loads as PackedScene")
	if packed == null:
		return
	var enemy: CampaignEnemyBase = packed.instantiate() as CampaignEnemyBase
	_expect(enemy != null, "generic campaign enemy instantiates as CampaignEnemyBase")
	if enemy == null:
		return
	_expect(enemy.data != null, "generic campaign enemy has safe default data")
	add_child(enemy)
	_expect(enemy.data.enemy_id == &"bone_crow", "generic default data ID is bone_crow")
	enemy.free()


func _check_enemy_resources() -> void:
	for enemy_id: StringName in ENEMY_IDS:
		var data_path: String = "res://resources/enemies/campaign/%s.tres" % enemy_id
		var data: CampaignEnemyData = load(data_path) as CampaignEnemyData
		_expect(data != null, "%s loads as CampaignEnemyData" % enemy_id)
		if data == null:
			continue
		_expect(data.enemy_id == enemy_id, "%s data ID matches filename" % enemy_id)
		_expect(data.loot_table != null, "%s has LootTable" % enemy_id)
		if data.loot_table != null:
			_expect(not data.loot_table.loot_entries.is_empty(), "%s loot table has entries" % enemy_id)


func _check_enemy_factory() -> void:
	for enemy_id: StringName in ENEMY_IDS:
		var enemy: CampaignEnemyBase = CampaignEnemyFactory.create(enemy_id)
		_expect(enemy != null, "%s factory instance succeeds" % enemy_id)
		if enemy == null:
			continue
		_expect(enemy.data.enemy_id == enemy_id, "%s factory assigns matching data" % enemy_id)
		_expect(enemy.combat_level == enemy.data.base_level, "%s factory assigns base level" % enemy_id)
		enemy.free()


func _check_boss_resources_and_scenes() -> void:
	for boss_id: StringName in BOSS_IDS:
		var data_path: String = "res://resources/enemies/campaign/%s.tres" % boss_id
		var scene_path: String = "res://scenes/actors/enemies/campaign/%s.tscn" % boss_id
		var data: CampaignEnemyData = load(data_path) as CampaignEnemyData
		var packed: PackedScene = load(scene_path) as PackedScene
		_expect(data != null, "%s data loads" % boss_id)
		_expect(packed != null, "%s scene loads" % boss_id)
		if data == null or packed == null:
			continue
		_expect(data.enemy_id == boss_id, "%s data ID matches exact boss ID" % boss_id)
		_expect(data.loot_table != null, "%s has boss LootTable" % boss_id)
		var boss: BossEnemyBase = packed.instantiate() as BossEnemyBase
		_expect(boss != null, "%s instantiates as BossEnemyBase" % boss_id)
		if boss == null:
			continue
		_expect(boss.data.enemy_id == boss_id, "%s scene data ID matches" % boss_id)
		_expect(boss.has_signal(&"died"), "%s inherits died signal" % boss_id)
		_expect(boss.has_signal(&"telegraph_started"), "%s inherits telegraph_started signal" % boss_id)
		_expect(boss.has_signal(&"phase_changed"), "%s exposes phase_changed signal" % boss_id)
		boss.free()


func _check_boss_phase_transition() -> void:
	var packed: PackedScene = load("res://scenes/actors/enemies/campaign/boss_drowned_executioner.tscn") as PackedScene
	var boss: BossEnemyBase = packed.instantiate() as BossEnemyBase
	add_child(boss)
	var packet: DamagePacket = DamagePacket.new(
		boss.max_health * 0.55,
		&"true",
		self,
		Vector2.ZERO,
		0.0,
		&"campaign_phase_test",
		true
	)
	boss.receive_damage(packet)
	_expect(boss.current_phase == BossEnemyBase.BossPhase.PHASE_TWO, "boss enters phase two below threshold")
	_expect(not boss.phase_two_patterns.is_empty(), "boss phase two has telegraph patterns")
	boss.free()


func _expect(condition: bool, message: String) -> void:
	_checks_run += 1
	if condition:
		print("[CAMPAIGN ENEMY][PASS] %s" % message)
	else:
		_failures.append(message)
		push_error("[CAMPAIGN ENEMY][FAIL] %s" % message)


func _finish() -> void:
	if _failures.is_empty():
		print("[CAMPAIGN ENEMY][PASS] %d checks completed." % _checks_run)
		get_tree().quit(0)
		return
	print("[CAMPAIGN ENEMY][SUMMARY] %d of %d checks failed." % [_failures.size(), _checks_run])
	get_tree().quit(1)
