class_name PixelGameplayUi
extends Control

const PixelTheme = preload("res://scripts/ui/pixel/pixel_ui_theme.gd")
const PixelHudType = preload("res://scripts/ui/pixel/pixel_hud_controller.gd")
const PixelInventoryType = preload("res://scripts/ui/pixel/pixel_inventory_panel.gd")
const PixelQuestType = preload("res://scripts/ui/pixel/pixel_quest_panel.gd")
const PixelMapType = preload("res://scripts/ui/pixel/pixel_map_panel.gd")

signal panel_state_changed(panel_id: StringName, opened: bool)

const PANEL_INVENTORY: StringName = &"inventory"
const PANEL_QUESTS: StringName = &"quests"
const PANEL_MAP: StringName = &"map"

@onready var hud: PixelHudType = %PixelHUD
@onready var backdrop: ColorRect = %PanelBackdrop
@onready var inventory_panel: PixelInventoryType = %InventoryPanel
@onready var quest_panel: PixelQuestType = %QuestPanel
@onready var map_panel: PixelMapType = %MapPanel
@onready var hotbar_slots: HBoxContainer = %HotbarSlots

var _hotbar_slot_nodes: Array[PanelContainer] = []
var _open_panel_id: StringName = &""


func _ready() -> void:
	_apply_readable_text(self)
	_connect_signals()
	_connect_buttons()
	_build_hotbar()
	close_panels()
	var existing_player := get_tree().get_first_node_in_group(&"player")
	if existing_player != null:
		hud.bind_player(existing_player)
	hud.refresh_from_state()
	hud.set_clock(GameState.game_time)
	hud.set_area(GameState.current_map)
	_refresh_equipment_and_item()
	_refresh_hotbar()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed(&"toggle_inventory"):
		toggle_panel(PANEL_INVENTORY)
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed(&"toggle_quest_journal"):
		toggle_panel(PANEL_QUESTS)
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed(&"toggle_map"):
		toggle_panel(PANEL_MAP)
		get_viewport().set_input_as_handled()
	elif event is InputEventKey:
		var key_event := event as InputEventKey
		if key_event.pressed and not key_event.echo and key_event.keycode == KEY_ESCAPE and _open_panel_id != &"":
			close_panels()
			get_viewport().set_input_as_handled()


func open_panel(panel_id: StringName) -> bool:
	var target := _panel_for_id(panel_id)
	if target == null:
		return false
	inventory_panel.visible = target == inventory_panel
	quest_panel.visible = target == quest_panel
	map_panel.visible = target == map_panel
	backdrop.visible = true
	_open_panel_id = panel_id
	if target == inventory_panel:
		inventory_panel.refresh()
	elif target == quest_panel:
		quest_panel.refresh()
	elif target == map_panel:
		map_panel.refresh()
	panel_state_changed.emit(panel_id, true)
	return true


func toggle_panel(panel_id: StringName) -> void:
	if _open_panel_id == panel_id:
		close_panels()
	else:
		open_panel(panel_id)


func close_panels() -> void:
	var closed_id := _open_panel_id
	inventory_panel.visible = false
	quest_panel.visible = false
	map_panel.visible = false
	backdrop.visible = false
	_open_panel_id = &""
	if closed_id != &"":
		panel_state_changed.emit(closed_id, false)


func get_open_panel_id() -> StringName:
	return _open_panel_id


func get_hotbar_slot_count() -> int:
	return _hotbar_slot_nodes.size()


func set_area_label(map_id: StringName, custom_name: String = "") -> void:
	hud.set_area(map_id, custom_name)
	map_panel.refresh(GameState.discovered_map_markers, map_id)


func _apply_readable_text(root_node: Node) -> void:
	for child: Node in root_node.get_children():
		if child is Label:
			var label := child as Label
			if not label.has_theme_color_override(&"font_color"):
				label.add_theme_color_override(&"font_color", PixelTheme.TEXT)
		_apply_readable_text(child)


