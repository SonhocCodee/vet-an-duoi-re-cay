class_name CampaignChapterMap
extends Node2D

signal encounter_started(encounter_index: int)
signal encounter_completed(encounter_index: int)
signal moral_choice_requested(choice_id: StringName, options: Array[Dictionary])
signal moral_choice_recorded(choice_id: StringName, option_id: StringName)
signal boss_started
signal boss_defeated(boss_id: StringName)
signal chapter_completed(chapter_id: StringName)
signal dialogue_line_requested(dialogue_id: StringName, speaker: String, text: String)

const MAP_SIZE := Vector2(2200.0, 900.0)
const ENCOUNTER_POSITIONS: Array[Vector2] = [
	Vector2(480.0, 450.0), Vector2(930.0, 450.0), Vector2(1450.0, 450.0)
]
const GATE_X_POSITIONS: Array[float] = [710.0, 1180.0, 1680.0, 2070.0]
const BOSS_POSITION := Vector2(1910.0, 450.0)
const SHRINE_POSITION := Vector2(1080.0, 450.0)
const FALLBACK_ENEMY_SCENES: Dictionary = {
	&"mist_shade": "res://scenes/actors/enemies/mist_shade.tscn",
	&"root_wolf": "res://scenes/actors/enemies/root_wolf.tscn",
	&"weeping_mushroom": "res://scenes/actors/enemies/weeping_mushroom.tscn",
	&"root_antler_stag": "res://scenes/actors/enemies/root_antler_stag.tscn",
}
const CAMPAIGN_ENEMY_DATA_ALIASES: Dictionary = {
	&"drowned_axe_corpse": &"drowned_axeman",
	&"blind_spell_soldier": &"blind_battlemage",
	&"night_hunting_mist_owl": &"night_mist_owl",
}
const CAMPAIGN_BOSS_SCENE_ALIASES: Dictionary = {
	&"boss_drowned_bell_warden": &"boss_drowned_executioner",
	&"boss_blind_procession_marshal": &"boss_hollow_paladin",
	&"boss_erased_name_curator": &"boss_blind_archivist",
}
const GENERIC_CAMPAIGN_ENEMY_PATH := "res://scenes/actors/enemies/campaign/generic_campaign_enemy.tscn"


@export_file("*.tres") var chapter_resource_path: String = ""
@export var chapter_id: StringName = &"chapter_2_drowned_bells"
@export var auto_complete_on_boss_defeated := true
@export var play_intro_on_ready := true

var _chapter_definition: ChapterDefinition
var _profile: Dictionary = {}
var _chapter_number := 2
var _chapter_title := ""
var _intro_lines: Array[String] = []
var _completion_lines: Array[String] = []
var _moral_choice_flags: Array[StringName] = []
var _unlock_class_id: StringName
var _objective := ""
var _encounters: Array[Variant] = []
var _boss_definition: Variant
var _intro_dialogue_id: StringName
var _completion_dialogue_id: StringName
var _completion_flag: StringName
var _next_map_id: StringName
var _moral_choice_id: StringName
var _moral_options: Array[Dictionary] = []
var _reward_exp := 0
var _recommended_level := 1

var _spawn_points: Node2D
var _enemy_container: Node2D
var _encounter_zones: Array[Area2D] = []
var _gate_shapes: Array[CollisionShape2D] = []
var _gate_open: Array[bool] = [true, true, true, true]
var _moral_shrine: CampaignMoralShrine
var _boss_zone: Area2D
var _active_enemies: Dictionary = {}
var _active_encounter := -1
var _next_encounter := 0
var _moral_resolved := false
var _resolving_global_choice := false
var _boss_active := false
var _active_boss_id: StringName
var _completed := false
var _ground_color := Color("17242b")
var _path_color := Color("33434b")
var _accent_color := Color("6bc5bd")


func _ready() -> void:
	_load_chapter_data()
	if not GameEvents.moral_choice_resolved.is_connected(_on_global_moral_choice_resolved):
		GameEvents.moral_choice_resolved.connect(_on_global_moral_choice_resolved)
	_build_procedural_map()
	if play_intro_on_ready:
		call_deferred("_emit_intro")


