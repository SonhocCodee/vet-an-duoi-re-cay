class_name NpcController
extends CharacterBody2D

signal target_changed(npc_id: StringName, target_id: StringName)
signal motion_state_changed(state: StringName, direction: Vector2)
signal interaction_requested(npc: NpcController, actor: Node)

@export var data: NpcData
@export_range(10.0, 400.0, 1.0) var movement_speed: float = 72.0
@export_range(1.0, 64.0, 1.0) var arrival_distance: float = 5.0
@export_range(0.1, 10.0, 0.1) var schedule_refresh_seconds: float = 1.0
@export var controls_enabled: bool = true

@onready var navigation_agent: NavigationAgent2D = get_node_or_null(^"NavigationAgent2D") as NavigationAgent2D

var schedule_service: Node
var current_target_id: StringName
var current_activity: String
var _target_position: Vector2
var _has_target_position: bool = false
var _refresh_remaining: float = 0.0
var _last_motion_state: StringName = &"idle"
var _last_direction: Vector2 = Vector2.DOWN


func _ready() -> void:
	add_to_group(&"city_npc")
	if schedule_service == null:
		schedule_service = get_node_or_null(^"/root/CityScheduleService")
	_register_with_service()
	refresh_schedule(true)


func _physics_process(delta: float) -> void:
	_refresh_remaining -= delta
	if _refresh_remaining <= 0.0:
		_refresh_remaining = schedule_refresh_seconds
		refresh_schedule()
	_update_movement(delta)


func configure(npc_data: NpcData, service: Node = null) -> void:
	data = npc_data
	if service != null:
		schedule_service = service
	_register_with_service()
	refresh_schedule(true)


func refresh_schedule(force: bool = false) -> void:
	if data == null or schedule_service == null:
		return
	var game_hour: float = float(schedule_service.get("game_time"))
	var next_target: StringName = StringName(schedule_service.call(&"resolve_target", data.npc_id, game_hour))
	var next_activity: String = data.resolve_activity(game_hour)
	if not force and next_target == current_target_id and next_activity == current_activity:
		return
	current_target_id = next_target
	current_activity = next_activity
	_refresh_target_position()
	target_changed.emit(data.npc_id, current_target_id)
	_store_state()


func set_target_position(world_position: Vector2) -> void:
	_target_position = world_position
	_has_target_position = true
	if navigation_agent != null:
		navigation_agent.target_position = world_position


func request_interaction(actor: Node) -> void:
	interaction_requested.emit(self, actor)


func get_dialogue_payload() -> Dictionary:
	if data == null:
		return {}
	return {
		&"npc_id": data.npc_id,
		&"speaker": data.display_name,
		&"profession": data.profession,
		&"dialogue_id": data.dialogue_id,
		&"quest_id": data.side_quest_id,
		&"activity": current_activity,
	}


func _register_with_service() -> void:
	if data != null and schedule_service != null and schedule_service.has_method(&"register_npc"):
		schedule_service.call(&"register_npc", data)


func _refresh_target_position() -> void:
	_has_target_position = false
	if schedule_service == null or not schedule_service.has_method(&"get_target_position"):
		return
	var resolved: Variant = schedule_service.call(&"get_target_position", current_target_id)
	if resolved is Vector2:
		set_target_position(resolved)


func _update_movement(_delta: float) -> void:
	if not controls_enabled or not _has_target_position:
		velocity = Vector2.ZERO
		_emit_motion_state(&"idle", _last_direction)
		return
	var next_position: Vector2 = _target_position
	if navigation_agent != null and not navigation_agent.is_navigation_finished():
		next_position = navigation_agent.get_next_path_position()
	var offset: Vector2 = next_position - global_position
	if global_position.distance_to(_target_position) <= arrival_distance:
		velocity = Vector2.ZERO
		_emit_motion_state(&"idle", _last_direction)
		_store_state()
		return
	var direction: Vector2 = offset.normalized()
	velocity = direction * movement_speed
	move_and_slide()
	_emit_motion_state(&"walk", direction)


func _emit_motion_state(state: StringName, direction: Vector2) -> void:
	var next_direction: Vector2 = _last_direction
	if direction.length_squared() > 0.001:
		next_direction = direction.normalized()
	if state == _last_motion_state and next_direction.is_equal_approx(_last_direction):
		return
	_last_motion_state = state
	_last_direction = next_direction
	motion_state_changed.emit(state, _last_direction)


func _store_state() -> void:
	if data == null:
		return
	var game_state: Node = get_node_or_null(^"/root/GameState")
	if game_state != null and game_state.has_method(&"set_npc_state"):
		game_state.call(&"set_npc_state", data.npc_id, {
			&"target_id": current_target_id,
			&"activity": current_activity,
			&"position": [global_position.x, global_position.y],
		})
