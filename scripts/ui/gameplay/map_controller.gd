class_name GameplayMapController
extends Control

signal panel_toggled(opened: bool)
signal markers_changed(markers: Dictionary)

@export var start_open: bool = false


func _ready() -> void:
	visible = start_open
	if GameState.has_signal(&"map_marker_discovered"):
		GameState.map_marker_discovered.connect(_on_marker_discovered)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed(&"toggle_map"):
		toggle()
		get_viewport().set_input_as_handled()


func toggle() -> void:
	set_open(not visible)


func set_open(opened: bool) -> void:
	visible = opened
	panel_toggled.emit(opened)
	GameEvents.map_toggled.emit(opened)
	if opened:
		markers_changed.emit(get_markers())


func discover_marker(marker_id: StringName, marker_data: Dictionary = {}) -> bool:
	return GameState.discover_map_marker(marker_id, marker_data)


func get_markers() -> Dictionary:
	return GameState.discovered_map_markers.duplicate(true)


func _on_marker_discovered(_marker_id: StringName, _data: Dictionary) -> void:
	if visible:
		markers_changed.emit(get_markers())
