class_name SecondWaveGameplaySuite
extends Control
const TextureLoader = preload("res://scripts/visuals/second_wave/second_wave_texture_loader.gd")


@onready var hp_bar: ProgressBar = %HealthBar
@onready var stamina_bar: ProgressBar = %StaminaBar
@onready var xp_bar: ProgressBar = %XPBar
@onready var level_label: Label = %LevelLabel
@onready var inventory_panel: Control = %InventoryPanel
@onready var inventory_list: VBoxContainer = %InventoryList
@onready var equipment_list: VBoxContainer = %EquipmentList
@onready var quest_panel: Control = %QuestPanel
@onready var quest_list: VBoxContainer = %QuestList
@onready var map_panel: Control = %MapPanel
@onready var map_title: Label = %MapTitle
@onready var dialogue_panel: Control = %DialoguePanel
@onready var dialogue_speaker: Label = %DialogueSpeaker
@onready var dialogue_line: Label = %DialogueLine
@onready var loot_prompt: Control = %LootPrompt
@onready var loot_label: Label = %LootLabel

var _player: Node
var _loot_tween: Tween
var _dialogue_quest_id: StringName


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	_bind_events()
	call_deferred(&"_bind_world")
	_refresh_progress()
	_refresh_inventory()
	_refresh_quests()
	_apply_ui_art()


func _unhandled_input(event: InputEvent) -> void:
	if event is not InputEventKey or not event.pressed or event.echo:
		return
	match event.physical_keycode:
		KEY_I:
			_toggle_panel(inventory_panel)
		KEY_U:
			_toggle_panel(quest_panel)
		KEY_M:
			_toggle_panel(map_panel)
		KEY_ESCAPE:
			_close_modals()
		_:
			return
	get_viewport().set_input_as_handled()


func _bind_world() -> void:
	var candidate := get_tree().get_first_node_in_group(&"player")
	if candidate != null:
		_bind_player(candidate)
	var legacy_ui := get_tree().get_first_node_in_group(&"hub_ui")
	if legacy_ui != null:
		var legacy_hud := legacy_ui.get_node_or_null(^"HUD") as CanvasItem
		if legacy_hud != null:
			legacy_hud.visible = false


func _bind_events() -> void:
	_connect_if_present(GameEvents, &"player_registered", _bind_player)
	_connect_if_present(GameEvents, &"hud_refresh_requested", _on_hud_refresh_requested)
	_connect_if_present(GameEvents, &"inventory_toggled", _on_inventory_toggled)
	_connect_if_present(GameEvents, &"quest_journal_toggled", _on_quest_toggled)
	_connect_if_present(GameEvents, &"map_toggled", _on_map_toggled)
	_connect_if_present(GameEvents, &"npc_dialogue_requested", _on_dialogue_requested)
	_connect_if_present(GameEvents, &"loot_picked_up", _on_loot_picked_up)
	if GameState.has_signal(&"level_changed"):
		GameState.level_changed.connect(_on_level_changed)
	if GameState.has_signal(&"inventory_changed"):
		GameState.inventory_changed.connect(_on_inventory_changed)
	if GameState.has_signal(&"quest_changed"):
		GameState.quest_changed.connect(_on_quest_changed)


func _bind_player(candidate: Node) -> void:
	if candidate == null:
		return
	_player = candidate
	_connect_if_present(_player, &"health_changed", _on_health_changed)
	_connect_if_present(_player, &"stamina_changed", _on_stamina_changed)
	if _player.has_method(&"get_health"):
		_on_health_changed(_player.call(&"get_health"), _player.call(&"get_max_health"))
	if _player.has_method(&"get_stamina"):
		_on_stamina_changed(_player.call(&"get_stamina"), _player.call(&"get_max_stamina"))


func _refresh_all() -> void:
	_refresh_progress()
	_refresh_inventory()
	_refresh_quests()


