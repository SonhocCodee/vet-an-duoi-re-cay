class_name SideQuestDefinition
extends Resource

@export_group("Identity")
@export var quest_id: StringName
@export var title: String
@export_multiline var description: String
@export var giver_npc_id: StringName

@export_group("Objectives")
@export var objectives: Array[SideQuestObjective] = []
@export var required_flags: Array[StringName] = []

@export_group("Rewards")
@export_range(0, 100000, 1) var reward_experience: int = 0
@export_range(0, 100000, 1) var reward_gold: int = 0
@export var reward_items: Dictionary = {}


func get_validation_errors() -> Array[String]:
	var errors: Array[String] = []
	if quest_id == &"":
		errors.append("quest_id is required")
	if title.strip_edges().is_empty():
		errors.append("title is required")
	if description.strip_edges().is_empty():
		errors.append("description is required")
	if giver_npc_id == &"":
		errors.append("giver_npc_id is required")
	if objectives.is_empty():
		errors.append("objectives must not be empty")
	for objective: SideQuestObjective in objectives:
		if objective == null or not objective.is_valid_objective():
			errors.append("objectives contains an invalid entry")
	for item_id: Variant in reward_items:
		if StringName(str(item_id)) == &"" or int(reward_items[item_id]) <= 0:
			errors.append("reward_items contains an invalid entry")
	return errors


func is_valid_definition() -> bool:
	return get_validation_errors().is_empty()
