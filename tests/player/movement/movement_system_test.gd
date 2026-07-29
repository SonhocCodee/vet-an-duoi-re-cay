extends SceneTree

const PLAYER_SCENE: PackedScene = preload("res://scenes/actors/player/player.tscn")
const FRAME_RATES: Array[int] = [30, 60, 120]
const MOVEMENT_ACTIONS: Array[StringName] = [&"move_left", &"move_right", &"move_up", &"move_down"]

var _failures: Array[String] = []
var _checks: int = 0


func _initialize() -> void:
	call_deferred(&"_run")


func _run() -> void:
	_test_input_map()
	var player := PLAYER_SCENE.instantiate() as PlayerController
	root.add_child(player)
	await process_frame
	player.set_physics_process(false)
	_test_analog_deadzone(player)
	_test_delta_independent_acceleration(player)
	_test_diagonal_speed(player)
	_test_smooth_stop(player)
	_test_stable_facing(player)
	_test_dodge_direction_and_iframes(player)
	_test_action_lock(player)
	_test_disabled_controls(player)
	player.queue_free()
	await process_frame
	await _test_collision_movement()
	_release_movement_actions()
	if _failures.is_empty():
		print("[PLAYER_MOVEMENT] %d/%d checks passed" % [_checks, _checks])
		quit(0)
	else:
		for failure: String in _failures:
			push_error("[PLAYER_MOVEMENT][FAIL] %s" % failure)
		print("[PLAYER_MOVEMENT] %d failures across %d checks" % [_failures.size(), _checks])
		quit(1)


func _test_input_map() -> void:
	for action: StringName in MOVEMENT_ACTIONS:
		_expect(InputMap.has_action(action), "%s exists in InputMap" % action)
		_expect(is_equal_approx(InputMap.action_get_deadzone(action), 0.2), "%s uses 0.2 deadzone" % action)
	_expect(_has_key(&"move_left", KEY_A) and _has_key(&"move_left", KEY_LEFT), "move_left maps A and Left Arrow")
	_expect(_has_key(&"move_right", KEY_D) and _has_key(&"move_right", KEY_RIGHT), "move_right maps D and Right Arrow")
	_expect(_has_key(&"move_up", KEY_W) and _has_key(&"move_up", KEY_UP), "move_up maps W and Up Arrow")
	_expect(_has_key(&"move_down", KEY_S) and _has_key(&"move_down", KEY_DOWN), "move_down maps S and Down Arrow")
	_expect(_has_axis(&"move_left", JOY_AXIS_LEFT_X, -1.0), "move_left maps left stick X-")
	_expect(_has_axis(&"move_right", JOY_AXIS_LEFT_X, 1.0), "move_right maps left stick X+")
	_expect(_has_axis(&"move_up", JOY_AXIS_LEFT_Y, -1.0), "move_up maps left stick Y-")
	_expect(_has_axis(&"move_down", JOY_AXIS_LEFT_Y, 1.0), "move_down maps left stick Y+")
	_expect(_has_key(&"dodge", KEY_SPACE), "dodge maps Space")
	_expect(_has_button(&"dodge", JOY_BUTTON_A), "dodge maps gamepad south button")


func _test_analog_deadzone(player: PlayerController) -> void:
	var below: Vector2 = player.call(&"_apply_analog_deadzone", Vector2(0.19, 0.0), 0.2)
	var edge: Vector2 = player.call(&"_apply_analog_deadzone", Vector2(0.2, 0.0), 0.2)
	var above: Vector2 = player.call(&"_apply_analog_deadzone", Vector2(0.6, 0.0), 0.2)
	_expect(below == Vector2.ZERO, "analog noise below deadzone is ignored")
	_expect(edge == Vector2.ZERO, "analog input at deadzone edge is ignored")
	_expect(above.x > 0.0 and above.x < 0.6, "analog input above deadzone is smoothly remapped")


func _test_delta_independent_acceleration(player: PlayerController) -> void:
	var sampled_speeds: Array[float] = []
	for frame_rate: int in FRAME_RATES:
		_reset_player_movement(player)
		Input.action_press(&"move_right")
		var delta := 1.0 / float(frame_rate)
		var steps := frame_rate / 10
		for step: int in range(steps):
			player.call(&"_update_movement", delta)
		sampled_speeds.append(player.velocity.length())
		Input.action_release(&"move_right")
	_expect(is_equal_approx(sampled_speeds[0], 140.0), "30 FPS acceleration reaches expected velocity")
	_expect(sampled_speeds[0] == sampled_speeds[1] and sampled_speeds[1] == sampled_speeds[2], "acceleration matches at 30/60/120 FPS")


func _test_diagonal_speed(player: PlayerController) -> void:
	_reset_player_movement(player)
	Input.action_press(&"move_right")
	Input.action_press(&"move_down")
	for step: int in range(60):
		player.call(&"_update_movement", 1.0 / 60.0)
	_expect(is_equal_approx(player.velocity.length(), player.combat_config.move_speed), "diagonal movement does not exceed move speed")
	_expect(is_equal_approx(absf(player.velocity.x), absf(player.velocity.y)), "diagonal movement keeps equal axes")
	Input.action_release(&"move_right")
	Input.action_release(&"move_down")


