class_name DamagePacket
extends RefCounted

enum DamageType {
	PHYSICAL,
	MAGICAL,
	TRUE,
	HOLY,
}

var amount: float
var damage_type: DamageType
var source: Node
var hit_direction: Vector2
var knockback_force: float
var action_id: StringName


func _init(
	p_amount: float = 0.0,
	p_damage_type: DamageType = DamageType.PHYSICAL,
	p_source: Node = null,
	p_hit_direction: Vector2 = Vector2.ZERO,
	p_knockback_force: float = 0.0,
	p_action_id: StringName = &""
) -> void:
	amount = maxf(p_amount, 0.0)
	damage_type = p_damage_type
	source = p_source
	hit_direction = p_hit_direction.normalized()
	knockback_force = maxf(p_knockback_force, 0.0)
	action_id = p_action_id
