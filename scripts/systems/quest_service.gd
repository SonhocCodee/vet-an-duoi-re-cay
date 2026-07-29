extends Node

signal quest_updated(quest_id: StringName, state: Dictionary)

const QUEST_IDS: Array[StringName] = [
	&"sword_without_name", &"three_poison_roots", &"unrung_bell", &"ash_bread",
	&"tracks_beyond_wall", &"erased_roads", &"shadowless_horse", &"memory_cloth",
	&"weeping_stone", &"doll_under_drain", &"kael_asterion_record", &"guest_room_seven",
	&"black_eyed_white_fish", &"silent_child", &"empty_thirteenth_grave", &"cracked_crown",
	&"false_decree", &"saint_marked_beast", &"watch_traitor", &"prophecy_beneath_roots",
]
const QUEST_RESOURCE_ROOT: String = "res://resources/quests/side/"

var _definitions: Dictionary = {}


func _ready() -> void:
	load_default_catalog()


func load_default_catalog() -> int:
	var loaded_count: int = 0
	for quest_id: StringName in QUEST_IDS:
		var definition: SideQuestDefinition = ResourceLoader.load(QUEST_RESOURCE_ROOT + String(quest_id) + ".tres") as SideQuestDefinition
		if definition != null and register_quest(definition):
			loaded_count += 1
	return loaded_count


func register_quest(definition: SideQuestDefinition) -> bool:
	if definition == null or not definition.is_valid_definition():
		return false
	_definitions[definition.quest_id] = definition
	return true


func start_quest(quest_id: StringName) -> bool:
	var definition: SideQuestDefinition = get_quest_definition(quest_id)
	if definition == null or GameState.completed_side_quests.has(quest_id) or GameState.active_quests.has(quest_id):
		return false
	for flag_id: StringName in definition.required_flags:
		if not GameState.has_flag(flag_id):
			return false
	var state: Dictionary = {
		&"status": &"active",
		&"objective_index": 0,
		&"progress": 0,
	}
	GameState.active_quests[quest_id] = state
	GameState.set_quest_state(quest_id, &"active")
	_emit_update(quest_id, state)
	return true


func advance_objective(quest_id: StringName, objective_id: StringName, amount: int = 1) -> bool:
	if amount <= 0 or not GameState.active_quests.has(quest_id):
		return false
	var definition: SideQuestDefinition = get_quest_definition(quest_id)
	var state: Dictionary = (GameState.active_quests[quest_id] as Dictionary).duplicate(true)
	if definition == null:
		return false
	var objective_index: int = int(state.get(&"objective_index", 0))
	if objective_index < 0 or objective_index >= definition.objectives.size():
		return false
	var objective: SideQuestObjective = definition.objectives[objective_index]
	if objective.objective_id != objective_id:
		return false
	state[&"progress"] = mini(int(state.get(&"progress", 0)) + amount, objective.required_count)
	if int(state[&"progress"]) >= objective.required_count:
		state[&"objective_index"] = objective_index + 1
		state[&"progress"] = 0
	GameState.active_quests[quest_id] = state
	if int(state[&"objective_index"]) >= definition.objectives.size():
		return complete_quest(quest_id)
	_emit_update(quest_id, state)
	return true


func complete_quest(quest_id: StringName) -> bool:
	if not GameState.active_quests.has(quest_id):
		return false
	var definition: SideQuestDefinition = get_quest_definition(quest_id)
	if definition == null:
		return false
	GameState.active_quests.erase(quest_id)
	GameState.completed_side_quests[quest_id] = true
	GameState.set_quest_state(quest_id, &"completed")
	if definition.reward_experience > 0:
		GameState.gain_exp(definition.reward_experience)
	if definition.reward_gold > 0:
		GameState.add_currency(GameIds.CURRENCY_GOLD, definition.reward_gold)
	for item_id: Variant in definition.reward_items:
		GameState.add_item(StringName(str(item_id)), int(definition.reward_items[item_id]))
	_emit_update(quest_id, {&"status": &"completed"})
	return true


func get_quest_definition(quest_id: StringName) -> SideQuestDefinition:
	return _definitions.get(quest_id) as SideQuestDefinition


func get_active_quest_state(quest_id: StringName) -> Dictionary:
	var state: Variant = GameState.active_quests.get(quest_id, {})
	return (state as Dictionary).duplicate(true) if state is Dictionary else {}


func get_registered_quest_count() -> int:
	return _definitions.size()


func _emit_update(quest_id: StringName, state: Dictionary) -> void:
	quest_updated.emit(quest_id, state.duplicate(true))
	GameState.side_quest_changed.emit(quest_id, state.duplicate(true))
	if GameEvents.has_signal(&"quest_journal_updated"):
		GameEvents.quest_journal_updated.emit(quest_id, state.duplicate(true))
