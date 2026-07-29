class_name EnemyBase
extends CharacterBody2D

signal telegraph_started(enemy: EnemyBase, duration: float)
signal attack_resolved
signal died(enemy_id: StringName, position: Vector2)
signal state_changed(previous_state: EnemyState, next_state: EnemyState)

enum EnemyState {
	IDLE,
	CHASE,
	TELEGRAPH,
	ATTACK,
	STAGGER,
	DEAD,
}

const PLAYER_GROUP: StringName = &"player"
const RECEIVE_DAMAGE_METHOD: StringName = &"receive_damage"
const DEFAULT_PICKUP_SCENE: PackedScene = preload("res://scenes/items/loot_item_pickup.tscn")

@export var data: EnemyData
@export_range(1, 35, 1) var combat_level: int = 1
@export var target_path: NodePath
@export var elite_roll_enabled: bool = true
@export_range(0.0, 1.0, 0.01) var elite_chance: float = 0.15
@export var force_elite: bool = false
@export var pickup_scene: PackedScene = DEFAULT_PICKUP_SCENE

@onready var visual: EnemyVisual = get_node_or_null(^"Visual") as EnemyVisual

var current_state: EnemyState = EnemyState.IDLE
var current_health: float = 1.0
var max_health: float = 1.0
var attack_power: float = 0.0
var defense: float = 0.0
var resistance: float = 0.0
var is_elite: bool = false

var _target: Node2D
var _state_time_remaining: float = 0.0
var _attack_applied: bool = false


func _ready() -> void:
	if data == null:
		push_error("EnemyBase requires an EnemyData resource.")
		set_physics_process(false)
		return
	combat_level = maxi(combat_level, data.base_level)
	_apply_scaled_stats()
	_roll_elite_variant()
	_acquire_target()


func _physics_process(delta: float) -> void:
	if data == null or current_state == EnemyState.DEAD:
		return
	if not is_instance_valid(_target):
		_acquire_target()
	match current_state:
		EnemyState.IDLE:
			_update_idle()
		EnemyState.CHASE:
			_update_chase()
		EnemyState.TELEGRAPH:
			_update_telegraph(delta)
		EnemyState.ATTACK:
			_update_attack(delta)
		EnemyState.STAGGER:
			_update_stagger(delta)


func receive_damage(packet: DamagePacket) -> DamageResult:
	if current_state == EnemyState.DEAD or packet == null:
		return DamageResult.new(0.0, 0.0, current_health, false, current_state == EnemyState.DEAD)
	var mitigation: float = _mitigation_for(packet.damage_type)
	var applied_damage: float = packet.amount
	if not packet.ignore_defense and packet.damage_type != &"true":
		applied_damage = packet.amount * (100.0 / (100.0 + maxf(mitigation, 0.0)))
	applied_damage = minf(maxf(applied_damage, 0.0), current_health)
	current_health = maxf(current_health - applied_damage, 0.0)
	var killed: bool = is_zero_approx(current_health)
	var staggered: bool = false
	if killed:
		_enter_dead()
	elif packet.stagger_power >= data.stagger_threshold:
		staggered = true
		_change_state(EnemyState.STAGGER, data.stagger_duration)
	var result: DamageResult = DamageResult.new(packet.amount, applied_damage, current_health, false, killed)
	result.was_staggered = staggered
	return result


func set_target(target: Node2D) -> void:
	_target = target


func _apply_scaled_stats() -> void:
	max_health = data.scaled_health(combat_level)
	attack_power = data.scaled_attack(combat_level)
	defense = data.scaled_defense(combat_level)
	resistance = data.scaled_resistance(combat_level)
	current_health = max_health


func _roll_elite_variant() -> void:
	is_elite = force_elite or (elite_roll_enabled and randf() <= elite_chance)
	if not is_elite:
		return
	max_health *= 1.8
	current_health = max_health
	attack_power *= 1.3
	if visual != null:
		visual.scale *= 1.25
		visual.set_elite_aura(true)


func _acquire_target() -> void:
	if not target_path.is_empty():
		_target = get_node_or_null(target_path) as Node2D
		if is_instance_valid(_target):
			return
	var players: Array[Node] = get_tree().get_nodes_in_group(PLAYER_GROUP)
	for player: Node in players:
		if player is Node2D:
			_target = player as Node2D
			return
	var player_fallback: Node = get_tree().root.find_child("Player", true, false)
	if player_fallback is Node2D and player_fallback.has_method(RECEIVE_DAMAGE_METHOD):
		_target = player_fallback as Node2D


