class_name AriaMap2Npc
extends CharacterBody2D

signal encounter_state_changed(active: bool)

@export var display_name: String = "Aria"
@onready var sprite: Sprite2D = %Sprite
@onready var status_label: Label = %StatusLabel

var encounter_active: bool = false


func set_encounter_active(value: bool) -> void:
	encounter_active = value
	status_label.text = "Đang chiến đấu" if value else "Aria"
	encounter_state_changed.emit(value)


func face_target(target: Node2D) -> void:
	if target == null:
		return
	var horizontal_direction: float = signf(target.global_position.x - global_position.x)
	if not is_zero_approx(horizontal_direction):
		sprite.scale.x = absf(sprite.scale.x) * horizontal_direction


func mark_boss_defeated() -> void:
	set_encounter_active(false)
	status_label.text = "Aria · bị thương"
