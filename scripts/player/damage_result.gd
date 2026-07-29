class_name DamageResult
extends RefCounted

var requested_damage: float
var applied_damage: float
var remaining_health: float
var was_avoided: bool
var killed: bool


func _init(
	p_requested_damage: float = 0.0,
	p_applied_damage: float = 0.0,
	p_remaining_health: float = 0.0,
	p_was_avoided: bool = false,
	p_killed: bool = false
) -> void:
	requested_damage = maxf(p_requested_damage, 0.0)
	applied_damage = maxf(p_applied_damage, 0.0)
	remaining_health = maxf(p_remaining_health, 0.0)
	was_avoided = p_was_avoided
	killed = p_killed
