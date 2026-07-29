class_name DamagePacket
extends RefCounted

enum DamageType {
	PHYSICAL,
	MAGICAL,
	VOID,
	TRUE,
}

var amount: float
var damage_type: DamageType
var source: Node
var source_position: Vector2
var stagger_power: float
var ignore_defense: bool


func _init(
	p_amount: float = 0.0,
	p_damage_type: DamageType = DamageType.PHYSICAL,
	p_source: Node = null,
	p_source_position: Vector2 = Vector2.ZERO,
	p_stagger_power: float = 0.0,
	p_ignore_defense: bool = false
) -> void:
	amount = maxf(p_amount, 0.0)
	damage_type = p_damage_type
	source = p_source
	source_position = p_source_position
	stagger_power = maxf(p_stagger_power, 0.0)
	ignore_defense = p_ignore_defense
