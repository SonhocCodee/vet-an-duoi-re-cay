extends Node2D
class_name Map1AwakeningForest

const MAP_ID: StringName = &"map1_awakening_forest"
const SPAWN_DEFAULT: StringName = &"default"
const SPAWN_FROM_MAP_2: StringName = &"from_map2"

@onready var spawn_points: Node2D = $SpawnPoints
@onready var rune_pillar: Map1RunePillar = $Gameplay/RunePillar
@onready var exit_gate: Map1ExitGate = $Gameplay/ExitGate
@onready var story_director: Map1StoryDirector = $StoryDirector


func _ready() -> void:
	story_director.bind_pillar(rune_pillar)
	rune_pillar.weapon_granted.connect(_on_weapon_granted)
	if GameState.has_flag(GameIds.FLAG_WEAPON_UNLOCKED):
		exit_gate.open()


func get_spawn_point(spawn_id: StringName = SPAWN_DEFAULT) -> Marker2D:
	var marker := spawn_points.get_node_or_null(NodePath(String(spawn_id))) as Marker2D
	if marker != null:
		return marker
	push_warning("Unknown Map 1 spawn '%s'; falling back to default." % spawn_id)
	return spawn_points.get_node(NodePath(String(SPAWN_DEFAULT))) as Marker2D


func get_spawn_position(spawn_id: StringName = SPAWN_DEFAULT) -> Vector2:
	return get_spawn_point(spawn_id).global_position


func _on_weapon_granted(_weapon_id: StringName) -> void:
	exit_gate.open()
