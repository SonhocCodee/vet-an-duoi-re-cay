class_name NpcScheduleEntry
extends Resource

@export_range(0, 23, 1) var start_hour: int = 0
@export_range(1, 24, 1) var end_hour: int = 24
@export var target_id: StringName
@export var activity: String


func contains_hour(hour: float) -> bool:
	var normalized_hour: float = fposmod(hour, 24.0)
	if start_hour == end_hour:
		return true
	if start_hour < end_hour:
		return normalized_hour >= float(start_hour) and normalized_hour < float(end_hour)
	return normalized_hour >= float(start_hour) or normalized_hour < float(end_hour)


func is_valid_entry() -> bool:
	return target_id != &"" and start_hour >= 0 and start_hour < 24 and end_hour > 0 and end_hour <= 24
