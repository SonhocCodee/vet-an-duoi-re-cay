class_name LootDrop
extends RefCounted

var item_id: StringName
var display_name: String
var amount: int
var rarity: LootEntry.Rarity


func _init(
	p_item_id: StringName,
	p_display_name: String,
	p_amount: int,
	p_rarity: LootEntry.Rarity
) -> void:
	item_id = p_item_id
	display_name = p_display_name
	amount = p_amount
	rarity = p_rarity