func _connect_signals() -> void:
	_connect_once(GameEvents.player_registered, _on_player_registered)
	_connect_once(GameEvents.hud_refresh_requested, _on_hud_snapshot)
	_connect_once(GameEvents.inventory_toggled, _on_inventory_toggled)
	_connect_once(GameEvents.quest_journal_toggled, _on_quest_toggled)
	_connect_once(GameEvents.map_toggled, _on_map_toggled)
	_connect_once(GameState.level_changed, _on_state_changed)
	_connect_once(GameState.currency_changed, _on_state_changed)
	_connect_once(GameState.inventory_changed, _on_inventory_changed)
	_connect_once(GameState.equipment_changed, _on_equipment_changed)
	_connect_once(GameState.game_time_changed, _on_game_time_changed)
	_connect_once(GameState.map_marker_discovered, _on_marker_discovered)
	_connect_once(GameState.side_quest_changed, _on_side_quest_changed)


func _connect_buttons() -> void:
	%InventoryButton.pressed.connect(toggle_panel.bind(PANEL_INVENTORY))
	%QuestButton.pressed.connect(toggle_panel.bind(PANEL_QUESTS))
	%MapButton.pressed.connect(toggle_panel.bind(PANEL_MAP))
	%InventoryClose.pressed.connect(close_panels)
	%QuestClose.pressed.connect(close_panels)
	%MapClose.pressed.connect(close_panels)
	PixelTheme.style_button(%InventoryButton)
	PixelTheme.style_button(%QuestButton)
	PixelTheme.style_button(%MapButton)
	PixelTheme.style_button(%InventoryClose)
	PixelTheme.style_button(%QuestClose)
	PixelTheme.style_button(%MapClose)


func _panel_for_id(panel_id: StringName) -> Control:
	match panel_id:
		PANEL_INVENTORY:
			return inventory_panel
		PANEL_QUESTS:
			return quest_panel
		PANEL_MAP:
			return map_panel
	return null


func _build_hotbar() -> void:
	PixelTheme.clear_children(hotbar_slots)
	_hotbar_slot_nodes.clear()
	for index: int in range(8):
		var slot := PanelContainer.new()
		slot.custom_minimum_size = Vector2(42.0, 42.0)
		slot.add_theme_stylebox_override(&"panel", PixelTheme.make_panel(PixelTheme.PANEL, PixelTheme.BORDER, 2))
		var content := Control.new()
		content.name = "Content"
		content.custom_minimum_size = Vector2(38.0, 38.0)
		var icon := TextureRect.new()
		icon.name = "Icon"
		icon.position = Vector2(9.0, 8.0)
		icon.size = Vector2(22.0, 22.0)
		icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		icon.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
		content.add_child(icon)
		var number := Label.new()
		number.name = "Number"
		number.position = Vector2(3.0, 1.0)
		number.size = Vector2(12.0, 12.0)
		number.text = str(index + 1)
		number.add_theme_font_size_override(&"font_size", 9)
		number.add_theme_color_override(&"font_color", PixelTheme.MUTED)
		content.add_child(number)
		var quantity := Label.new()
		quantity.name = "Quantity"
		quantity.position = Vector2(23.0, 25.0)
		quantity.size = Vector2(14.0, 12.0)
		quantity.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		quantity.add_theme_font_size_override(&"font_size", 9)
		quantity.add_theme_color_override(&"font_color", PixelTheme.TEXT)
		content.add_child(quantity)
		slot.add_child(content)
		hotbar_slots.add_child(slot)
		_hotbar_slot_nodes.append(slot)


