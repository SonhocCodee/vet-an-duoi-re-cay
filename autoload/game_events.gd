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

signal moral_choice_requested(choice_id: StringName, options: Array[Dictionary])
signal moral_choice_resolved(choice_id: StringName, selected_option: StringName)
signal chapter_completed(chapter_number: int, map_id: StringName)
signal campaign_completed

signal hud_refresh_requested(snapshot: Dictionary)
signal inventory_toggled(visible: bool)
signal quest_journal_toggled(visible: bool)
signal map_toggled(visible: bool)
signal npc_dialogue_requested(npc_id: StringName, dialogue_id: StringName, quest_id: StringName)
signal loot_picked_up(item_id: StringName, quantity: int)
signal quest_journal_updated(quest_id: StringName, state: Dictionary)
