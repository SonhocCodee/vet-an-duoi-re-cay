class_name GameplayHudController
extends Control

signal snapshot_changed(snapshot: Dictionary)

var _player: Node
var _last_snapshot: Dictionary = {}


func _ready() -> void:
	GameEvents.player_registered.connect(bind_player)
	GameState.level_changed.connect(_on_state_changed)
	GameState.class_changed.connect(_on_class_changed)
	GameState.inventory_changed.connect(_on_inventory_changed)
	call_deferred(&"_bind_existing_player")
	request_refresh()


func bind_player(player: Node) -> void:
	_player = player
	if player.has_signal(&"health_changed") and not player.health_changed.is_connected(_on_player_vitals_changed):
		player.health_changed.connect(_on_player_vitals_changed)
	if player.has_signal(&"stamina_changed") and not player.stamina_changed.is_connected(_on_player_vitals_changed):
		player.stamina_changed.connect(_on_player_vitals_changed)
	request_refresh()


func request_refresh() -> Dictionary:
	_last_snapshot = build_snapshot()
	snapshot_changed.emit(_last_snapshot.duplicate(true))
	GameEvents.hud_refresh_requested.emit(_last_snapshot.duplicate(true))
	return _last_snapshot.duplicate(true)


func build_snapshot() -> Dictionary:
	var snapshot: Dictionary = {
		&"level": GameState.level,
		&"experience": GameState.experience,
		&"required_experience": GameState.experience_required(),
		&"class_id": GameState.current_class,
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
	return snapshot


func get_last_snapshot() -> Dictionary:
	return _last_snapshot.duplicate(true)


func _bind_existing_player() -> void:
	var player: Node = get_tree().get_first_node_in_group(&"player")
	if player != null:
		bind_player(player)


func _on_state_changed(_a: Variant = null, _b: Variant = null, _c: Variant = null) -> void:
	request_refresh()


func _on_class_changed(_class_id: StringName) -> void:
	request_refresh()


func _on_inventory_changed(_item_id: StringName, _quantity: int) -> void:
	request_refresh()


func _on_player_vitals_changed(_current: float, _maximum: float) -> void:
	request_refresh()
