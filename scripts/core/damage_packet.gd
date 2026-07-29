class_name DamagePacket
extends RefCounted

var source: Node
var amount: float
var damage_type: StringName
var hit_direction: Vector2
var stagger: float
var ignores_defense: bool

func _init(p_source: Node = null, p_amount: float = 0.0, p_damage_type: StringName = &"physical", p_hit_direction: Vector2 = Vector2.ZERO, p_stagger: float = 0.0, p_ignores_defense: bool = false) -> void:
	source = p_source
	amount = maxf(p_amount, 0.0)
	damage_type = p_damage_type
	hit_direction = p_hit_direction
	stagger = maxf(p_stagger, 0.0)
	ignores_defense = p_ignores_defense
