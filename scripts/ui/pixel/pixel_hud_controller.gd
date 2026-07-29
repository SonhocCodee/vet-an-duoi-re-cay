class_name PixelHudController
extends Control

const PixelTheme = preload("res://scripts/ui/pixel/pixel_ui_theme.gd")

@onready var health_bar: ProgressBar = %HealthBar
@onready var stamina_bar: ProgressBar = %StaminaBar
@onready var health_label: Label = %HealthLabel
@onready var stamina_label: Label = %StaminaLabel
@onready var level_label: Label = %LevelLabel
@onready var gold_label: Label = %GoldLabel
@onready var weapon_icon: TextureRect = %WeaponIcon
@onready var weapon_label: Label = %WeaponLabel
@onready var item_icon: TextureRect = %ItemIcon
@onready var item_label: Label = %ItemLabel
@onready var clock_label: Label = %ClockLabel
@onready var area_label: Label = %AreaLabel

var _player: Node
var _last_snapshot: Dictionary = {}


func bind_player(player: Node) -> void:
	if is_instance_valid(_player):
		_disconnect_player(_player)
	_player = player
	if not is_instance_valid(_player):
		return
	_connect_player(_player)
	refresh_from_state()


func apply_snapshot(snapshot: Dictionary) -> void:
	_last_snapshot = snapshot.duplicate(true)
	var health := float(snapshot.get(&"health", health_bar.value))
	var max_health := maxf(float(snapshot.get(&"max_health", health_bar.max_value)), 1.0)
	var stamina := float(snapshot.get(&"stamina", stamina_bar.value))
	var max_stamina := maxf(float(snapshot.get(&"max_stamina", stamina_bar.max_value)), 1.0)
	health_bar.max_value = max_health
	health_bar.value = clampf(health, 0.0, max_health)
	stamina_bar.max_value = max_stamina
	stamina_bar.value = clampf(stamina, 0.0, max_stamina)
	health_label.text = "%d / %d" % [roundi(health_bar.value), roundi(max_health)]
	stamina_label.text = "%d / %d" % [roundi(stamina_bar.value), roundi(max_stamina)]
	level_label.text = "CẤP %d" % int(snapshot.get(&"level", 1))
	gold_label.text = str(int(snapshot.get(&"gold", 0)))


func refresh_from_state() -> Dictionary:
	var snapshot: Dictionary = {
		&"level": GameState.level,
		&"gold": GameState.get_currency(GameIds.CURRENCY_GOLD),
	}
	if is_instance_valid(_player):
		if _player.has_method(&"get_health"):
			snapshot[&"health"] = float(_player.call(&"get_health"))
		if _player.has_method(&"get_max_health"):
			snapshot[&"max_health"] = float(_player.call(&"get_max_health"))
		if _player.has_method(&"get_stamina"):
			snapshot[&"stamina"] = float(_player.call(&"get_stamina"))
		if _player.has_method(&"get_max_stamina"):
			snapshot[&"max_stamina"] = float(_player.call(&"get_max_stamina"))
	apply_snapshot(snapshot)
	return snapshot


func set_clock(hour: float) -> void:
	clock_label.text = PixelTheme.format_clock(hour)


func set_area(map_id: StringName, custom_name: String = "") -> void:
	area_label.text = custom_name if not custom_name.is_empty() else PixelTheme.format_area(map_id)


func set_weapon(item_id: StringName) -> void:
	weapon_icon.texture = PixelTheme.load_icon(PixelTheme.icon_path_for_item(item_id)) if item_id != &"" else PixelTheme.load_icon("res://assets/art/pixel/ui/icon_sword.svg")
	weapon_label.text = PixelTheme.humanize_id(item_id)
	weapon_icon.tooltip_text = weapon_label.text


func set_item(item_id: StringName, quantity: int) -> void:
	item_icon.texture = PixelTheme.load_icon(PixelTheme.icon_path_for_item(item_id)) if item_id != &"" else PixelTheme.load_icon("res://assets/art/pixel/ui/icon_potion.svg")
	item_label.text = "x%d" % quantity if quantity > 0 else "--"
	item_icon.tooltip_text = PixelTheme.humanize_id(item_id)


func get_last_snapshot() -> Dictionary:
	return _last_snapshot.duplicate(true)


func _connect_player(player: Node) -> void:
	if player.has_signal(&"health_changed") and not player.is_connected(&"health_changed", _on_vitals_changed):
		player.connect(&"health_changed", _on_vitals_changed)
	if player.has_signal(&"stamina_changed") and not player.is_connected(&"stamina_changed", _on_vitals_changed):
		player.connect(&"stamina_changed", _on_vitals_changed)


func _disconnect_player(player: Node) -> void:
	if player.has_signal(&"health_changed") and player.is_connected(&"health_changed", _on_vitals_changed):
		player.disconnect(&"health_changed", _on_vitals_changed)
	if player.has_signal(&"stamina_changed") and player.is_connected(&"stamina_changed", _on_vitals_changed):
		player.disconnect(&"stamina_changed", _on_vitals_changed)


func _on_vitals_changed(_current: float, _maximum: float) -> void:
	refresh_from_state()
