class_name DamageResult
extends RefCounted

var requested_damage: float
var applied_damage: float
var remaining_health: float
var was_staggered: bool
var was_killed: bool


func _init(
	p_requested_damage: float = 0.0,
	p_applied_damage: float = 0.0,
	p_remaining_health: float = 0.0,
	p_was_staggered: bool = false,
	p_was_killed: bool = false
) -> void:
	requested_damage = p_requested_damage
	applied_damage = p_applied_damage
	remaining_health = p_remaining_health
	was_staggered = p_was_staggered
	was_killed = p_was_killed
