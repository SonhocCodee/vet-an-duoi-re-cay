extends Node

signal level_changed(level: int, experience: int, required_experience: int)
signal potential_points_changed(points: int)
signal class_changed(class_id: StringName)
signal inventory_changed(item_id: StringName, quantity: int)
signal currency_changed(currency_id: StringName, amount: int)
signal flag_changed(flag_id: StringName, value: bool)
signal quest_changed(quest_id: StringName, state: StringName)
signal stats_changed(stats: Dictionary)
signal moral_choice_changed(choice_id: StringName, selected_option: StringName)
signal chapter_progress_changed(current_chapter: int, completed_chapters: Dictionary)

const SAVE_VERSION: int = 2
const MAX_LEVEL: int = 35

var current_map: StringName = GameIds.MAP_1
var current_spawn: StringName = GameIds.SPAWN_DEFAULT
var checkpoint_map: StringName = GameIds.MAP_1
var checkpoint_spawn: StringName = GameIds.SPAWN_DEFAULT
var level: int = 1
var experience: int = 0
var potential_points: int = 0
var current_class: StringName = GameIds.CLASS_BLADEMASTER
var attributes: Dictionary = {}
var inventory: Dictionary = {}
var currencies: Dictionary = {}
var flags: Dictionary = {}
var quests: Dictionary = {}
var equipment: Dictionary = {}
var current_chapter: int = 1
var moral_choices: Dictionary = {}
var completed_chapters: Dictionary = {}

func _ready() -> void:
	reset_new_game()

func reset_new_game() -> void:
	current_map = GameIds.MAP_1
	current_spawn = GameIds.SPAWN_DEFAULT
	checkpoint_map = current_map
	checkpoint_spawn = current_spawn
	level = 1
	experience = 0
	potential_points = 0
	current_class = GameIds.CLASS_BLADEMASTER
	attributes = {
		GameIds.STAT_STR: 0,
		GameIds.STAT_INT: 0,
		GameIds.STAT_VIT: 0,
		GameIds.STAT_DEX: 0,
		GameIds.STAT_MND: 0,
	}
	inventory = {}
	currencies = {
		GameIds.CURRENCY_GOLD: 50,
		GameIds.CURRENCY_SOUL_SHARD: 0,
		GameIds.CURRENCY_WORLD_FRAGMENT: 0,
	}
	flags = {}
	quests = {}
	equipment = {&"weapon_level": 0, &"armor_level": 0, &"sockets": []}
	current_chapter = 1
	moral_choices = {}
	completed_chapters = {}
	_emit_all_changed()

func experience_required(target_level: int = level) -> int:
	return int(floor(100.0 * pow(float(maxi(target_level, 1)), 2.15)))

func gain_exp(amount: int) -> void:
	if amount <= 0 or level >= MAX_LEVEL:
		return
	experience += amount
	while level < MAX_LEVEL and experience >= experience_required(level):
		experience -= experience_required(level)
		level += 1
		potential_points += 5
	potential_points_changed.emit(potential_points)
	level_changed.emit(level, experience, experience_required(level))

func allocate_stat(stat_id: StringName, points: int) -> bool:
	if not GameIds.ALLOCATABLE_STATS.has(stat_id) or points <= 0 or points > potential_points:
		return false
	attributes[stat_id] = int(attributes.get(stat_id, 0)) + points
	potential_points -= points
	potential_points_changed.emit(potential_points)
	stats_changed.emit(get_calculated_stats())
	return true

func refund_stats() -> void:
	var refunded: int = 0
	for stat_id: StringName in GameIds.ALLOCATABLE_STATS:
		refunded += int(attributes.get(stat_id, 0))
		attributes[stat_id] = 0
	potential_points += refunded
	potential_points_changed.emit(potential_points)
	stats_changed.emit(get_calculated_stats())

func set_class(class_id: StringName) -> bool:
	if not GameIds.PLAYABLE_CLASSES.has(class_id):
		return false
	current_class = class_id
	class_changed.emit(current_class)
	stats_changed.emit(get_calculated_stats())
	return true

func add_item(item_id: StringName, quantity: int = 1) -> void:
	if item_id.is_empty() or quantity == 0:
		return
	var next_quantity: int = maxi(0, int(inventory.get(item_id, 0)) + quantity)
	if next_quantity == 0:
		inventory.erase(item_id)
	else:
		inventory[item_id] = next_quantity
	inventory_changed.emit(item_id, next_quantity)

func get_item_quantity(item_id: StringName) -> int:
	return int(inventory.get(item_id, 0))

func add_currency(currency_id: StringName, amount: int) -> void:
	var next_amount: int = maxi(0, int(currencies.get(currency_id, 0)) + amount)
	currencies[currency_id] = next_amount
	currency_changed.emit(currency_id, next_amount)

func spend_currency(currency_id: StringName, amount: int) -> bool:
	if amount < 0 or int(currencies.get(currency_id, 0)) < amount:
		return false
	add_currency(currency_id, -amount)
	return true

func get_currency(currency_id: StringName) -> int:
	return int(currencies.get(currency_id, 0))

func set_flag(flag_id: StringName, value: bool = true) -> void:
	flags[flag_id] = value
	flag_changed.emit(flag_id, value)

func has_flag(flag_id: StringName) -> bool:
	return bool(flags.get(flag_id, false))

