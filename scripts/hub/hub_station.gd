class_name HubStation
extends Interactable

@export var station_id: StringName = &"station"

func _ready() -> void:
    add_to_group(HubConstants.GROUP_HUB_STATION)

func interact(actor: Node) -> void:
    super.interact(actor)
    if not enabled:
        return
    HubServices.emit_event(HubConstants.EVENT_STATION_INTERACTED, {"station_id": station_id, "actor": actor})
    HubServices.request_panel(station_id)
    HubServices.open_station_ui(self)

func get_station_type() -> StringName:
    return station_id
