extends Node

const UI_SCENE: PackedScene = preload("res://scenes/ui/pixel/pixel_gameplay_ui.tscn")
const AnimationBridgeType = preload("res://scripts/visuals/pixel/pixel_animation_bridge.gd")

class MockActor:
	extends Node2D

	signal action_committed(action_id: StringName)
	signal health_changed(current: float, maximum: float)
	signal died

	var animation_velocity: Vector2 = Vector2.ZERO
	var facing: Vector2 = Vector2.DOWN

	func get_animation_velocity() -> Vector2:
		return animation_velocity

	func get_facing_direction() -> Vector2:
		return facing

var _failures: PackedStringArray = []
var _checks: int = 0


func _ready() -> void:
	GameState.reset_new_game()
	InventoryService.add_item(&"small_health_potion", 3)
	InventoryService.add_item(&"iron_sword", 1)
	InventoryService.add_item(&"root_herb", 5)
	InventoryService.equip_item(&"weapon", &"iron_sword")
	QuestService.start_quest(&"sword_without_name")
	GameState.discover_map_marker(&"market_square", {&"label": "Quảng trường", &"position": [920.0, 430.0]})
	await _test_pixel_ui_scene()
	await _test_animation_bridge()
	_finish()


func _test_pixel_ui_scene() -> void:
	var ui := UI_SCENE.instantiate()
	add_child(ui)
	await get_tree().process_frame
	await get_tree().process_frame
	_check(ui.is_in_group(&"pixel_ui"), "scene exposes pixel_ui group")
	_check(ui.get_node(^"PixelHUD/VitalPanel").size.x <= 340.0, "HUD stays compact")
	_check(ui.get_node(^"InventoryPanel").size.x <= 620.0, "inventory panel does not dominate viewport")
	_check(ui.get_node(^"QuestPanel").size.x <= 620.0, "quest panel does not dominate viewport")
	_check(ui.get_node(^"MapPanel").size.x <= 620.0, "map panel does not dominate viewport")
	_check(int(ui.call(&"get_hotbar_slot_count")) == 8, "hotbar creates eight square slots")
	_check(ui.call(&"get_open_panel_id") == &"", "panels start closed")

	GameEvents.hud_refresh_requested.emit({
		&"health": 47.0,
		&"max_health": 120.0,
		&"stamina": 31.0,
		&"max_stamina": 90.0,
		&"level": 7,
		&"gold": 234,
	})
	_check(is_equal_approx((ui.get_node(^"PixelHUD/VitalPanel/Margin/Layout/Vitals/HealthRow/HealthBar") as ProgressBar).value, 47.0), "HUD applies health snapshot")
	_check(is_equal_approx((ui.get_node(^"PixelHUD/VitalPanel/Margin/Layout/Vitals/StaminaRow/StaminaBar") as ProgressBar).value, 31.0), "HUD applies stamina snapshot")
	_check((ui.get_node(^"PixelHUD/VitalPanel/Margin/Layout/Vitals/Header/LevelLabel") as Label).text == "CẤP 7", "HUD applies level snapshot")
	_check((ui.get_node(^"PixelHUD/VitalPanel/Margin/Layout/Vitals/Header/GoldLabel") as Label).text == "234", "HUD applies currency snapshot")

	GameState.set_game_time(16.5)
	_check((ui.get_node(^"PixelHUD/ClockPanel/Margin/Layout/Text/ClockLabel") as Label).text == "16:30", "clock formats game time")
	ui.call(&"set_area_label", &"map_3", "Thị trấn Mùa Tro")
	_check((ui.get_node(^"PixelHUD/ClockPanel/Margin/Layout/Text/AreaLabel") as Label).text == "Thị trấn Mùa Tro", "area label accepts map presentation name")

	_check(bool(ui.call(&"open_panel", &"inventory")), "inventory panel opens")
	_check((ui.get_node(^"InventoryPanel") as Control).visible, "inventory is visible")
	_check(int((ui.get_node(^"InventoryPanel") as Node).call(&"get_rendered_item_count")) == 3, "inventory renders owned items")
	_check(bool(ui.call(&"open_panel", &"quests")), "quest panel opens")
	_check(not (ui.get_node(^"InventoryPanel") as Control).visible, "opening quest closes inventory")
	_check(int((ui.get_node(^"QuestPanel") as Node).call(&"get_rendered_quest_count")) >= 1, "quest panel renders active quest")
	_check(bool(ui.call(&"open_panel", &"map")), "map panel opens")
	_check(not (ui.get_node(^"QuestPanel") as Control).visible, "opening map closes quest panel")
	_check(int((ui.get_node(^"MapPanel") as Node).call(&"get_marker_count")) == 1, "map renders discovered marker")
	ui.call(&"close_panels")
	_check(ui.call(&"get_open_panel_id") == &"", "close hides modal panels")
	_check(not (ui.get_node(^"PanelBackdrop") as Control).visible, "close hides soft backdrop")

	for icon_name: String in ["icon_heart.svg", "icon_stamina.svg", "icon_sword.svg", "icon_potion.svg", "icon_bag.svg", "icon_scroll.svg", "icon_map.svg", "icon_clock.svg"]:
		var icon_path := "res://assets/art/pixel/ui/" + icon_name
		_check(ResourceLoader.exists(icon_path), "pixel icon imports: %s" % icon_name)
	ui.queue_free()
	await get_tree().process_frame


