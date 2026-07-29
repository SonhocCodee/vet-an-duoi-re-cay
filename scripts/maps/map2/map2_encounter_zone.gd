class_name Map2EncounterZone
extends Area2D

signal activated(encounter_index: int)

@export_range(0, 3, 1) var encounter_index: int = 0
var _consumed: bool = false


func _ready() -> void:
	body_entered.connect(_on_body_entered)


func set_consumed(value: bool) -> void:
	_consumed = value
	monitoring = not value


func _on_body_entered(body: Node2D) -> void:
	if _consumed or not _is_player(body):
		return
	activated.emit(encounter_index)


func _is_player(body: Node) -> bool:
	return body.is_in_group(&"player") or body.name == &"Player" or body.name == &"PlayerController"
