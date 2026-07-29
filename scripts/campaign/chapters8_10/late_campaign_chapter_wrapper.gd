class_name LateCampaignChapterWrapper
extends Node2D

signal chapter_adapter_ready(definition: Resource, campaign_map: Node)
signal chapter_completed(chapter_id: StringName)

const CAMPAIGN_MAP_CLASS: StringName = &"CampaignChapterMap"
const CHAPTER_DEFINITION_CLASS: StringName = &"ChapterDefinition"

@export var chapter_id: StringName
@export_range(8, 10, 1) var chapter_number: int = 8
@export var chapter_title: String = "Chương Cuối"
@export_multiline var chapter_objective: String = "Tiến sâu vào vùng chiến dịch."
@export var boss_id: StringName
@export var next_chapter_id: StringName
@export var definition_resource_path: String = ""
@export var auto_complete_on_boss_defeated := true

var campaign_map: Node
var chapter_definition: Resource

func _ready() -> void:
    add_to_group(&"campaign_chapter_wrapper")
    set_meta(&"chapter_id", chapter_id)
    set_meta(&"chapter_number", chapter_number)
    chapter_definition = _resolve_chapter_definition()
    campaign_map = _instantiate_global_node(CAMPAIGN_MAP_CLASS)
    if campaign_map != null:
        _configure_campaign_map(campaign_map, chapter_definition)
        var socket: Node = get_node_or_null("GenericMapSocket")
        (socket if socket != null else self).add_child(campaign_map)
        _connect_completion_signal(campaign_map)
    chapter_adapter_ready.emit(chapter_definition, campaign_map)

func get_campaign_map() -> Node:
    return campaign_map

func get_chapter_definition() -> Resource:
    return chapter_definition

func complete_chapter() -> void:
    chapter_completed.emit(chapter_id)

func _resolve_chapter_definition() -> Resource:
    if not definition_resource_path.is_empty() and ResourceLoader.exists(definition_resource_path):
        var loaded: Resource = load(definition_resource_path) as Resource
        if loaded != null:
            return loaded
    var created: Object = _instantiate_global_class(CHAPTER_DEFINITION_CLASS)
    var definition: Resource = created as Resource
    if definition == null:
        definition = Resource.new()
    _set_first_supported(definition, [&"chapter_id", &"id"], chapter_id)
    _set_first_supported(definition, [&"chapter_number", &"number", &"index"], chapter_number)
    _set_first_supported(definition, [&"title", &"display_name", &"name"], chapter_title)
    _set_first_supported(definition, [&"objective", &"description"], chapter_objective)
    _set_first_supported(definition, [&"boss_id", &"chapter_boss_id"], boss_id)
    _set_first_supported(definition, [&"next_chapter_id", &"next_map_id"], next_chapter_id)
    definition.set_meta(&"chapter_id", chapter_id)
    definition.set_meta(&"chapter_number", chapter_number)
    definition.set_meta(&"title", chapter_title)
    definition.set_meta(&"objective", chapter_objective)
    definition.set_meta(&"boss_id", boss_id)
    definition.set_meta(&"next_chapter_id", next_chapter_id)
    return definition

func _configure_campaign_map(target: Node, definition: Resource) -> void:
    _set_first_supported(target, [&"_chapter_definition", &"chapter_definition", &"definition"], definition)
    _set_first_supported(target, [&"chapter_resource_path"], definition_resource_path)
    _set_first_supported(target, [&"chapter_id", &"map_id"], chapter_id)
    _set_first_supported(target, [&"auto_complete_on_boss_defeated"], auto_complete_on_boss_defeated)
    _set_first_supported(target, [&"spawn_points_path"], NodePath("../SpawnPoints"))
    if not _call_exact(target, [&"configure_chapter", &"configure", &"setup"], [definition]):
        _call_exact(target, [&"set_chapter_definition"], [definition])

func _connect_completion_signal(target: Node) -> void:
    for signal_name: StringName in [&"chapter_completed", &"chapter_finished"]:
        if target.has_signal(signal_name):
            var callback: Callable = _on_generic_chapter_completed
            if not target.is_connected(signal_name, callback):
                target.connect(signal_name, callback)
            return

func _on_generic_chapter_completed(_payload: Variant = null) -> void:
    complete_chapter()

func _instantiate_global_node(target_class_name: StringName) -> Node:
    return _instantiate_global_class(target_class_name) as Node

func _instantiate_global_class(target_class_name: StringName) -> Object:
    for entry: Dictionary in ProjectSettings.get_global_class_list():
        if StringName(entry.get("class", &"")) != target_class_name:
            continue
        var script_path: String = str(entry.get("path", ""))
        if script_path.is_empty() or not ResourceLoader.exists(script_path):
            return null
        var script: Script = load(script_path) as Script
        return null if script == null else script.new()
    return null

func _set_first_supported(target: Object, property_names: Array[StringName], value: Variant) -> bool:
    if target == null:
        return false
    var properties: Dictionary = {}
    for property: Dictionary in target.get_property_list():
        properties[StringName(property.get("name", &""))] = true
    for property_name: StringName in property_names:
        if properties.has(property_name):
            target.set(property_name, value)
            return true
    return false

func _call_exact(target: Object, method_names: Array[StringName], arguments: Array) -> bool:
    if target == null:
        return false
    for method: Dictionary in target.get_method_list():
        var method_name: StringName = StringName(method.get("name", &""))
        if not method_names.has(method_name):
            continue
        var method_arguments: Array = method.get("args", []) as Array
        if method_arguments.size() == arguments.size():
            target.callv(method_name, arguments)
            return true
    return false
