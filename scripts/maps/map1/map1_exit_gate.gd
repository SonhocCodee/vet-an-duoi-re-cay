extends Area2D
class_name Map1ExitGate

signal unlocked
signal transition_requested

const OPEN_TEXTURE := preload("res://assets/placeholder/world/map1/forest_gate_open.svg")

@onready var gate_sprite: Sprite2D = $Sprite2D
@onready var blocker_shape: CollisionShape2D = $Blocker/CollisionShape2D

var _is_unlocked := false
var _transition_started := false


func _ready() -> void:
	body_entered.connect(_on_body_entered)


func open() -> void:
	if _is_unlocked:
		return
	_is_unlocked = true
	gate_sprite.texture = OPEN_TEXTURE
	blocker_shape.set_deferred("disabled", true)
	unlocked.emit()


func is_unlocked() -> bool:
	return _is_unlocked


func _on_body_entered(body: Node2D) -> void:
	if not _is_unlocked or _transition_started or body is not PlayerController:
		return
	_transition_started = true
	GameState.set_flag(GameIds.FLAG_MAP_1_COMPLETE)
	transition_requested.emit()
	GameEvents.map_change_requested.emit(GameIds.MAP_2, GameIds.SPAWN_DEFAULT)