func _draw() -> void:
	draw_rect(Rect2(Vector2.ZERO, MAP_SIZE), _ground_color)
	draw_colored_polygon(PackedVector2Array([
		Vector2(0.0, 330.0), Vector2(2200.0, 300.0), Vector2(2200.0, 610.0),
		Vector2(0.0, 580.0)
	]), _path_color)
	for index: int in range(ENCOUNTER_POSITIONS.size()):
		var zone_color := _accent_color
		zone_color.a = 0.11 if index >= _next_encounter else 0.04
		draw_circle(ENCOUNTER_POSITIONS[index], 150.0, zone_color)
		draw_arc(ENCOUNTER_POSITIONS[index], 126.0, 0.0, TAU, 48, Color(_accent_color, 0.35), 3.0)

	draw_circle(BOSS_POSITION, 210.0, Color(0.35, 0.08, 0.12, 0.16))
	draw_arc(BOSS_POSITION, 188.0, 0.0, TAU, 64, Color(0.82, 0.31, 0.32, 0.55), 5.0)
	for index: int in range(GATE_X_POSITIONS.size()):
		if _gate_open[index]:
			continue
		var gate_x := GATE_X_POSITIONS[index]
		draw_rect(Rect2(Vector2(gate_x - 11.0, 282.0), Vector2(22.0, 336.0)), Color(0.23, 0.72, 0.67, 0.68))

	for index: int in range(18):
		var x_position := 90.0 + float(index) * 122.0
		var top_height := 88.0 + float(index % 3) * 18.0
		draw_circle(Vector2(x_position, top_height), 46.0, Color(0.10, 0.18, 0.17, 0.9))
		draw_circle(Vector2(x_position + 35.0, 790.0 - float(index % 2) * 22.0), 52.0, Color(0.10, 0.17, 0.16, 0.92))


func resolve_moral_choice(option_id: StringName) -> void:
	if _moral_resolved or option_id.is_empty():
		return
	_moral_shrine.resolve(option_id)


func spawn_boss(enemy_id: StringName, spawn_position: Vector2 = BOSS_POSITION) -> Node2D:
	if _boss_active or enemy_id.is_empty():
		return null
	_boss_active = true
	_active_boss_id = enemy_id
	return _spawn_definition(enemy_id, spawn_position, true)


func complete_chapter() -> void:
	_complete_chapter()


func get_spawn_point(spawn_id: StringName = GameIds.SPAWN_DEFAULT) -> Marker2D:
	var marker := _spawn_points.get_node_or_null(NodePath(String(spawn_id))) as Marker2D
	if marker != null:
		return marker
	return _spawn_points.get_node(NodePath(String(GameIds.SPAWN_DEFAULT))) as Marker2D


