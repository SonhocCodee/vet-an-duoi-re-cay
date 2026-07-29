extends Node

const NPC_IDS: PackedStringArray = [
	"alden_blacksmith", "mira_apothecary", "father_oren", "lysa_baker", "tomas_guard",
	"neris_cartographer", "gareth_stablemaster", "maela_weaver", "borin_mason", "ivy_orphan",
	"cedric_archivist", "helena_innkeeper", "oswin_fisher", "rosalind_midwife", "silas_gravedigger",
	"yvette_jeweler", "damian_scribe", "freya_hunter", "rowan_watch_captain", "elric_beggar_prophet",
]

var checks := 0
var failures: Array[String] = []


func _ready() -> void:
	await _run()
	if failures.is_empty():
		print("[SECOND_WAVE_INTEGRATION] PASS %d/%d" % [checks, checks])
		get_tree().quit(0)
	else:
		for failure: String in failures:
			push_error("[SECOND_WAVE_INTEGRATION] " + failure)
		print("[SECOND_WAVE_INTEGRATION] FAIL %d issue(s), %d checks" % [failures.size(), checks])
		get_tree().quit(1)


func _run() -> void:
	GameState.reset_new_game()
	await _test_player_animation()
	await _test_city_and_npcs()
	await _test_ui_loot_quest_save()
	_test_main_scene_contract()
	preload("res://scripts/visuals/second_wave/second_wave_texture_loader.gd").clear_cache()


func _test_player_animation() -> void:
	var packed := load("res://scenes/actors/player/player.tscn") as PackedScene
	_check(packed != null, "player scene loads")
	var player := packed.instantiate()
	add_child(player)
	await get_tree().process_frame
	var animated := player.get_node_or_null(^"AnimatedSprite2D") as AnimatedSprite2D
	_check(animated != null, "player has AnimatedSprite2D")
	_check(animated != null and animated.visible, "player animated art is visible")
	for animation_name: StringName in [&"idle_down", &"idle_up", &"idle_side", &"walk_down", &"walk_up", &"walk_side", &"interact", &"hurt"]:
		_check(animated.sprite_frames.has_animation(animation_name), "player animation %s exists" % animation_name)
		_check(animated.sprite_frames.get_frame_count(animation_name) >= 1, "player animation %s has frames" % animation_name)
	player.queue_free()
	await get_tree().process_frame


func _test_city_and_npcs() -> void:
	var packed := load("res://scenes/maps/map3_ashen_town_hub.tscn") as PackedScene
	_check(packed != null, "Map 3 city scene loads")
	var map := packed.instantiate()
	add_child(map)
	await get_tree().process_frame
	await get_tree().physics_frame
	await get_tree().process_frame
	await get_tree().physics_frame
	await get_tree().process_frame
	var city := map.get_node_or_null(^"SecondWaveCity")
	_check(city != null, "second-wave city is integrated into Map 3")
	_check(city.get_node(^"Background").texture != null, "city background texture loads")
	_check(city.get_node(^"Buildings").get_child_count() == 20, "20 medieval buildings instantiate")
	_check(city.get_node(^"Props").get_child_count() == 20, "20 city props instantiate")
	_check(city.get_node(^"NavigationTargets").get_child_count() == 47, "47 schedule navigation targets register")
	_check(city.get_node(^"NavigationRegion2D").navigation_polygon != null, "city navigation polygon exists")
	var npcs := city.get_node(^"NPCs").get_children()
	_check(npcs.size() == 20, "20 NPCs instantiate")
	var unique_ids: Dictionary = {}
	for npc: Node in npcs:
		var npc_id := StringName(npc.get_meta(&"npc_id", &""))
		unique_ids[npc_id] = true
		_check(NPC_IDS.has(String(npc_id)), "NPC %s has canonical ID" % npc_id)
		_check(npc.get("data") != null, "NPC %s has NpcData" % npc_id)
		_check(StringName(npc.get("current_target_id")) != &"", "NPC %s resolves schedule target" % npc_id)
		var animated := npc.get_node_or_null(^"AnimatedSprite2D") as AnimatedSprite2D
		_check(animated != null and animated.visible, "NPC %s animated art is visible" % npc_id)
		_check(animated != null and animated.sprite_frames.get_frame_count(&"walk_down") == 2, "NPC %s has two-frame walk" % npc_id)
		_check(npc.get_node_or_null(^"BodyCollision") != null, "NPC %s has wall collision" % npc_id)
		var nameplate := npc.get_node_or_null(^"Nameplate") as Label
		_check(nameplate != null and not nameplate.visible, "NPC %s nameplate stays hidden without a nearby player" % npc_id)
	_check(unique_ids.size() == 20, "all NPC IDs are distinct")
	for target: Node in city.get_node(^"NavigationTargets").get_children():
		_check(CityScheduleService.get_target_position(StringName(target.name)) is Vector2, "target %s registered in schedule service" % target.name)
	_check(map.get_node(^"Stations/Campfire") != null, "legacy campfire preserved")
	_check(map.get_node(^"Stations/Forge") != null, "legacy forge preserved")
	_check(map.get_node(^"Stations/Shop") != null, "legacy shop preserved")
	_check(map.get_node(^"Stations/QuestBoard") != null, "legacy quest board preserved")
	map.queue_free()
	await get_tree().process_frame


