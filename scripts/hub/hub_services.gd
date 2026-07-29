class_name HubServices
extends RefCounted

const GAME_STATE_NAME: StringName = &"GameState"
const SAVE_SERVICE_NAME: StringName = &"SaveService"
const GAME_EVENTS_NAME: StringName = &"GameEvents"

static func singleton(singleton_name: StringName) -> Node:
    var tree: SceneTree = Engine.get_main_loop() as SceneTree
    if tree == null:
        return null
    return tree.root.get_node_or_null(NodePath(String(singleton_name)))

static func player() -> Node:
    var tree: SceneTree = Engine.get_main_loop() as SceneTree
    return null if tree == null else tree.get_first_node_in_group(&"player")

static func call_game_state(method_names: Array[StringName], arguments: Array = []) -> Variant:
    return call_first(singleton(GAME_STATE_NAME), method_names, arguments)

static func call_save_service(method_names: Array[StringName], arguments: Array = []) -> Variant:
    return call_first(singleton(SAVE_SERVICE_NAME), method_names, arguments)

static func call_first(target: Node, method_names: Array[StringName], arguments: Array = []) -> Variant:
    if target == null:
        return null
    for method_name: StringName in method_names:
        if target.has_method(method_name):
            return target.callv(method_name, arguments)
    return null

static func request_panel(panel_id: StringName) -> void:
    var events: Node = singleton(GAME_EVENTS_NAME)
    if events != null and events.has_signal(&"hub_panel_requested"):
        events.emit_signal(&"hub_panel_requested", panel_id)

static func toast(message: String) -> void:
    var events: Node = singleton(GAME_EVENTS_NAME)
    if events != null and events.has_signal(&"toast_requested"):
        events.emit_signal(&"toast_requested", message)

static func emit_event(event_name: StringName, payload: Dictionary = {}) -> void:
    var events: Node = singleton(GAME_EVENTS_NAME)
    if events == null:
        return
    if events.has_method(&"emit_event"):
        events.call(&"emit_event", event_name, payload)
    elif events.has_method(&"publish"):
        events.call(&"publish", event_name, payload)

static func open_station_ui(station: Node) -> void:
    if station == null or station.get_tree() == null:
        return
    var ui: Node = station.get_tree().get_first_node_in_group(HubConstants.GROUP_HUB_UI)
    if ui != null and ui.has_method(&"open_station"):
        ui.call(&"open_station", station)

static func read_number(property_names: Array[StringName], fallback: float) -> float:
    var value: Variant = read_first_property(singleton(GAME_STATE_NAME), property_names)
    return float(value) if value is int or value is float else fallback

static func read_int(property_names: Array[StringName], fallback: int) -> int:
    return int(read_number(property_names, float(fallback)))

static func read_text(property_names: Array[StringName], fallback: String) -> String:
    var value: Variant = read_first_property(singleton(GAME_STATE_NAME), property_names)
    return fallback if value == null else str(value)

static func call_number(target: Node, method_names: Array[StringName], fallback: float) -> float:
    var value: Variant = call_first(target, method_names)
    return float(value) if value is int or value is float else fallback

static func read_first_property(target: Object, property_names: Array[StringName]) -> Variant:
    if target == null:
        return null
    var available: Dictionary = {}
    for property: Dictionary in target.get_property_list():
        available[StringName(property.get("name", ""))] = true
    for property_name: StringName in property_names:
        if available.has(property_name):
            return target.get(property_name)
    return null

static func write_first_property(target: Object, property_names: Array[StringName], value: Variant) -> bool:
    if target == null:
        return false
    var available: Dictionary = {}
    for property: Dictionary in target.get_property_list():
        available[StringName(property.get("name", ""))] = true
    for property_name: StringName in property_names:
        if available.has(property_name):
            target.set(property_name, value)
            return true
    return false
