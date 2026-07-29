class_name Map2TutorialRoad
extends Node2D

const Map2ProgressScript: Script = preload("res://scripts/maps/map2/map2_progress.gd")
const MIST_SHADE_SCENE: PackedScene = preload("res://scenes/actors/enemies/mist_shade.tscn")
const ROOT_WOLF_SCENE: PackedScene = preload("res://scenes/actors/enemies/root_wolf.tscn")
const MUSHROOM_SCENE: PackedScene = preload("res://scenes/actors/enemies/mushroom.tscn")
const ROOT_ANTLER_STAG_SCENE: PackedScene = preload("res://scenes/actors/enemies/root_antler_stag.tscn")
const ARIA_SCENE: PackedScene = preload("res://scenes/npcs/aria/aria_map2.tscn")
const ARIA_AFTER_STAG: Resource = preload("res://resources/story/map2/aria_after_stag.tres")
const TELEGRAPH_GRACE_MSEC: int = 180
const DEFAULT_TELEGRAPH_SECONDS: float = 0.8

const ENCOUNTER_FLAGS: Array[StringName] = [
	&"map2_combo_complete",
	&"map2_dodge_complete",
	&"map2_skill_1_complete",
	&"map2_root_antler_stag_defeated",
]
const TUTORIAL_RESOURCES: Array[Resource] = [
	preload("res://resources/tutorial/map2/combo_finisher.tres"),
	preload("res://resources/tutorial/map2/dodge_telegraph.tres"),
	preload("res://resources/tutorial/map2/skill_1.tres"),
	preload("res://resources/tutorial/map2/root_antler_stag.tres"),
]
const ENEMY_SCENES: Array[PackedScene] = [
	MIST_SHADE_SCENE,
	ROOT_WOLF_SCENE,
	MUSHROOM_SCENE,
	ROOT_ANTLER_STAG_SCENE,
]
const ENEMY_COUNTS: Array[int] = [2, 2, 1, 1]

@onready var encounter_zones: Array[Node] = [
	%EncounterZone1,
	%EncounterZone2,
	%EncounterZone3,
	%BossEncounterZone,
]
@onready var encounter_gates: Array[Node2D] = [
	%EncounterGate1,
	%EncounterGate2,
	%EncounterGate3,
]
@onready var enemy_spawn_groups: Array[Node2D] = [
	%Encounter1Spawns,
	%Encounter2Spawns,
	%Encounter3Spawns,
	%BossSpawns,
]
@onready var aria_spawn: Marker2D = %AriaSpawn
@onready var exit_gate: Map2ExitGate = %Map3ExitGate

var progress: Map2Progress
var active_enemies: Array[Node] = []
var player_controller: Node
var aria: AriaMap2Npc
var telegraph_window_ends_msec: int = 0
var awaiting_aria_dialogue: bool = false


func _ready() -> void:
	progress = Map2ProgressScript.new()
	for zone_index: int in range(encounter_zones.size()):
		var zone: Map2EncounterZone = encounter_zones[zone_index] as Map2EncounterZone
		zone.activated.connect(_on_encounter_zone_activated)
	exit_gate.exit_requested.connect(_on_exit_requested)
	_restore_progress()
	_connect_game_events()
	_connect_player_controller()
	get_tree().node_added.connect(_on_tree_node_added)


func _restore_progress() -> void:
	for encounter_index: int in range(ENCOUNTER_FLAGS.size()):
		if _get_game_state_flag(ENCOUNTER_FLAGS[encounter_index]):
			progress.restore_completed(encounter_index)
			_mark_zone_consumed(encounter_index)
			if encounter_index < encounter_gates.size():
				_set_encounter_gate_open(encounter_index, true)
	if _get_game_state_flag(&"map2_aria_dialogue_complete"):
		exit_gate.set_open(true)


func _connect_game_events() -> void:
	var game_events: Node = get_node_or_null("/root/GameEvents")
	if game_events == null:
		return
	for signal_name: StringName in [&"dialogue_finished", &"dialogue_completed"]:
		if game_events.has_signal(signal_name):
			var callback: Callable = _on_dialogue_finished
			if not game_events.is_connected(signal_name, callback):
				game_events.connect(signal_name, callback)


func _connect_player_controller(candidate: Node = null) -> void:
	if player_controller != null and is_instance_valid(player_controller):
		return
	var controller: Node = candidate
	if controller == null:
		controller = get_tree().get_first_node_in_group(&"player")
	if controller == null:
		controller = get_node_or_null("/root/PlayerController")
	if controller == null or not controller.has_signal(&"action_committed"):
		return
	player_controller = controller
	var callback: Callable = _on_player_action_committed
	if not player_controller.is_connected(&"action_committed", callback):
		player_controller.connect(&"action_committed", callback)


