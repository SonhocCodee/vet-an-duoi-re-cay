class_name ItemDefinition
extends Resource

enum Rarity { COMMON, UNCOMMON, RARE }

@export var item_id: StringName
@export var display_name: String = ""
@export_multiline var description: String = ""
@export var buy_price: int = 0
@export var sell_price: int = 0
@export var rarity: Rarity = Rarity.COMMON
