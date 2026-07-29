class_name UIEventBridge
extends Node

const MAP1_STORY: Map1StoryResource = preload("res://resources/story/map1/map1_story_vi.tres")
const ARIA_DIALOGUE: AriaDialogueData = preload("res://resources/story/map2/aria_after_stag.tres")

var _ui: HubUI
var _player: PlayerController
var _active_dialogue_id: StringName = &""
var _dialogue_lines: Array[String] = []
var _dialogue_index: int = 0
var _manual_dialogue: bool = false
var _active_choice_id: StringName = &""
var _active_choice_options: Array[Dictionary] = []
var _choice_previous_controls_enabled: bool = true

func configure(ui: HubUI, player: PlayerController) -> void:
	_ui = ui
	_player = player
	if not GameEvents.dialogue_requested.is_connected(_on_dialogue_requested):
		GameEvents.dialogue_requested.connect(_on_dialogue_requested)
	if not GameEvents.moral_choice_requested.is_connected(_on_moral_choice_requested):
		GameEvents.moral_choice_requested.connect(_on_moral_choice_requested)
	if not GameEvents.moral_choice_resolved.is_connected(_on_external_choice_resolved):
		GameEvents.moral_choice_resolved.connect(_on_external_choice_resolved)
	var dialogue_panel := _ui.get_node("DialoguePanel") as DialoguePanel
	if not dialogue_panel.choice_selected.is_connected(_on_choice_selected):
		dialogue_panel.choice_selected.connect(_on_choice_selected)

func _unhandled_input(event: InputEvent) -> void:
	if not _active_choice_id.is_empty() and event is InputEventKey and event.pressed and not event.echo:
		var choice_index := _choice_index_for_key(event as InputEventKey)
		if choice_index >= 0:
			_on_choice_selected(choice_index)
			get_viewport().set_input_as_handled()
		return
	if not _manual_dialogue or _active_dialogue_id.is_empty():
		return
	if event.is_action_pressed(&"interact") or event.is_action_pressed(&"attack"):
		_advance_dialogue()
		get_viewport().set_input_as_handled()

func _on_dialogue_requested(dialogue_id: StringName) -> void:
	_active_dialogue_id = dialogue_id
	_dialogue_index = 0
	_manual_dialogue = dialogue_id == ARIA_DIALOGUE.dialogue_id
	_dialogue_lines = _resolve_dialogue_lines(dialogue_id)
	if _dialogue_lines.is_empty():
		_dialogue_lines = [String(dialogue_id).replace("_", " ")]
	if _manual_dialogue:
		_player.set_control_enabled(false)
	_show_current_dialogue_line()
	if not _manual_dialogue:
		_auto_close_dialogue(dialogue_id)

func _advance_dialogue() -> void:
	_dialogue_index += 1
	if _dialogue_index < _dialogue_lines.size():
		_show_current_dialogue_line()
		return
	_finish_dialogue()

func _finish_dialogue() -> void:
	var finished_id: StringName = _active_dialogue_id
	var restore_player_control: bool = _manual_dialogue
	_active_dialogue_id = &""
	_dialogue_lines.clear()
	_manual_dialogue = false
	if _ui != null:
		(_ui.get_node("DialoguePanel") as DialoguePanel).close_dialogue()
	if restore_player_control:
		_player.set_control_enabled(true)
	GameEvents.dialogue_finished.emit(finished_id)

func _auto_close_dialogue(dialogue_id: StringName) -> void:
	await get_tree().create_timer(2.15).timeout
	if _active_dialogue_id == dialogue_id and not _manual_dialogue:
		_finish_dialogue()

func _show_current_dialogue_line() -> void:
	if _ui == null or _dialogue_index >= _dialogue_lines.size():
		return
	var speaker: String = ARIA_DIALOGUE.speaker_name if _manual_dialogue else "Kael"
	_ui.show_dialogue(speaker, _dialogue_lines[_dialogue_index])

func _resolve_dialogue_lines(dialogue_id: StringName) -> Array[String]:
	if dialogue_id == ARIA_DIALOGUE.dialogue_id:
		return ARIA_DIALOGUE.lines.duplicate()
	var id_text: String = String(dialogue_id)
	if id_text.begins_with("map1_opening_"):
		var opening_index: int = id_text.get_slice("_", 2).to_int()
		if opening_index >= 0 and opening_index < MAP1_STORY.opening_lines.size():
			return [MAP1_STORY.opening_lines[opening_index]]
	if id_text.begins_with("map1_weapon_"):
		var weapon_index: int = id_text.get_slice("_", 2).to_int()
		if weapon_index >= 0 and weapon_index < MAP1_STORY.weapon_lines.size():
			return [MAP1_STORY.weapon_lines[weapon_index]]
	return []

func _on_moral_choice_requested(choice_id: StringName, options: Array[Dictionary]) -> void:
	if choice_id.is_empty() or not _active_choice_id.is_empty() or options.size() < 2:
		return
	_active_choice_id = choice_id
	_active_choice_options.clear()
	for option: Dictionary in options:
		_active_choice_options.append(option.duplicate(true))
	_choice_previous_controls_enabled = _player.controls_enabled
	_player.set_control_enabled(false)
	var labels: Array[String] = [
		_option_text(_active_choice_options[0], 0),
		_option_text(_active_choice_options[1], 1),
	]
	_ui.show_dialogue("Lựa chọn", "Chọn con đường của Kael. Nhấn 1 hoặc 2.", labels)

func _on_choice_selected(index: int) -> void:
	if _active_choice_id.is_empty() or index < 0 or index >= mini(2, _active_choice_options.size()):
		return
	var choice_id: StringName = _active_choice_id
	var option_id := _option_id(_active_choice_options[index], index)
	_dismiss_active_choice()
	GameState.record_choice(choice_id, option_id)
	GameEvents.moral_choice_resolved.emit(choice_id, option_id)

func _on_external_choice_resolved(choice_id: StringName, _option_id: StringName) -> void:
	if _active_choice_id != choice_id:
		return
	_dismiss_active_choice()

func _choice_index_for_key(event: InputEventKey) -> int:
	var pressed_key := event.physical_keycode if event.physical_keycode != KEY_NONE else event.keycode
	if pressed_key == KEY_1 or pressed_key == KEY_KP_1:
		return 0
	if pressed_key == KEY_2 or pressed_key == KEY_KP_2:
		return 1
	return -1

func _option_id(option: Dictionary, index: int) -> StringName:
	var option_id := StringName(option.get("id", option.get("option_id", &"")))
	if not option_id.is_empty():
		return option_id
	return StringName("option_%d" % (index + 1))

func _option_text(option: Dictionary, index: int) -> String:
	var option_text := String(option.get("text", option.get("label", ""))).strip_edges()
	if not option_text.is_empty():
		return option_text
	return "Lựa chọn %d" % (index + 1)

func _dismiss_active_choice() -> void:
	_active_choice_id = &""
	_active_choice_options.clear()
	(_ui.get_node("DialoguePanel") as DialoguePanel).close_dialogue()
	_player.set_control_enabled(_choice_previous_controls_enabled)