func _update_idle() -> void:
	velocity = Vector2.ZERO
	move_and_slide()
	if _target_in_range(data.detection_radius):
		_change_state(EnemyState.CHASE)


func _update_chase() -> void:
	if not is_instance_valid(_target):
		_change_state(EnemyState.IDLE)
		return
	var distance_to_target: float = global_position.distance_to(_target.global_position)
	if distance_to_target > data.detection_radius * 1.25:
		_change_state(EnemyState.IDLE)
		return
	if distance_to_target <= data.attack_range:
		_change_state(EnemyState.TELEGRAPH, data.telegraph_duration)
		telegraph_started.emit(self, data.telegraph_duration)
		return
	velocity = global_position.direction_to(_target.global_position) * data.movement_speed
	move_and_slide()


func _update_telegraph(delta: float) -> void:
	velocity = Vector2.ZERO
	move_and_slide()
	_state_time_remaining = maxf(_state_time_remaining - delta, 0.0)
	if visual != null:
		var progress: float = 1.0 - (_state_time_remaining / maxf(data.telegraph_duration, 0.001))
		visual.set_telegraph_progress(progress)
	if is_zero_approx(_state_time_remaining):
		_change_state(EnemyState.ATTACK, data.attack_recovery)


func _update_attack(delta: float) -> void:
	velocity = Vector2.ZERO
	move_and_slide()
	if not _attack_applied:
		_attack_applied = true
		_resolve_attack()
	_state_time_remaining = maxf(_state_time_remaining - delta, 0.0)
	if is_zero_approx(_state_time_remaining):
		_change_state(EnemyState.CHASE if is_instance_valid(_target) else EnemyState.IDLE)


func _update_stagger(delta: float) -> void:
	velocity = Vector2.ZERO
	move_and_slide()
	_state_time_remaining = maxf(_state_time_remaining - delta, 0.0)
	if is_zero_approx(_state_time_remaining):
		_change_state(EnemyState.CHASE if is_instance_valid(_target) else EnemyState.IDLE)


func _resolve_attack() -> void:
	if _target_in_range(data.attack_range * 1.15) and _target.has_method(RECEIVE_DAMAGE_METHOD):
		var packet: DamagePacket = DamagePacket.new(
			attack_power,
			DamagePacket.DamageType.PHYSICAL,
			self,
			global_position.direction_to(_target.global_position),
			data.stagger_threshold * 0.5
		)
		_target.call(RECEIVE_DAMAGE_METHOD, packet)
	attack_resolved.emit()


func _mitigation_for(damage_type: StringName) -> float:
	match damage_type:
		&"physical":
			return defense
		&"magic", &"void", &"holy":
			return resistance
		_:
			return 0.0


func _target_in_range(radius: float) -> bool:
	return is_instance_valid(_target) and global_position.distance_squared_to(_target.global_position) <= radius * radius


func _change_state(next_state: EnemyState, duration: float = 0.0) -> void:
	if current_state == next_state:
		return
	var previous_state: EnemyState = current_state
	current_state = next_state
	_state_time_remaining = maxf(duration, 0.0)
	_attack_applied = false
	if visual != null and next_state != EnemyState.TELEGRAPH:
		visual.set_telegraph_progress(0.0)
	state_changed.emit(previous_state, next_state)


func _enter_dead() -> void:
	if current_state == EnemyState.DEAD:
		return
	_change_state(EnemyState.DEAD)
	velocity = Vector2.ZERO
	set_physics_process(false)
	for child: Node in get_children():
		if child is CollisionShape2D:
			(child as CollisionShape2D).set_deferred(&"disabled", true)
	died.emit(data.enemy_id, global_position)
	_spawn_loot()
	if visual != null:
		var tween: Tween = create_tween()
		tween.tween_property(visual, ^"modulate:a", 0.0, 0.2)
		tween.tween_callback(queue_free)
	else:
		queue_free()


func _spawn_loot() -> void:
	if data.loot_table == null or pickup_scene == null:
		return
	var drops: Array[LootDrop] = data.loot_table.roll_drops()
	var spawn_parent: Node = get_tree().current_scene
	if spawn_parent == null:
		spawn_parent = get_parent()
	if spawn_parent == null:
		return
	for drop: LootDrop in drops:
		var pickup: LootItemPickup = pickup_scene.instantiate() as LootItemPickup
		if pickup == null:
			continue
		spawn_parent.add_child(pickup)
		pickup.global_position = global_position + Vector2(randf_range(-14.0, 14.0), randf_range(-14.0, 14.0))
		pickup.configure(drop.item_id, drop.display_name, drop.amount, drop.rarity)
