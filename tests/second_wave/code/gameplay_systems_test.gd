extends Node

var _failures: PackedStringArray = []
var _checks: int = 0
var _loot_event_count: int = 0
var _dialogue_event_count: int = 0


func _ready() -> void:
	GameState.reset_new_game()
	GameEvents.loot_picked_up.connect(_on_loot_picked_up)
	GameEvents.npc_dialogue_requested.connect(_on_npc_dialogue_requested)
	_check_inventory_and_equipment()
	_check_loot_pickup()
	_check_side_quests()
	_check_dialogue_bridge()
	_check_ui_controllers()
	_finish.call_deferred()


func _check_inventory_and_equipment() -> void:
	_expect(InventoryService.add_item(&"iron_sword", 2), "inventory adds valid item")
	_expect(InventoryService.get_quantity(&"iron_sword") == 2, "inventory quantity is tracked")
	_expect(InventoryService.remove_item(&"iron_sword", 1), "inventory removes available item")
	_expect(not InventoryService.remove_item(&"iron_sword", 2), "inventory rejects over-removal")
	_expect(InventoryService.equip_item(&"weapon", &"iron_sword"), "owned item equips")
	_expect(InventoryService.get_equipped_item(&"weapon") == &"iron_sword", "equipment slot persists item")
	_expect(not InventoryService.equip_item(&"helmet", &"iron_sword"), "invalid equipment slot is rejected")
	_expect(not InventoryService.equip_item(&"armor", &"missing_armor"), "unowned item cannot equip")


func _check_loot_pickup() -> void:
	var pickup := LootPickup.new()
	pickup.configure(&"small_health_potion", 3)
	add_child(pickup)
	_expect(pickup.collect(), "loot pickup collects once")
	_expect(GameState.get_item_quantity(&"small_health_potion") == 3, "loot enters inventory")
	_expect(_loot_event_count == 1, "loot emits global pickup event")


func _check_side_quests() -> void:
	_expect(QuestService.get_registered_quest_count() == 20, "quest service registers 20 side quests")
	var definition: SideQuestDefinition = QuestService.get_quest_definition(&"sword_without_name")
	_expect(definition != null and definition.is_valid_definition(), "side quest definition is valid")
	if definition == null:
		return
	_expect(QuestService.start_quest(definition.quest_id), "side quest starts")
	_expect(not QuestService.start_quest(definition.quest_id), "active quest cannot start twice")
	for objective: SideQuestObjective in definition.objectives:
		_expect(QuestService.advance_objective(definition.quest_id, objective.objective_id, objective.required_count), "objective advances: %s" % objective.objective_id)
	_expect(GameState.completed_side_quests.has(definition.quest_id), "finished quest enters completed catalog")
	_expect(not GameState.active_quests.has(definition.quest_id), "finished quest leaves active catalog")
	_expect(GameState.get_item_quantity(&"nameless_blade_fragment") == 1, "quest item reward is granted")
	_expect(GameState.get_currency(GameIds.CURRENCY_GOLD) > 50, "quest gold reward is granted")


func _check_dialogue_bridge() -> void:
	var npc := NpcController.new()
	npc.data = load("res://resources/npcs/mira_apothecary.tres") as NpcData
	npc.schedule_service = CityScheduleService
	add_child(npc)
	var bridge := NpcDialogueBridge.new()
	add_child(bridge)
	_expect(bridge.bind_npc(npc), "dialogue bridge binds NPC controller")
	var payload: Dictionary = bridge.request_dialogue(npc)
	_expect(payload.get(&"npc_id") == &"mira_apothecary", "dialogue payload exposes NPC ID")
	_expect(payload.get(&"quest_id") == &"three_poison_roots", "dialogue payload exposes side quest")
	_expect(_dialogue_event_count == 1, "dialogue bridge emits global typed event")
	npc.queue_free()
	bridge.queue_free()


func _check_ui_controllers() -> void:
	var inventory_controller := InventoryGameplayController.new()
	add_child(inventory_controller)
	inventory_controller.set_open(true)
	_expect(inventory_controller.get_snapshot()[&"items"].has(&"iron_sword"), "inventory UI exposes item snapshot")
	var journal_controller := QuestJournalGameplayController.new()
	add_child(journal_controller)
	journal_controller.set_open(true)
	_expect(journal_controller.get_snapshot()[&"completed"].has(&"sword_without_name"), "journal exposes completed quest")
	var map_controller := GameplayMapController.new()
	add_child(map_controller)
	_expect(map_controller.discover_marker(&"market_square", {&"label": "Quảng trường"}), "map discovers marker")
	_expect(not map_controller.discover_marker(&"market_square"), "map marker discovery is idempotent")
	_expect(map_controller.get_markers().has(&"market_square"), "map UI exposes discovered markers")
	var hud_controller := GameplayHudController.new()
	add_child(hud_controller)
	var hud_snapshot: Dictionary = hud_controller.request_refresh()
	_expect(int(hud_snapshot[&"level"]) == GameState.level, "HUD exposes player level")
	_expect(int(hud_snapshot[&"gold"]) == GameState.get_currency(GameIds.CURRENCY_GOLD), "HUD exposes gold")
	inventory_controller.queue_free()
	journal_controller.queue_free()
	map_controller.queue_free()
	hud_controller.queue_free()


func _on_loot_picked_up(_item_id: StringName, _quantity: int) -> void:
	_loot_event_count += 1


func _on_npc_dialogue_requested(_npc_id: StringName, _dialogue_id: StringName, _quest_id: StringName) -> void:
	_dialogue_event_count += 1


func _expect(condition: bool, message: String) -> void:
	_checks += 1
	if not condition:
		_failures.append(message)
		push_error("[SECOND WAVE SYSTEMS][FAIL] %s" % message)


func _finish() -> void:
	if _failures.is_empty():
		print("[SECOND WAVE SYSTEMS][PASS] %d checks." % _checks)
		get_tree().quit(0)
		return
	print("[SECOND WAVE SYSTEMS][SUMMARY] %d/%d failed." % [_failures.size(), _checks])
	get_tree().quit(1)
