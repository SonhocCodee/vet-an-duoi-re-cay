class_name PlayerCombatConfig
extends Resource

@export_group("Movement")
@export var move_speed: float = 180.0
@export var acceleration: float = 1400.0
@export var deceleration: float = 1800.0
@export_range(0.0, 0.95, 0.01) var analog_deadzone: float = 0.2
@export_range(0.0, 1.0, 0.01) var facing_input_threshold: float = 0.3
@export var stop_speed_threshold: float = 1.0

@export_group("Basic Attack")
@export var attack_duration: float = 0.26
@export var attack_active_start: float = 0.055
@export var attack_active_end: float = 0.145
@export var attack_cooldown: float = 0.10
@export_range(0.0, 1.0, 0.05) var attack_move_speed_multiplier: float = 0.60
@export var attack_move_acceleration: float = 1250.0
@export_range(30.0, 160.0, 1.0) var attack_arc_degrees: float = 90.0
@export var attack_reach: float = 45.0
@export var attack_hitbox_offset: float = 25.0
@export var attack_hitbox_depth: float = 36.0
@export var attack_hitbox_width: float = 40.0
@export var attack_knockback_force: float = 65.0
@export var attack_knockback_distance: float = 7.0
@export_range(0.0, 0.1, 0.005) var attack_hit_stop: float = 0.035
@export var combo_reset_time: float = 0.48
@export var combo_damage_multipliers: PackedFloat32Array = PackedFloat32Array([1.0, 1.15, 1.5])

@export_group("Dodge")
@export var dodge_speed: float = 460.0
@export var dodge_duration: float = 0.34
@export var dodge_iframe_duration: float = 0.22
@export var dodge_stamina_cost: float = 28.0

@export_group("Stamina")
@export var stamina_regen_per_second: float = 24.0
@export var stamina_regen_delay: float = 0.65

@export_group("Skill")
@export var skill_duration: float = 0.55
@export var skill_active_time: float = 0.18
@export var skill_stamina_cost: float = 20.0
@export var world_pixels_per_meter: float = 64.0
