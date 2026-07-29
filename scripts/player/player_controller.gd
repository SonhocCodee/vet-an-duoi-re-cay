class_name PlayerController
extends CharacterBody2D

signal action_committed(action_id: StringName)
signal health_changed(current: float, maximum: float)
signal stamina_changed(current: float, maximum: float)
signal died
signal weapon_state_changed(unlocked: bool)

enum PlayerClass {
	BLADEMASTER,
	GUARDIAN,
	SPELLBLADE,
	PRIEST,
}

enum ActionState {
	FREE,
	ATTACKING,
	DODGING,
	CASTING,
	DEAD,
}

const ACTION_MOVE_UP: StringName = &"move_up"
const ACTION_MOVE_DOWN: StringName = &"move_down"
const ACTION_MOVE_LEFT: StringName = &"move_left"
const ACTION_MOVE_RIGHT: StringName = &"move_right"
const ACTION_ATTACK: StringName = &"attack"
const ACTION_COMBO_FINISHER: StringName = &"combo_finisher"
const ACTION_DODGE: StringName = &"dodge"
const ACTION_SKILL_ONE: StringName = &"skill_1"
const DAMAGE_PHYSICAL: StringName = &"physical"
const DAMAGE_MAGICAL: StringName = &"magic"
const DAMAGE_HOLY: StringName = &"holy"

const CLASS_MAX_HEALTH = [115.0, 145.0, 90.0, 105.0]
const CLASS_MAX_STAMINA = [110.0, 125.0, 100.0, 115.0]
const CLASS_ATTACK = [14.0, 11.0, 8.0, 7.0]
const CLASS_MAGIC = [10.0, 8.0, 17.0, 15.0]
const CLASS_DEFENSE = [8.0, 13.0, 4.0, 6.0]
const CLASS_RESISTANCE = [7.0, 10.0, 9.0, 13.0]

const EFFECT_SCRIPT: Script = preload("res://scripts/player/player_combat_effect.gd")

@export_enum("Blademaster", "Guardian", "Spellblade", "Priest") var player_class: int = PlayerClass.BLADEMASTER
@export var combat_config: PlayerCombatConfig
@export_flags_2d_physics var target_collision_mask: int = 6
@export var controls_enabled: bool = true

@onready var melee_hitbox: Area2D = %MeleeHitbox
@onready var melee_shape: CollisionShape2D = %MeleeShape
@onready var skill_origin: Marker2D = %SkillOrigin

var _maximum_health: float = 100.0
var _health: float = 100.0
var _maximum_stamina: float = 100.0
var _stamina: float = 100.0
var _facing_direction: Vector2 = Vector2.DOWN
var _weapon_unlocked: bool = false
var _action_state: ActionState = ActionState.FREE
var _action_elapsed: float = 0.0
var _combo_index: int = 0
var _combo_reset_remaining: float = 0.0
var _attack_buffered: bool = false
var _attack_hitbox_open: bool = false
var _skill_effect_spawned: bool = false
var _dodge_direction: Vector2 = Vector2.DOWN
var _stamina_regen_block_remaining: float = 0.0
var _melee_hit_targets: Dictionary = {}


func _ready() -> void:
	if combat_config == null:
		combat_config = PlayerCombatConfig.new()
	melee_hitbox.collision_mask = target_collision_mask
	melee_hitbox.body_entered.connect(_on_melee_body_entered)
	melee_hitbox.area_entered.connect(_on_melee_area_entered)
	_close_melee_hitbox()
	_apply_class_stats(true)
	health_changed.emit(_health, _maximum_health)
	stamina_changed.emit(_stamina, _maximum_stamina)
	weapon_state_changed.emit(_weapon_unlocked)


func _physics_process(delta: float) -> void:
	if _action_state == ActionState.DEAD:
		velocity = Vector2.ZERO
		return
	_update_timers(delta)
	if controls_enabled:
		_read_action_input()
	_update_action(delta)
	_update_movement(delta)
	move_and_slide()