func _refresh_progress() -> void:
	_on_level_changed(GameState.level, GameState.experience, GameState.experience_required())


func _refresh_inventory() -> void:
	_clear_list(inventory_list)
	var inventory: Dictionary = GameState.inventory
	if inventory.is_empty():
		_add_row(inventory_list, "Túi đồ đang trống")
	else:
		var item_ids := inventory.keys()
		item_ids.sort()
		for item_id: Variant in item_ids:
			_add_row(inventory_list, "%s  ×%d" % [_humanize(String(item_id)), int(inventory[item_id])])
	_clear_list(equipment_list)
	for slot_id: Variant in GameState.equipment.keys():
		_add_row(equipment_list, "%s: %s" % [_humanize(String(slot_id)), str(GameState.equipment[slot_id])])


func _refresh_quests() -> void:
	_clear_list(quest_list)
	var quests: Dictionary = GameState.active_quests
	if quests.is_empty():
		_add_row(quest_list, "Chưa có nhiệm vụ đang theo dõi")
	else:
		for quest_id: Variant in quests.keys():
			_add_row(quest_list, "%s — %s" % [_humanize(String(quest_id)), _humanize(str(quests[quest_id]))])


func _on_health_changed(current: float, maximum: float) -> void:
	hp_bar.max_value = maxf(maximum, 1.0)
	hp_bar.value = current
	hp_bar.tooltip_text = "Sinh lực %d / %d" % [roundi(current), roundi(maximum)]


func _on_stamina_changed(current: float, maximum: float) -> void:
	stamina_bar.max_value = maxf(maximum, 1.0)
	stamina_bar.value = current
	stamina_bar.tooltip_text = "Thể lực %d / %d" % [roundi(current), roundi(maximum)]


func _on_level_changed(level: int, experience: int, required: int) -> void:
	level_label.text = "KAEL  •  CẤP %d" % level
	xp_bar.max_value = maxf(float(required), 1.0)
	xp_bar.value = experience


func _on_inventory_changed(_item_id: StringName, _quantity: int) -> void:
	_refresh_inventory()


func _on_quest_changed(_quest_id: StringName, _state: StringName) -> void:
	_refresh_quests()


func _on_hud_refresh_requested(snapshot: Dictionary) -> void:
	if snapshot.has(&"health"):
		_on_health_changed(float(snapshot.get(&"health", 0.0)), float(snapshot.get(&"max_health", 1.0)))
	if snapshot.has(&"stamina"):
		_on_stamina_changed(float(snapshot.get(&"stamina", 0.0)), float(snapshot.get(&"max_stamina", 1.0)))
	_on_level_changed(int(snapshot.get(&"level", GameState.level)), int(snapshot.get(&"experience", GameState.experience)), int(snapshot.get(&"required_experience", GameState.experience_required())))


func _on_inventory_toggled(opened: bool) -> void:
	_refresh_inventory()
	_set_panel_open(inventory_panel, opened)


func _on_quest_toggled(opened: bool) -> void:
	_refresh_quests()
	_set_panel_open(quest_panel, opened)


func _on_map_toggled(opened: bool) -> void:
	map_title.text = "BẢN ĐỒ — %s" % _humanize(String(GameState.current_map))
	_set_panel_open(map_panel, opened)


func _on_dialogue_requested(npc_id: StringName, dialogue_id: StringName, quest_id: StringName) -> void:
	_close_modals()
	_dialogue_quest_id = quest_id
	dialogue_speaker.text = _npc_display_name(npc_id)
	dialogue_line.text = "%s\n\nNhiệm vụ liên quan: %s" % [_humanize(String(dialogue_id)), _humanize(String(quest_id))]
	dialogue_panel.visible = true
	%AcceptQuest.visible = quest_id != &"" and not GameState.active_quests.has(quest_id) and not GameState.completed_side_quests.has(quest_id)
	_set_npc_paused(npc_id, true)
	_set_player_control(false)


