class_name EnemyData
extends Resource

@export_group("Identity")
@export var enemy_id: StringName = &"enemy"
@export var display_name: String = "Enemy"
@export_range(1, 35, 1) var base_level: int = 1
@export_range(0, 100000, 1) var experience_reward: int = 0

@export_group("Base Stats")
@export_range(1.0, 100000.0, 1.0) var base_health: float = 50.0
@export_range(0.0, 10000.0, 0.5) var base_attack: float = 8.0
@export_range(0.0, 10000.0, 0.5) var base_defense: float = 2.0
@export_range(0.0, 10000.0, 0.5) var base_resistance: float = 2.0
@export_range(0.0, 1000.0, 1.0) var movement_speed: float = 70.0

@export_group("Behavior")
@export_range(16.0, 2000.0, 1.0) var detection_radius: float = 260.0
@export_range(8.0, 1000.0, 1.0) var attack_range: float = 44.0
@export_range(0.4, 1.0, 0.05) var telegraph_duration: float = 0.6
@export_range(0.05, 5.0, 0.05) var attack_recovery: float = 0.65
@export_range(0.05, 5.0, 0.05) var stagger_duration: float = 0.3
@export_range(0.0, 1000.0, 0.5) var stagger_threshold: float = 10.0

@export_group("Scaling")
@export_range(0.0, 1.0, 0.01) var health_scale_per_level: float = 0.12
@export_range(1.0, 3.0, 0.01) var health_scale_exponent: float = 1.18
@export_range(0.0, 1.0, 0.01) var attack_scale_per_level: float = 0.10
@export_range(0.0, 1.0, 0.01) var defense_scale_per_level: float = 0.08
@export_range(0.0, 1.0, 0.01) var resistance_scale_per_level: float = 0.08

@export_group("Loot")
@export var loot_table: LootTable


func scaled_health(level: int) -> float:
	var level_delta: int = maxi(level - base_level, 0)
	var growth_base: float = 1.0 + health_scale_per_level * float(level_delta)
	return base_health * pow(growth_base, health_scale_exponent)


func scaled_attack(level: int) -> float:
	var level_delta: int = maxi(level - base_level, 0)
	return base_attack * (1.0 + attack_scale_per_level * float(level_delta))


func scaled_defense(level: int) -> float:
	var level_delta: int = maxi(level - base_level, 0)
	return base_defense * (1.0 + defense_scale_per_level * float(level_delta))


func scaled_resistance(level: int) -> float:
	var level_delta: int = maxi(level - base_level, 0)
	return base_resistance * (1.0 + resistance_scale_per_level * float(level_delta))
