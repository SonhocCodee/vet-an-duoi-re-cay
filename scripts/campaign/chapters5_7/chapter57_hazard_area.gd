class_name Chapter57HazardArea
extends Area2D

signal hazard_tick(hazard_id: StringName, target: Node2D, applied_damage: float)

@export var hazard_id: StringName = &"campaign_hazard"
@export_range(0.1, 100.0, 0.1) var damage_per_tick: float = 7.0
@export_range(0.1, 5.0, 0.05) var tick_interval: float = 0.8
@export_range(1.0, 100.0, 1.0) var minimum_survivable_health: float = 1.0
@export var damage_type: StringName = &"true"
@export var visual_size: Vector2 = Vector2(180.0, 90.0)
@export var visual_color: Color = Color(0.85, 0.25, 0.12, 0.42)

var _tracked_targets: Dictionary = {}
var _pulse_time: float = 0.0


func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	queue_redraw()


func _physics_process(delta: float) -> void:
	_pulse_time += delta
	queue_redraw()
	for target_id: int in _tracked_targets.keys():
		var target_data: Dictionary = _tracked_targets[target_id] as Dictionary
		var target: Node2D = target_data.get(&"target") as Node2D
		if not is_instance_valid(target):
			_tracked_targets.erase(target_id)
			continue
		var time_remaining: float = float(target_data.get(&"time_remaining", tick_interval)) - delta
		if time_remaining <= 0.0:
			_apply_hazard_tick(target)
			time_remaining += tick_interval
		target_data[&"time_remaining"] = time_remaining
		_tracked_targets[target_id] = target_data


func _draw() -> void:
	var pulse_alpha: float = 0.75 + sin(_pulse_time * 3.0) * 0.18
	var color: Color = visual_color
	color.a *= pulse_alpha
	draw_rect(Rect2(-visual_size * 0.5, visual_size), color, true)
	draw_rect(Rect2(-visual_size * 0.5, visual_size), color.lightened(0.3), false, 3.0)


func _on_body_entered(body: Node2D) -> void:
	if not _is_player(body):
		return
	_tracked_targets[body.get_instance_id()] = {
		&"target": body,
		&"time_remaining": 0.0,
	}


func _on_body_exited(body: Node2D) -> void:
	_tracked_targets.erase(body.get_instance_id())


func _apply_hazard_tick(target: Node2D) -> void:
	if not target.has_method(&"get_health") or not target.has_method(&"receive_damage"):
		return
	var current_health: float = float(target.call(&"get_health"))
	var safe_damage: float = minf(damage_per_tick, maxf(current_health - minimum_survivable_health, 0.0))
	if safe_damage <= 0.0:
		return
	var packet: DamagePacket = DamagePacket.new(self, safe_damage, damage_type)
	packet.ignore_defense = true
	packet.ignores_defense = true
	target.call(&"receive_damage", packet)
	hazard_tick.emit(hazard_id, target, safe_damage)


func _is_player(body: Node) -> bool:
	return body.is_in_group(&"player") or body.name == &"Player" or body.name == &"PlayerController"
