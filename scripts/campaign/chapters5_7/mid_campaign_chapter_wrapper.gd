class_name MidCampaignChapterWrapper
extends Node2D

signal chapter_adapter_ready(definition: Resource, campaign_map: Node)
signal chapter_completed(chapter_id: StringName)

const CAMPAIGN_MAP_SCRIPT_PATH: String = "res://scripts/campaign/map/campaign_chapter_map.gd"
const CAMPAIGN_MAP_CLASS: StringName = &"CampaignChapterMap"
const ChapterDefinitionType = preload("res://scripts/campaign/data/chapter_definition.gd")

@export_file("*.tres") var definition_resource_path: String = ""

var campaign_map: Node
var chapter_definition: ChapterDefinitionType


func _ready() -> void:
	add_to_group(&"campaign_chapter_wrapper")
	chapter_definition = _load_chapter_definition()
	if chapter_definition == null:
		push_error("Missing ChapterDefinition: %s" % definition_resource_path)
		return
	set_meta(&"chapter_id", chapter_definition.chapter_id)
	set_meta(&"chapter_number", chapter_definition.chapter_number)
	set_meta(&"chapter_definition_path", definition_resource_path)
	campaign_map = _instantiate_campaign_map()
	if campaign_map == null:
		push_error("CampaignChapterMap is unavailable: %s" % CAMPAIGN_MAP_SCRIPT_PATH)
		chapter_adapter_ready.emit(chapter_definition, campaign_map)
		return
	_prepare_campaign_map(campaign_map)
	var socket: Node = get_node_or_null("GenericMapSocket")
	(socket if socket != null else self).add_child(campaign_map)
	_apply_chapter_palette(campaign_map)
	_connect_completion_signal(campaign_map)
	chapter_adapter_ready.emit(chapter_definition, campaign_map)


func get_campaign_map() -> Node:
	return campaign_map


func get_chapter_definition() -> ChapterDefinitionType:
	return chapter_definition


func complete_chapter() -> void:
	if chapter_definition != null:
		chapter_completed.emit(chapter_definition.chapter_id)


func _load_chapter_definition() -> ChapterDefinitionType:
	if definition_resource_path.is_empty() or not ResourceLoader.exists(definition_resource_path):
		return null
	var definition: ChapterDefinitionType = load(definition_resource_path) as ChapterDefinitionType
	if definition == null:
		return null
	var validation_errors: Array[String] = definition.get_validation_errors()
	if not validation_errors.is_empty():
		push_error("Invalid ChapterDefinition %s: %s" % [definition_resource_path, ", ".join(validation_errors)])
		return null
	return definition


func _instantiate_campaign_map() -> Node:
	if ResourceLoader.exists(CAMPAIGN_MAP_SCRIPT_PATH):
		var campaign_script: Script = load(CAMPAIGN_MAP_SCRIPT_PATH) as Script
		if campaign_script != null:
			return campaign_script.new() as Node
	for entry: Dictionary in ProjectSettings.get_global_class_list():
		if StringName(entry.get(&"class", &"")) != CAMPAIGN_MAP_CLASS:
			continue
		var script_path: String = str(entry.get(&"path", ""))
		if script_path.is_empty() or not ResourceLoader.exists(script_path):
			return null
		var global_script: Script = load(script_path) as Script
		return null if global_script == null else global_script.new() as Node
	return null


func _prepare_campaign_map(target: Node) -> void:
	target.set(&"chapter_id", chapter_definition.chapter_id)
	target.set(&"chapter_resource_path", definition_resource_path)
	target.set_meta(&"source_chapter_resource_path", definition_resource_path)


func _apply_chapter_palette(target: Node) -> void:
	var palette: Array[Color] = chapter_definition.palette_colors
	_set_first_supported(target, [&"_ground_color"], chapter_definition.background_color)
	if palette.size() >= 3:
		_set_first_supported(target, [&"_path_color"], palette[1])
		_set_first_supported(target, [&"_accent_color"], palette[2])
	if target is CanvasItem:
		(target as CanvasItem).queue_redraw()


func _connect_completion_signal(target: Node) -> void:
	for signal_name: StringName in [&"chapter_completed", &"chapter_finished"]:
		if not target.has_signal(signal_name):
			continue
		var callback: Callable = _on_generic_chapter_completed
		if not target.is_connected(signal_name, callback):
			target.connect(signal_name, callback)
		return


func _on_generic_chapter_completed(_payload: Variant = null) -> void:
	complete_chapter()


func _set_first_supported(target: Object, property_names: Array[StringName], value: Variant) -> bool:
	var properties: Dictionary = {}
	for property_data: Dictionary in target.get_property_list():
		properties[StringName(property_data.get(&"name", &""))] = true
	for property_name: StringName in property_names:
		if properties.has(property_name):
			target.set(property_name, value)
			return true
	return false
