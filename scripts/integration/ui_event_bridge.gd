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

func configure(ui: HubUI, player: PlayerController) -> void:
	_ui = ui
	_player = player
	GameEvents.dialogue_requested.connect(_on_dialogue_requested)

func _unhandled_input(event: InputEvent) -> void:
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