func _unhandled_input(event: InputEvent) -> void:
	if not controls_enabled or _action_state == ActionState.DEAD:
		return
	if event is InputEventMouseButton:
		var mouse_event := event as InputEventMouseButton
		if not InputMap.has_action(ACTION_ATTACK) and mouse_event.button_index == MOUSE_BUTTON_LEFT and mouse_event.pressed:
			_request_attack()
	elif event is InputEventKey:
		var key_event := event as InputEventKey
		if not key_event.pressed or key_event.echo:
			return
		if not InputMap.has_action(ACTION_DODGE) and key_event.keycode == KEY_SPACE:
			_request_dodge()
		elif not InputMap.has_action(ACTION_SKILL_ONE) and key_event.keycode == KEY_Q:
			_request_skill_one()


func set_control_enabled(enabled: bool) -> void:
	controls_enabled = enabled
	if not enabled:
		velocity = Vector2.ZERO
		_cancel_action()


func grant_weapon() -> void:
	if _weapon_unlocked:
		return
	_weapon_unlocked = true
	weapon_state_changed.emit(true)


func restore_full() -> void:
	if _action_state == ActionState.DEAD:
		_action_state = ActionState.FREE
	_health = _maximum_health
	_stamina = _maximum_stamina
	health_changed.emit(_health, _maximum_health)
	stamina_changed.emit(_stamina, _maximum_stamina)


func receive_damage(packet: DamagePacket) -> DamageResult:
	var result := DamageResult.new()
	if packet == null:
		result.was_ignored = true
		return result
	if _action_state == ActionState.DEAD or is_dodging():
		result.was_ignored = true
		return result
	var mitigation: float = _get_mitigation(packet.damage_type)
	var minimum_damage: float = 1.0 if packet.amount > 0.0 else 0.0
	var applied_damage: float = packet.amount if packet.ignores_defense else maxf(packet.amount - mitigation, minimum_damage)
	_health = maxf(_health - applied_damage, 0.0)
	health_changed.emit(_health, _maximum_health)
	var killed: bool = is_zero_approx(_health)
	if killed:
		_die()
	result.applied_damage = applied_damage
	result.blocked_damage = maxf(packet.amount - applied_damage, 0.0)
	result.killed_target = killed
	return result


func get_facing_direction() -> Vector2:
	return _facing_direction


func is_dodging() -> bool:
	return _action_state == ActionState.DODGING and _action_elapsed <= combat_config.dodge_iframe_duration


func is_weapon_unlocked() -> bool:
	return _weapon_unlocked


func get_max_health() -> float:
	return _maximum_health


func get_health() -> float:
	return _health


func get_max_stamina() -> float:
	return _maximum_stamina


func get_stamina() -> float:
	return _stamina


func set_player_class(value: PlayerClass) -> void:
	player_class = value
	_apply_class_stats(false)


func restore_health(amount: float) -> void:
	if amount <= 0.0 or _action_state == ActionState.DEAD:
		return
	var previous_health: float = _health
	_health = minf(_health + amount, _maximum_health)
	if not is_equal_approx(previous_health, _health):
		health_changed.emit(_health, _maximum_health)


func _read_action_input() -> void:
	if InputMap.has_action(ACTION_ATTACK) and Input.is_action_just_pressed(ACTION_ATTACK):
		_request_attack()
	if InputMap.has_action(ACTION_DODGE) and Input.is_action_just_pressed(ACTION_DODGE):
		_request_dodge()
	if InputMap.has_action(ACTION_SKILL_ONE) and Input.is_action_just_pressed(ACTION_SKILL_ONE):
		_request_skill_one()


