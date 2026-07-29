class_name CitySceneIntegrator
extends Node2D
const TextureLoader = preload("res://scripts/visuals/second_wave/second_wave_texture_loader.gd")


const NPC_SCENE_PATH := "res://scenes/npcs/city_npc.tscn"
const NPC_CONTROLLER_PATH := "res://scripts/npc/npc_controller.gd"
const FALLBACK_CONTROLLER_PATH := "res://scripts/visuals/second_wave/npc_fallback_controller.gd"
const NPC_IDS: PackedStringArray = [
	"alden_blacksmith", "mira_apothecary", "father_oren", "lysa_baker", "tomas_guard",
	"neris_cartographer", "gareth_stablemaster", "maela_weaver", "borin_mason", "ivy_orphan",
	"cedric_archivist", "helena_innkeeper", "oswin_fisher", "rosalind_midwife", "silas_gravedigger",
	"yvette_jeweler", "damian_scribe", "freya_hunter", "rowan_watch_captain", "elric_beggar_prophet",
]

@export var layout: CityLayoutDefinition
@onready var background: Sprite2D = $Background
@onready var buildings_root: Node2D = $Buildings
@onready var props_root: Node2D = $Props
@onready var npc_root: Node2D = $NPCs
@onready var target_root: Node2D = $NavigationTargets


func _ready() -> void:
	if layout == null:
		layout = load("res://resources/content/city/ashen_city_layout.tres") as CityLayoutDefinition
	_apply_background()
	_ensure_navigation()
	_build_navigation_targets()
	_build_decorations(layout.buildings, buildings_root, true)
	_build_decorations(layout.props, props_root, false)
	call_deferred(&"_spawn_npcs_after_navigation_sync")


func _ensure_navigation() -> void:
	var region := get_node_or_null(^"NavigationRegion2D") as NavigationRegion2D
	if region == null:
		return
	var polygon := NavigationPolygon.new()
	polygon.vertices = PackedVector2Array([Vector2(24.0, 24.0), Vector2(2176.0, 24.0), Vector2(2176.0, 876.0), Vector2(24.0, 876.0)])
	polygon.add_polygon(PackedInt32Array([0, 1, 2, 3]))
	region.navigation_polygon = polygon


func get_npc_count() -> int:
	return npc_root.get_child_count()


func get_navigation_target(target_id: StringName) -> Vector2:
	var marker := target_root.get_node_or_null(NodePath(String(target_id))) as Marker2D
	return marker.global_position if marker != null else Vector2(1100.0, 450.0)


func _apply_background() -> void:
	if layout == null:
		return
	background.texture = TextureLoader.load_texture(layout.background_path)
	background.position = layout.bounds.position + layout.bounds.size * 0.5
	if background.texture != null:
		var texture_size := background.texture.get_size()
		if texture_size.x > 0.0 and texture_size.y > 0.0:
			background.scale = layout.bounds.size / texture_size


func _build_navigation_targets() -> void:
	for entry: Dictionary in layout.navigation_targets:
		var marker := Marker2D.new()
		marker.name = String(entry.get("id", "target"))
		marker.position = entry.get("position", Vector2.ZERO)
		target_root.add_child(marker)
		var schedule_service := get_node_or_null(^"/root/CityScheduleService")
		if schedule_service != null and schedule_service.has_method(&"register_target"):
			schedule_service.call(&"register_target", StringName(marker.name), marker)


func _build_decorations(entries: Array[Dictionary], parent: Node2D, solid: bool) -> void:
	for entry: Dictionary in entries:
		var holder := Node2D.new()
		holder.name = String(entry.get("id", "decoration"))
		holder.position = entry.get("position", Vector2.ZERO)
		var sprite := Sprite2D.new()
		var asset_path := String(entry.get("asset", ""))
		sprite.texture = TextureLoader.load_texture(asset_path)
		if sprite.texture != null:
			var target_size: Vector2 = entry.get("size", Vector2(180.0, 120.0))
			if sprite.texture != null and sprite.texture.get_size().x > 0.0:
				sprite.scale = target_size / sprite.texture.get_size()
		holder.add_child(sprite)
		if solid:
			var body := StaticBody2D.new()
			body.collision_layer = 1
			body.collision_mask = 0
			var shape_node := CollisionShape2D.new()
			var shape := RectangleShape2D.new()
			shape.size = entry.get("collision_size", Vector2(150.0, 70.0))
			shape_node.position = entry.get("collision_offset", Vector2(0.0, 20.0))
			shape_node.shape = shape
			body.add_child(shape_node)
			holder.add_child(body)
			var obstacle := NavigationObstacle2D.new()
			obstacle.avoidance_enabled = true
			obstacle.radius = maxf(shape.size.x, shape.size.y) * 0.42
			holder.add_child(obstacle)
		parent.add_child(holder)


