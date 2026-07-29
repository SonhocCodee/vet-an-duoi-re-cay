class_name InventoryGameplayController
extends Control

signal panel_toggled(opened: bool)
signal snapshot_changed(snapshot: Dictionary)

@export var start_open: bool = false


func _ready() -> void:
	visible = start_open
	GameState.inventory_changed.connect(_on_inventory_changed)
	var inventory_service: Node = get_node_or_null(^"/root/InventoryService")
	if inventory_service != null and inventory_service.has_signal(&"equipment_changed"):
		inventory_service.equipment_changed.connect(_on_equipment_changed)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed(&"toggle_inventory"):
		toggle()
		get_viewport().set_input_as_handled()


func toggle() -> void:
	set_open(not visible)


func set_open(opened: bool) -> void:
	visible = opened
	panel_toggled.emit(opened)
	GameEvents.inventory_toggled.emit(opened)
	if opened:
		refresh()


func refresh() -> Dictionary:
	var snapshot: Dictionary = get_snapshot()
	snapshot_changed.emit(snapshot.duplicate(true))
	return snapshot


func get_snapshot() -> Dictionary:
	return {
		&"items": GameState.inventory.duplicate(true),
		&"equipment": GameState.equipment.duplicate(true),
	}


func equip(slot_id: StringName, item_id: StringName) -> bool:
	var inventory_service: Node = get_node_or_null(^"/root/InventoryService")
	return bool(inventory_service.call(&"equip_item", slot_id, item_id)) if inventory_service != null else false


func _on_inventory_changed(_item_id: StringName, _quantity: int) -> void:
	if visible:
		refresh()


func _on_equipment_changed(_slot_id: StringName, _item_id: StringName) -> void:
	if visible:
		refresh()
