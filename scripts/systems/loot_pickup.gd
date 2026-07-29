class_name LootPickup
extends Area2D

signal picked_up(item_id: StringName, quantity: int)

@export var item_id: StringName
@export_range(1, 999, 1) var quantity: int = 1
@export var auto_collect: bool = true

var collected: bool = false


func _ready() -> void:
	if auto_collect and not body_entered.is_connected(_on_body_entered):
		body_entered.connect(_on_body_entered)


func configure(next_item_id: StringName, next_quantity: int = 1) -> void:
	item_id = next_item_id
	quantity = maxi(next_quantity, 1)


func collect(_actor: Node = null) -> bool:
	if collected or item_id == &"" or quantity <= 0:
		return false
	collected = true
	if item_id == GameIds.CURRENCY_GOLD or item_id == GameIds.CURRENCY_SOUL_SHARD or item_id == GameIds.CURRENCY_WORLD_FRAGMENT:
		GameState.add_currency(item_id, quantity)
	else:
		var inventory_service: Node = get_node_or_null(^"/root/InventoryService")
		if inventory_service != null:
			inventory_service.call(&"add_item", item_id, quantity)
		else:
			GameState.add_item(item_id, quantity)
	picked_up.emit(item_id, quantity)
	GameEvents.loot_picked_up.emit(item_id, quantity)
	queue_free()
	return true


func _on_body_entered(body: Node) -> void:
	if body.is_in_group(&"player"):
		collect(body)
