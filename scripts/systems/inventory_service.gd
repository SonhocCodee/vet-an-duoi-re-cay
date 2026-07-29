extends Node

signal inventory_changed(item_id: StringName, quantity: int)
signal equipment_changed(slot_id: StringName, item_id: StringName)

const EQUIPMENT_SLOTS: Array[StringName] = [&"weapon", &"armor", &"accessory"]


func _ready() -> void:
	if not GameState.inventory_changed.is_connected(_on_game_state_inventory_changed):
		GameState.inventory_changed.connect(_on_game_state_inventory_changed)


func add_item(item_id: StringName, quantity: int = 1) -> bool:
	if item_id == &"" or quantity <= 0:
		return false
	GameState.add_item(item_id, quantity)
	return true


func remove_item(item_id: StringName, quantity: int = 1) -> bool:
	if item_id == &"" or quantity <= 0 or get_quantity(item_id) < quantity:
		return false
	GameState.add_item(item_id, -quantity)
	return true


func get_quantity(item_id: StringName) -> int:
	return GameState.get_item_quantity(item_id)


func equip_item(slot_id: StringName, item_id: StringName) -> bool:
	if not EQUIPMENT_SLOTS.has(slot_id):
		return false
	if item_id != &"" and get_quantity(item_id) <= 0:
		return false
	GameState.equipment[slot_id] = item_id
	if GameState.has_signal(&"equipment_changed"):
		GameState.equipment_changed.emit(slot_id, item_id)
	equipment_changed.emit(slot_id, item_id)
	return true


func get_equipped_item(slot_id: StringName) -> StringName:
	return StringName(GameState.equipment.get(slot_id, &""))


func get_inventory_snapshot() -> Dictionary:
	return GameState.inventory.duplicate(true)


func _on_game_state_inventory_changed(item_id: StringName, quantity: int) -> void:
	inventory_changed.emit(item_id, quantity)
