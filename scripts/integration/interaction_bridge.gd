class_name InteractionBridge
extends Node

var _player: Node2D
var _nearby: Array[Interactable] = []

func configure(player: Node2D) -> void:
	_player = player
	var interaction_area: Area2D = _player.get_node_or_null("InteractionArea") as Area2D
	if interaction_area == null:
		push_warning("Player scene has no InteractionArea; world interactions are disabled.")
		return
	interaction_area.area_entered.connect(_on_area_entered)
	interaction_area.area_exited.connect(_on_area_exited)

func _unhandled_input(event: InputEvent) -> void:
	if not event.is_action_pressed("interact") or _nearby.is_empty():
		return
	var target: Interactable = _nearest_interactable()
	if target != null:
		target.interact(_player)
		get_viewport().set_input_as_handled()

func _on_area_entered(area: Area2D) -> void:
	if area is Interactable:
		_nearby.append(area)
		_update_prompt()

func _on_area_exited(area: Area2D) -> void:
	if area is Interactable:
		_nearby.erase(area)
		_update_prompt()

func _nearest_interactable() -> Interactable:
	var nearest: Interactable
	var nearest_distance: float = INF
	for candidate: Interactable in _nearby:
		if not is_instance_valid(candidate) or not candidate.enabled:
			continue
		var distance: float = _player.global_position.distance_squared_to(candidate.global_position)
		if distance < nearest_distance:
			nearest = candidate
			nearest_distance = distance
	return nearest

func _update_prompt() -> void:
	var nearest: Interactable = _nearest_interactable()
	GameEvents.interaction_prompt_changed.emit(nearest.get_prompt_text() if nearest != null else "", nearest != null)