func _test_animation_bridge() -> void:
	var actor := MockActor.new()
	var sprite := AnimatedSprite2D.new()
	var frames := SpriteFrames.new()
	frames.remove_animation(&"default")
	var frame_image := Image.create(2, 2, false, Image.FORMAT_RGBA8)
	frame_image.fill(Color.WHITE)
	var frame_texture := ImageTexture.create_from_image(frame_image)
	for animation_name: StringName in [&"idle_down", &"idle_up", &"idle_side", &"walk_down", &"walk_up", &"walk_side", &"attack_side", &"hurt", &"dead"]:
		frames.add_animation(animation_name)
		frames.add_frame(animation_name, frame_texture)
	sprite.sprite_frames = frames
	actor.add_child(sprite)
	add_child(actor)
	var bridge := AnimationBridgeType.new()
	actor.add_child(bridge)
	_check(bridge.configure(actor, sprite), "animation bridge binds actor and sprite")
	actor.facing = Vector2.DOWN
	actor.animation_velocity = Vector2.ZERO
	bridge.update_animation(true)
	_check(sprite.animation == &"idle_down", "bridge selects downward idle")
	actor.animation_velocity = Vector2.RIGHT * 20.0
	bridge.update_animation(true)
	_check(sprite.animation == &"walk_side" and not sprite.flip_h, "bridge selects right walk")
	actor.animation_velocity = Vector2.LEFT * 20.0
	bridge.update_animation(true)
	_check(sprite.animation == &"walk_side" and sprite.flip_h, "bridge mirrors left walk")
	actor.action_committed.emit(&"basic_attack")
	_check(sprite.animation == &"attack_side", "bridge maps combat action to directional attack")
	bridge.notify_hurt()
	_check(sprite.animation == &"hurt", "bridge exposes hurt animation")
	actor.died.emit()
	_check(sprite.animation == &"dead", "bridge exposes death animation")
	actor.queue_free()
	await get_tree().process_frame


func _check(condition: bool, message: String) -> void:
	_checks += 1
	if condition:
		print("[PIXEL_UI][PASS] %s" % message)
		return
	_failures.append(message)
	push_error("[PIXEL_UI][FAIL] %s" % message)


func _finish() -> void:
	if _failures.is_empty():
		print("[PIXEL_UI][PASS] %d checks completed with no failures." % _checks)
		get_tree().quit(0)
		return
	print("[PIXEL_UI][SUMMARY] %d of %d checks failed." % [_failures.size(), _checks])
	get_tree().quit(1)