func _test_ui_loot_quest_save() -> void:
	var ui_packed := load("res://scenes/ui/gameplay/gameplay_suite.tscn") as PackedScene
	_check(ui_packed != null, "gameplay UI suite loads")
	var ui := ui_packed.instantiate()
	add_child(ui)
	await get_tree().process_frame
	GameEvents.hud_refresh_requested.emit({&"health": 42.0, &"max_health": 100.0, &"stamina": 27.0, &"max_stamina": 80.0, &"level": 4, &"experience": 50, &"required_experience": 200})
	_check(is_equal_approx(ui.get_node(^"HUD/Margin/Bars/HealthBar").value, 42.0), "HUD health updates")
	_check(is_equal_approx(ui.get_node(^"HUD/Margin/Bars/StaminaBar").value, 27.0), "HUD stamina updates")
	_check(is_equal_approx(ui.get_node(^"HUD/Margin/Bars/XPBar").value, 50.0), "HUD XP updates")
	GameEvents.inventory_toggled.emit(true)
	_check(ui.get_node(^"InventoryPanel").visible, "inventory/equipment panel opens")
	GameEvents.quest_journal_toggled.emit(true)
	_check(ui.get_node(^"QuestPanel").visible, "quest journal opens")
	GameEvents.map_toggled.emit(true)
	_check(ui.get_node(^"MapPanel").visible, "local/world map opens")
	GameEvents.npc_dialogue_requested.emit(&"alden_blacksmith", &"dialogue_alden_blacksmith", &"sword_without_name")
	_check(ui.get_node(^"DialoguePanel").visible, "NPC dialogue panel opens")
	var before := InventoryService.get_quantity(&"small_health_potion")
	var loot_packed := load("res://scenes/city/loot_pickup.tscn") as PackedScene
	var loot := loot_packed.instantiate()
	loot.item_id = &"small_health_potion"
	loot.quantity = 2
	add_child(loot)
	await get_tree().process_frame
	_check(loot.collect(), "loot pickup collects")
	_check(InventoryService.get_quantity(&"small_health_potion") == before + 2, "loot enters inventory")
	_check(ui.get_node(^"LootPrompt").visible, "loot prompt appears")
	_check(QuestService.start_quest(&"sword_without_name"), "side quest starts")
	_check(GameState.active_quests.has(&"sword_without_name"), "active quest stored")
	_check(QuestService.complete_quest(&"sword_without_name"), "side quest completes")
	_check(GameState.completed_side_quests.has(&"sword_without_name"), "completed quest stored")
	GameState.set_game_time(13.5)
	GameState.set_npc_state(&"alden_blacksmith", {&"target_id": &"blacksmith_forge"})
	GameState.discover_map_marker(&"city_forge", {&"position": [335.0, 300.0]})
	var save_data := GameState.to_save_data()
	_check(int(save_data.get("version", 0)) == 3, "save version is 3")
	_check(save_data.has("game_time") and save_data.has("npc_states"), "save includes city schedule state")
	_check(save_data.has("active_quests") and save_data.has("completed_side_quests"), "save includes side quests")
	_check(save_data.has("discovered_map_markers"), "save includes map markers")
	_check(GameState.load_save_data(save_data), "save v3 reloads")
	ui.queue_free()
	await get_tree().process_frame


func _test_main_scene_contract() -> void:
	var packed := load("res://scenes/bootstrap/main.tscn") as PackedScene
	_check(packed != null, "main scene loads")
	var main := packed.instantiate()
	_check(main.get_node_or_null(^"Interface/HudSocket/SecondWaveGameplaySuite") != null, "main contains second-wave UI")
	main.free()


func _check(condition: bool, message: String) -> void:
	checks += 1
	if not condition:
		failures.append(message)