func _load_chapter_data() -> void:
	_profile = _fallback_profile(chapter_id)
	if not chapter_resource_path.is_empty() and ResourceLoader.exists(chapter_resource_path):
		_chapter_definition = load(chapter_resource_path) as ChapterDefinition
	elif not chapter_resource_path.is_empty():
		push_warning("ChapterDefinition is not available yet: %s. Using campaign fallback profile." % chapter_resource_path)

	if _chapter_definition != null:
		var validation_errors := _chapter_definition.get_validation_errors()
		if not validation_errors.is_empty():
			push_warning("Invalid ChapterDefinition %s: %s" % [chapter_resource_path, ", ".join(validation_errors)])
		chapter_id = _chapter_definition.chapter_id
		_chapter_number = _chapter_definition.chapter_number
		_chapter_title = _chapter_definition.title
		_intro_lines = _chapter_definition.intro_lines.duplicate()
		_completion_lines = _chapter_definition.completion_lines.duplicate()
		_reward_exp = _chapter_definition.reward_exp
		_unlock_class_id = _chapter_definition.unlock_class_id
		_objective = _chapter_definition.objective
		_next_map_id = _normalize_next_map_id(_chapter_definition.next_map_id)
		_completion_flag = StringName("chapter_%d_complete" % _chapter_number)
		_moral_choice_id = _chapter_definition.moral_choice_id
		_moral_options = [
			{"id": &"a", "text": _chapter_definition.moral_option_a_text, "flag": _chapter_definition.moral_option_a_flag},
			{"id": &"b", "text": _chapter_definition.moral_option_b_text, "flag": _chapter_definition.moral_option_b_flag},
		]
		_moral_choice_flags = _chapter_definition.get_moral_choice_flags()
		_encounters.clear()
		for enemy_id_value: StringName in _chapter_definition.encounter_enemy_ids:
			_encounters.append(enemy_id_value)
		_boss_definition = _chapter_definition.boss_enemy_id
		_recommended_level = maxi(1, 2 + _chapter_number * 3)
		_ground_color = _chapter_definition.background_color
		if _chapter_definition.palette_colors.size() >= 3:
			_path_color = _chapter_definition.palette_colors[1]
			_accent_color = _chapter_definition.palette_colors[2]
		return

	chapter_id = StringName(_profile.get("chapter_id", chapter_id))
	_chapter_number = 3 if chapter_id == &"chapter_3_blind_procession" else 4 if chapter_id == &"chapter_4_erased_archive" else 2
	_chapter_title = String(chapter_id).replace("_", " ").capitalize()
	_intro_lines = ["Kael bước vào %s." % _chapter_title]
	_completion_lines = ["Con đường qua %s đã được mở." % _chapter_title]
	_completion_flag = StringName(_profile.get("completion_flag", StringName("%s_complete" % chapter_id)))
	_next_map_id = StringName(_profile.get("next_map_id", &""))
	_reward_exp = int(_profile.get("reward_exp", 0))
	_unlock_class_id = &""
	_objective = "Hoàn thành ba đợt giao tranh và đánh bại thủ lĩnh."
	_recommended_level = int(_profile.get("recommended_level", 1))
	_moral_choice_id = StringName(_profile.get("moral_choice_id", &"campaign_choice"))
	_moral_options = _dictionary_array(_profile.get("moral_options", []))
	_moral_choice_flags.clear()
	for option: Dictionary in _moral_options:
		_moral_choice_flags.append(StringName(option.get("flag", StringName("%s_%s" % [_moral_choice_id, option.get("id", &"option")]))))
	_encounters.clear()
	for encounter: Variant in (_profile.get("encounters", []) as Array):
		_encounters.append(encounter)
	_boss_definition = _profile.get("boss", {})
	var ground_value: Variant = _profile.get("ground_color", _ground_color)
	var path_value: Variant = _profile.get("path_color", _path_color)
	var accent_value: Variant = _profile.get("accent_color", _accent_color)
	if ground_value is Color:
		_ground_color = ground_value
	if path_value is Color:
		_path_color = path_value
	if accent_value is Color:
		_accent_color = accent_value

func _build_procedural_map() -> void:
	_spawn_points = Node2D.new()
	_spawn_points.name = "SpawnPoints"
	add_child(_spawn_points)
	var default_spawn := Marker2D.new()
	default_spawn.name = String(GameIds.SPAWN_DEFAULT)
	default_spawn.position = Vector2(130.0, 450.0)
	default_spawn.set_meta(&"spawn_id", GameIds.SPAWN_DEFAULT)
	_spawn_points.add_child(default_spawn)

	_enemy_container = Node2D.new()
	_enemy_container.name = "Enemies"
	add_child(_enemy_container)
	_build_boundaries()
	_build_encounter_zones()
	_build_gates()
	_build_moral_shrine()
	_build_boss_zone()
	_build_landmark()
	queue_redraw()


func _build_boundaries() -> void:
	var boundaries := StaticBody2D.new()
	boundaries.name = "WorldCollisions"
	boundaries.collision_layer = 1
	boundaries.collision_mask = 3
	add_child(boundaries)
	_add_rectangle_collision(boundaries, Vector2(1100.0, 266.0), Vector2(2240.0, 36.0))
	_add_rectangle_collision(boundaries, Vector2(1100.0, 634.0), Vector2(2240.0, 36.0))
	_add_rectangle_collision(boundaries, Vector2(-18.0, 450.0), Vector2(36.0, 404.0))
	_add_rectangle_collision(boundaries, Vector2(2218.0, 450.0), Vector2(36.0, 404.0))
	for obstacle_position: Vector2 in [Vector2(340.0, 350.0), Vector2(820.0, 555.0), Vector2(1320.0, 345.0), Vector2(1810.0, 565.0)]:
		_add_rectangle_collision(boundaries, obstacle_position, Vector2(70.0, 70.0))


