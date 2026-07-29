class_name LootEntry
extends Resource

enum Rarity {
	COMMON,
	UNCOMMON,
	RARE,
}

@export var item_id: StringName = &"item"
@export var display_name: String = "Item"
@export_range(0.0, 1.0, 0.001) var drop_chance: float = 1.0
@export_range(1, 999, 1) var minimum_amount: int = 1
@export_range(1, 999, 1) var maximum_amount: int = 1
@export var rarity: Rarity = Rarity.COMMON


func roll_amount(random: RandomNumberGenerator) -> int:
	return random.randi_range(minimum_amount, maxi(minimum_amount, maximum_amount))
