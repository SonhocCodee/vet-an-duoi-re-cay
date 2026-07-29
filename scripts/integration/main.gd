extends Node

const PLAYER_SCENE_PATH: String = "res://scenes/actors/player/player.tscn"
const HUD_SCENE_PATH: String = "res://scenes/ui/game_hud.tscn"
const UI_SUITE_PATH: String = "res://scenes/ui/game_hud.tscn"

@onready var map_container: Node2D = $World/MapContainer
@onready var world: Node2D = $World
@onready var fade_rect: ColorRect = $FadeLayer/FadeRect

var player: PlayerController
var interaction_bridge: InteractionBridge
var ui_event_bridge: UIEventBridge
var ui_suite: HubUI
var campaign_gate_injector: CampaignGateInjector

func _enter_tree() -> void:
	_ensure_input_actions()

func _ready() -> void:
	player = _instantiate_player()
	if player == null:
		push_error("Missing player scene at %s" % PLAYER_SCENE_PATH)
		return
	world.add_child(player)
	_ensure_player_contract()
	ui_suite = _instantiate_ui_suite()
	interaction_bridge = InteractionBridge.new()
	add_child(interaction_bridge)
	interaction_bridge.configure(player)
	if ui_suite != null:
		ui_event_bridge = UIEventBridge.new()
		add_child(ui_event_bridge)
		ui_event_bridge.configure(ui_suite, player)
	campaign_gate_injector = CampaignGateInjector.new()
	add_child(campaign_gate_injector)
	SceneRouter.configure(map_container, player, fade_rect)
	GameEvents.player_registered.emit(player)
	player.died.connect(_on_player_died)
	SceneRouter.change_map(GameState.current_map, GameState.current_spawn)

func _instantiate_player() -> PlayerController:
	if not ResourceLoader.exists(PLAYER_SCENE_PATH):
		return null
	var scene: PackedScene = load(PLAYER_SCENE_PATH) as PackedScene
	return scene.instantiate() as PlayerController

func _instantiate_ui_suite() -> HubUI:
	if not ResourceLoader.exists(UI_SUITE_PATH):
		push_warning("Missing UI suite at %s" % UI_SUITE_PATH)
		return null
	var scene: PackedScene = load(UI_SUITE_PATH) as PackedScene
	var ui: HubUI = scene.instantiate() as HubUI
	add_child(ui)
	return ui

func _ensure_player_contract() -> void:
	player.add_to_group(&"player")
	if player.get_node_or_null("InteractionArea") != null:
		return
	var area := Area2D.new()
	area.name = "InteractionArea"
	area.collision_layer = 0
	area.collision_mask = 32
	area.monitoring = true
	var shape_node := CollisionShape2D.new()
	var shape := CircleShape2D.new()
	shape.radius = 52.0
	shape_node.shape = shape
	area.add_child(shape_node)
	player.add_child(area)

func _on_player_died() -> void:
	GameEvents.player_died.emit()
	await get_tree().create_timer(0.6).timeout
	player.restore_full()
	SceneRouter.reload_checkpoint()

func _ensure_input_actions() -> void:
	_add_key_action(&"move_left", KEY_A)
	_add_key_action(&"move_left", KEY_LEFT)
	_add_key_action(&"move_right", KEY_D)
	_add_key_action(&"move_right", KEY_RIGHT)
	_add_key_action(&"move_up", KEY_W)
	_add_key_action(&"move_up", KEY_UP)
	_add_key_action(&"move_down", KEY_S)
	_add_key_action(&"move_down", KEY_DOWN)
	_add_key_action(&"attack", KEY_J)
	_add_mouse_action(&"attack", MOUSE_BUTTON_LEFT)
	_add_key_action(&"dodge", KEY_SPACE)
	_add_key_action(&"dodge", KEY_K)
	_add_key_action(&"skill_1", KEY_Q)
	_add_key_action(&"skill_1", KEY_L)
	_add_key_action(&"interact", KEY_E)
	_add_key_action(&"pause", KEY_ESCAPE)
	_add_joypad_button(&"attack", JOY_BUTTON_X)
	_add_joypad_button(&"dodge", JOY_BUTTON_A)
	_add_joypad_button(&"skill_1", JOY_BUTTON_Y)
	_add_joypad_button(&"interact", JOY_BUTTON_B)

func _add_key_action(action: StringName, keycode: Key) -> void:
	if not InputMap.has_action(action):
		InputMap.add_action(action)
	var input_event := InputEventKey.new()
	input_event.physical_keycode = keycode
	if not InputMap.action_has_event(action, input_event):
		InputMap.action_add_event(action, input_event)

func _add_mouse_action(action: StringName, button: MouseButton) -> void:
	if not InputMap.has_action(action):
		InputMap.add_action(action)
	var input_event := InputEventMouseButton.new()
	input_event.button_index = button
	if not InputMap.action_has_event(action, input_event):
		InputMap.action_add_event(action, input_event)

func _add_joypad_button(action: StringName, button: JoyButton) -> void:
	if not InputMap.has_action(action):
		InputMap.add_action(action)
	var input_event := InputEventJoypadButton.new()
	input_event.button_index = button
	if not InputMap.action_has_event(action, input_event):
		InputMap.action_add_event(action, input_event)
