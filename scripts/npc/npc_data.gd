class_name NpcData
extends Resource

@export_group("Identity")
@export var npc_id: StringName
@export var display_name: String
@export var profession: String
@export var district_id: StringName

@export_group("Interaction")
@export var dialogue_id: StringName
@export var side_quest_id: StringName
@export var portrait_path: String
@export var animation_root: String

@export_group("Schedule")
@export var schedule: Array[NpcScheduleEntry] = []


func resolve_target(hour: float) -> StringName:
	for entry: NpcScheduleEntry in schedule:
		if entry != null and entry.contains_hour(hour):
			return entry.target_id
	return district_id


func resolve_activity(hour: float) -> String:
	for entry: NpcScheduleEntry in schedule:
		if entry != null and entry.contains_hour(hour):
			return entry.activity
	return "Đang nghỉ"


func get_validation_errors() -> Array[String]:
	var errors: Array[String] = []
	if npc_id == &"":
		errors.append("npc_id is required")
	if display_name.strip_edges().is_empty():
		errors.append("display_name is required")
	if profession.strip_edges().is_empty():
		errors.append("profession is required")
	if district_id == &"":
		errors.append("district_id is required")
	if dialogue_id == &"":
		errors.append("dialogue_id is required")
	if side_quest_id == &"":
		errors.append("side_quest_id is required")
	if schedule.is_empty():
		errors.append("schedule must not be empty")
	for entry: NpcScheduleEntry in schedule:
		if entry == null or not entry.is_valid_entry():
			errors.append("schedule contains an invalid entry")
	return errors


func is_valid_definition() -> bool:
	return get_validation_errors().is_empty()