func _on_loot_picked_up(item_id: StringName, quantity: int) -> void:
	loot_label.text = "+%d  %s" % [quantity, _humanize(String(item_id))]
	loot_prompt.visible = true
	loot_prompt.modulate.a = 1.0
	if _loot_tween != null and _loot_tween.is_valid():
		_loot_tween.kill()
	_loot_tween = create_tween()
	_loot_tween.tween_interval(1.4)
	_loot_tween.tween_property(loot_prompt, "modulate:a", 0.0, 0.35)
	_loot_tween.tween_callback(func() -> void: loot_prompt.visible = false)


func _toggle_panel(panel: Control) -> void:
	_set_panel_open(panel, not panel.visible)


func _set_panel_open(panel: Control, opened: bool) -> void:
	_close_modals()
	panel.visible = opened
	_set_player_control(not opened)


func _close_modals() -> void:
	inventory_panel.visible = false
	quest_panel.visible = false
	map_panel.visible = false
	dialogue_panel.visible = false
	for npc: Node in get_tree().get_nodes_in_group(&"city_npc"):
		npc.set("controls_enabled", true)
	_set_player_control(true)


func _on_accept_quest_pressed() -> void:
	var quest_service := get_node_or_null(^"/root/QuestService")
	if quest_service != null and quest_service.has_method(&"start_quest") and quest_service.call(&"start_quest", _dialogue_quest_id):
		%AcceptQuest.visible = false
		dialogue_line.text += "\n\nNhiệm vụ đã được ghi vào nhật ký."
		_refresh_quests()


func _set_npc_paused(npc_id: StringName, paused: bool) -> void:
	var npc := get_tree().root.find_child(String(npc_id), true, false)
	if npc != null:
		npc.set("controls_enabled", not paused)


func _set_player_control(enabled: bool) -> void:
	if _player != null and _player.has_method(&"set_control_enabled"):
		_player.call(&"set_control_enabled", enabled)


func _clear_list(container: VBoxContainer) -> void:
	for child: Node in container.get_children():
		child.queue_free()


func _add_row(container: VBoxContainer, text_value: String) -> void:
	var label := Label.new()
	label.text = text_value
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	container.add_child(label)


func _npc_display_name(npc_id: StringName) -> String:
	var resource_path := "res://resources/npcs/%s.tres" % String(npc_id)
	if ResourceLoader.exists(resource_path):
		var data := load(resource_path)
		var display_name: Variant = data.get("display_name")
		if display_name != null and not String(display_name).is_empty():
			return String(display_name)
	return _humanize(String(npc_id))


func _humanize(value: String) -> String:
	return value.replace("_", " ").capitalize()


func _connect_if_present(source: Object, signal_name: StringName, callback: Callable) -> void:
	if source != null and source.has_signal(signal_name) and not source.is_connected(signal_name, callback):
		source.connect(signal_name, callback)


func _apply_ui_art() -> void:
	var art_paths := {
		%HUDFrame: "res://assets/art/ui/health_frame.svg",
		%InventoryArt: "res://assets/art/ui/inventory_panel.svg",
		%EquipmentArt: "res://assets/art/ui/equipment_panel.svg",
		%QuestArt: "res://assets/art/ui/quest_panel.svg",
		%MapArt: "res://assets/art/ui/map_frame.svg",
		%LootArt: "res://assets/art/ui/loot_prompt.svg",
		%CityMap: "res://assets/art/city/backgrounds/ashen_city_full.svg",
		%PlayerMarker: "res://assets/art/ui/marker_player.svg",
		%QuestMarker: "res://assets/art/ui/marker_quest.svg",
		%NpcMarker: "res://assets/art/ui/marker_npc.svg",
	}
	for target: TextureRect in art_paths:
		var resource_path: String = art_paths[target]
		target.texture = TextureLoader.load_texture(resource_path)
