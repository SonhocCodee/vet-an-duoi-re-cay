extends Interactable
class_name Map1RunePillar

signal weapon_granted(weapon_id: StringName)

const WEAPON_ID: StringName = &"rootbound_sword"
const ACTIVE_TEXTURE := preload("res://assets/placeholder/world/map1/rune_pillar_active.svg")

@export var story: Map1StoryResource
@onready var pillar_sprite: Sprite2D = $Sprite2D

var _activated := false
var _nearby_player: PlayerController


func _ready() -> void:
	prompt_text = story.pillar_prompt
	interacted.connect(_on_interacted)
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	if GameState.has_flag(GameIds.FLAG_WEAPON_UNLOCKED):
		restore_activated()


func _unhandled_input(event: InputEvent) -> void:
	if _activated or _nearby_player == null or not event.is_action_pressed(&"interact"):
		return
	interact(_nearby_player)
	get_viewport().set_input_as_handled()


func activate(player: PlayerController) -> void:
	if _activated:
		return
	player.grant_weapon()
	GameState.set_flag(GameIds.FLAG_WEAPON_UNLOCKED)
	_activated = true
	enabled = false
	pillar_sprite.texture = ACTIVE_TEXTURE
	GameEvents.interaction_prompt_changed.emit("", false)
	weapon_granted.emit(WEAPON_ID)


func restore_activated() -> void:
	_activated = true
	enabled = false
	pillar_sprite.texture = ACTIVE_TEXTURE


func is_activated() -> bool:
	return _activated


func _on_interacted(actor: Node) -> void:
	if actor is not PlayerController:
		return
	activate(actor as PlayerController)


func _on_body_entered(body: Node2D) -> void:
	if _activated or body is not PlayerController:
		return
	_nearby_player = body as PlayerController
	GameEvents.interaction_prompt_changed.emit(prompt_text, true)


func _on_body_exited(body: Node2D) -> void:
	if body != _nearby_player:
		return
	_nearby_player = null
	GameEvents.interaction_prompt_changed.emit("", false)
