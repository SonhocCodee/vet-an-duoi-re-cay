extends Node

signal game_time_changed(hour: float, day: int)
signal npc_target_changed(npc_id: StringName, target_id: StringName)

const NPC_IDS: Array[StringName] = [
	&"alden_blacksmith", &"mira_apothecary", &"father_oren", &"lysa_baker",
	&"tomas_guard", &"neris_cartographer", &"gareth_stablemaster", &"maela_weaver",
	&"borin_mason", &"ivy_orphan", &"cedric_archivist", &"helena_innkeeper",
	&"oswin_fisher", &"rosalind_midwife", &"silas_gravedigger", &"yvette_jeweler",
	&"damian_scribe", &"freya_hunter", &"rowan_watch_captain", &"elric_beggar_prophet",
]
const NPC_RESOURCE_ROOT: String = "res://resources/npcs/"

@export_range(1.0, 600.0, 1.0) var real_seconds_per_game_hour: float = 30.0
@export var paused: bool = false

var game_time: float = 8.0
var day: int = 1
var _npc_data_by_id: Dictionary = {}
var _last_target_by_npc: Dictionary = {}
var _target_positions: Dictionary = {}


func _ready() -> void:
	var game_state: Node = get_node_or_null(^"/root/GameState")
	if game_state != null:
		game_time = float(game_state.get("game_time"))
	load_default_catalog()


func _process(delta: float) -> void:
	if not paused:
		tick_game_time(delta)


func load_default_catalog() -> int:
	var loaded_count: int = 0
	for npc_id: StringName in NPC_IDS:
		var data: NpcData = ResourceLoader.load(NPC_RESOURCE_ROOT + String(npc_id) + ".tres") as NpcData
		if data != null:
			register_npc(data)
			loaded_count += 1
	return loaded_count


func register_npc(npc_data: NpcData) -> bool:
	if npc_data == null or not npc_data.is_valid_definition():
		return false
	_npc_data_by_id[npc_data.npc_id] = npc_data
	_update_npc_target(npc_data.npc_id)
	return true


func resolve_target(npc_id: StringName, hour: float = -1.0) -> StringName:
	var npc_data: NpcData = _npc_data_by_id.get(npc_id) as NpcData
	if npc_data == null:
		return &""
	return npc_data.resolve_target(game_time if hour < 0.0 else hour)


func register_target(target_id: StringName, target: Variant) -> bool:
	if target_id == &"":
		return false
	if target is Node2D:
		_target_positions[target_id] = target
		return true
	if target is Vector2:
		_target_positions[target_id] = target
		return true
	return false


func unregister_target(target_id: StringName) -> void:
	_target_positions.erase(target_id)


func get_target_position(target_id: StringName) -> Variant:
	var target: Variant = _target_positions.get(target_id)
	if target is Node2D:
		if is_instance_valid(target):
			return (target as Node2D).global_position
		_target_positions.erase(target_id)
		return null
	if target is Vector2:
		return target
	return null


func tick_game_time(delta: float) -> void:
	if delta <= 0.0 or real_seconds_per_game_hour <= 0.0:
		return
	var previous_day: int = day
	game_time += delta / real_seconds_per_game_hour
	while game_time >= 24.0:
		game_time -= 24.0
		day += 1
	_set_game_state_time()
	game_time_changed.emit(game_time, day)
	_update_all_targets()
	if previous_day != day:
		_last_target_by_npc.clear()
		_update_all_targets()


func set_game_time(hour: float, current_day: int = -1) -> void:
	game_time = fposmod(hour, 24.0)
	if current_day > 0:
		day = current_day
	_set_game_state_time()
	game_time_changed.emit(game_time, day)
	_update_all_targets()


func get_registered_npc_count() -> int:
	return _npc_data_by_id.size()


func _update_all_targets() -> void:
	for npc_id: Variant in _npc_data_by_id:
		_update_npc_target(StringName(npc_id))


func _update_npc_target(npc_id: StringName) -> void:
	var target_id: StringName = resolve_target(npc_id, game_time)
	if StringName(_last_target_by_npc.get(npc_id, &"")) == target_id:
		return
	_last_target_by_npc[npc_id] = target_id
	npc_target_changed.emit(npc_id, target_id)
	var game_state: Node = get_node_or_null(^"/root/GameState")
	if game_state != null and game_state.has_method(&"set_npc_state"):
		var previous_state: Dictionary = game_state.call(&"get_npc_state", npc_id)
		previous_state[&"target_id"] = target_id
		game_state.call(&"set_npc_state", npc_id, previous_state)


func _set_game_state_time() -> void:
	var game_state: Node = get_node_or_null(^"/root/GameState")
	if game_state != null and game_state.has_method(&"set_game_time"):
		game_state.call(&"set_game_time", game_time)
