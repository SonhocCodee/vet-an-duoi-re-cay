class_name AriaMap2Npc
extends CharacterBody2D

signal encounter_state_changed(active: bool)

@export var display_name: String = "Aria"
@onready var sprite: AnimatedSprite2D = %Sprite
@onready var status_label: Label = %StatusLabel

var encounter_active: bool = false


func set_encounter_active(value: bool) -> void:
	encounter_active = value
	status_label.text = "Đang chiến đấu" if value else "Aria"
	if value and sprite.has_method(&"play_action"):
		sprite.call(&"play_action", &"interact", 0.5)
	encounter_state_changed.emit(value)


func face_target(target: Node2D) -> void:
	if target == null:
		return
	var direction := global_position.direction_to(target.global_position)
	if sprite.has_method(&"set_facing_direction"):
		sprite.call(&"set_facing_direction", direction)


func mark_boss_defeated() -> void:
	set_encounter_active(false)
	status_label.text = "Aria · bị thương"
	if sprite.has_method(&"play_hurt"):
		sprite.call(&"play_hurt")
