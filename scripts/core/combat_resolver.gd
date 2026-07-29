class_name CombatResolver
extends RefCounted

static func resolve_damage(packet: DamagePacket, defense: float, resistance: float, invulnerable: bool = false) -> DamageResult:
	if invulnerable:
		return DamageResult.new(packet.amount, 0.0, 0.0, true, false)
	var mitigation: float = defense if packet.damage_type == DamagePacket.DamageType.PHYSICAL else resistance
	if packet.ignore_defense or packet.damage_type == DamagePacket.DamageType.TRUE:
		mitigation = 0.0
	var multiplier: float = 100.0 / (100.0 + maxf(mitigation, 0.0))
	var applied: float = maxf(1.0, packet.amount * multiplier) if packet.amount > 0.0 else 0.0
	return DamageResult.new(packet.amount, applied, 0.0, false, false)
