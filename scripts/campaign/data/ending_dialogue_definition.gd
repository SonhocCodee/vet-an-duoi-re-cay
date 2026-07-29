class_name EndingDialogueDefinition
extends Resource

@export var ending_id: StringName
@export var title: String
@export var subtitle: String
@export var speaker_name: String
@export var lines: Array[String] = []
@export var required_choice_flags: Array[StringName] = []
@export var completion_flag: StringName
@export var next_map_id: StringName
@export var spawn_id: StringName = &"epilogue_start"
@export var background_color: Color = Color.BLACK


func is_valid_definition() -> bool:
	return (
		ending_id != &""
		and not title.strip_edges().is_empty()
		and not speaker_name.strip_edges().is_empty()
		and not lines.is_empty()
		and not required_choice_flags.is_empty()
		and completion_flag != &""
		and next_map_id != &""
		and spawn_id != &""
	)