func _update_timers(delta: float) -> void:
	if _combo_reset_remaining > 0.0 and _action_state == ActionState.FREE:
		_combo_reset_remaining = maxf(_combo_reset_remaining - delta, 0.0)
		if is_zero_approx(_combo_reset_remaining):
			_combo_index = 0
	if _stamina_regen_block_remaining > 0.0:
		_stamina_regen_block_remaining = maxf(_stamina_regen_block_remaining - delta, 0.0)
	elif _action_state != ActionState.DODGING and _stamina < _maximum_stamina:
		var previous_stamina: float = _stamina
		_stamina = minf(_stamina + combat_config.stamina_regen_per_second * delta, _maximum_stamina)
		if not is_equal_approx(previous_stamina, _stamina):
			stamina_changed.emit(_stamina, _maximum_stamina)


func _update_action(delta: float) -> void:
	if _action_state == ActionState.FREE or _action_state == ActionState.DEAD:
		return
	_action_elapsed += delta
	match _action_state:
		ActionState.ATTACKING:
			_update_attack()
		ActionState.DODGING:
			if _action_elapsed >= combat_config.dodge_duration:
				_finish_action()
		ActionState.CASTING:
			if not _skill_effect_spawned and _action_elapsed >= combat_config.skill_active_time:
				_skill_effect_spawned = true
				_spawn_skill_one_effect()
			if _action_elapsed >= combat_config.skill_duration:
				_finish_action()


func _update_movement(delta: float) -> void:
	if _action_state == ActionState.DODGING:
		velocity = _dodge_direction * combat_config.dodge_speed
		return
	if _action_state == ActionState.ATTACKING or _action_state == ActionState.CASTING:
		velocity = velocity.move_toward(Vector2.ZERO, combat_config.deceleration * delta)
		return
	var input_direction: Vector2 = _get_movement_input() if controls_enabled else Vector2.ZERO
	if not input_direction.is_zero_approx():
		_facing_direction = input_direction
		velocity = velocity.move_toward(input_direction * combat_config.move_speed, combat_config.acceleration * delta)
	else:
		velocity = velocity.move_toward(Vector2.ZERO, combat_config.deceleration * delta)
	_update_facing_nodes()


func _request_attack() -> void:
	if not _weapon_unlocked:
		return
	if _action_state == ActionState.ATTACKING:
		if _combo_index < 3:
			_attack_buffered = true
		return
	if _action_state != ActionState.FREE:
		return
	var next_combo: int = _combo_index + 1 if _combo_reset_remaining > 0.0 else 1
	_start_attack(next_combo)


func _start_attack(combo_hit: int) -> void:
	_action_state = ActionState.ATTACKING
	_action_elapsed = 0.0
	_combo_index = clampi(combo_hit, 1, 3)
	_combo_reset_remaining = 0.0
	_attack_buffered = false
	_attack_hitbox_open = false
	_melee_hit_targets.clear()
	_update_facing_nodes()
	action_committed.emit(ACTION_COMBO_FINISHER if _combo_index == 3 else ACTION_ATTACK)


func _update_attack() -> void:
	if not _attack_hitbox_open and _action_elapsed >= combat_config.attack_active_start and _action_elapsed < combat_config.attack_active_end:
		_open_melee_hitbox()
	if _attack_hitbox_open and _action_elapsed >= combat_config.attack_active_end:
		_close_melee_hitbox()
	if _action_elapsed < combat_config.attack_duration:
		return
	_close_melee_hitbox()
	if _attack_buffered and _combo_index < 3:
		_start_attack(_combo_index + 1)
		return
	_combo_reset_remaining = combat_config.combo_reset_time if _combo_index < 3 else 0.0
	if _combo_index >= 3:
		_combo_index = 0
	_finish_action()


func _request_dodge() -> void:
	if _action_state != ActionState.FREE or _stamina < combat_config.dodge_stamina_cost:
		return
	var input_direction: Vector2 = _get_movement_input()
	_dodge_direction = input_direction if not input_direction.is_zero_approx() else _facing_direction
	_facing_direction = _dodge_direction
	_action_state = ActionState.DODGING
	_action_elapsed = 0.0
	_spend_stamina(combat_config.dodge_stamina_cost)
	_update_facing_nodes()
	action_committed.emit(ACTION_DODGE)


