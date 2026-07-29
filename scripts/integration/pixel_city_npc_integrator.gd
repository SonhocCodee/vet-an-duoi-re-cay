class_name PixelCityNpcIntegrator
extends Node

const NPC_SCENE := preload("res://scenes/npcs/city_npc.tscn")
const NPC_CONTROLLER := preload("res://scripts/npc/npc_controller.gd")
const DIALOGUE_BRIDGE := preload("res://scripts/ui/gameplay/npc_dialogue_bridge.gd")
const NPC_IDS: PackedStringArray = [
	"alden_blacksmith", "mira_apothecary", "father_oren", "lysa_baker", "tomas_guard",
	"neris_cartographer", "gareth_stablemaster", "maela_weaver", "borin_mason", "ivy_orphan",
	"cedric_archivist", "helena_innkeeper", "oswin_fisher", "rosalind_midwife", "silas_gravedigger",
	"yvette_jeweler", "damian_scribe", "freya_hunter", "rowan_watch_captain", "elric_beggar_prophet",
]

@export var city_core_path: NodePath = ^"../CityCore"


func _ready() -> void:
	await get_tree().physics_frame
	await get_tree().physics_frame
	await get_tree().process_frame
	var city_core := get_node_or_null(city_core_path)
	if city_core == null:
		push_error("Pixel city NPC integrator cannot find CityCore")
		return
	var dialogue_bridge := DIALOGUE_BRIDGE.new() as NpcDialogueBridge
	dialogue_bridge.name = "DialogueBridge"
	add_child(dialogue_bridge)
	_register_schedule_targets(city_core)
	_spawn_npcs(city_core, dialogue_bridge)


func _register_schedule_targets(city_core: Node) -> void:
	var patrol_root := city_core.get_node_or_null(^"PatrolPoints")
	var service := get_node_or_null(^"/root/CityScheduleService")
	if patrol_root == null or service == null:
		return
	var target_ids: Array[StringName] = []
	for npc_id: String in NPC_IDS:
		var data := _load_npc_data(npc_id)
		if data == null:
			continue
		if not target_ids.has(data.district_id):
			target_ids.append(data.district_id)
		for entry: NpcScheduleEntry in data.schedule:
			if entry != null and not target_ids.has(entry.target_id):
				target_ids.append(entry.target_id)
	var patrols := patrol_root.get_children()
	for index in target_ids.size():
		if patrols.is_empty():
			break
		service.call(&"register_target", target_ids[index], patrols[index % patrols.size()])


func _spawn_npcs(city_core: Node, dialogue_bridge: NpcDialogueBridge) -> void:
	var spawn_root := city_core.get_node_or_null(^"NpcSpawnPoints")
	var y_sort_root := city_core.get_node_or_null(^"YSortWorld")
	if spawn_root == null or y_sort_root == null:
		return
	var spawn_points := spawn_root.get_children()
	for index in mini(NPC_IDS.size(), spawn_points.size()):
		var npc_id := NPC_IDS[index]
		var actor := NPC_SCENE.instantiate() as CharacterBody2D
		actor.name = npc_id
		actor.set_meta(&"npc_id", StringName(npc_id))
		actor.set_script(NPC_CONTROLLER)
		var sprite := actor.get_node_or_null(^"AnimatedSprite2D")
		if sprite != null:
			sprite.set("npc_id", StringName(npc_id))
		y_sort_root.add_child(actor)
		actor.global_position = (spawn_points[index] as Marker2D).global_position
		var data := _load_npc_data(npc_id)
		if data != null:
			actor.call(&"configure", data)
			var nameplate := actor.get_node_or_null(^"Nameplate") as Label
			if nameplate != null:
				nameplate.text = "%s — %s" % [data.display_name, data.profession]
			var interaction := actor.get_node_or_null(^"InteractionArea") as Interactable
			if interaction != null:
				interaction.prompt_text = "Nói chuyện với %s" % data.display_name
		dialogue_bridge.bind_npc(actor as NpcController)


func _load_npc_data(npc_id: String) -> NpcData:
	var path := "res://resources/npcs/%s.tres" % npc_id
	return load(path) as NpcData if ResourceLoader.exists(path) else null
