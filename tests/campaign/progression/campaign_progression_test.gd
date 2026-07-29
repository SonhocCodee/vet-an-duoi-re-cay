extends Node

const TEST_SAVE_SLOT: int = 97321
const TEST_SAVE_PATH: String = "user://save_97321.json"
const TRUE_ENDING_SCENE_PATH: String = "res://scenes/ending/true_ending.tscn"

const CHAPTER_RESOURCES: Array[String] = [
	"res://resources/campaign/chapters/chapter_2_drowned_bells.tres",
	"res://resources/campaign/chapters/chapter_3_blind_procession.tres",
	"res://resources/campaign/chapters/chapter_4_erased_archive.tres",
	"res://resources/campaign/chapters/chapter_5_quartz_wastes.tres",
	"res://resources/campaign/chapters/chapter_6_burning_root_garden.tres",
	"res://resources/campaign/chapters/chapter_7_black_resin_pass.tres",
	"res://resources/campaign/chapters/chapter_8_empty_monastery.tres",
	"res://resources/campaign/chapters/chapter_9_false_sun_citadel.tres",
	"res://resources/campaign/chapters/chapter_10_world_root.tres",
]

var _failures: Array[String] = []
var _checks_run: int = 0
var _map_requests: Array[Dictionary] = []
var _chapter_completions: Array[Dictionary] = []
var _campaign_completion_count: int = 0


func _ready() -> void:
	call_deferred(&"_run")


func _run() -> void:
	_connect_campaign_signals()
	_cleanup_test_save()
	_test_save_version_three_round_trip()
	_test_future_save_version_is_rejected()
	_test_campaign_director_progression()
	await _test_true_ending_scene_route()
	_cleanup_test_save()
	_finish()


func _connect_campaign_signals() -> void:
	GameEvents.map_change_requested.connect(_on_map_change_requested)
	GameEvents.chapter_completed.connect(_on_chapter_completed)
	GameEvents.campaign_completed.connect(_on_campaign_completed)


func _test_save_version_three_round_trip() -> void:
	GameState.reset_new_game()
	var expected_choices: Dictionary = _record_all_moral_choices()
	_complete_all_chapters_in_game_state()
	GameState.current_map = GameIds.MAP_CHAPTER_10
	GameState.current_spawn = GameIds.SPAWN_DEFAULT

	var save_data: Dictionary = GameState.to_save_data()
	_expect(int(save_data.get("version", 0)) == 3, "GameState serializes save version 3")
	_expect(save_data.has("current_chapter"), "version 3 save contains current_chapter")
	_expect(save_data.has("moral_choices"), "version 3 save contains moral_choices")
	_expect(save_data.has("completed_chapters"), "version 3 save contains completed_chapters")
	_expect((save_data.get("moral_choices", {}) as Dictionary).size() == 9, "version 3 save contains nine moral choices")
	_expect((save_data.get("completed_chapters", {}) as Dictionary).size() == 9, "version 3 save contains Chapter 2 through Chapter 10")

	var save_error: Error = SaveService.save_game(TEST_SAVE_SLOT)
	_expect(save_error == OK, "SaveService writes the version 3 campaign save")
	var persisted_data: Dictionary = _read_test_save()
	_expect(int(persisted_data.get("version", 0)) == 3, "persisted JSON uses save version 3")

	GameState.reset_new_game()
	_expect(GameState.moral_choices.is_empty(), "reset clears moral choices before load")
	_expect(GameState.completed_chapters.is_empty(), "reset clears chapter completion before load")
	var load_error: Error = SaveService.load_game(TEST_SAVE_SLOT)
	_expect(load_error == OK, "SaveService loads the version 3 campaign save")
	_expect(GameState.current_chapter == 10, "version 3 load restores current_chapter 10")
	_expect(GameState.current_map == GameIds.MAP_CHAPTER_10, "version 3 load restores current map")
	_expect(GameState.moral_choices.size() == 9, "version 3 load restores nine moral choices")
	_expect(GameState.completed_chapters.size() == 9, "version 3 load restores nine completed chapters")
	for choice_id: Variant in expected_choices:
		_expect(GameState.get_choice(StringName(choice_id)) == StringName(expected_choices[choice_id]), "version 3 load restores moral choice %s" % String(choice_id))
	for chapter_number: int in range(2, 11):
		_expect(GameState.is_chapter_complete(chapter_number), "version 3 load restores Chapter %d completion" % chapter_number)


func _test_future_save_version_is_rejected() -> void:
	var before: Dictionary = GameState.to_save_data()
	var future_data: Dictionary = before.duplicate(true)
	future_data["version"] = 4
	future_data["current_chapter"] = 1
	_expect(not GameState.load_save_data(future_data), "GameState rejects save versions newer than 3")
	_expect(GameState.current_chapter == int(before["current_chapter"]), "rejected future save does not mutate progression")


