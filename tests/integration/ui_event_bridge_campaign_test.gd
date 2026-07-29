extends Node

const UI_SCENE: PackedScene = preload("res://scenes/ui/game_hud.tscn")
const PLAYER_SCENE: PackedScene = preload("res://scenes/actors/player/player.tscn")

var _failures: PackedStringArray = []
var _checks_run := 0
var _resolved_events: Array[Dictionary] = []
var _ui: HubUI
var _player: PlayerController
var _bridge: UIEventBridge


func _ready() -> void:
	GameState.reset_new_game()
	_ui = UI_SCENE.instantiate() as HubUI
	_player = PLAYER_SCENE.instantiate() as PlayerController
	_bridge = UIEventBridge.new()
	add_child(_ui)
	add_child(_player)
	add_child(_bridge)
	_bridge.configure(_ui, _player)
	GameEvents.moral_choice_resolved.connect(_on_moral_choice_resolved)
	_test_existing_dialogue_flow()
	_test_button_choice_uses_payload_id()
	_test_number_keys_use_payload_ids()
	_test_external_resolution_restores_control_state()
	_finish()


func _test_existing_dialogue_flow() -> void:
	GameEvents.dialogue_requested.emit(&"map2_aria_after_root_antler_stag")
	var panel := _dialogue_panel()
	_check(panel.visible, "existing dialogue remains visible")
	_check_equal((panel.get_node("Content/Speaker") as Label).text, "Aria", "existing dialogue speaker remains unchanged")
	_check(not (panel.get_node("Content/Line") as Label).text.is_empty(), "existing dialogue line still resolves")
	_bridge._finish_dialogue()
	_check(not panel.visible, "existing dialogue still closes")


func _test_button_choice_uses_payload_id() -> void:
	_resolved_events.clear()
	var options: Array[Dictionary] = [
		{"id": &"show_mercy", "text": "Tha thứ người giữ chuông"},
		{"id": &"break_bell", "text": "Phá chiếc chuông bị nguyền"},
	]
	GameEvents.moral_choice_requested.emit(&"choice_button", options)
	var panel := _dialogue_panel()
	var buttons := panel.choices.get_children()
	_check(panel.visible, "choice panel opens for button input")
	_check_equal(buttons.size(), 2, "choice panel renders exactly two buttons")
	if buttons.size() >= 2:
		_check_equal((buttons[0] as Button).text, options[0]["text"], "first button shows payload text")
		_check_equal((buttons[1] as Button).text, options[1]["text"], "second button shows payload text")
		(buttons[1] as Button).pressed.emit()
	_check_equal(_last_resolved_option(), &"break_bell", "button emits the selected payload ID")
	_check_equal(GameState.get_choice(&"choice_button"), &"break_bell", "button selection is recorded")
	_check(not panel.visible, "button selection closes choice panel")
	_check(_player.controls_enabled, "button selection restores player control")


func _test_number_keys_use_payload_ids() -> void:
	var options: Array[Dictionary] = [
		{"id": &"keep_truth", "text": "Giữ lại sự thật"},
		{"id": &"erase_truth", "text": "Xóa sự thật"},
	]
	_resolved_events.clear()
	GameEvents.moral_choice_requested.emit(&"choice_key_1", options)
	var key_one := InputEventKey.new()
	key_one.pressed = true
	key_one.physical_keycode = KEY_1
	_bridge._unhandled_input(key_one)
	_check_equal(_last_resolved_option(), &"keep_truth", "key 1 emits the first payload ID")

	_resolved_events.clear()
	GameEvents.moral_choice_requested.emit(&"choice_key_2", options)
	var key_two := InputEventKey.new()
	key_two.pressed = true
	key_two.keycode = KEY_2
	_bridge._unhandled_input(key_two)
	_check_equal(_last_resolved_option(), &"erase_truth", "key 2 emits the second payload ID")


func _test_external_resolution_restores_control_state() -> void:
	_player.set_control_enabled(false)
	var options: Array[Dictionary] = [
		{"id": &"wait", "text": "Chờ đợi"},
		{"id": &"leave", "text": "Rời đi"},
	]
	GameEvents.moral_choice_requested.emit(&"choice_external", options)
	GameEvents.moral_choice_resolved.emit(&"choice_external", &"leave")
	_check(not _dialogue_panel().visible, "external resolution closes choice panel")
	_check(not _player.controls_enabled, "external resolution preserves prior disabled controls")


func _dialogue_panel() -> DialoguePanel:
	return _ui.get_node("DialoguePanel") as DialoguePanel


func _last_resolved_option() -> StringName:
	if _resolved_events.is_empty():
		return &""
	return StringName(_resolved_events.back().get("option_id", &""))


func _on_moral_choice_resolved(choice_id: StringName, option_id: StringName) -> void:
	_resolved_events.append({"choice_id": choice_id, "option_id": option_id})


func _check(condition: bool, message: String) -> void:
	_checks_run += 1
	if condition:
		print("[UI_EVENT_BRIDGE][PASS] %s" % message)
		return
	_failures.append(message)
	push_error("[UI_EVENT_BRIDGE][FAIL] %s" % message)


func _check_equal(actual: Variant, expected: Variant, message: String) -> void:
	_check(actual == expected, "%s (expected %s, got %s)" % [message, expected, actual])


func _finish() -> void:
	if _failures.is_empty():
		print("[UI_EVENT_BRIDGE][PASS] %d checks completed with no failures." % _checks_run)
		get_tree().quit(0)
		return
	print("[UI_EVENT_BRIDGE][SUMMARY] %d of %d checks failed." % [_failures.size(), _checks_run])
	get_tree().quit(1)
