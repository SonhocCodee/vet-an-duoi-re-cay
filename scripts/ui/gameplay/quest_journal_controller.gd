class_name QuestJournalGameplayController
extends Control

signal panel_toggled(opened: bool)
signal snapshot_changed(snapshot: Dictionary)

@export var start_open: bool = false


func _ready() -> void:
	visible = start_open
	var quest_service: Node = get_node_or_null(^"/root/QuestService")
	if quest_service != null and quest_service.has_signal(&"quest_updated"):
		quest_service.quest_updated.connect(_on_quest_updated)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed(&"toggle_quest_journal"):
		toggle()
		get_viewport().set_input_as_handled()


func toggle() -> void:
	set_open(not visible)


func set_open(opened: bool) -> void:
	visible = opened
	panel_toggled.emit(opened)
	GameEvents.quest_journal_toggled.emit(opened)
	if opened:
		refresh()


func refresh() -> Dictionary:
	var snapshot: Dictionary = get_snapshot()
	snapshot_changed.emit(snapshot.duplicate(true))
	return snapshot


func get_snapshot() -> Dictionary:
	return {
		&"active": GameState.active_quests.duplicate(true),
		&"completed": GameState.completed_side_quests.duplicate(true),
	}


func _on_quest_updated(_quest_id: StringName, _state: Dictionary) -> void:
	if visible:
		refresh()