func _request_skill_one() -> void:
	if not _weapon_unlocked or _action_state != ActionState.FREE:
		return
	if _stamina < combat_config.skill_stamina_cost:
		return
	_action_state = ActionState.CASTING
	_action_elapsed = 0.0
	_skill_effect_spawned = false
	_spend_stamina(combat_config.skill_stamina_cost)
	action_committed.emit(ACTION_SKILL_ONE)


func _spawn_skill_one_effect() -> void:
	var effect: PlayerCombatEffect = EFFECT_SCRIPT.new() as PlayerCombatEffect
	get_parent().add_child(effect)
	effect.global_position = skill_origin.global_position
	match player_class:
		PlayerClass.BLADEMASTER:
			var wind_packet := DamagePacket.new(
				self,
				_get_attack_stat() * 1.8,
				DAMAGE_PHYSICAL,
				_facing_direction,
				90.0
			)
			effect.configure_projectile(
				wind_packet,
				_facing_direction,
				520.0,
				combat_config.world_pixels_per_meter * 5.0 / 520.0,
				Vector2(42.0, 18.0),
				Color("8de9f2"),
				target_collision_mask
			)
		PlayerClass.GUARDIAN:
			var slam_packet := DamagePacket.new(
				self,
				_get_attack_stat() * 1.5 + _get_defense_stat() * 0.6,
				DAMAGE_PHYSICAL,
				_facing_direction,
				180.0
			)
			effect.global_position = global_position
			effect.configure_circle(slam_packet, combat_config.world_pixels_per_meter * 4.0, 0.32, Color("8d6e45"), target_collision_mask)
		PlayerClass.SPELLBLADE:
			var purple_packet := DamagePacket.new(
				self,
				_get_magic_stat() * 1.8,
				DAMAGE_MAGICAL,
				_facing_direction,
				55.0
			)
			effect.configure_cone(purple_packet, _facing_direction, combat_config.world_pixels_per_meter * 6.0, deg_to_rad(70.0), 0.38, Color("a653e5"), target_collision_mask)
		PlayerClass.PRIEST:
			var sanctuary_packet := DamagePacket.new(
				self,
				_get_magic_stat() * 1.2 * 0.5,
				DAMAGE_HOLY,
				Vector2.ZERO,
				0.0
			)
			effect.global_position = global_position
			effect.configure_circle(sanctuary_packet, combat_config.world_pixels_per_meter * 4.0, 3.0, Color("f5df78"), target_collision_mask, 0.5, 0.04, self)


func _open_melee_hitbox() -> void:
	_attack_hitbox_open = true
	melee_hitbox.monitoring = true
	melee_shape.set_deferred("disabled", false)
	call_deferred("_apply_melee_overlaps")


func _close_melee_hitbox() -> void:
	_attack_hitbox_open = false
	if melee_hitbox != null:
		melee_hitbox.monitoring = false
	if melee_shape != null:
		melee_shape.set_deferred("disabled", true)


func _apply_melee_overlaps() -> void:
	if not _attack_hitbox_open:
		return
	for body: Node2D in melee_hitbox.get_overlapping_bodies():
		_apply_melee_damage(body)
	for area: Area2D in melee_hitbox.get_overlapping_areas():
		_apply_melee_damage(_find_damage_receiver(area))


func _on_melee_body_entered(body: Node2D) -> void:
	_apply_melee_damage(body)


func _on_melee_area_entered(area: Area2D) -> void:
	_apply_melee_damage(_find_damage_receiver(area))


func _apply_melee_damage(target: Node) -> void:
	if not _attack_hitbox_open or target == null or target == self:
		return
	var target_id: int = target.get_instance_id()
	if _melee_hit_targets.has(target_id) or not target.has_method("receive_damage"):
		return
	_melee_hit_targets[target_id] = true
	var multiplier_index: int = clampi(_combo_index - 1, 0, combat_config.combo_damage_multipliers.size() - 1)
	var packet := DamagePacket.new(
		self,
		_get_attack_stat() * combat_config.combo_damage_multipliers[multiplier_index],
		DAMAGE_PHYSICAL,
		_facing_direction,
		140.0 if _combo_index == 3 else 70.0
	)
	target.call("receive_damage", packet)