func _build_encounter_zones() -> void:
	for index: int in range(3):
		var zone := Area2D.new()
		zone.name = "EncounterZone%d" % (index + 1)
		zone.position = ENCOUNTER_POSITIONS[index]
		zone.collision_layer = 64
		zone.collision_mask = 3
		var shape := CollisionShape2D.new()
		var rectangle := RectangleShape2D.new()
		rectangle.size = Vector2(190.0, 320.0)
		shape.shape = rectangle
		zone.add_child(shape)
		zone.body_entered.connect(_on_encounter_zone_entered.bind(index))
		add_child(zone)
		_encounter_zones.append(zone)


func _build_gates() -> void:
	for index: int in range(GATE_X_POSITIONS.size()):
		var gate := StaticBody2D.new()
		gate.name = "EncounterGate%d" % (index + 1)
		gate.position = Vector2(GATE_X_POSITIONS[index], 450.0)
		gate.collision_layer = 1
		gate.collision_mask = 3
		var gate_shape := _add_rectangle_collision(gate, Vector2.ZERO, Vector2(26.0, 336.0))
		gate_shape.disabled = true
		add_child(gate)
		_gate_shapes.append(gate_shape)


func _build_moral_shrine() -> void:
	_moral_shrine = CampaignMoralShrine.new()
	_moral_shrine.name = "MoralShrine"
	_moral_shrine.position = SHRINE_POSITION
	var shape := CollisionShape2D.new()
	var circle := CircleShape2D.new()
	circle.radius = 78.0
	shape.shape = circle
	_moral_shrine.add_child(shape)
	_moral_shrine.configure(_moral_choice_id, _moral_options, "Lắng nghe phán quyết của thánh tích")
	_moral_shrine.choice_requested.connect(_on_moral_choice_requested)
	_moral_shrine.choice_selected.connect(_on_moral_choice_selected)
	add_child(_moral_shrine)
	_moral_shrine.set_available(false)


func _build_boss_zone() -> void:
	_boss_zone = Area2D.new()
	_boss_zone.name = "BossArena"
	_boss_zone.position = BOSS_POSITION
	_boss_zone.collision_layer = 64
	_boss_zone.collision_mask = 3
	var shape := CollisionShape2D.new()
	var circle := CircleShape2D.new()
	circle.radius = 165.0
	shape.shape = circle
	_boss_zone.add_child(shape)
	_boss_zone.body_entered.connect(_on_boss_zone_entered)
	add_child(_boss_zone)


func _build_landmark() -> void:
	var filename := String(chapter_id) + ".svg"
	var path := "res://assets/placeholder/world/campaign/chapter2_4/%s" % filename
	if not ResourceLoader.exists(path):
		return
	var landmark := Sprite2D.new()
	landmark.name = "ChapterLandmark"
	landmark.position = Vector2(360.0, 205.0)
	landmark.texture = load(path) as Texture2D
	add_child(landmark)


func _emit_intro() -> void:
	await _emit_dialogue_sequence(_intro_lines, &"intro")
	GameEvents.tutorial_requested.emit(StringName("%s_campaign_flow" % chapter_id), _objective)


func _emit_dialogue_sequence(lines: Array[String], phase: StringName) -> void:
	for index: int in range(lines.size()):
		_emit_dialogue_line(phase, index, lines[index])
		await get_tree().create_timer(2.2).timeout


func _emit_dialogue_line(phase: StringName, line_index: int, text: String) -> void:
	if text.strip_edges().is_empty():
		return
	var dialogue_id := StringName("%s_%s_%02d" % [chapter_id, phase, line_index])
	dialogue_line_requested.emit(dialogue_id, "Kael", text)
	GameEvents.dialogue_requested.emit(StringName(text))

func _on_encounter_zone_entered(body: Node2D, encounter_index: int) -> void:
	if not _is_player(body) or encounter_index != _next_encounter or _active_encounter >= 0 or _boss_active:
		return
	if encounter_index == 2 and not _moral_resolved:
		GameEvents.tutorial_requested.emit(&"campaign_moral_required", "Hãy đưa ra lựa chọn tại thánh tích trước khi tiếp tục.")
		return
	_encounter_zones[encounter_index].set_deferred(&"monitoring", false)
	_active_encounter = encounter_index
	_set_gate_open(encounter_index, false)
	encounter_started.emit(encounter_index)
	_spawn_definition(_encounters[encounter_index], ENCOUNTER_POSITIONS[encounter_index], false)


