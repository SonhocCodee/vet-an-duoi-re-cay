class_name PixelInventoryPanel
extends PanelContainer

const PixelTheme = preload("res://scripts/ui/pixel/pixel_ui_theme.gd")

signal item_focused(item_id: StringName)

@onready var item_grid: GridContainer = %ItemGrid
@onready var empty_label: Label = %InventoryEmpty
@onready var weapon_icon: TextureRect = %EquipmentWeaponIcon
@onready var weapon_label: Label = %EquipmentWeaponLabel
@onready var armor_icon: TextureRect = %EquipmentArmorIcon
@onready var armor_label: Label = %EquipmentArmorLabel
@onready var accessory_icon: TextureRect = %EquipmentAccessoryIcon
@onready var accessory_label: Label = %EquipmentAccessoryLabel

var _rendered_item_count: int = 0


func refresh(items: Dictionary = GameState.inventory, equipment: Dictionary = GameState.equipment) -> void:
	PixelTheme.clear_children(item_grid)
	var item_ids: Array = items.keys()
	item_ids.sort_custom(func(a: Variant, b: Variant) -> bool: return String(a) < String(b))
	_rendered_item_count = 0
	for item_value: Variant in item_ids:
		var item_id := StringName(str(item_value))
		var quantity := int(items.get(item_value, 0))
		if quantity <= 0:
			continue
		item_grid.add_child(_create_item_button(item_id, quantity))
		_rendered_item_count += 1
	empty_label.visible = _rendered_item_count == 0
	_set_equipment_slot(weapon_icon, weapon_label, StringName(equipment.get(&"weapon", &"")), "Vũ khí")
	_set_equipment_slot(armor_icon, armor_label, StringName(equipment.get(&"armor", &"")), "Giáp")
	_set_equipment_slot(accessory_icon, accessory_label, StringName(equipment.get(&"accessory", &"")), "Phụ kiện")


func get_rendered_item_count() -> int:
	return _rendered_item_count


func _create_item_button(item_id: StringName, quantity: int) -> Button:
	var button := Button.new()
	button.custom_minimum_size = Vector2(88.0, 58.0)
	button.text = "%s
x%d" % [PixelTheme.humanize_id(item_id), quantity]
	button.icon = PixelTheme.load_icon(PixelTheme.icon_path_for_item(item_id))
	button.add_theme_constant_override(&"icon_max_width", 20)
	button.expand_icon = true
	button.alignment = HORIZONTAL_ALIGNMENT_LEFT
	button.tooltip_text = PixelTheme.humanize_id(item_id)
	button.set_meta(&"item_id", item_id)
	PixelTheme.style_button(button)
	button.pressed.connect(_on_item_pressed.bind(item_id))
	return button


func _set_equipment_slot(icon: TextureRect, label: Label, item_id: StringName, fallback: String) -> void:
	icon.texture = PixelTheme.load_icon(PixelTheme.icon_path_for_item(item_id)) if item_id != &"" else null
	label.text = PixelTheme.humanize_id(item_id) if item_id != &"" else "%s: Trống" % fallback
	icon.tooltip_text = label.text


func _on_item_pressed(item_id: StringName) -> void:
	item_focused.emit(item_id)
