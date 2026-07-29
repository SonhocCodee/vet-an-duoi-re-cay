class_name CombatResolver
extends RefCounted

static func resolve_damage(packet: DamagePacket, defense: float, resistance: float, invulnerable: bool = false) -> DamageResult:
	var result := DamageResult.new()
	if invulnerable:
		result.was_ignored = true
		result.blocked_damage = packet.amount
		return result
	var mitigation: float = defense if packet.damage_type == GameIds.DAMAGE_PHYSICAL else resistance
	if packet.ignores_defense:
		mitigation = 0.0
	var multiplier: float = 100.0 / (100.0 + maxf(mitigation, 0.0))
	result.applied_damage = maxf(1.0, packet.amount * multiplier)
	result.blocked_damage = maxf(0.0, packet.amount - result.applied_damage)
	return result
