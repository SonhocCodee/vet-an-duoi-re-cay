extends Node

const ENEMY_SCENES: Array[String] = [
	"res://scenes/actors/enemies/mist_shade.tscn",
	"res://scenes/actors/enemies/root_wolf.tscn",
	"res://scenes/actors/enemies/weeping_mushroom.tscn",
	"res://scenes/actors/enemies/root_antler_stag.tscn",
]

var _failures: PackedStringArray = []
var _checks_run: int = 0


func _ready() -> void:
	_check_packed_scenes()
	_check_scaling_formula()
	_check_elite_multiplier()
	_check_damage_contract()
	_check_guaranteed_loot()
	_check_pickup_contract()
	_finish()


func _check_packed_scenes() -> void:
	for scene_path: String in ENEMY_SCENES:
		var packed: PackedScene = load(scene_path) as PackedScene
		_expect(packed != null, "%s loads as PackedScene" % scene_path)
		if packed == null:
			continue
		var enemy: EnemyBase = packed.instantiate() as EnemyBase
		_expect(enemy != null, "%s instantiates as EnemyBase" % scene_path)
		if enemy == null:
			continue
		_expect(enemy.data != null, "%s has EnemyData" % scene_path)
		_expect(enemy.has_signal(&"telegraph_started"), "%s exposes telegraph_started" % scene_path)
		_expect(enemy.has_signal(&"attack_resolved"), "%s exposes attack_resolved" % scene_path)
		_expect(enemy.has_signal(&"died"), "%s exposes died" % scene_path)
		enemy.free()


func _check_scaling_formula() -> void:
	var data: EnemyData = load("res://resources/enemies/mist_shade.tres") as EnemyData
	var level: int = data.base_level + 4
	var expected_health: float = data.base_health * pow(1.0 + 0.12 * 4.0, 1.18)
	_expect(is_equal_approx(data.scaled_health(level), expected_health), "HP scaling matches master spec")
	_expect(is_equal_approx(data.scaled_attack(level), data.base_attack * 1.4), "ATK scaling matches master spec")


func _check_elite_multiplier() -> void:
	var packed: PackedScene = load("res://scenes/actors/enemies/root_wolf.tscn") as PackedScene
	var enemy: EnemyBase = packed.instantiate() as EnemyBase
	enemy.elite_roll_enabled = false
	enemy.force_elite = true
	add_child(enemy)
	var base_health: float = enemy.data.scaled_health(enemy.combat_level)
	var base_attack: float = enemy.data.scaled_attack(enemy.combat_level)
	_expect(enemy.is_elite, "force_elite creates elite variant")
	_expect(is_equal_approx(enemy.max_health, base_health * 1.8), "elite HP multiplier is 1.8")
	_expect(is_equal_approx(enemy.attack_power, base_attack * 1.3), "elite ATK multiplier is 1.3")
	enemy.free()


func _check_damage_contract() -> void:
	var packed: PackedScene = load("res://scenes/actors/enemies/mist_shade.tscn") as PackedScene
	var enemy: EnemyBase = packed.instantiate() as EnemyBase
	enemy.elite_roll_enabled = false
	add_child(enemy)
	var packet: DamagePacket = DamagePacket.new(
		10.0,
		DamagePacket.DamageType.PHYSICAL,
		self
	)
	var result: DamageResult = enemy.receive_damage(packet)
	_expect(result != null, "receive_damage returns DamageResult")
	_expect(enemy.current_health < enemy.max_health, "receive_damage lowers health")
	enemy.free()


func _check_guaranteed_loot() -> void:
	var table: LootTable = load("res://resources/loot/mist_shade_loot.tres") as LootTable
	var random: RandomNumberGenerator = RandomNumberGenerator.new()
	random.seed = 1337
	for iteration: int in range(20):
		var drops: Array[LootDrop] = table.roll_drops(random)
		var has_gold: bool = false
		for drop: LootDrop in drops:
			if drop.item_id == &"gold":
				has_gold = drop.amount >= 5 and drop.amount <= 12
		_expect(has_gold, "mist shade always drops 5-12 gold")


func _check_pickup_contract() -> void:
	var packed: PackedScene = load("res://scenes/items/loot_item_pickup.tscn") as PackedScene
	var pickup: LootItemPickup = packed.instantiate() as LootItemPickup
	_expect(pickup != null, "loot pickup PackedScene instantiates")
	_expect(is_equal_approx(pickup.magnet_radius, 100.0), "loot pickup magnet radius is 100px")
	pickup.free()


func _expect(condition: bool, message: String) -> void:
	_checks_run += 1
	if condition:
		print("[ENEMY][PASS] %s" % message)
	else:
		_failures.append(message)
		push_error("[ENEMY][FAIL] %s" % message)


func _finish() -> void:
	if _failures.is_empty():
		print("[ENEMY][PASS] %d checks completed." % _checks_run)
		get_tree().quit(0)
		return
	print("[ENEMY][SUMMARY] %d of %d checks failed." % [_failures.size(), _checks_run])
	get_tree().quit(1)