func _on_boss_zone_entered(body: Node2D) -> void:
	if not _is_player(body) or _next_encounter < 3 or _active_encounter >= 0 or _boss_active or _completed:
		return
	_boss_active = true
	_active_boss_id = StringName(_normalize_enemy_spec(_boss_definition, true).get("enemy_id", &""))
	_boss_zone.set_deferred(&"monitoring", false)
	_set_gate_open(3, false)
	boss_started.emit()
	_emit_dialogue_line(&"boss_intro", 0, "Kẻ canh giữ %s đã thức tỉnh." % _chapter_title)
	_spawn_definition(_boss_definition, BOSS_POSITION, true)


func _spawn_definition(definition: Variant, center: Vector2, is_boss: bool) -> Node2D:
	_active_enemies.clear()
	var specs := _enemy_specs(definition, is_boss)
	var spawn_index := 0
	var first_spawned: Node2D
	for spec: Dictionary in specs:
		var count := maxi(1, int(spec.get("count", 1)))
		for _member: int in range(count):
			var enemy_scene := _resolve_enemy_scene(spec, is_boss)
			if enemy_scene == null:
				continue
			var enemy := enemy_scene.instantiate() as Node2D
			if enemy == null:
				continue
			var enemy_id_value := StringName(spec.get("enemy_id", &"root_antler_stag" if is_boss else &"mist_shade"))
			_set_property_if_present(enemy, &"combat_level", int(spec.get("level", _recommended_level)))
			_configure_campaign_enemy(enemy, enemy_id_value, is_boss)
			_enemy_container.add_child(enemy)
			if first_spawned == null:
				first_spawned = enemy
			var angle := TAU * float(spawn_index) / float(maxi(1, _total_enemy_count(specs)))
			enemy.global_position = center + Vector2.from_angle(angle) * (62.0 + float(spawn_index % 2) * 34.0)
			if enemy.has_method(&"set_target"):
				enemy.call(&"set_target", SceneRouter.get_player())
			var instance_id := enemy.get_instance_id()
			_active_enemies[instance_id] = true
			enemy.tree_exited.connect(_on_enemy_tree_exited.bind(instance_id), CONNECT_ONE_SHOT)
			spawn_index += 1

	if _active_enemies.is_empty():
		push_warning("No enemy scene could be resolved for %s." % chapter_id)
		call_deferred("_complete_active_combat")
	return first_spawned

func _on_enemy_tree_exited(instance_id: int) -> void:
	_active_enemies.erase(instance_id)
	if _active_enemies.is_empty():
		call_deferred("_complete_active_combat")


func _complete_active_combat() -> void:
	if _boss_active:
		_boss_active = false
		var defeated_boss_id := _active_boss_id
		_active_boss_id = &""
		boss_defeated.emit(defeated_boss_id)
		if auto_complete_on_boss_defeated:
			_complete_chapter()
		return
	if _active_encounter < 0:
		return
	var completed_index := _active_encounter
	_active_encounter = -1
	_next_encounter = completed_index + 1
	encounter_completed.emit(completed_index)
	if completed_index == 1:
		_moral_shrine.set_available(true)
		GameEvents.tutorial_requested.emit(&"campaign_moral_shrine", "Wave 2 đã kết thúc. Tương tác thánh tích và chọn 1 hoặc 2.")
	else:
		_set_gate_open(completed_index, true)


func _on_moral_choice_requested(choice_id_value: StringName, options_value: Array[Dictionary]) -> void:
	moral_choice_requested.emit(choice_id_value, options_value)
	GameEvents.moral_choice_requested.emit(choice_id_value, options_value)
	GameEvents.tutorial_requested.emit(&"campaign_moral_options", _format_choice_prompt(options_value))


func _on_global_moral_choice_resolved(choice_id_value: StringName, option_id: StringName) -> void:
	if choice_id_value != _moral_choice_id or _moral_resolved:
		return
	_resolving_global_choice = true
	_moral_shrine.resolve(option_id)
	_resolving_global_choice = false


func _on_moral_choice_selected(choice_id_value: StringName, option_id: StringName) -> void:
	if _moral_resolved:
		return
	_moral_resolved = true
	if GameState.has_method(&"record_choice"):
		GameState.call(&"record_choice", choice_id_value, option_id)
	var selected_flag := _choice_flag_for(option_id)
	if not selected_flag.is_empty() and GameState.has_method(&"set_flag"):
		GameState.call(&"set_flag", selected_flag, true)
	if not _resolving_global_choice:
		GameEvents.moral_choice_resolved.emit(choice_id_value, option_id)
	moral_choice_recorded.emit(choice_id_value, option_id)
	_set_gate_open(1, true)
	var selected_text := _choice_text_for(option_id)
	_emit_dialogue_line(&"moral_aftermath", 0, selected_text)


