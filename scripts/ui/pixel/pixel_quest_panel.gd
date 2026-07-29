class_name PixelQuestPanel
extends PanelContainer

const PixelTheme = preload("res://scripts/ui/pixel/pixel_ui_theme.gd")

@onready var quest_list: VBoxContainer = %QuestList
@onready var empty_label: Label = %QuestEmpty
@onready var detail_title: Label = %QuestDetailTitle
@onready var detail_description: Label = %QuestDetailDescription
@onready var objective_label: Label = %QuestObjective
@onready var reward_label: Label = %QuestReward

var _selected_quest: StringName = &""
var _active: Dictionary = {}
var _completed: Dictionary = {}
var _rendered_quest_count: int = 0


func refresh(active: Dictionary = GameState.active_quests, completed: Dictionary = GameState.completed_side_quests) -> void:
	_active = active.duplicate(true)
	_completed = completed.duplicate(true)
	PixelTheme.clear_children(quest_list)
	var active_ids: Array = _active.keys()
	active_ids.sort_custom(func(a: Variant, b: Variant) -> bool: return String(a) < String(b))
	var completed_ids: Array = _completed.keys()
	completed_ids.sort_custom(func(a: Variant, b: Variant) -> bool: return String(a) < String(b))
	_rendered_quest_count = 0
	for quest_value: Variant in active_ids:
		_add_quest_button(StringName(str(quest_value)), false)
	for quest_value: Variant in completed_ids:
		_add_quest_button(StringName(str(quest_value)), true)
	empty_label.visible = _rendered_quest_count == 0
	if _selected_quest == &"" or (not _active.has(_selected_quest) and not _completed.has(_selected_quest)):
		_selected_quest = StringName(str(active_ids[0])) if not active_ids.is_empty() else (StringName(str(completed_ids[0])) if not completed_ids.is_empty() else &"")
	_show_selected_quest()


func get_rendered_quest_count() -> int:
	return _rendered_quest_count


func _add_quest_button(quest_id: StringName, completed: bool) -> void:
	var definition: SideQuestDefinition = QuestService.get_quest_definition(quest_id)
	var title := definition.title if definition != null else PixelTheme.humanize_id(quest_id)
	var button := Button.new()
	button.custom_minimum_size = Vector2(238.0, 38.0)
	button.text = ("[X] " if completed else "[>] ") + title
	button.alignment = HORIZONTAL_ALIGNMENT_LEFT
	button.tooltip_text = "Đã hoàn thành" if completed else "Đang theo dõi"
	PixelTheme.style_button(button, quest_id == _selected_quest)
	button.pressed.connect(_select_quest.bind(quest_id))
	quest_list.add_child(button)
	_rendered_quest_count += 1


func _select_quest(quest_id: StringName) -> void:
	_selected_quest = quest_id
	refresh(_active, _completed)


func _show_selected_quest() -> void:
	if _selected_quest == &"":
		detail_title.text = "CHƯA CÓ NHIỆM VỤ"
		detail_description.text = "Khám phá thành phố để tìm người cần giúp đỡ."
		objective_label.text = ""
		reward_label.text = ""
		return
	var definition: SideQuestDefinition = QuestService.get_quest_definition(_selected_quest)
	if definition == null:
		detail_title.text = PixelTheme.humanize_id(_selected_quest)
		detail_description.text = "Không tìm thấy dữ liệu nhiệm vụ."
		objective_label.text = ""
		reward_label.text = ""
		return
	detail_title.text = definition.title.to_upper()
	detail_description.text = definition.description
	if _completed.has(_selected_quest):
		objective_label.text = "[HOÀN THÀNH]"
	else:
		var state: Dictionary = _active.get(_selected_quest, {}) as Dictionary
		var objective_index := int(state.get(&"objective_index", 0))
		if objective_index >= 0 and objective_index < definition.objectives.size():
			var objective: SideQuestObjective = definition.objectives[objective_index]
			objective_label.text = "%s  %d/%d" % [objective.description, int(state.get(&"progress", 0)), objective.required_count]
		else:
			objective_label.text = "Mục tiêu đã hoàn tất"
	reward_label.text = "Thưởng: %d XP  |  %d vàng" % [definition.reward_experience, definition.reward_gold]
