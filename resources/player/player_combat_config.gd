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
@export var attack_duration: float = 0.28
@export var attack_active_start: float = 0.07
@export var attack_active_end: float = 0.16
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