func _choice_flag_for(option_id: StringName) -> StringName:
	for option: Dictionary in _moral_options:
		if StringName(option.get("id", &"")) == option_id:
			return StringName(option.get("flag", &""))
	return StringName("%s_%s" % [_moral_choice_id, option_id])


func _choice_text_for(option_id: StringName) -> String:
	for option: Dictionary in _moral_options:
		if StringName(option.get("id", &"")) == option_id:
			return String(option.get("text", "Lựa chọn đã được ghi nhận."))
	return "Lựa chọn đã được ghi nhận."

func _complete_chapter() -> void:
	if _completed:
		return
	_completed = true
	_boss_active = false
	_set_gate_open(3, true)
	if GameState.has_method(&"gain_exp"):
		GameState.call(&"gain_exp", _reward_exp)
	if not _completion_flag.is_empty() and GameState.has_method(&"set_flag"):
		GameState.call(&"set_flag", _completion_flag, true)
	if not _unlock_class_id.is_empty() and GameState.has_method(&"set_flag"):
		GameState.call(&"set_flag", StringName("class_%s_unlocked" % _unlock_class_id), true)
	chapter_completed.emit(chapter_id)
	await _emit_dialogue_sequence(_completion_lines, &"completion")
	CampaignDirector.complete_chapter(_chapter_number, chapter_id, _next_map_id)

func _set_gate_open(gate_index: int, is_open: bool) -> void:
	if gate_index < 0 or gate_index >= _gate_shapes.size():
		return
	_gate_open[gate_index] = is_open
	_gate_shapes[gate_index].set_deferred(&"disabled", is_open)
	queue_redraw()


func _enemy_specs(definition: Variant, is_boss: bool) -> Array[Dictionary]:
	var specs: Array[Dictionary] = []
	var members: Variant = _value(definition, [&"enemies", &"members", &"enemy_entries"], null)
	if members is Array:
		for member: Variant in members:
			specs.append(_normalize_enemy_spec(member, is_boss))
		return specs
	var enemy_ids: Variant = _value(definition, [&"enemy_ids", &"enemy_types"], null)
	if enemy_ids is Array:
		var default_count := maxi(1, int(_value(definition, [&"count", &"enemy_count"], 1)))
		for enemy_id_value: Variant in enemy_ids:
			specs.append({"enemy_id": StringName(enemy_id_value), "count": default_count, "level": _recommended_level})
		return specs
	if definition is Array:
		for member: Variant in definition:
			specs.append(_normalize_enemy_spec(member, is_boss))
	else:
		specs.append(_normalize_enemy_spec(definition, is_boss))
	return specs


func _normalize_enemy_spec(source: Variant, is_boss: bool) -> Dictionary:
	if source is String or source is StringName:
		var text := String(source)
		return {"scene_path": text if text.ends_with(".tscn") else "", "enemy_id": StringName(text), "count": 1 if is_boss else clampi(_chapter_number, 3, 4), "level": _recommended_level}
	return {
		"enemy_id": StringName(_value(source, [&"enemy_id", &"id", &"enemy_type"], &"root_antler_stag" if is_boss else &"mist_shade")),
		"scene_path": String(_value(source, [&"scene_path", &"enemy_scene_path", &"packed_scene_path"], "")),
		"count": maxi(1, int(_value(source, [&"count", &"enemy_count", &"amount"], 1))),
		"level": maxi(1, int(_value(source, [&"level", &"combat_level", &"enemy_level"], _recommended_level))),
	}


