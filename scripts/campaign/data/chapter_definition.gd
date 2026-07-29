class_name ChapterDefinition
extends Resource

const REQUIRED_WAVE_COUNT: int = 3
const BOSS_PREFIX: String = "boss_"

@export_group("Identity")
@export var chapter_id: StringName
@export_range(2, 10, 1) var chapter_number: int = 2
@export var title: String
@export var subtitle: String

@export_group("Narrative")
@export var intro_lines: Array[String] = []
@export_multiline var objective: String
@export var companion: StringName
@export var completion_lines: Array[String] = []

@export_group("Encounters")
@export var encounter_enemy_ids: Array[StringName] = []
@export var boss_enemy_id: StringName

@export_group("Moral Choice")
@export var moral_choice_id: StringName
@export_multiline var moral_option_a_text: String
@export var moral_option_a_flag: StringName
@export_multiline var moral_option_b_text: String
@export var moral_option_b_flag: StringName

@export_group("Progression")
@export_range(0, 1000000, 1) var reward_exp: int = 0
@export var unlock_class_id: StringName
@export var next_map_id: StringName
@export var spawn_id: StringName = &"chapter_start"

@export_group("Presentation")
@export var palette_colors: Array[Color] = []
@export var background_color: Color = Color.BLACK


func get_moral_choice_flags() -> Array[StringName]:
	return [moral_option_a_flag, moral_option_b_flag]


func has_class_unlock() -> bool:
	return unlock_class_id != &""


func get_validation_errors() -> Array[String]:
	var errors: Array[String] = []
	if chapter_id == &"":
		errors.append("chapter_id is required")
	if chapter_number < 2 or chapter_number > 10:
		errors.append("chapter_number must be between 2 and 10")
	if title.strip_edges().is_empty():
		errors.append("title is required")
	if subtitle.strip_edges().is_empty():
		errors.append("subtitle is required")
	if intro_lines.is_empty():
		errors.append("intro_lines must not be empty")
	if objective.strip_edges().is_empty():
		errors.append("objective is required")
	if encounter_enemy_ids.size() != REQUIRED_WAVE_COUNT:
		errors.append("encounter_enemy_ids must contain exactly three waves")
	for enemy_id: StringName in encounter_enemy_ids:
		if enemy_id == &"":
			errors.append("wave enemy IDs must not be empty")
	if not String(boss_enemy_id).begins_with(BOSS_PREFIX):
		errors.append("boss_enemy_id must begin with boss_")
	if moral_choice_id == &"":
		errors.append("moral_choice_id is required")
	if moral_option_a_text.strip_edges().is_empty() or moral_option_a_flag == &"":
		errors.append("moral option A requires text and flag")
	if moral_option_b_text.strip_edges().is_empty() or moral_option_b_flag == &"":
		errors.append("moral option B requires text and flag")
	if moral_option_a_flag == moral_option_b_flag:
		errors.append("moral option flags must be distinct")
	if companion == &"":
		errors.append("companion is required")
	if completion_lines.is_empty():
		errors.append("completion_lines must not be empty")
	if reward_exp <= 0:
		errors.append("reward_exp must be positive")
	if next_map_id == &"":
		errors.append("next_map_id is required")
	if spawn_id == &"":
		errors.append("spawn_id is required")
	if palette_colors.size() < 3:
		errors.append("palette_colors must contain at least three colors")
	return errors


func is_valid_definition() -> bool:
	return get_validation_errors().is_empty()
