extends Node

var _failures: PackedStringArray = []
var _checks: int = 0


func _ready() -> void:
	_check_v2_migration()
	_check_v3_round_trip()
	_check_future_version_rejected()
	_finish()


func _check_v2_migration() -> void:
	GameState.reset_new_game()
	var legacy: Dictionary = GameState.to_save_data()
	legacy["version"] = 2
	legacy["current_chapter"] = 7
	legacy["moral_choices"] = {"choice_bells": "mercy"}
	legacy["completed_chapters"] = {"chapter_2": true, "chapter_3": true}
	legacy["inventory"] = {"legacy_root": 4}
	legacy.erase("game_time")
	legacy.erase("npc_states")
	legacy.erase("active_quests")
	legacy.erase("completed_side_quests")
	legacy.erase("discovered_map_markers")
	_expect(GameState.load_save_data(legacy), "v2 save migrates successfully")
	_expect(GameState.current_chapter == 7, "migration preserves campaign chapter")
	_expect(GameState.get_choice(&"choice_bells") == &"mercy", "migration preserves moral choice")
	_expect(GameState.is_chapter_complete(2), "migration preserves completed chapters")
	_expect(GameState.get_item_quantity(&"legacy_root") == 4, "migration preserves inventory")
	_expect(is_equal_approx(GameState.game_time, 8.0), "migration supplies default game time")
	_expect(GameState.npc_states.is_empty(), "migration supplies empty NPC states")
	_expect(GameState.active_quests.is_empty(), "migration supplies empty active quests")
	_expect(GameState.completed_side_quests.is_empty(), "migration supplies empty completed side quests")
	_expect(GameState.discovered_map_markers.is_empty(), "migration supplies empty map markers")


func _check_v3_round_trip() -> void:
	GameState.set_game_time(17.5)
	GameState.set_npc_state(&"mira_apothecary", {&"target_id": &"herb_garden", &"position": [10.0, 20.0]})
	GameState.active_quests[&"three_poison_roots"] = {&"status": &"active", &"objective_index": 1, &"progress": 2}
	GameState.completed_side_quests[&"ash_bread"] = true
	GameState.discover_map_marker(&"herb_market", {&"label": "Chợ thảo dược"})
	var save_data: Dictionary = GameState.to_save_data()
	_expect(int(save_data["version"]) == 3, "save output uses version 3")
	GameState.reset_new_game()
	_expect(GameState.load_save_data(save_data), "v3 save reloads")
	_expect(is_equal_approx(GameState.game_time, 17.5), "v3 preserves game time")
	_expect(GameState.get_npc_state(&"mira_apothecary").get(&"target_id") == &"herb_garden", "v3 preserves NPC target")
	_expect(GameState.active_quests.has(&"three_poison_roots"), "v3 preserves active quest")
	_expect(GameState.completed_side_quests.has(&"ash_bread"), "v3 preserves completed side quest")
	_expect(GameState.discovered_map_markers.has(&"herb_market"), "v3 preserves discovered marker")


func _check_future_version_rejected() -> void:
	var future: Dictionary = GameState.to_save_data()
	future["version"] = 4
	_expect(not GameState.load_save_data(future), "future save version is rejected")


func _expect(condition: bool, message: String) -> void:
	_checks += 1
	if not condition:
		_failures.append(message)
		push_error("[SECOND WAVE SAVE][FAIL] %s" % message)


func _finish() -> void:
	if _failures.is_empty():
		print("[SECOND WAVE SAVE][PASS] %d checks." % _checks)
		get_tree().quit(0)
		return
	print("[SECOND WAVE SAVE][SUMMARY] %d/%d failed." % [_failures.size(), _checks])
	get_tree().quit(1)
