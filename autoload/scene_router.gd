extends Node

const MAP_PATHS: Dictionary = {
	GameIds.MAP_1: "res://scenes/maps/map1_awakening_forest.tscn",
	GameIds.MAP_2: "res://scenes/maps/map2_tutorial_road.tscn",
	GameIds.MAP_3: "res://scenes/maps/map3_ashen_town_hub.tscn",
}
const FADE_DURATION: float = 0.3

var _map_container: Node
var _player: Node2D
var _fade_rect: ColorRect
var _active_map: Node
var _transitioning: bool = false

func _ready() -> void:
	GameEvents.map_change_requested.connect(change_map)

func configure(map_container: Node, player: Node2D, fade_rect: ColorRect) -> void:
	_map_container = map_container
	_player = player
	_fade_rect = fade_rect
	_fade_rect.color.a = 1.0

func change_map(map_id: StringName, spawn_id: StringName = GameIds.SPAWN_DEFAULT) -> void:
	if _transitioning or _map_container == null or _player == null:
		return
	_perform_change_map(map_id, spawn_id)

func _perform_change_map(map_id: StringName, spawn_id: StringName) -> void:
	_transitioning = true
	_set_player_control(false)
	await _fade_to(1.0)
	if _active_map != null:
		_active_map.queue_free()
		await get_tree().process_frame
	var map_scene: PackedScene = _load_map_scene(map_id)
	if map_scene == null:
		GameEvents.toast_requested.emit("Không thể mở bản đồ: %s" % String(map_id))
		await _fade_to(0.0)
		_set_player_control(true)
		_transitioning = false
		return
	_active_map = map_scene.instantiate()
	_map_container.add_child(_active_map)
	await get_tree().process_frame
	_place_player(spawn_id)
	GameState.current_map = map_id
	GameState.current_spawn = spawn_id
	GameEvents.map_changed.emit(map_id, spawn_id)
	await _fade_to(0.0)
	_set_player_control(true)
	_transitioning = false

func reload_checkpoint() -> void:
	change_map(GameState.checkpoint_map, GameState.checkpoint_spawn)

func get_active_map() -> Node:
	return _active_map

func get_player() -> Node2D:
	return _player

func _load_map_scene(map_id: StringName) -> PackedScene:
	var scene_path: String = String(MAP_PATHS.get(map_id, ""))
	if scene_path.is_empty() or not ResourceLoader.exists(scene_path):
		return null
	return load(scene_path) as PackedScene

func _place_player(spawn_id: StringName) -> void:
	var spawn_points: Node = _active_map.get_node_or_null("SpawnPoints")
	var marker: Marker2D
	if spawn_points != null:
		marker = spawn_points.get_node_or_null(NodePath(String(spawn_id))) as Marker2D
		if marker == null:
			marker = spawn_points.get_node_or_null(NodePath(String(GameIds.SPAWN_DEFAULT))) as Marker2D
	_player.global_position = marker.global_position if marker != null else Vector2.ZERO

func _set_player_control(enabled: bool) -> void:
	if _player.has_method("set_control_enabled"):
		_player.call("set_control_enabled", enabled)
	else:
		_player.set_physics_process(enabled)

func _fade_to(alpha: float) -> void:
	if _fade_rect == null:
		return
	var tween: Tween = create_tween()
	tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tween.tween_property(_fade_rect, "color:a", alpha, FADE_DURATION)
	await tween.finished