func _resolve_enemy_scene(spec: Dictionary, is_boss: bool) -> PackedScene:
	var explicit_path := String(spec.get("scene_path", ""))
	if not explicit_path.is_empty() and ResourceLoader.exists(explicit_path):
		return load(explicit_path) as PackedScene
	var enemy_id_value := StringName(spec.get("enemy_id", &"root_antler_stag" if is_boss else &"mist_shade"))
	if is_boss:
		var boss_scene_id := StringName(CAMPAIGN_BOSS_SCENE_ALIASES.get(enemy_id_value, enemy_id_value))
		var boss_path := "res://scenes/actors/enemies/campaign/%s.tscn" % String(boss_scene_id)
		if ResourceLoader.exists(boss_path):
			return load(boss_path) as PackedScene
	var campaign_path := "res://scenes/actors/enemies/campaign/%s.tscn" % String(enemy_id_value)
	if ResourceLoader.exists(campaign_path):
		return load(campaign_path) as PackedScene
	if ResourceLoader.exists(_campaign_enemy_data_path(enemy_id_value)) and ResourceLoader.exists(GENERIC_CAMPAIGN_ENEMY_PATH):
		return load(GENERIC_CAMPAIGN_ENEMY_PATH) as PackedScene
	var fallback_id := _fallback_enemy_id(enemy_id_value, is_boss)
	var fallback_path := String(FALLBACK_ENEMY_SCENES[fallback_id])
	return load(fallback_path) as PackedScene if ResourceLoader.exists(fallback_path) else null


func _configure_campaign_enemy(enemy: Node2D, enemy_id_value: StringName, is_boss: bool) -> void:
	var data_path := _campaign_enemy_data_path(enemy_id_value)
	if ResourceLoader.exists(data_path):
		_set_property_if_present(enemy, &"data", load(data_path))
	if is_boss:
		_set_property_if_present(enemy, &"force_elite", true)
		_set_property_if_present(enemy, &"elite_roll_enabled", false)


func _campaign_enemy_data_path(enemy_id_value: StringName) -> String:
	var data_id := StringName(CAMPAIGN_ENEMY_DATA_ALIASES.get(enemy_id_value, enemy_id_value))
	return "res://resources/enemies/campaign/%s.tres" % String(data_id)

func _fallback_enemy_id(enemy_id_value: StringName, is_boss: bool) -> StringName:
	if is_boss:
		return &"root_antler_stag"
	var lowered := String(enemy_id_value).to_lower()
	if "wolf" in lowered or "hound" in lowered or "beast" in lowered:
		return &"root_wolf"
	if "mushroom" in lowered or "drowned" in lowered or "bell" in lowered:
		return &"weeping_mushroom"
	if "stag" in lowered or "antler" in lowered:
		return &"root_antler_stag"
	return &"mist_shade"


func _total_enemy_count(specs: Array[Dictionary]) -> int:
	var total := 0
	for spec: Dictionary in specs:
		total += maxi(1, int(spec.get("count", 1)))
	return total


func _set_property_if_present(target: Object, property_name: StringName, value: Variant) -> void:
	for property: Dictionary in target.get_property_list():
		if StringName(property.get("name", &"")) == property_name:
			target.set(property_name, value)
			return


func _value(source: Variant, keys: Array[StringName], fallback: Variant) -> Variant:
	if source == null:
		return fallback
	if source is Dictionary:
		for key: StringName in keys:
			if (source as Dictionary).has(key):
				return (source as Dictionary)[key]
			if (source as Dictionary).has(String(key)):
				return (source as Dictionary)[String(key)]
		return fallback
	if source is Object:
		var property_names: Dictionary = {}
		for property: Dictionary in (source as Object).get_property_list():
			property_names[StringName(property.get("name", &""))] = true
		for key: StringName in keys:
			if property_names.has(key):
				return (source as Object).get(key)
	return fallback


func _dictionary_array(source: Variant) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	if source is not Array:
		return result
	for entry: Variant in source:
		if entry is Dictionary:
			result.append((entry as Dictionary).duplicate(true))
		else:
			result.append({
				"id": StringName(_value(entry, [&"id", &"option_id", &"choice_id"], &"option")),
				"text": String(_value(entry, [&"text", &"label", &"description"], "Lựa chọn")),
			})
	return result


func _format_choice_prompt(options_value: Array[Dictionary]) -> String:
	var parts: PackedStringArray = []
	for index: int in range(mini(options_value.size(), 2)):
		parts.append("%d: %s" % [index + 1, String(options_value[index].get("text", "Lựa chọn"))])
	return " · ".join(parts)


func _add_rectangle_collision(parent: StaticBody2D, center: Vector2, size: Vector2) -> CollisionShape2D:
	var shape := CollisionShape2D.new()
	shape.position = center
	var rectangle := RectangleShape2D.new()
	rectangle.size = size
	shape.shape = rectangle
	parent.add_child(shape)
	return shape


