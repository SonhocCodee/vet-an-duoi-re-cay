extends Interactable
class_name Map1RunePillar

signal weapon_granted(weapon_id: StringName)

const WEAPON_ID: StringName = &"rootbound_sword"
const ACTIVE_TEXTURE := preload("res://assets/placeholder/world/map1/rune_pillar_active.svg")

@export var story: Map1StoryResource
@onready var pillar_sprite: Sprite2D = $Sprite2D

var _activated := false


func _ready() -> void:
	prompt_text = story.pillar_prompt
	interacted.connect(_on_interacted)
	if GameState.has_flag(GameIds.FLAG_WEAPON_UNLOCKED):
		restore_activated()


func activate(player: PlayerController) -> void:
	if _activated:
		return
	player.grant_weapon(WEAPON_ID)
	GameState.set_flag(GameIds.FLAG_WEAPON_UNLOCKED)
	_activated = true
	enabled = false
	pillar_sprite.texture = ACTIVE_TEXTURE
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
