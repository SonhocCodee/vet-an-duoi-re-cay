extends Node

const PLAYER_SCENE_PATH: String = "res://scenes/actors/player/player.tscn"
const HUD_SCENE_PATH: String = "res://scenes/ui/game_hud.tscn"

@onready var map_container: Node2D = $World/MapContainer
@onready var world: Node2D = $World
@onready var hud_socket: Control = $Interface/HudSocket
@onready var fade_rect: ColorRect = $FadeLayer/FadeRect

var player: Node2D
var interaction_bridge: InteractionBridge

func _enter_tree() -> void:
	_ensure_input_actions()

func _ready() -> void:
	player = _instantiate_player()
	if player == null:
		push_error("Missing player scene at %s" % PLAYER_SCENE_PATH)
		return
	world.add_child(player)
	interaction_bridge = InteractionBridge.new()
	add_child(interaction_bridge)
	interaction_bridge.configure(player)
	_instantiate_hud()
	SceneRouter.configure(map_container, player, fade_rect)
	GameEvents.player_registered.emit(player)
	if player.has_signal("died"):
		player.connect("died", _on_player_died)
	SceneRouter.change_map(GameState.current_map, GameState.current_spawn)

func _instantiate_player() -> Node2D:
	if not ResourceLoader.exists(PLAYER_SCENE_PATH):
		return null
	var scene: PackedScene = load(PLAYER_SCENE_PATH) as PackedScene
	return scene.instantiate() as Node2D

func _instantiate_hud() -> void:
	if not ResourceLoader.exists(HUD_SCENE_PATH):
		return
	var scene: PackedScene = load(HUD_SCENE_PATH) as PackedScene
	var hud: Control = scene.instantiate() as Control
	hud_socket.add_child(hud)

func _on_player_died() -> void:
	GameEvents.player_died.emit()
	await get_tree().create_timer(0.6).timeout
	if player.has_method("restore_full"):
		player.call("restore_full")
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