func _refresh_hotbar() -> void:
	if _hotbar_slot_nodes.is_empty():
		return
	for slot: PanelContainer in _hotbar_slot_nodes:
		var icon := slot.get_node(^"Content/Icon") as TextureRect
		var quantity := slot.get_node(^"Content/Quantity") as Label
		icon.texture = null
		quantity.text = ""
		slot.tooltip_text = "Ô trống"
	var weapon_id := StringName(GameState.equipment.get(&"weapon", &""))
	_set_hotbar_slot(0, weapon_id, 0, "res://assets/art/pixel/ui/icon_sword.svg", "Vũ khí")
	var item_ids: Array = GameState.inventory.keys()
	item_ids.sort_custom(func(a: Variant, b: Variant) -> bool:
		var a_value := String(a)
		var b_value := String(b)
		var a_priority := 0 if a_value.contains("potion") else 1
		var b_priority := 0 if b_value.contains("potion") else 1
		return a_value < b_value if a_priority == b_priority else a_priority < b_priority
	)
	var slot_index := 1
	for item_value: Variant in item_ids:
		if slot_index >= _hotbar_slot_nodes.size():
			break
		var item_id := StringName(str(item_value))
		if item_id == weapon_id:
			continue
		var quantity := int(GameState.inventory.get(item_value, 0))
		if quantity <= 0:
			continue
		_set_hotbar_slot(slot_index, item_id, quantity, PixelTheme.icon_path_for_item(item_id), "Vật phẩm")
		slot_index += 1


func _set_hotbar_slot(index: int, item_id: StringName, quantity_value: int, icon_path: String, fallback: String) -> void:
	if index < 0 or index >= _hotbar_slot_nodes.size():
		return
	var slot := _hotbar_slot_nodes[index]
	var icon := slot.get_node(^"Content/Icon") as TextureRect
	var quantity := slot.get_node(^"Content/Quantity") as Label
	icon.texture = PixelTheme.load_icon(icon_path)
	quantity.text = str(quantity_value) if quantity_value > 1 else ""
	slot.tooltip_text = PixelTheme.humanize_id(item_id) if item_id != &"" else fallback


func _refresh_equipment_and_item() -> void:
	var weapon_id := StringName(GameState.equipment.get(&"weapon", &""))
	hud.set_weapon(weapon_id)
	var item_id: StringName = &""
	var quantity := 0
	var item_ids: Array = GameState.inventory.keys()
	item_ids.sort_custom(func(a: Variant, b: Variant) -> bool: return String(a) < String(b))
	for item_value: Variant in item_ids:
		var candidate_id := StringName(str(item_value))
		var candidate_quantity := int(GameState.inventory.get(item_value, 0))
		if candidate_quantity > 0 and (String(candidate_id).contains("potion") or item_id == &""):
			item_id = candidate_id
			quantity = candidate_quantity
			if String(candidate_id).contains("potion"):
				break
	hud.set_item(item_id, quantity)


func _connect_once(signal_value: Signal, callback: Callable) -> void:
	if not signal_value.is_connected(callback):
		signal_value.connect(callback)


func _on_player_registered(player: Node) -> void:
	hud.bind_player(player)


func _on_hud_snapshot(snapshot: Dictionary) -> void:
	hud.apply_snapshot(snapshot)


func _on_inventory_toggled(opened: bool) -> void:
	if opened:
		open_panel(PANEL_INVENTORY)
	elif _open_panel_id == PANEL_INVENTORY:
		close_panels()


func _on_quest_toggled(opened: bool) -> void:
	if opened:
		open_panel(PANEL_QUESTS)
	elif _open_panel_id == PANEL_QUESTS:
		close_panels()


func _on_map_toggled(opened: bool) -> void:
	if opened:
		open_panel(PANEL_MAP)
	elif _open_panel_id == PANEL_MAP:
		close_panels()


func _on_state_changed(_a: Variant = null, _b: Variant = null, _c: Variant = null) -> void:
	hud.refresh_from_state()


func _on_inventory_changed(_item_id: StringName, _quantity: int) -> void:
	_refresh_equipment_and_item()
	_refresh_hotbar()
	if inventory_panel.visible:
		inventory_panel.refresh()


func _on_equipment_changed(_slot_id: StringName, _item_id: StringName) -> void:
	_refresh_equipment_and_item()
	_refresh_hotbar()
	if inventory_panel.visible:
		inventory_panel.refresh()


func _on_game_time_changed(hour: float) -> void:
	hud.set_clock(hour)


func _on_marker_discovered(_marker_id: StringName, _marker_data: Dictionary) -> void:
	if map_panel.visible:
		map_panel.refresh()


func _on_side_quest_changed(_quest_id: StringName, _state: Dictionary) -> void:
	if quest_panel.visible:
		quest_panel.refresh()
