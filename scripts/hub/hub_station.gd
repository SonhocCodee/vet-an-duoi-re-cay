class_name HubStation
extends Area2D

signal interaction_availability_changed(station: HubStation, available: bool)

@export var station_id: StringName = &"station"
@export var prompt_text: String = "Tương tác"

func _ready() -> void:
    add_to_group(HubConstants.GROUP_HUB_STATION)
    body_entered.connect(_on_body_entered)
    body_exited.connect(_on_body_exited)

func interact(actor: Node) -> void:
    HubServices.emit_event(HubConstants.EVENT_STATION_INTERACTED, {
        "station_id": station_id,
        "actor": actor,
    })
    HubServices.open_station_ui(self)

func get_station_type() -> StringName:
    return station_id

func _on_body_entered(body: Node2D) -> void:
    if _is_player(body):
        interaction_availability_changed.emit(self, true)
        var ui: Node = get_tree().get_first_node_in_group(HubConstants.GROUP_HUB_UI)
        if ui != null and ui.has_method(&"show_interaction"):
            ui.call(&"show_interaction", self, prompt_text)

func _on_body_exited(body: Node2D) -> void:
    if _is_player(body):
        interaction_availability_changed.emit(self, false)
        var ui: Node = get_tree().get_first_node_in_group(HubConstants.GROUP_HUB_UI)
        if ui != null and ui.has_method(&"hide_interaction"):
            ui.call(&"hide_interaction", self)

func _is_player(body: Node) -> bool:
    return body.is_in_group(&"player") or body.has_method(&"get_interaction_origin")
