extends SceneTree

const PLAYER_SCENE: PackedScene = preload("res://scenes/actors/player/player.tscn")

var failures: Array[String] = []


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var player := PLAYER_SCENE.instantiate() as PlayerController
	root.add_child(player)
	await process_frame
	_expect(not player.is_weapon_unlocked(), "Weapon starts locked")
	var committed_actions: Array[StringName] = []
	player.action_committed.connect(func(action_id: StringName) -> void: committed_actions.append(action_id))
	player.call("_request_attack")
	_expect(committed_actions.is_empty(), "Weapon lock blocks attacks")
	var weapon_signal_received: Array[bool] = [false]
	player.weapon_state_changed.connect(func(unlocked: bool) -> void: weapon_signal_received[0] = unlocked)
	player.grant_weapon()
	_expect(player.is_weapon_unlocked(), "grant_weapon unlocks combat")
	_expect(weapon_signal_received[0], "grant_weapon emits weapon_state_changed")
	player.call("_request_attack")
	_expect(committed_actions == [&"attack"], "Unlocked attack emits attack action")
	player.call("_start_attack", 3)
	_expect(committed_actions.back() == &"combo_finisher", "Third combo hit emits combo_finisher")
	player.call("_cancel_action")

	var initial_health: float = player.get_health()
	var damage_result: DamageResult = player.receive_damage(DamagePacket.new(null, 20.0, &"physical"))
	_expect(damage_result.applied_damage > 0.0, "receive_damage applies mitigated damage")
	_expect(player.get_health() < initial_health, "receive_damage lowers health")
	player.restore_full()
	_expect(is_equal_approx(player.get_health(), player.get_max_health()), "restore_full restores health")
	_expect(is_equal_approx(player.get_stamina(), player.get_max_stamina()), "restore_full restores stamina")

	player.call("_request_dodge")
	_expect(player.is_dodging(), "Dodge starts an i-frame window")
	var avoided_result: DamageResult = player.receive_damage(DamagePacket.new(null, 999.0, &"physical"))
	_expect(avoided_result.was_ignored, "Dodge i-frame avoids damage")
	_expect(player.get_stamina() < player.get_max_stamina(), "Dodge spends stamina")

	player.queue_free()
	if failures.is_empty():
		print("Player MVP tests passed")
		quit(0)
	else:
		for failure: String in failures:
			push_error(failure)
		quit(1)


func _expect(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)
