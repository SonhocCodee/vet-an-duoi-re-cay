class_name SideQuestObjective
extends Resource

@export var objective_id: StringName
@export_multiline var description: String
@export_range(1, 999, 1) var required_count: int = 1


func is_valid_objective() -> bool:
	return objective_id != &"" and not description.strip_edges().is_empty() and required_count > 0
