extends Node

const MAIN_SCENE_PATH: String = "res://scenes/bootstrap/main.tscn"
const MAP_LOAD_TIMEOUT_MS: int = 6000

const CAMPAIGN_ROUTE_IDS: Array[StringName] = [
	GameIds.MAP_CHAPTER_2,
	GameIds.MAP_CHAPTER_3,
	GameIds.MAP_CHAPTER_4,
	GameIds.MAP_CHAPTER_5,
	GameIds.MAP_CHAPTER_6,
	GameIds.MAP_CHAPTER_7,
	GameIds.MAP_CHAPTER_8,
	GameIds.MAP_CHAPTER_9,
	GameIds.MAP_CHAPTER_10,
	GameIds.MAP_TRUE_ENDING,
]

var _checks_run: int = 0
var _failures: Array[String] = []
var _chapter_two_intro_finished: bool = false


func _ready() -> void:
	call_deferred(&"_run")


func _run() -> void:
	GameState.reset_new_game()
	GameState.set_flag(GameIds.FLAG_WEAPON_UNLOCKED)
	GameEvents.tutorial_requested.connect(_on_tutorial_requested)
	var main_instance := _instantiate_main()
	if main_instance == null:
		_finish()
		return
	add_child(main_instance)

	var initial_map_loaded := await _wait_for_map(GameIds.MAP_1)
	_expect(initial_map_loaded, "main scene completes its initial Map 1 load")
	var router_idle := await _wait_for_router_idle()
	_expect(router_idle, "SceneRouter finishes the initial transition")
	_check_campaign_gate_injector(main_instance)
	_check_campaign_routes()

	GameEvents.map_change_requested.emit(GameIds.MAP_CHAPTER_2, GameIds.SPAWN_DEFAULT)
	var chapter_two_loaded := await _wait_for_map(GameIds.MAP_CHAPTER_2)
	_expect(chapter_two_loaded, "Chapter 2 loads through map_change_requested")
	if chapter_two_loaded:
		_check_chapter_two_spawn()
	var chapter_router_idle := await _wait_for_router_idle()
	_expect(chapter_router_idle, "SceneRouter finishes the Chapter 2 transition")
	var chapter_intro_finished := await _wait_for_chapter_two_intro()
	_expect(chapter_intro_finished, "Chapter 2 intro sequence finishes cleanly")

	main_instance.queue_free()
	await get_tree().process_frame
	await get_tree().process_frame
	_finish()


func _instantiate_main() -> Node:
	_checks_run += 1
	if not ResourceLoader.exists(MAIN_SCENE_PATH, "PackedScene"):
		_fail("main scene is missing at %s" % MAIN_SCENE_PATH)
		return null
	var main_scene := load(MAIN_SCENE_PATH) as PackedScene
	if main_scene == null:
		_fail("main scene cannot load as PackedScene")
		return null
	var main_instance := main_scene.instantiate()
	if main_instance == null:
		_fail("main scene cannot instantiate")
		return null
	_pass("main scene loads and instantiates")
	return main_instance


func _check_campaign_gate_injector(main_instance: Node) -> void:
	var injector: Node = null
	for child: Node in main_instance.get_children():
		if child is CampaignGateInjector:
			injector = child
			break
	_expect(injector != null, "CampaignGateInjector exists under the main scene")
	_expect(
		main_instance.get("campaign_gate_injector") == injector,
		"main scene retains the CampaignGateInjector instance"
	)


func _check_campaign_routes() -> void:
	var router_script := SceneRouter.get_script() as Script
	_expect(router_script != null, "SceneRouter has an inspectable script")
	if router_script == null:
		return
	var constants := router_script.get_script_constant_map()
	var routes_variant: Variant = constants.get("MAP_PATHS", constants.get(&"MAP_PATHS", null))
	_expect(routes_variant is Dictionary, "SceneRouter exposes MAP_PATHS")
	if not routes_variant is Dictionary:
		return
	var routes: Dictionary = routes_variant
	for map_id: StringName in CAMPAIGN_ROUTE_IDS:
		var has_route := routes.has(map_id)
		_expect(has_route, "SceneRouter contains route %s" % String(map_id))
		if not has_route:
			continue
		var scene_path := String(routes[map_id])
		_expect(
			ResourceLoader.exists(scene_path, "PackedScene"),
			"route %s points to a loadable PackedScene" % String(map_id)
		)


func _check_chapter_two_spawn() -> void:
	var active_map := SceneRouter.get_active_map()
	var player := SceneRouter.get_player()
	_expect(active_map != null, "SceneRouter exposes the active Chapter 2 map")
	_expect(player != null, "SceneRouter exposes the main player")
	if active_map == null or player == null:
		return
	var spawn_points := active_map.get_node_or_null("SpawnPoints")
	_expect(spawn_points != null, "Chapter 2 creates SpawnPoints")
	if spawn_points == null:
		return
	var default_spawn := spawn_points.get_node_or_null(NodePath(String(GameIds.SPAWN_DEFAULT))) as Marker2D
	_expect(default_spawn != null, "Chapter 2 creates the default spawn marker")
	if default_spawn == null:
		return
	_expect(
		player.global_position.distance_to(default_spawn.global_position) <= 0.1,
		"player is placed at the Chapter 2 default spawn"
	)


func _wait_for_map(map_id: StringName) -> bool:
	var deadline := Time.get_ticks_msec() + MAP_LOAD_TIMEOUT_MS
	while Time.get_ticks_msec() < deadline:
		if GameState.current_map == map_id and SceneRouter.get_active_map() != null:
			return true
		await get_tree().process_frame
	return false


func _wait_for_router_idle() -> bool:
	var deadline := Time.get_ticks_msec() + MAP_LOAD_TIMEOUT_MS
	while Time.get_ticks_msec() < deadline:
		if not bool(SceneRouter.get("_transitioning")):
			return true
		await get_tree().process_frame
	return false


func _wait_for_chapter_two_intro() -> bool:
	var deadline := Time.get_ticks_msec() + 9000
	while Time.get_ticks_msec() < deadline:
		if _chapter_two_intro_finished:
			return true
		await get_tree().process_frame
	return false


func _on_tutorial_requested(step_id: StringName, _message: String) -> void:
	if step_id == StringName("%s_campaign_flow" % String(GameIds.MAP_CHAPTER_2)):
		_chapter_two_intro_finished = true


func _expect(condition: bool, message: String) -> void:
	_checks_run += 1
	if condition:
		_pass(message)
	else:
		_fail(message)


func _pass(message: String) -> void:
	print("[MAIN_CAMPAIGN_BOOT][PASS] %s" % message)


func _fail(message: String) -> void:
	_failures.append(message)
	push_error("[MAIN_CAMPAIGN_BOOT][FAIL] %s" % message)


func _finish() -> void:
	if _failures.is_empty():
		print("[MAIN_CAMPAIGN_BOOT][PASS] %d checks completed with no failures." % _checks_run)
		get_tree().quit(0)
		return
	print("[MAIN_CAMPAIGN_BOOT][SUMMARY] %d of %d checks failed:" % [_failures.size(), _checks_run])
	for failure: String in _failures:
		print("  - %s" % failure)
	get_tree().quit(1)
