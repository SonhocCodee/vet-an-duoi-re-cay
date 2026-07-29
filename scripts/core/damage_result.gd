class_name DamageResult
extends RefCounted

var requested_damage: float
var applied_damage: float
var blocked_damage: float
var remaining_health: float
var was_avoided: bool
var was_staggered: bool
var was_critical: bool
var was_ignored: bool
var killed: bool
var was_killed: bool
var killed_target: bool

func _init(
	p_requested_damage: float = 0.0,
	p_applied_damage: float = 0.0,
	p_remaining_health: float = 0.0,
	p_state_flag: bool = false,
	p_killed: bool = false
) -> void:
	requested_damage = maxf(p_requested_damage, 0.0)
	applied_damage = maxf(p_applied_damage, 0.0)
	blocked_damage = maxf(requested_damage - applied_damage, 0.0)
	remaining_health = maxf(p_remaining_health, 0.0)
	was_avoided = p_state_flag
	was_staggered = p_state_flag
	was_critical = false
	was_ignored = p_state_flag and is_zero_approx(applied_damage)
	killed = p_killed
	was_killed = p_killed
	killed_target = p_killed
