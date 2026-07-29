extends Node

const LATER_CHAPTER_MIN_STAT_RATIO: float = 0.90
const MIN_CHAPTER_REWARD_GROWTH: float = 1.20

const CHAPTER_PATHS: Array[String] = [
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

const NORMAL_ENEMY_IDS: Array[StringName] = [
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

var _failures: PackedStringArray = []
var _checks_run: int = 0


func _ready() -> void:
	var enemy_data_by_id: Dictionary = _load_enemy_data()
	var chapters: Array[ChapterDefinition] = _load_chapters()
	_check_loot_tables(enemy_data_by_id)
	_check_chapter_curve(chapters, enemy_data_by_id)
	_check_chapter_bosses(chapters, enemy_data_by_id)
	_finish()


func _load_enemy_data() -> Dictionary:
	var enemy_data_by_id: Dictionary = {}
	var all_enemy_ids: Array[StringName] = NORMAL_ENEMY_IDS + BOSS_IDS
	_expect(all_enemy_ids.size() == 26, "balance catalog contains exactly 26 enemy IDs")
	for enemy_id: StringName in all_enemy_ids:
		var resource_path: String = "res://resources/enemies/campaign/%s.tres" % enemy_id
		var data: CampaignEnemyData = ResourceLoader.load(resource_path) as CampaignEnemyData
		_expect(data != null, "%s loads as CampaignEnemyData" % enemy_id)
		if data == null:
			continue
		_expect(data.enemy_id == enemy_id, "%s data ID matches its filename" % enemy_id)
		enemy_data_by_id[enemy_id] = data
	return enemy_data_by_id


func _load_chapters() -> Array[ChapterDefinition]:
	var chapters: Array[ChapterDefinition] = []
	_expect(CHAPTER_PATHS.size() == 9, "balance catalog contains Chapter 2 through Chapter 10")
	for index: int in range(CHAPTER_PATHS.size()):
		var chapter: ChapterDefinition = ResourceLoader.load(CHAPTER_PATHS[index]) as ChapterDefinition
		_expect(chapter != null, "%s loads as ChapterDefinition" % CHAPTER_PATHS[index])
		if chapter == null:
			continue
		_expect(chapter.chapter_number == index + 2, "%s has the expected chapter number" % chapter.chapter_id)
		_expect(chapter.encounter_enemy_ids.size() == 3, "%s defines three encounter enemies" % chapter.chapter_id)
		chapters.append(chapter)
	return chapters


func _check_loot_tables(enemy_data_by_id: Dictionary) -> void:
	for enemy_id: Variant in enemy_data_by_id:
		var data: CampaignEnemyData = enemy_data_by_id[enemy_id] as CampaignEnemyData
		_expect(data.loot_table != null, "%s has a loot table" % enemy_id)
		if data.loot_table == null:
			continue
		_expect(not data.loot_table.loot_entries.is_empty(), "%s loot table is not empty" % enemy_id)
		for entry: LootEntry in data.loot_table.loot_entries:
			_expect(entry != null, "%s loot table contains no null entries" % enemy_id)
			if entry == null:
				continue
			_expect(
				entry.drop_chance >= 0.0 and entry.drop_chance <= 1.0,
				"%s/%s drop chance %.3f is within 0.0..1.0" % [enemy_id, entry.item_id, entry.drop_chance]
			)
			_expect(entry.minimum_amount > 0, "%s/%s minimum amount is positive" % [enemy_id, entry.item_id])
			_expect(
				entry.maximum_amount >= entry.minimum_amount,
				"%s/%s maximum amount is not below minimum" % [enemy_id, entry.item_id]
			)


func _check_chapter_curve(chapters: Array[ChapterDefinition], enemy_data_by_id: Dictionary) -> void:
	if chapters.size() != CHAPTER_PATHS.size():
		return
	var previous_metrics: Dictionary = {}
	var previous_reward: int = 0
	for chapter: ChapterDefinition in chapters:
		var metrics: Dictionary = _chapter_enemy_metrics(chapter, enemy_data_by_id)
		if metrics.is_empty():
			continue
		if not previous_metrics.is_empty():
			_expect(
				float(metrics[&"level"]) >= float(previous_metrics[&"level"]),
				"%s average enemy level does not regress" % chapter.chapter_id
			)
			_expect(
				float(metrics[&"health"]) >= float(previous_metrics[&"health"]) * LATER_CHAPTER_MIN_STAT_RATIO,
				"%s average enemy HP does not drop by more than 10%%" % chapter.chapter_id
			)
			_expect(
				float(metrics[&"attack"]) >= float(previous_metrics[&"attack"]) * LATER_CHAPTER_MIN_STAT_RATIO,
				"%s average enemy damage does not drop by more than 10%%" % chapter.chapter_id
			)
			_expect(
				float(metrics[&"experience"]) >= float(previous_metrics[&"experience"]) * LATER_CHAPTER_MIN_STAT_RATIO,
				"%s average enemy XP does not drop by more than 10%%" % chapter.chapter_id
			)
			_expect(
				chapter.reward_exp >= ceili(float(previous_reward) * MIN_CHAPTER_REWARD_GROWTH),
				"%s reward_exp grows by at least 20%%" % chapter.chapter_id
			)
		previous_metrics = metrics
		previous_reward = chapter.reward_exp


func _check_chapter_bosses(chapters: Array[ChapterDefinition], enemy_data_by_id: Dictionary) -> void:
	for chapter: ChapterDefinition in chapters:
		var boss: CampaignEnemyData = enemy_data_by_id.get(chapter.boss_enemy_id) as CampaignEnemyData
		_expect(boss != null, "%s boss data loads" % chapter.chapter_id)
		if boss == null:
			continue
		var normal_enemies: Array[CampaignEnemyData] = _chapter_enemies(chapter, enemy_data_by_id)
		if normal_enemies.size() != chapter.encounter_enemy_ids.size():
			continue
		var minimum_level: int = normal_enemies[0].base_level
		var maximum_health: float = normal_enemies[0].base_health
		var maximum_attack: float = normal_enemies[0].base_attack
		var maximum_experience: int = normal_enemies[0].experience_reward
		for enemy: CampaignEnemyData in normal_enemies:
			minimum_level = mini(minimum_level, enemy.base_level)
			maximum_health = maxf(maximum_health, enemy.base_health)
			maximum_attack = maxf(maximum_attack, enemy.base_attack)
			maximum_experience = maxi(maximum_experience, enemy.experience_reward)
		_expect(boss.base_level >= minimum_level, "%s boss level is not below every normal enemy" % chapter.chapter_id)
		_expect(boss.base_health > maximum_health, "%s boss HP exceeds every normal enemy" % chapter.chapter_id)
		_expect(boss.base_attack > maximum_attack, "%s boss damage exceeds every normal enemy" % chapter.chapter_id)
		_expect(boss.experience_reward > maximum_experience, "%s boss XP exceeds every normal enemy" % chapter.chapter_id)


func _chapter_enemy_metrics(chapter: ChapterDefinition, enemy_data_by_id: Dictionary) -> Dictionary:
	var enemies: Array[CampaignEnemyData] = _chapter_enemies(chapter, enemy_data_by_id)
	if enemies.size() != chapter.encounter_enemy_ids.size() or enemies.is_empty():
		return {}
	var total_level: float = 0.0
	var total_health: float = 0.0
	var total_attack: float = 0.0
	var total_experience: float = 0.0
	for enemy: CampaignEnemyData in enemies:
		total_level += float(enemy.base_level)
		total_health += enemy.base_health
		total_attack += enemy.base_attack
		total_experience += float(enemy.experience_reward)
	var enemy_count: float = float(enemies.size())
	return {
		&"level": total_level / enemy_count,
		&"health": total_health / enemy_count,
		&"attack": total_attack / enemy_count,
		&"experience": total_experience / enemy_count,
	}


func _chapter_enemies(chapter: ChapterDefinition, enemy_data_by_id: Dictionary) -> Array[CampaignEnemyData]:
	var enemies: Array[CampaignEnemyData] = []
	for enemy_id: StringName in chapter.encounter_enemy_ids:
		var enemy: CampaignEnemyData = enemy_data_by_id.get(enemy_id) as CampaignEnemyData
		_expect(enemy != null, "%s references loadable enemy %s" % [chapter.chapter_id, enemy_id])
		if enemy != null:
			enemies.append(enemy)
	return enemies


func _expect(condition: bool, message: String) -> void:
	_checks_run += 1
	if condition:
		print("[CAMPAIGN BALANCE][PASS] %s" % message)
		return
	_failures.append(message)
	push_error("[CAMPAIGN BALANCE][FAIL] %s" % message)


func _finish() -> void:
	if _failures.is_empty():
		print("[CAMPAIGN BALANCE][PASS] %d checks completed." % _checks_run)
		get_tree().quit(0)
		return
	print("[CAMPAIGN BALANCE][SUMMARY] %d of %d checks failed." % [_failures.size(), _checks_run])
	get_tree().quit(1)
