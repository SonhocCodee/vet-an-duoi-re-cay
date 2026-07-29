class_name LootItemPickup
extends Node2D

signal collected(item_id: StringName, amount: int)

const PLAYER_GROUP: StringName = &"player"
const COLLECT_LOOT_METHOD: StringName = &"collect_loot"

@export_range(1.0, 500.0, 1.0) var magnet_radius: float = 100.0
@export_range(1.0, 1000.0, 1.0) var magnet_speed: float = 280.0
@export_range(1.0, 64.0, 1.0) var collect_radius: float = 12.0

@onready var visual: LootPickupVisual = get_node_or_null(^"Visual") as LootPickupVisual

var item_id: StringName = &"item"
var display_name: String = "Item"
var amount: int = 1
var rarity: LootEntry.Rarity = LootEntry.Rarity.COMMON

var _target: Node2D
var _collected: bool = false


func _ready() -> void:
	add_to_group(&"loot_pickup")
	_refresh_visual()


func _physics_process(delta: float) -> void:
	if _collected:
		return
	if not is_instance_valid(_target):
		_target = _nearest_player()
	if not is_instance_valid(_target):
		return
	var distance: float = global_position.distance_to(_target.global_position)
	if distance > magnet_radius:
		_target = null
		return
	global_position = global_position.move_toward(_target.global_position, magnet_speed * delta)
	if global_position.distance_to(_target.global_position) <= collect_radius:
		_collect()


func configure(
	p_item_id: StringName,
	p_display_name: String,
	p_amount: int,
	p_rarity: LootEntry.Rarity
) -> void:
	item_id = p_item_id
	display_name = p_display_name
	amount = maxi(p_amount, 1)
	rarity = p_rarity
	_refresh_visual()


func _nearest_player() -> Node2D:
	var nearest: Node2D
	var nearest_distance_squared: float = magnet_radius * magnet_radius
	var players: Array[Node] = get_tree().get_nodes_in_group(PLAYER_GROUP)
	for player: Node in players:
		if not player is Node2D:
			continue
		var candidate: Node2D = player as Node2D
		var distance_squared: float = global_position.distance_squared_to(candidate.global_position)
		if distance_squared <= nearest_distance_squared:
			nearest = candidate
			nearest_distance_squared = distance_squared
	if nearest == null:
		var fallback: Node = get_tree().root.find_child("Player", true, false)
		if fallback is Node2D and global_position.distance_squared_to((fallback as Node2D).global_position) <= nearest_distance_squared:
			nearest = fallback as Node2D
	return nearest


func _collect() -> void:
	_collected = true
	if _target.has_method(COLLECT_LOOT_METHOD):
		_target.call(COLLECT_LOOT_METHOD, item_id, amount)
	else:
		_store_in_game_state()
	collected.emit(item_id, amount)
	queue_free()


func _store_in_game_state() -> void:
	var game_state: Node = get_node_or_null(^"/root/GameState")
	if game_state == null:
		return
	if item_id == GameIds.CURRENCY_GOLD or item_id == GameIds.CURRENCY_SOUL_SHARD:
		game_state.call(&"add_currency", item_id, amount)
	else:
		game_state.call(&"add_item", item_id, amount)


func _refresh_visual() -> void:
	if visual != null:
		visual.set_rarity(rarity)
