class_name AshenTownHub
extends Node2D

const DEFAULT_SPAWN: StringName = &"default"

func _ready() -> void:
    var state: Node = HubServices.singleton(HubServices.GAME_STATE_NAME)
    HubServices.write_first_property(state, [&"current_map"], HubConstants.MAP_ID)
    HubServices.write_first_property(state, [&"current_spawn"], HubConstants.SPAWN_DEFAULT)
    call_deferred(&"_show_arrival_tutorial")

func get_spawn_point(spawn_id: StringName = DEFAULT_SPAWN) -> Marker2D:
    var named_spawn: Node = $SpawnPoints.get_node_or_null(NodePath(String(spawn_id)))
    if named_spawn is Marker2D:
        return named_spawn as Marker2D
    return $SpawnPoints/default as Marker2D

func get_spawn_points() -> Array[Marker2D]:
    var result: Array[Marker2D] = []
    for child: Node in $SpawnPoints.get_children():
        if child is Marker2D:
            result.append(child as Marker2D)
    return result

func _show_arrival_tutorial() -> void:
    var ui: Node = get_tree().get_first_node_in_group(HubConstants.GROUP_HUB_UI)
    if ui != null and ui.has_method(&"show_tutorial"):
        ui.call(&"show_tutorial", "Thị Trấn Gió Than", "Đến gần Bàn Lửa, Lò Rèn, Dược Sĩ hoặc Bảng Cáo Thị rồi nhấn tương tác.")
