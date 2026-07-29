class_name SecondWaveNpcFallbackController
extends CharacterBody2D

signal npc_interacted(npc_id: StringName)
signal schedule_slot_changed(npc_id: StringName, slot_id: StringName)

@export var movement_speed := 46.0
var npc_id: StringName
var npc_data: Resource
var _navigation_agent: NavigationAgent2D
var _paused := false


func _ready() -> void:
	_navigation_agent = get_node_or_null(^"NavigationAgent2D") as NavigationAgent2D
	if _navigation_agent != null:
		_navigation_agent.path_desired_distance = 8.0
		_navigation_agent.target_desired_distance = 10.0


func _physics_process(_delta: float) -> void:
	if _paused or _navigation_agent == null or _navigation_agent.is_navigation_finished():
		velocity = velocity.move_toward(Vector2.ZERO, movement_speed)
		move_and_slide()
		return
	var next_position := _navigation_agent.get_next_path_position()
	velocity = global_position.direction_to(next_position) * movement_speed
	move_and_slide()


func configure(data: Resource) -> void:
	npc_data = data
	if data != null:
		npc_id = StringName(data.get("npc_id"))


func set_navigation_target(target_position: Vector2) -> void:
	if _navigation_agent != null:
		_navigation_agent.target_position = target_position


func pause_for_dialogue() -> void:
	_paused = true
	velocity = Vector2.ZERO


func resume_schedule() -> void:
	_paused = false


func request_interaction() -> void:
	npc_interacted.emit(npc_id)