func _spawn_npcs_after_navigation_sync() -> void:
	await get_tree().physics_frame
	await get_tree().process_frame
	_spawn_npcs()


func _spawn_npcs() -> void:
	if not ResourceLoader.exists(NPC_SCENE_PATH):
		return
	var packed := load(NPC_SCENE_PATH) as PackedScene
	var controller_script: Script = load(NPC_CONTROLLER_PATH) as Script if ResourceLoader.exists(NPC_CONTROLLER_PATH) else load(FALLBACK_CONTROLLER_PATH) as Script
	for index: int in NPC_IDS.size():
		var npc_id := StringName(NPC_IDS[index])
		var actor := packed.instantiate() as CharacterBody2D
		actor.name = String(npc_id)
		actor.set_script(controller_script)
		actor.set_meta(&"npc_id", npc_id)
		actor.position = _spawn_position(index)
		_configure_actor_visual(actor, npc_id)
		npc_root.add_child(actor)
		var data_path := "res://resources/npcs/%s.tres" % String(npc_id)
		if ResourceLoader.exists(data_path) and actor.has_method(&"configure"):
			var npc_data := load(data_path)
			actor.call(&"configure", npc_data)
			var nameplate := actor.get_node_or_null(^"Nameplate") as Label
			if nameplate != null:
				nameplate.text = "%s — %s" % [String(npc_data.get("display_name")), String(npc_data.get("profession"))]
			var interaction := actor.get_node_or_null(^"InteractionArea") as Interactable
			if interaction != null:
				interaction.prompt_text = "Nói chuyện với %s" % String(npc_data.get("display_name"))
		if actor.has_signal(&"npc_interacted"):
			actor.connect(&"npc_interacted", _on_npc_interacted)
		_register_schedule(actor)
		var dialogue_bridge := get_node_or_null(^"DialogueBridge")
		if dialogue_bridge != null and dialogue_bridge.has_method(&"bind_npc"):
			dialogue_bridge.call(&"bind_npc", actor)


func _configure_actor_visual(actor: CharacterBody2D, npc_id: StringName) -> void:
	var animated := actor.get_node_or_null(^"AnimatedSprite2D") as AnimatedActorSprite
	if animated == null:
		return
	animated.actor_id = npc_id
	animated.asset_directory = _npc_asset_directory(String(npc_id))


func _register_schedule(actor: Node) -> void:
	if actor.has_method(&"refresh_schedule"):
		actor.call_deferred(&"refresh_schedule", true)


func _on_npc_interacted(npc_id: StringName) -> void:
	if GameEvents.has_signal(&"npc_dialogue_requested"):
		GameEvents.emit_signal(&"npc_dialogue_requested", npc_id)
	else:
		GameEvents.dialogue_requested.emit(npc_id)


func _spawn_position(index: int) -> Vector2:
	if layout != null and index < layout.npc_spawns.size():
		return layout.npc_spawns[index].get("position", Vector2(1100.0, 450.0))
	var column := index % 5
	var row := index / 5
	return Vector2(520.0 + column * 260.0, 250.0 + row * 150.0)


func _npc_asset_directory(npc_id: String) -> String:
	var index := NPC_IDS.find(npc_id)
	if index < 7:
		return "res://assets/art/npcs/set_d/%s" % npc_id
	if index < 14:
		return "res://assets/art/npcs/set_e/%s" % npc_id
	return "res://assets/art/npcs/set_f/%s" % npc_id
