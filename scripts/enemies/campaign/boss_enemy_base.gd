class_name BossEnemyBase
extends CampaignEnemyBase

signal phase_changed(boss: BossEnemyBase, phase: BossPhase)
signal pattern_telegraphed(boss: BossEnemyBase, pattern: TelegraphPattern)

enum BossPhase {
	PHASE_ONE = 1,
	PHASE_TWO = 2,
}

enum TelegraphPattern {
	DIRECT,
	RADIAL,
	PROJECTILE_BURST,
}

@export_range(0.1, 0.9, 0.05) var phase_two_health_ratio: float = 0.5
@export var phase_one_patterns: Array[TelegraphPattern] = [
	TelegraphPattern.DIRECT,
	TelegraphPattern.PROJECTILE_BURST,
]
@export var phase_two_patterns: Array[TelegraphPattern] = [
	TelegraphPattern.RADIAL,
	TelegraphPattern.PROJECTILE_BURST,
	TelegraphPattern.DIRECT,
]
@export_range(3, 12, 1) var projectile_count: int = 5
@export_range(1.0, 3.0, 0.1) var phase_two_attack_multiplier: float = 1.35
@export_range(1.0, 3.0, 0.1) var radial_range_multiplier: float = 1.8

var current_phase: BossPhase = BossPhase.PHASE_ONE
var selected_pattern: TelegraphPattern = TelegraphPattern.DIRECT
var _pattern_index: int = 0


func _ready() -> void:
	elite_roll_enabled = false
	super._ready()


func receive_damage(packet: DamagePacket) -> DamageResult:
	var result: DamageResult = super.receive_damage(packet)
	if current_state != EnemyState.DEAD and current_phase == BossPhase.PHASE_ONE:
		if current_health <= max_health * phase_two_health_ratio:
			_enter_phase_two()
	return result


func _update_chase() -> void:
	if is_instance_valid(_target) and _target_in_range(data.attack_range):
		_prepare_next_pattern()
	super._update_chase()


func _resolve_attack() -> void:
	match selected_pattern:
		TelegraphPattern.RADIAL:
			_resolve_radial_attack()
		TelegraphPattern.PROJECTILE_BURST:
			_resolve_projectile_burst()
		_:
			_deal_target_damage(1.0, data.attack_range * 1.2)
	attack_resolved.emit()


func _prepare_next_pattern() -> void:
	var patterns: Array[TelegraphPattern] = phase_one_patterns if current_phase == BossPhase.PHASE_ONE else phase_two_patterns
	if patterns.is_empty():
		selected_pattern = TelegraphPattern.DIRECT
	else:
		selected_pattern = patterns[_pattern_index % patterns.size()]
		_pattern_index += 1
	pattern_telegraphed.emit(self, selected_pattern)
	if selected_pattern == TelegraphPattern.RADIAL:
		_spawn_radial_placeholder(Color("ffca58"), data.telegraph_duration)


func _enter_phase_two() -> void:
	current_phase = BossPhase.PHASE_TWO
	_pattern_index = 0
	if visual != null:
		visual.modulate = Color(1.0, 0.72, 0.58, 1.0)
	phase_changed.emit(self, current_phase)


func _resolve_radial_attack() -> void:
	var radial_range: float = data.attack_range * radial_range_multiplier
	_spawn_radial_placeholder(Color("ff5d45"), 0.45, radial_range)
	_deal_target_damage(1.15, radial_range)


func _resolve_projectile_burst() -> void:
	var base_direction: Vector2 = Vector2.RIGHT
	if is_instance_valid(_target):
		base_direction = global_position.direction_to(_target.global_position)
	var spawn_parent: Node = get_tree().current_scene
	if spawn_parent == null:
		spawn_parent = get_parent()
	if spawn_parent != null:
		for projectile_index: int in range(projectile_count):
			var ratio: float = float(projectile_index) / float(maxi(projectile_count - 1, 1))
			var direction: Vector2 = base_direction.rotated(lerpf(-0.65, 0.65, ratio))
			var projectile: BossAttackPlaceholder = BossAttackPlaceholder.new()
			spawn_parent.add_child(projectile)
			projectile.global_position = global_position
			projectile.configure(BossAttackPlaceholder.Kind.PROJECTILE, direction, 16.0, Color("f7a54a"))
	_deal_target_damage(0.9, data.attack_range * 3.0)


func _spawn_radial_placeholder(
	color: Color,
	duration: float,
	radius: float = 0.0
) -> void:
	var effect: BossAttackPlaceholder = BossAttackPlaceholder.new()
	add_child(effect)
	effect.lifetime = maxf(duration, 0.1)
	effect.configure(
		BossAttackPlaceholder.Kind.RADIAL,
		Vector2.RIGHT,
		radius if radius > 0.0 else data.attack_range * radial_range_multiplier,
		color
	)


func _deal_target_damage(multiplier: float, maximum_range: float) -> void:
	if not _target_in_range(maximum_range) or not _target.has_method(RECEIVE_DAMAGE_METHOD):
		return
	var phase_multiplier: float = phase_two_attack_multiplier if current_phase == BossPhase.PHASE_TWO else 1.0
	var packet: DamagePacket = DamagePacket.new(
		attack_power * multiplier * phase_multiplier,
		&"physical",
		self,
		global_position.direction_to(_target.global_position),
		data.stagger_threshold
	)
	_target.call(RECEIVE_DAMAGE_METHOD, packet)
