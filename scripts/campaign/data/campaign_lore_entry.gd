class_name CampaignLoreEntry
extends Resource

const VALID_CATEGORIES: Array[StringName] = [
	&"location",
	&"adversary",
	&"moral_choice",
]

@export_group("Identity")
@export var entry_id: StringName
@export var chapter_id: StringName
@export_range(2, 10, 1) var chapter_number: int = 2
@export var category_id: StringName = &"location"

@export_group("Codex Text")
@export var title: String
@export_multiline var summary: String
@export_multiline var body: String

@export_group("Links")
@export var related_ids: Array[StringName] = []
@export var unlock_condition: StringName


func get_validation_errors() -> Array[String]:
	var errors: Array[String] = []
	if entry_id == &"":
		errors.append("entry_id is required")
	if chapter_id == &"":
		errors.append("chapter_id is required")
	if chapter_number < 2 or chapter_number > 10:
		errors.append("chapter_number must be between 2 and 10")
	if category_id not in VALID_CATEGORIES:
		errors.append("category must be location, adversary, or moral_choice")
	if title.strip_edges().is_empty():
		errors.append("title is required")
	if summary.strip_edges().is_empty():
		errors.append("summary is required")
	if body.strip_edges().is_empty():
		errors.append("body is required")
	if related_ids.is_empty():
		errors.append("related_ids must not be empty")
	if unlock_condition == &"":
		errors.append("unlock_condition is required")
	return errors


func is_valid_entry() -> bool:
	return get_validation_errors().is_empty()