func _find_damage_receiver(node: Node) -> Node:
	var current: Node = node
	while current != null:
		if current.has_method("receive_damage"):
			return current
		current = current.get_parent()
	return null


func _spend_stamina(amount: float) -> void:
	_stamina = maxf(_stamina - amount, 0.0)
	_stamina_regen_block_remaining = combat_config.stamina_regen_delay
	stamina_changed.emit(_stamina, _maximum_stamina)


func _finish_action() -> void:
	_action_state = ActionState.FREE
	_action_elapsed = 0.0
	_skill_effect_spawned = false


func _cancel_action() -> void:
	_close_melee_hitbox()
	_attack_buffered = false
	_combo_index = 0
	_combo_reset_remaining = 0.0
	if _action_state != ActionState.DEAD:
		_finish_action()


func _die() -> void:
	_cancel_action()
	_action_state = ActionState.DEAD
	velocity = Vector2.ZERO
	died.emit()


func _apply_class_stats(refill: bool) -> void:
	var class_index: int = clampi(player_class, 0, PlayerClass.size() - 1)
	var previous_health_ratio: float = _health / _maximum_health if _maximum_health > 0.0 else 1.0
	var previous_stamina_ratio: float = _stamina / _maximum_stamina if _maximum_stamina > 0.0 else 1.0
	_maximum_health = CLASS_MAX_HEALTH[class_index]
	_maximum_stamina = CLASS_MAX_STAMINA[class_index]
	_health = _maximum_health if refill else clampf(_maximum_health * previous_health_ratio, 0.0, _maximum_health)
	_stamina = _maximum_stamina if refill else clampf(_maximum_stamina * previous_stamina_ratio, 0.0, _maximum_stamina)
	if is_node_ready():
		health_changed.emit(_health, _maximum_health)
		stamina_changed.emit(_stamina, _maximum_stamina)


func _get_mitigation(damage_type: StringName) -> float:
	match damage_type:
		DAMAGE_PHYSICAL:
			return _get_defense_stat() * 0.35
		DAMAGE_MAGICAL, DAMAGE_HOLY:
			return _get_resistance_stat() * 0.35
		_:
			return 0.0


func _get_attack_stat() -> float:
	return CLASS_ATTACK[clampi(player_class, 0, PlayerClass.size() - 1)]


func _get_magic_stat() -> float:
	return CLASS_MAGIC[clampi(player_class, 0, PlayerClass.size() - 1)]


func _get_defense_stat() -> float:
	return CLASS_DEFENSE[clampi(player_class, 0, PlayerClass.size() - 1)]


func _get_resistance_stat() -> float:
	return CLASS_RESISTANCE[clampi(player_class, 0, PlayerClass.size() - 1)]


func _get_movement_input() -> Vector2:
	var horizontal: float = _get_axis(ACTION_MOVE_LEFT, ACTION_MOVE_RIGHT, KEY_A, KEY_D)
	var vertical: float = _get_axis(ACTION_MOVE_UP, ACTION_MOVE_DOWN, KEY_W, KEY_S)
	return Vector2(horizontal, vertical).limit_length(1.0)


func _get_axis(negative_action: StringName, positive_action: StringName, negative_key: Key, positive_key: Key) -> float:
	var value: float = 0.0
	if InputMap.has_action(negative_action):
		value -= Input.get_action_strength(negative_action)
	elif Input.is_key_pressed(negative_key):
		value -= 1.0
	if InputMap.has_action(positive_action):
		value += Input.get_action_strength(positive_action)
	elif Input.is_key_pressed(positive_key):
		value += 1.0
	return value


func _update_facing_nodes() -> void:
	if melee_hitbox == null:
		return
	melee_hitbox.position = _facing_direction * 25.0
	melee_hitbox.rotation = _facing_direction.angle()
	skill_origin.position = _facing_direction * 24.0
