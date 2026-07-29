class_name CampaignGateInjector
extends Node

func _ready() -> void:
	GameEvents.map_changed.connect(_on_map_changed)

func _on_map_changed(map_id: StringName, _spawn_id: StringName) -> void:
	if map_id != GameIds.MAP_3:
		return
	await get_tree().process_frame
	var active_map: Node = SceneRouter.get_active_map()
	if active_map == null or active_map.get_node_or_null("CampaignDepartureGate") != null:
		return
	var gate := CampaignDepartureGate.new()
	gate.name = "CampaignDepartureGate"
	active_map.add_child(gate)
	gate.global_position = Vector2(1160.0, 360.0)