func set_quest_state(quest_id: StringName, state: StringName) -> bool:
	if quest_id.is_empty() or state.is_empty() or StringName(quests.get(quest_id, &"")) == state:
		return false
	quests[quest_id] = state
	quest_changed.emit(quest_id, state)
	return true

func set_checkpoint(map_id: StringName, spawn_id: StringName) -> void:
	checkpoint_map = map_id
	checkpoint_spawn = spawn_id

func record_choice(choice_id: StringName, selected_option: StringName) -> bool:
	if choice_id.is_empty() or selected_option.is_empty():
		return false
	moral_choices[choice_id] = selected_option
	moral_choice_changed.emit(choice_id, selected_option)
	return true

func get_choice(choice_id: StringName) -> StringName:
	return StringName(moral_choices.get(choice_id, &""))

func complete_chapter(chapter_number: int, map_id: StringName) -> bool:
	if chapter_number < 1:
		return false
	var chapter_key := StringName("chapter_%d" % chapter_number)
	if bool(completed_chapters.get(chapter_key, false)):
		return false
	completed_chapters[chapter_key] = true
	current_chapter = maxi(current_chapter, mini(chapter_number + 1, 10))
	set_flag(StringName("%s_complete" % String(map_id)), true)
	chapter_progress_changed.emit(current_chapter, completed_chapters.duplicate())
	return true

func is_chapter_complete(chapter_number: int) -> bool:
	return bool(completed_chapters.get(StringName("chapter_%d" % chapter_number), false))

func get_calculated_stats() -> Dictionary:
	var strength: int = int(attributes.get(GameIds.STAT_STR, 0))
	var intellect: int = int(attributes.get(GameIds.STAT_INT, 0))
	var vitality: int = int(attributes.get(GameIds.STAT_VIT, 0))
	var dexterity: int = int(attributes.get(GameIds.STAT_DEX, 0))
	var mind: int = int(attributes.get(GameIds.STAT_MND, 0))
	return {
		&"max_hp": 100.0 + vitality * 18.0,
		&"attack": 12.0 + strength * 2.5,
		&"magic": 8.0 + intellect * 2.8,
		&"defense": 5.0 + strength + vitality * 1.5,
		&"resistance": 5.0 + intellect + mind * 1.5,
		&"max_stamina": 100.0 + dexterity * 1.2,
		&"critical_chance": 0.05 + dexterity * 0.004,
		&"speed": 100.0 + dexterity * 0.5,
		&"healing_bonus": mind * 0.006,
		&"void_resistance": mind * 0.004,
	}

func to_save_data() -> Dictionary:
	return {
		"version": SAVE_VERSION,
		"current_map": String(current_map),
		"current_spawn": String(current_spawn),
		"checkpoint_map": String(checkpoint_map),
		"checkpoint_spawn": String(checkpoint_spawn),
		"level": level,
		"experience": experience,
		"potential_points": potential_points,
		"current_class": String(current_class),
		"attributes": attributes,
		"inventory": inventory,
		"currencies": currencies,
		"flags": flags,
		"quests": quests,
		"equipment": equipment,
		"current_chapter": current_chapter,
		"moral_choices": moral_choices,
		"completed_chapters": completed_chapters,
	}

func load_save_data(data: Dictionary) -> bool:
	if int(data.get("version", 0)) > SAVE_VERSION:
		return false
	current_map = StringName(data.get("current_map", String(GameIds.MAP_1)))
	current_spawn = StringName(data.get("current_spawn", String(GameIds.SPAWN_DEFAULT)))
	checkpoint_map = StringName(data.get("checkpoint_map", String(current_map)))
	checkpoint_spawn = StringName(data.get("checkpoint_spawn", String(current_spawn)))
	level = clampi(int(data.get("level", 1)), 1, MAX_LEVEL)
	experience = maxi(0, int(data.get("experience", 0)))
	potential_points = maxi(0, int(data.get("potential_points", 0)))
	current_class = StringName(data.get("current_class", String(GameIds.CLASS_BLADEMASTER)))
	attributes = _normalize_dictionary(data.get("attributes", {}))
	inventory = _normalize_dictionary(data.get("inventory", {}))
	currencies = _normalize_dictionary(data.get("currencies", {}))
	flags = _normalize_dictionary(data.get("flags", {}))
	quests = _normalize_dictionary(data.get("quests", {}))
	equipment = _normalize_dictionary(data.get("equipment", {}))
	current_chapter = clampi(int(data.get("current_chapter", 1)), 1, 10)
	moral_choices = _normalize_dictionary(data.get("moral_choices", {}))
	completed_chapters = _normalize_dictionary(data.get("completed_chapters", {}))
	_emit_all_changed()
	return true

func _normalize_dictionary(source: Variant) -> Dictionary:
	var converted: Dictionary = {}
	if source is not Dictionary:
		return converted
	for key: Variant in source.keys():
		converted[StringName(str(key))] = source[key]
	return converted

func _emit_all_changed() -> void:
	level_changed.emit(level, experience, experience_required(level))
	potential_points_changed.emit(potential_points)
	class_changed.emit(current_class)
	stats_changed.emit(get_calculated_stats())
	chapter_progress_changed.emit(current_chapter, completed_chapters.duplicate())
	for currency_id: Variant in currencies:
		currency_changed.emit(StringName(currency_id), int(currencies[currency_id]))
