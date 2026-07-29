class_name PixelMapPanel
extends PanelContainer

const PixelTheme = preload("res://scripts/ui/pixel/pixel_ui_theme.gd")
const PixelMapCanvasType = preload("res://scripts/ui/pixel/pixel_map_canvas.gd")

@onready var map_canvas: PixelMapCanvasType = %MapCanvas
@onready var marker_list: VBoxContainer = %MarkerList
@onready var empty_label: Label = %MapEmpty
@onready var area_label: Label = %MapAreaLabel

var _markers: Dictionary = {}


func refresh(markers: Dictionary = GameState.discovered_map_markers, map_id: StringName = GameState.current_map) -> void:
	_markers = markers.duplicate(true)
	map_canvas.set_markers(_markers)
	area_label.text = PixelTheme.format_area(map_id).to_upper()
	PixelTheme.clear_children(marker_list)
	var marker_ids: Array = _markers.keys()
	marker_ids.sort_custom(func(a: Variant, b: Variant) -> bool: return String(a) < String(b))
	for marker_value: Variant in marker_ids:
		var marker_id := StringName(str(marker_value))
		var marker_data: Dictionary = _markers.get(marker_value, {}) as Dictionary
		var label := Label.new()
		label.text = "> " + String(marker_data.get(&"label", marker_data.get("label", PixelTheme.humanize_id(marker_id))))
		label.add_theme_color_override(&"font_color", PixelTheme.TEXT)
		label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		marker_list.add_child(label)
	empty_label.visible = marker_ids.is_empty()


func get_marker_count() -> int:
	return map_canvas.get_marker_count()