func _is_player(body: Node) -> bool:
	return body is PlayerController or body.is_in_group(&"player") or body.name == &"Player"


func _normalize_next_map_id(raw_map_id: StringName) -> StringName:
	var map_text := String(raw_map_id)
	if map_text.begins_with("map_"):
		var normalized := StringName(map_text.trim_prefix("map_"))
		if GameIds.CAMPAIGN_MAPS.has(normalized):
			return normalized
	return raw_map_id

func _fallback_profile(requested_chapter_id: StringName) -> Dictionary:
	match requested_chapter_id:
		&"chapter_3_blind_procession":
			return {
				"chapter_id": &"chapter_3_blind_procession",
				"intro_dialogue_id": &"chapter_3_blind_procession_intro",
				"completion_dialogue_id": &"chapter_3_blind_procession_complete",
				"completion_flag": &"chapter_3_complete",
				"next_map_id": &"chapter_4_erased_archive",
				"reward_exp": 900,
				"recommended_level": 14,
				"moral_choice_id": &"chapter_3_procession_judgement",
				"moral_options": [{"id": &"guide", "text": "Dẫn đoàn linh hồn qua màn sương"}, {"id": &"release", "text": "Phá nghi thức và giải thoát họ"}],
				"encounters": [
					{"enemies": [{"enemy_id": &"campaign_blind_acolyte", "count": 3}]},
					{"enemies": [{"enemy_id": &"campaign_procession_hound", "count": 3}]},
					{"enemies": [{"enemy_id": &"campaign_veiled_scribe", "count": 4}]},
				],
				"boss": {"enemy_id": &"campaign_blind_hierophant", "count": 1, "level": 16},
				"ground_color": Color("171923"), "path_color": Color("353342"), "accent_color": Color("b2a0dc"),
			}
		&"chapter_4_erased_archive":
			return {
				"chapter_id": &"chapter_4_erased_archive",
				"intro_dialogue_id": &"chapter_4_erased_archive_intro",
				"completion_dialogue_id": &"chapter_4_erased_archive_complete",
				"completion_flag": &"chapter_4_complete",
				"next_map_id": &"chapter_5_white_desert",
				"reward_exp": 1400,
				"recommended_level": 20,
				"moral_choice_id": &"chapter_4_forbidden_record",
				"moral_options": [{"id": &"restore", "text": "Khôi phục tên những người bị xóa"}, {"id": &"seal", "text": "Niêm phong ký ức để bảo vệ người sống"}],
				"encounters": [
					{"enemies": [{"enemy_id": &"campaign_ink_wraith", "count": 4}]},
					{"enemies": [{"enemy_id": &"campaign_archive_guardian", "count": 3}]},
					{"enemies": [{"enemy_id": &"campaign_erased_scholar", "count": 4}]},
				],
				"boss": {"enemy_id": &"campaign_redacted_curator", "count": 1, "level": 22},
				"ground_color": Color("211b18"), "path_color": Color("463b32"), "accent_color": Color("d8ae71"),
			}
		_:
			return {
				"chapter_id": &"chapter_2_drowned_bells",
				"intro_dialogue_id": &"chapter_2_drowned_bells_intro",
				"completion_dialogue_id": &"chapter_2_drowned_bells_complete",
				"completion_flag": &"chapter_2_complete",
				"next_map_id": &"chapter_3_blind_procession",
				"reward_exp": 500,
				"recommended_level": 8,
				"moral_choice_id": &"chapter_2_drowned_bell_oath",
				"moral_options": [{"id": &"ring", "text": "Đánh chuông để gọi tên người chết"}, {"id": &"silence", "text": "Giữ chuông im lặng để bảo vệ làng"}],
				"encounters": [
					{"enemies": [{"enemy_id": &"campaign_drowned_pilgrim", "count": 3}]},
					{"enemies": [{"enemy_id": &"campaign_bell_mire_hound", "count": 3}]},
					{"enemies": [{"enemy_id": &"campaign_sunken_cantor", "count": 4}]},
				],
				"boss": {"enemy_id": &"campaign_drowned_bell_keeper", "count": 1, "level": 10},
				"ground_color": Color("14252a"), "path_color": Color("30474a"), "accent_color": Color("5fc7c4"),
			}