func _on_tree_node_added(node: Node) -> void:
	if player_controller == null and (node.is_in_group(&"player") or node.name == &"PlayerController"):
		call_deferred(&"_connect_player_controller", node)


func _on_encounter_zone_activated(encounter_index: int) -> void:
	if encounter_index < 0 or encounter_index >= ENEMY_COUNTS.size():
		return
	if not progress.start(encounter_index, ENEMY_COUNTS[encounter_index]):
		return
	_request_tutorial(TUTORIAL_RESOURCES[encounter_index])
	if encounter_index == 3:
		_start_boss_encounter()
	else:
		_spawn_enemy_wave(encounter_index)


func _spawn_enemy_wave(encounter_index: int) -> void:
	var spawn_group: Node2D = enemy_spawn_groups[encounter_index]
	var spawn_points: Array[Node] = spawn_group.get_children()
	for enemy_index: int in range(ENEMY_COUNTS[encounter_index]):
		var enemy: Node2D = ENEMY_SCENES[encounter_index].instantiate() as Node2D
		if enemy == null:
			push_error("Map2 enemy scene root must inherit Node2D.")
			continue
		add_child(enemy)
		enemy.global_position = (spawn_points[enemy_index] as Node2D).global_position
		_register_enemy(enemy)


func _start_boss_encounter() -> void:
	aria = ARIA_SCENE.instantiate() as AriaMap2Npc
	add_child(aria)
	aria.global_position = aria_spawn.global_position
	aria.set_encounter_active(true)
	var boss: Node2D = ROOT_ANTLER_STAG_SCENE.instantiate() as Node2D
	add_child(boss)
	boss.global_position = (%BossSpawn as Marker2D).global_position
	aria.face_target(boss)
	_register_enemy(boss)


func _register_enemy(enemy: Node) -> void:
	active_enemies.append(enemy)
	if enemy.has_signal(&"telegraph_started"):
		var telegraph_callback: Callable = func(duration: float = DEFAULT_TELEGRAPH_SECONDS) -> void:
			_on_enemy_telegraph_started(duration)
		enemy.connect(&"telegraph_started", telegraph_callback)
	if enemy.has_signal(&"died"):
		var died_callback: Callable = func(_defeated: Node = enemy) -> void:
			_on_enemy_died(enemy)
		enemy.connect(&"died", died_callback, CONNECT_ONE_SHOT)
	else:
		enemy.tree_exiting.connect(_on_enemy_died.bind(enemy), CONNECT_ONE_SHOT)


func _on_enemy_telegraph_started(duration: float = DEFAULT_TELEGRAPH_SECONDS) -> void:
	var duration_msec: int = ceili(maxf(duration, 0.0) * 1000.0)
	telegraph_window_ends_msec = Time.get_ticks_msec() + duration_msec + TELEGRAPH_GRACE_MSEC


func _on_player_action_committed(action: StringName, context: Dictionary = {}) -> void:
	if progress.active_encounter < 0:
		return
	var during_telegraph: bool = Time.get_ticks_msec() <= telegraph_window_ends_msec
	if context.has(&"during_telegraph"):
		during_telegraph = bool(context[&"during_telegraph"])
	var was_met: bool = progress.requirement_met
	var is_met: bool = progress.note_action(action, during_telegraph)
	if is_met and not was_met:
		_set_game_state_flag(_requirement_flag(progress.active_encounter), true)
	_try_complete_active_encounter()


func _on_enemy_died(enemy: Node) -> void:
	if enemy not in active_enemies:
		return
	active_enemies.erase(enemy)
	progress.note_enemy_died()
	_try_complete_active_encounter()


func _try_complete_active_encounter() -> void:
	if not progress.is_ready_to_complete():
		return
	var completed_index: int = progress.complete_active()
	_set_game_state_flag(ENCOUNTER_FLAGS[completed_index], true)
	_mark_zone_consumed(completed_index)
	if completed_index < encounter_gates.size():
		_set_encounter_gate_open(completed_index, true)
	else:
		_complete_boss_encounter()


func _complete_boss_encounter() -> void:
	if aria != null:
		aria.mark_boss_defeated()
	awaiting_aria_dialogue = true
	_set_game_state_flag(&"map2_boss_defeated", true)
	_request_dialogue(ARIA_AFTER_STAG)