func _test_smooth_stop(player: PlayerController) -> void:
	_reset_player_movement(player)
	player.velocity = Vector2.RIGHT * player.combat_config.move_speed
	var sampled_speeds: Array[float] = []
	for frame_rate: int in FRAME_RATES:
		player.velocity = Vector2.RIGHT * player.combat_config.move_speed
		var delta := 1.0 / float(frame_rate)
		for step: int in range(frame_rate / 10):
			player.call(&"_update_movement", delta)
		sampled_speeds.append(player.velocity.length())
	_expect(sampled_speeds.all(func(speed: float) -> bool: return is_zero_approx(speed)), "deceleration stops cleanly at 30/60/120 FPS")


func _test_stable_facing(player: PlayerController) -> void:
	_reset_player_movement(player)
	Input.action_press(&"move_right")
	player.call(&"_update_movement", 1.0 / 60.0)
	Input.action_release(&"move_right")
	var facing_before := player.get_facing_direction()
	Input.action_press(&"move_up", 0.3)
	player.call(&"_update_movement", 1.0 / 60.0)
	Input.action_release(&"move_up")
	_expect(player.get_facing_direction().is_equal_approx(facing_before), "weak analog input does not jitter facing")


func _test_dodge_direction_and_iframes(player: PlayerController) -> void:
	_reset_player_movement(player)
	Input.action_press(&"move_right")
	player.call(&"_request_dodge")
	Input.action_release(&"move_right")
	_expect(player.is_dodging(), "dodge starts inside i-frame window")
	_expect(player.velocity.is_equal_approx(Vector2.RIGHT * player.combat_config.dodge_speed), "dodge starts at configured speed")
	Input.action_press(&"move_left")
	player.call(&"_update_movement", 1.0 / 60.0)
	Input.action_release(&"move_left")
	_expect(player.velocity.is_equal_approx(Vector2.RIGHT * player.combat_config.dodge_speed), "dodge holds its committed direction")
	player.call(&"_update_action", player.combat_config.dodge_iframe_duration + 0.001)
	_expect(not player.is_dodging(), "i-frame ends at configured duration")
	player.call(&"_cancel_action")


func _test_action_lock(player: PlayerController) -> void:
	_reset_player_movement(player)
	player.velocity = Vector2.RIGHT * player.combat_config.move_speed
	player.call(&"_start_attack", 1)
	_expect(player.velocity == Vector2.ZERO, "attack lock clears inherited movement immediately")
	Input.action_press(&"move_right")
	player.call(&"_update_movement", 1.0 / 60.0)
	Input.action_release(&"move_right")
	_expect(player.velocity == Vector2.ZERO, "attack lock cannot drift from held movement input")
	player.call(&"_cancel_action")


func _test_disabled_controls(player: PlayerController) -> void:
	_reset_player_movement(player)
	player.velocity = Vector2.RIGHT * player.combat_config.move_speed
	player.set_control_enabled(false)
	_expect(player.velocity == Vector2.ZERO, "disabling controls clears velocity")
	Input.action_press(&"move_right")
	player.call(&"_update_movement", 1.0 / 30.0)
	Input.action_release(&"move_right")
	_expect(player.velocity == Vector2.ZERO, "disabled controls ignore movement input")
	_expect(not player.is_dodging(), "disabling controls cancels dodge/action state")
	player.set_control_enabled(true)


func _test_collision_movement() -> void:
	var world := Node2D.new()
	root.add_child(world)
	var wall := StaticBody2D.new()
	wall.position = Vector2(70.0, 0.0)
	var wall_shape := CollisionShape2D.new()
	var rectangle := RectangleShape2D.new()
	rectangle.size = Vector2(20.0, 160.0)
	wall_shape.shape = rectangle
	wall.add_child(wall_shape)
	world.add_child(wall)
	var player := PLAYER_SCENE.instantiate() as PlayerController
	player.position = Vector2.ZERO
	world.add_child(player)
	await physics_frame
	Input.action_press(&"move_right")
	for frame: int in range(60):
		await physics_frame
	Input.action_release(&"move_right")
	_expect(player.position.x > 45.0 and player.position.x < 52.0, "move_and_slide stops player against world collision")
	_expect(absf(player.position.y) < 0.1, "collision movement does not introduce vertical drift")
	player.queue_free()
	world.queue_free()
	await process_frame


func _reset_player_movement(player: PlayerController) -> void:
	_release_movement_actions()
	player.set_control_enabled(true)
	player.call(&"_cancel_action")
	player.velocity = Vector2.ZERO


func _release_movement_actions() -> void:
	for action: StringName in MOVEMENT_ACTIONS:
		Input.action_release(action)


func _has_key(action: StringName, physical_keycode: Key) -> bool:
	for event: InputEvent in InputMap.action_get_events(action):
		if event is InputEventKey and (event as InputEventKey).physical_keycode == physical_keycode:
			return true
	return false


func _has_axis(action: StringName, axis: JoyAxis, axis_value: float) -> bool:
	for event: InputEvent in InputMap.action_get_events(action):
		if event is InputEventJoypadMotion:
			var motion := event as InputEventJoypadMotion
			if motion.axis == axis and is_equal_approx(motion.axis_value, axis_value):
				return true
	return false


func _has_button(action: StringName, button: JoyButton) -> bool:
	for event: InputEvent in InputMap.action_get_events(action):
		if event is InputEventJoypadButton and (event as InputEventJoypadButton).button_index == button:
			return true
	return false


func _expect(condition: bool, message: String) -> void:
	_checks += 1
	if not condition:
		_failures.append(message)