func _test_campaign_director_progression() -> void:
	GameState.reset_new_game()
	_clear_captured_signals()

	CampaignDirector.start_from_hub()
	_expect(_map_requests.size() == 1, "start_from_hub emits one map request")
	_expect(_last_requested_map() == GameIds.MAP_CHAPTER_2, "start_from_hub routes a new game to Chapter 2")
	_clear_captured_signals()

	for chapter_number: int in range(2, 11):
		var chapter_map: StringName = CampaignDirector.get_chapter_map(chapter_number)
		var expected_map: StringName = GameIds.MAP_TRUE_ENDING if chapter_number == 10 else CampaignDirector.get_chapter_map(chapter_number + 1)
		CampaignDirector.complete_chapter(chapter_number, chapter_map)
		_expect(GameState.is_chapter_complete(chapter_number), "CampaignDirector completes Chapter %d" % chapter_number)
		_expect(GameState.has_flag(StringName("%s_complete" % String(chapter_map))), "Chapter %d completion flag is recorded" % chapter_number)
		_expect(_chapter_completions.size() == chapter_number - 1, "Chapter %d emits chapter_completed exactly once" % chapter_number)
		_expect(_last_requested_map() == expected_map, "Chapter %d routes to %s" % [chapter_number, String(expected_map)])

	_expect(GameState.current_chapter == 10, "CampaignDirector progression ends at current_chapter 10")
	_expect(GameState.completed_chapters.size() == 9, "CampaignDirector records all nine campaign chapters")
	_expect(_campaign_completion_count == 1, "Chapter 10 emits campaign_completed exactly once")
	_expect(_last_requested_map() == GameIds.MAP_TRUE_ENDING, "Chapter 10 requests the canonical true_ending route")


func _test_true_ending_scene_route() -> void:
	GameState.reset_new_game()
	_clear_captured_signals()
	var route_host := Node.new()
	route_host.name = "ProgressionRouteHost"
	get_tree().root.add_child(route_host)
	var map_container := Node.new()
	map_container.name = "MapContainer"
	route_host.add_child(map_container)
	var player := Node2D.new()
	player.name = "Player"
	route_host.add_child(player)
	var fade_rect := ColorRect.new()
	fade_rect.name = "FadeRect"
	route_host.add_child(fade_rect)
	SceneRouter.configure(map_container, player, fade_rect)

	CampaignDirector.complete_chapter(10, GameIds.MAP_CHAPTER_10)
	await get_tree().create_timer(0.8).timeout
	var active_map: Node = SceneRouter.get_active_map()
	_expect(GameState.current_map == GameIds.MAP_TRUE_ENDING, "SceneRouter applies the true_ending map ID")
	_expect(active_map != null, "SceneRouter instantiates the true ending scene")
	if active_map != null:
		_expect(active_map.scene_file_path == TRUE_ENDING_SCENE_PATH, "SceneRouter loads the canonical true ending scene")


func _record_all_moral_choices() -> Dictionary:
	var expected_choices: Dictionary = {}
	for resource_path: String in CHAPTER_RESOURCES:
		var chapter: Resource = load(resource_path)
		_expect(chapter != null, "chapter resource loads for moral progression: %s" % resource_path)
		if chapter == null:
			continue
		var choice_id: StringName = StringName(chapter.get(&"moral_choice_id"))
		var selected_option: StringName = StringName(chapter.get(&"moral_option_a_flag"))
		_expect(GameState.record_choice(choice_id, selected_option), "record_choice accepts %s" % String(choice_id))
		expected_choices[choice_id] = selected_option
	_expect(expected_choices.size() == 9, "record_choice stores one moral choice per campaign chapter")
	return expected_choices


func _complete_all_chapters_in_game_state() -> void:
	for chapter_number: int in range(2, 11):
		var map_id: StringName = CampaignDirector.get_chapter_map(chapter_number)
		_expect(GameState.complete_chapter(chapter_number, map_id), "GameState completes Chapter %d" % chapter_number)
	_expect(GameState.current_chapter == 10, "GameState clamps campaign progression at Chapter 10")


func _read_test_save() -> Dictionary:
	var file := FileAccess.open(TEST_SAVE_PATH, FileAccess.READ)
	_expect(file != null, "persisted save file can be opened")
	if file == null:
		return {}
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	file.close()
	_expect(parsed is Dictionary, "persisted save file contains valid JSON data")
	return parsed as Dictionary if parsed is Dictionary else {}


func _cleanup_test_save() -> void:
	if FileAccess.file_exists(TEST_SAVE_PATH):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(TEST_SAVE_PATH))


func _clear_captured_signals() -> void:
	_map_requests.clear()
	_chapter_completions.clear()
	_campaign_completion_count = 0


func _last_requested_map() -> StringName:
	if _map_requests.is_empty():
		return &""
	return StringName(_map_requests.back().get("map_id", &""))


func _on_map_change_requested(map_id: StringName, spawn_id: StringName) -> void:
	_map_requests.append({"map_id": map_id, "spawn_id": spawn_id})


func _on_chapter_completed(chapter_number: int, map_id: StringName) -> void:
	_chapter_completions.append({"chapter_number": chapter_number, "map_id": map_id})


func _on_campaign_completed() -> void:
	_campaign_completion_count += 1


func _expect(condition: bool, message: String) -> void:
	_checks_run += 1
	if condition:
		print("[CAMPAIGN PROGRESSION][PASS] %s" % message)
		return
	_failures.append(message)
	push_error("[CAMPAIGN PROGRESSION][FAIL] %s" % message)


func _finish() -> void:
	if _failures.is_empty():
		print("[CAMPAIGN PROGRESSION][PASS] %d checks completed." % _checks_run)
		get_tree().quit(0)
		return
	print("[CAMPAIGN PROGRESSION][SUMMARY] %d of %d checks failed." % [_failures.size(), _checks_run])
	for failure: String in _failures:
		print("  - %s" % failure)
	get_tree().quit(1)