func complete_aria_dialogue(dialogue_id: Variant = null) -> void:
	_on_dialogue_finished(dialogue_id)


func _on_dialogue_finished(dialogue_data: Variant = null) -> void:
	if not awaiting_aria_dialogue and not _get_game_state_flag(&"map2_boss_defeated"):
		return
	var dialogue_id: StringName = &""
	if dialogue_data is Dictionary:
		dialogue_id = StringName(str((dialogue_data as Dictionary).get(&"dialogue_id", "")))
	elif dialogue_data != null:
		dialogue_id = StringName(str(dialogue_data))
	if dialogue_id != &"" and dialogue_id != ARIA_AFTER_STAG.dialogue_id:
		return
	awaiting_aria_dialogue = false
	_set_game_state_flag(&"map2_aria_dialogue_complete", true)
	_set_game_state_flag(&"map2_complete", true)
	exit_gate.set_open(true)


func _on_exit_requested(destination_scene: String, spawn_id: StringName) -> void:
	if not _get_game_state_flag(&"map2_complete"):
		return
	var scene_router: Node = get_node_or_null("/root/SceneRouter")
	if scene_router != null:
		for method_name: StringName in [&"change_scene", &"transition_to", &"go_to_map"]:
			if scene_router.has_method(method_name):
				_call_scene_router(scene_router, method_name, destination_scene, spawn_id)
				return
	get_tree().change_scene_to_file(destination_scene)


func _call_scene_router(router: Node, method_name: StringName, scene_path: String, spawn_id: StringName) -> void:
	for method_data: Dictionary in router.get_method_list():
		if StringName(method_data.get("name", &"")) != method_name:
			continue
		var arguments: Array = method_data.get("args", []) as Array
		if arguments.size() >= 2:
			router.call(method_name, scene_path, spawn_id)
		else:
			router.call(method_name, scene_path)
		return


func _request_tutorial(step: Resource) -> void:
	var game_events: Node = get_node_or_null("/root/GameEvents")
	if game_events == null or not game_events.has_signal(&"tutorial_requested"):
		return
	game_events.emit_signal(&"tutorial_requested", {
		&"tutorial_id": step.tutorial_id,
		&"title": step.title,
		&"instruction": step.instruction,
		&"required_action": step.required_action,
		&"encounter_index": step.encounter_index,
	})


func _request_dialogue(dialogue: Resource) -> void:
	var game_events: Node = get_node_or_null("/root/GameEvents")
	if game_events == null or not game_events.has_signal(&"dialogue_requested"):
		return
	game_events.emit_signal(&"dialogue_requested", {
		&"dialogue_id": dialogue.dialogue_id,
		&"speaker_name": dialogue.speaker_name,
		&"lines": dialogue.lines,
		&"completion_flag": dialogue.completion_flag,
		&"next_scene": dialogue.next_scene,
		&"next_spawn_id": dialogue.next_spawn_id,
		&"source": self,
	})


func _set_encounter_gate_open(gate_index: int, is_open: bool) -> void:
	var gate: Node2D = encounter_gates[gate_index]
	gate.visible = not is_open
	for child: Node in gate.find_children("*", "CollisionShape2D", true, false):
		(child as CollisionShape2D).set_deferred(&"disabled", is_open)


func _mark_zone_consumed(encounter_index: int) -> void:
	(encounter_zones[encounter_index] as Map2EncounterZone).set_consumed(true)


func _requirement_flag(encounter_index: int) -> StringName:
	match encounter_index:
		0:
			return &"map2_combo_finisher_performed"
		1:
			return &"map2_telegraph_dodge_performed"
		2:
			return &"map2_skill_1_performed"
		_:
			return &"map2_boss_requirement_met"


func _get_game_state_flag(flag_name: StringName) -> bool:
	var game_state: Node = get_node_or_null("/root/GameState")
	if game_state == null:
		return false
	for method_name: StringName in [&"get_flag", &"get_story_flag", &"has_flag"]:
		if game_state.has_method(method_name):
			return bool(game_state.call(method_name, flag_name))
	return bool(game_state.get_meta(flag_name, false))


func _set_game_state_flag(flag_name: StringName, value: bool) -> void:
	var game_state: Node = get_node_or_null("/root/GameState")
	if game_state == null:
		return
	for method_name: StringName in [&"set_flag", &"set_story_flag"]:
		if game_state.has_method(method_name):
			game_state.call(method_name, flag_name, value)
			return
	game_state.set_meta(flag_name, value)
