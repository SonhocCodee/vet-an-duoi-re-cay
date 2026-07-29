class_name PixelUiTheme
extends RefCounted

const INK: Color = Color("2a1b19")
const PANEL: Color = Color("ead8aa")
const PANEL_ALT: Color = Color("c99a62")
const BORDER: Color = Color("70452f")
const GOLD: Color = Color("d99b3d")
const TEXT: Color = Color("3a2420")
const MUTED: Color = Color("6f5746")
const HEALTH: Color = Color("d95763")
const STAMINA: Color = Color("67c77b")
const FOCUS: Color = Color("77d5dc")


static func make_panel(fill: Color = PANEL, border: Color = BORDER, width: int = 3) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = fill
	style.border_color = border
	style.border_width_left = width
	style.border_width_top = width
	style.border_width_right = width
	style.border_width_bottom = width
	style.corner_radius_top_left = 0
	style.corner_radius_top_right = 0
	style.corner_radius_bottom_left = 0
	style.corner_radius_bottom_right = 0
	style.shadow_color = Color(0.18, 0.10, 0.07, 0.35)
	style.shadow_size = 4
	style.shadow_offset = Vector2(4.0, 4.0)
	return style


static func make_bar(fill: Color) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = fill
	style.corner_radius_top_left = 0
	style.corner_radius_top_right = 0
	style.corner_radius_bottom_left = 0
	style.corner_radius_bottom_right = 0
	return style


static func style_button(button: Button, selected: bool = false) -> void:
	button.add_theme_color_override(&"font_color", TEXT)
	button.add_theme_color_override(&"font_hover_color", Color("fff4cf"))
	button.add_theme_color_override(&"font_pressed_color", INK)
	button.add_theme_stylebox_override(&"normal", make_panel(PANEL_ALT, BORDER, 2))
	button.add_theme_stylebox_override(&"hover", make_panel(Color("ddb77a"), GOLD, 2))
	button.add_theme_stylebox_override(&"pressed", make_panel(GOLD, Color("f4cf75"), 2))
	button.add_theme_stylebox_override(&"focus", make_panel(PANEL_ALT, FOCUS, 2))
	if selected:
		button.add_theme_stylebox_override(&"normal", make_panel(Color("ddb77a"), GOLD, 2))


static func clear_children(container: Node) -> void:
	for child: Node in container.get_children():
		child.queue_free()


static func humanize_id(value: StringName) -> String:
	if value == &"":
		return "Trống"
	var display_names: Dictionary = {
		&"ash_coin": "Đồng tro",
		&"blackstone_armor": "Giáp đá đen",
		&"cracked_crown": "Vương miện nứt",
		&"flooded_steel_ore": "Quặng thép ngập",
		&"forged_decree": "Sắc lệnh rèn",
		&"frost_guard_helm": "Mũ vệ binh băng",
		&"gold": "Vàng",
		&"grave_token": "Thẻ mộ",
		&"hunter_bow": "Cung thợ săn",
		&"iron_sword": "Kiếm sắt",
		&"poison_herb": "Dược thảo độc",
		&"quartz_crystal": "Tinh thể thạch anh",
		&"root_herb": "Thảo dược rễ",
		&"rough_root_stone": "Đá rễ thô",
		&"sacred_beast_mark": "Dấu thú thiêng",
		&"scribe_dagger": "Dao găm thư lại",
		&"silverleaf_herb": "Cỏ lá bạc",
		&"silver_moon_armor": "Giáp trăng bạc",
		&"small_focus_flask": "Bình tập trung",
		&"small_health_potion": "Thuốc hồi máu",
		&"stamina_potion": "Thuốc thể lực",
		&"thirteenth_grave_key": "Chìa mộ thứ mười ba",
		&"traveler_leather_armor": "Giáp da lữ khách",
		&"watch_halberd": "Kích tuần vệ",
		&"nameless_blade_fragment": "Mảnh kiếm vô danh",
	}
	return String(display_names.get(value, String(value).replace("_", " ").capitalize()))


static func format_clock(hour: float) -> String:
	var normalized := fposmod(hour, 24.0)
	var hour_value := int(floor(normalized))
	var minute_value := int(round((normalized - float(hour_value)) * 60.0))
	if minute_value >= 60:
		hour_value = (hour_value + 1) % 24
		minute_value = 0
	return "%02d:%02d" % [hour_value, minute_value]


static func format_area(map_id: StringName) -> String:
	var known_names: Dictionary = {
		&"map_1": "Rừng Thức Tỉnh",
		&"map_2": "Đường Tro Tàn",
		&"map_3": "Thành Ashen",
		&"map1_awakening_forest": "Rừng Thức Tỉnh",
		&"map2_tutorial_road": "Đường Tro Tàn",
		&"map3_ashen_town_hub": "Thành Ashen",
		&"ashen_city": "Thành Ashen",
		&"chapter_2_drowned_bells": "Chuông Chìm Dưới Nước",
		&"chapter_3_blind_procession": "Thánh Lộ Mù",
		&"chapter_4_erased_archive": "Thư Viện Tên Bị Xóa",
		&"chapter_5_quartz_wastes": "Hoang Mạc Thạch Anh",
		&"chapter_6_burning_root_garden": "Vườn Rễ Thiêu",
		&"chapter_7_black_resin_pass": "Đèo Hắc Tín",
		&"chapter_8_empty_monastery": "Tu Viện Rỗng",
		&"chapter_9_false_sun_citadel": "Thành Mặt Trời Giả",
		&"chapter_10_world_root": "Tâm Rễ Asterion",
		&"true_ending": "Rễ Cây Thế Giới",
	}
	return String(known_names.get(map_id, humanize_id(map_id)))


static func icon_path_for_item(item_id: StringName) -> String:
	var value := String(item_id).to_lower()
	if value.contains("potion") or value.contains("flask"):
		return "res://assets/art/pixel/ui/icon_potion.svg"
	if value.contains("sword") or value.contains("blade") or value.contains("dagger") or value.contains("bow") or value.contains("halberd"):
		return "res://assets/art/pixel/ui/icon_sword.svg"
	if value.contains("armor") or value.contains("helm") or value.contains("leather"):
		return "res://assets/art/pixel/ui/icon_armor.svg"
	return "res://assets/art/pixel/ui/icon_material.svg"


static func load_icon(resource_path: String) -> Texture2D:
	if not ResourceLoader.exists(resource_path):
		return null
	return ResourceLoader.load(resource_path) as Texture2D
