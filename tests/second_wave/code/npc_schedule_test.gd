extends Node

const NPC_IDS: Array[StringName] = [
	&"alden_blacksmith", &"mira_apothecary", &"father_oren", &"lysa_baker",
	&"tomas_guard", &"neris_cartographer", &"gareth_stablemaster", &"maela_weaver",
	&"borin_mason", &"ivy_orphan", &"cedric_archivist", &"helena_innkeeper",
	&"oswin_fisher", &"rosalind_midwife", &"silas_gravedigger", &"yvette_jeweler",
	&"damian_scribe", &"freya_hunter", &"rowan_watch_captain", &"elric_beggar_prophet",
]

var _failures: PackedStringArray = []
var _checks: int = 0


func _ready() -> void:
	CityScheduleService.paused = true
	_check_resources()
	_check_schedule_service()
	await _check_controller_movement()
	_finish()


func _check_resources() -> void:
	var unique_ids: Dictionary = {}
	var changed_targets: int = 0
	for npc_id: StringName in NPC_IDS:
		var path: String = "res://resources/npcs/%s.tres" % npc_id
		var data: NpcData = ResourceLoader.load(path) as NpcData
		_expect(data != null, "%s loads as NpcData" % npc_id)
		if data == null:
			continue
		_expect(data.npc_id == npc_id, "%s ID matches filename" % npc_id)
		_expect(data.is_valid_definition(), "%s passes validation" % npc_id)
		var quest: SideQuestDefinition = ResourceLoader.load("res://resources/quests/side/%s.tres" % data.side_quest_id) as SideQuestDefinition
		_expect(quest != null, "%s side quest loads" % npc_id)
		_expect(quest != null and quest.is_valid_definition(), "%s side quest validates" % npc_id)
		_expect(quest != null and quest.giver_npc_id == npc_id, "%s side quest giver matches" % npc_id)
		_expect(not unique_ids.has(data.npc_id), "%s is unique" % npc_id)
		unique_ids[data.npc_id] = true
		for hour: int in range(24):
			_expect(data.resolve_target(float(hour)) != &"", "%s resolves hour %d" % [npc_id, hour])
			_expect(data.resolve_target(float(hour)) == data.resolve_target(float(hour)), "%s is deterministic at %d" % [npc_id, hour])
		if data.resolve_target(8.0) != data.resolve_target(19.0):
			changed_targets += 1
	_expect(unique_ids.size() == 20, "catalog contains exactly 20 unique NPC IDs")
	_expect(changed_targets >= 15, "most NPC targets change between work and evening")


func _check_schedule_service() -> void:
	_expect(CityScheduleService.get_registered_npc_count() == 20, "schedule service registers 20 NPCs")
	CityScheduleService.set_game_time(8.0, 1)
	_expect(CityScheduleService.resolve_target(&"alden_blacksmith", 8.0) == &"blacksmith_forge", "Alden works at forge at 08:00")
	CityScheduleService.set_game_time(19.0, 1)
	_expect(CityScheduleService.resolve_target(&"alden_blacksmith", 19.0) == &"root_inn", "Alden moves to inn at 19:00")
	CityScheduleService.real_seconds_per_game_hour = 30.0
	CityScheduleService.set_game_time(23.5, 4)
	CityScheduleService.tick_game_time(30.0)
	_expect(is_equal_approx(CityScheduleService.game_time, 0.5), "game time wraps deterministically")
	_expect(CityScheduleService.day == 5, "day increments at midnight")


func _check_controller_movement() -> void:
	var data: NpcData = load("res://resources/npcs/alden_blacksmith.tres") as NpcData
	CityScheduleService.register_target(&"blacksmith_forge", Vector2(100.0, 0.0))
	CityScheduleService.set_game_time(8.0)
	var npc := NpcController.new()
	npc.data = data
	npc.schedule_service = CityScheduleService
	npc.movement_speed = 50.0
	add_child(npc)
	npc.refresh_schedule(true)
	var previous_position: Vector2 = npc.global_position
	await get_tree().physics_frame
	await get_tree().physics_frame
	_expect(npc.current_target_id == &"blacksmith_forge", "controller receives schedule target")
	_expect(npc.global_position.x > previous_position.x, "controller autonomously moves toward target")
	CityScheduleService.set_game_time(19.0)
	npc.refresh_schedule(true)
	_expect(npc.current_target_id == &"root_inn", "controller target changes with hour")
	npc.queue_free()


func _expect(condition: bool, message: String) -> void:
	_checks += 1
	if not condition:
		_failures.append(message)
		push_error("[SECOND WAVE NPC][FAIL] %s" % message)


func _finish() -> void:
	if _failures.is_empty():
		print("[SECOND WAVE NPC][PASS] %d checks." % _checks)
		get_tree().quit(0)
		return
	print("[SECOND WAVE NPC][SUMMARY] %d/%d failed." % [_failures.size(), _checks])
	get_tree().quit(1)
