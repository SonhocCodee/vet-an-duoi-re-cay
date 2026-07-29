extends SceneTree

const PLAYER_SCENE: PackedScene = preload("res://scenes/actors/player/player.tscn")

class CombatDummy:
	extends CharacterBody2D

	var received_packets: Array[DamagePacket] = []

	func _init() -> void:
		var collision_shape := CollisionShape2D.new()
		var circle := CircleShape2D.new()
		circle.radius = 6.0
		collision_shape.shape = circle
		add_child(collision_shape)

	func receive_damage(packet: DamagePacket) -> DamageResult:
		received_packets.append(packet)
		return DamageResult.new(packet.amount, packet.amount, 100.0, false, false)


var _failures: Array[String] = []
var _checks: int = 0


func _initialize() -> void:
	call_deferred(&"_run")


func _run() -> void:
	var player := PLAYER_SCENE.instantiate() as PlayerController
	root.add_child(player)
	await process_frame
	player.set_physics_process(false)
	player.grant_weapon()
	_test_cardinal_attack_commitment(player)
	_test_attack_movement(player)
	_test_single_swing_cooldown(player)
	await _test_short_arc_impact(player)
	_test_runtime_hitbox_shape(player)
	_release_movement_actions()
	player.queue_free()
	await process_frame
	if _failures.is_empty():
		print("[COMBAT_TOPDOWN] %d/%d checks passed" % [_checks, _checks])
		quit(0)
	else:
		for failure: String in _failures:
			push_error("[COMBAT_TOPDOWN][FAIL] %s" % failure)
		print("[COMBAT_TOPDOWN] %d failures across %d checks" % [_failures.size(), _checks])
		quit(1)


func _test_cardinal_attack_commitment(player: PlayerController) -> void:
	var samples: Array[Vector2] = [
		Vector2(0.9, 0.3),
		Vector2(-0.9, 0.3),
		Vector2(0.2, -0.9),
		Vector2(0.2, 0.9),
	]
	var expected: Array[Vector2] = [Vector2.RIGHT, Vector2.LEFT, Vector2.UP, Vector2.DOWN]
	for index: int in range(samples.size()):
		_reset_combat(player)
		player.set(&"_facing_direction", samples[index])
		player.call(&"_start_attack", 1)
		_expect(player.get_attack_direction() == expected[index], "attack snaps sample %d to a cardinal direction" % index)


func _test_attack_movement(player: PlayerController) -> void:
	_reset_combat(player)
	player.set(&"_facing_direction", Vector2.RIGHT)
	player.velocity = Vector2.RIGHT * player.combat_config.move_speed
	player.call(&"_start_attack", 1)
	var speed_cap: float = player.combat_config.move_speed * player.combat_config.attack_move_speed_multiplier
	_expect(is_equal_approx(player.velocity.length(), speed_cap), "starting a swing slows movement without rooting the player")
	Input.action_press(&"move_down")
	for step: int in range(12):
		player.call(&"_update_movement", 1.0 / 60.0)
	Input.action_release(&"move_down")
	_expect(player.velocity.y > 0.0, "player can steer while swinging")
	_expect(player.velocity.length() <= speed_cap + 0.01, "swing movement respects the reduced speed cap")
	_expect(player.get_attack_direction() == Vector2.RIGHT, "steering does not bend the active four-way swing")


func _test_single_swing_cooldown(player: PlayerController) -> void:
	_reset_combat(player)
	var committed_actions: Array[StringName] = []
	var callback := func(action_id: StringName) -> void: committed_actions.append(action_id)
	player.action_committed.connect(callback)
	player.call(&"_request_attack")
	player.call(&"_request_attack")
	_expect(committed_actions == [&"attack"], "repeated input does not buffer a heavy combo chain")
	player.call(&"_update_action", player.combat_config.attack_duration)
	_expect(not player.is_attacking(), "single swing ends after its readable attack duration")
	_expect(player.get_attack_cooldown_remaining() > 0.0, "attack enters an explicit recovery cooldown")
	player.call(&"_request_attack")
	_expect(committed_actions.size() == 1, "cooldown blocks immediate repeat attacks")
	player.call(&"_update_timers", player.combat_config.attack_cooldown)
	_expect(player.can_attack(), "attack becomes available when cooldown expires")
	player.call(&"_request_attack")
	_expect(committed_actions == [&"attack", &"attack"], "next input starts another independent basic swing")
	player.action_committed.disconnect(callback)


func _test_short_arc_impact(player: PlayerController) -> void:
	_reset_combat(player)
	player.global_position = Vector2.ZERO
	player.set(&"_facing_direction", Vector2.RIGHT)
	player.call(&"_start_attack", 1)
	player.set(&"_attack_hitbox_open", true)
	var front := CombatDummy.new()
	var behind := CombatDummy.new()
	var outside_arc := CombatDummy.new()
	var beyond_reach := CombatDummy.new()
	root.add_child(front)
	root.add_child(behind)
	root.add_child(outside_arc)
	root.add_child(beyond_reach)
	front.global_position = Vector2(30.0, 0.0)
	behind.global_position = Vector2(-30.0, 0.0)
	outside_arc.global_position = Vector2(20.0, 30.0)
	beyond_reach.global_position = Vector2(60.0, 0.0)
	await physics_frame
	var front_start: Vector2 = front.global_position
	player.call(&"_apply_melee_damage", front)
	player.call(&"_apply_melee_damage", front)
	player.call(&"_apply_melee_damage", behind)
	player.call(&"_apply_melee_damage", outside_arc)
	player.call(&"_apply_melee_damage", beyond_reach)
	_expect(front.received_packets.size() == 1, "active swing damages each valid target only once")
	_expect(behind.received_packets.is_empty(), "short arc rejects targets behind the player")
	_expect(outside_arc.received_packets.is_empty(), "short arc rejects targets outside its configured angle")
	_expect(beyond_reach.received_packets.is_empty(), "short arc rejects targets beyond its configured reach")
	if not front.received_packets.is_empty():
		var packet: DamagePacket = front.received_packets[0]
		_expect(packet.hit_direction == Vector2.RIGHT, "damage packet carries the committed cardinal direction")
		_expect(is_equal_approx(packet.knockback_force, player.combat_config.attack_knockback_force), "basic swing sends configured knockback force")
		_expect(packet.action_id == &"attack", "basic swing identifies itself as an attack action")
	_expect(front.global_position.x > front_start.x, "landed hit nudges a physics target away from the player")
	_expect(is_equal_approx(player.get_hit_stop_remaining(), player.combat_config.attack_hit_stop), "landed hit starts a light local hit-stop")
	for dummy: CombatDummy in [front, behind, outside_arc, beyond_reach]:
		dummy.queue_free()
	await process_frame


func _test_runtime_hitbox_shape(player: PlayerController) -> void:
	var rectangle := player.melee_shape.shape as RectangleShape2D
	_expect(rectangle != null, "melee hitbox remains a rectangle compatible with the player scene")
	if rectangle != null:
		_expect(rectangle.size.is_equal_approx(Vector2(player.combat_config.attack_hitbox_depth, player.combat_config.attack_hitbox_width)), "runtime hitbox uses the configured short-arc dimensions")


func _reset_combat(player: PlayerController) -> void:
	_release_movement_actions()
	player.call(&"_cancel_action")
	player.velocity = Vector2.ZERO


func _release_movement_actions() -> void:
	Input.action_release(&"move_left")
	Input.action_release(&"move_right")
	Input.action_release(&"move_up")
	Input.action_release(&"move_down")


func _expect(condition: bool, message: String) -> void:
	_checks += 1
	if not condition:
		_failures.append(message)
