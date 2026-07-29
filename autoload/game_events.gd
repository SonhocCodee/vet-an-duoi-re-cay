extends Node

signal map_change_requested(map_id: StringName, spawn_id: StringName)
signal map_changed(map_id: StringName, spawn_id: StringName)
signal tutorial_requested(step_id: StringName, message: String)
signal tutorial_closed(step_id: StringName)
signal dialogue_requested(dialogue_id: StringName)
signal dialogue_finished(dialogue_id: StringName)
signal hub_panel_requested(panel_id: StringName)
signal toast_requested(message: String)
signal interaction_prompt_changed(message: String, visible: bool)
signal player_registered(player: Node)
signal player_died
