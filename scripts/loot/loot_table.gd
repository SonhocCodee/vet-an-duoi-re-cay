class_name LootTable
extends Resource

@export var loot_entries: Array[LootEntry] = []


func roll_drops(random: RandomNumberGenerator = null) -> Array[LootDrop]:
	var generator: RandomNumberGenerator = random
	if generator == null:
		generator = RandomNumberGenerator.new()
		generator.randomize()

	var drops: Array[LootDrop] = []
	for entry: LootEntry in loot_entries:
		if entry == null or generator.randf() > entry.drop_chance:
			continue
		drops.append(LootDrop.new(
			entry.item_id,
			entry.display_name,
			entry.roll_amount(generator),
			entry.rarity
		))
	return drops
