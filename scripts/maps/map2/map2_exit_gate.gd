class_name Map2ExitGate
extends Node2D

signal exit_requested(destination_scene: String, spawn_id: StringName)

@export_file("*.tscn") var destination_scene: String = "res://scenes/maps/map3_ashen_town_hub.tscn"
@export var destination_spawn_id: StringName = &"FromMap2"
@onready var barrier_collision: CollisionShape2D = %BarrierCollision
@onready var barrier_visual: CanvasItem = %BarrierVisual
@onready var exit_area: Area2D = %ExitArea

var is_open: bool = false


func _ready() -> void:
	exit_area.body_entered.connect(_on_exit_body_entered)
	set_open(false)


func set_open(value: bool) -> void:
	is_open = value
	barrier_collision.set_deferred(&"disabled", value)
	barrier_visual.visible = not value
	exit_area.set_deferred(&"monitoring", value)


func _on_exit_body_entered(body: Node2D) -> void:
	if not is_open:
		return
	if body.is_in_group(&"player") or body.name == &"Player" or body.name == &"PlayerController":
		exit_requested.emit(destination_scene, destination_spawn_id)
