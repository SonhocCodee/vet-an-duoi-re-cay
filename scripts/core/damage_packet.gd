class_name DamagePacket
extends RefCounted

enum DamageType {
	PHYSICAL,
	MAGICAL,
	VOID,
	TRUE,
	HOLY,
}

var amount: float = 0.0
var damage_type: StringName = &"physical"
var source: Node
var hit_direction: Vector2 = Vector2.ZERO
var source_position: Vector2 = Vector2.ZERO
var knockback_force: float = 0.0
var stagger_power: float = 0.0
var action_id: StringName = &""
var ignore_defense: bool = false
var ignores_defense: bool = false

func _init(
	first: Variant = null,
	second: Variant = 0.0,
	third: Variant = &"physical",
	fourth: Variant = Vector2.ZERO,
	fifth: Variant = 0.0,
	sixth: Variant = &"",
	seventh: Variant = false
) -> void:
	if first is Node or first == null:
		source = first as Node
		amount = maxf(float(second), 0.0)
		damage_type = _normalize_damage_type(third)
		hit_direction = (fourth as Vector2).normalized() if fourth is Vector2 else Vector2.ZERO
	else:
		amount = maxf(float(first), 0.0)
		damage_type = _normalize_damage_type(second)
		source = third as Node if third is Node else null
		hit_direction = (fourth as Vector2).normalized() if fourth is Vector2 else Vector2.ZERO
	source_position = source.global_position if source is Node2D else Vector2.ZERO
	knockback_force = maxf(float(fifth), 0.0)
	stagger_power = knockback_force
	action_id = StringName(sixth) if sixth is String or sixth is StringName else &""
	ignore_defense = bool(seventh)
	ignores_defense = ignore_defense

func _normalize_damage_type(value: Variant) -> StringName:
	if value is String or value is StringName:
		return StringName(value)
	if value is int:
		match int(value):
			DamageType.MAGICAL:
				return &"magic"
			DamageType.VOID:
				return &"void"
			DamageType.TRUE:
				return &"true"
			DamageType.HOLY:
				return &"holy"
	return &"physical"
