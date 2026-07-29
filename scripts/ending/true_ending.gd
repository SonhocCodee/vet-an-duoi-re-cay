class_name TrueEndingScreen
extends Control

enum ReturnMode { TITLE, HUB }

const HUB_MAP_ID: StringName = &"map3_ashen_town_hub"
const DEFAULT_SPAWN_ID: StringName = &"default"
const MAIN_SCENE_PATH: String = "res://scenes/bootstrap/main.tscn"

@export var auto_return_seconds: float = 0.0
@export var auto_return_mode: ReturnMode = ReturnMode.HUB
@export_file("*.tscn") var title_scene_path: String = "res://scenes/title/title_screen.tscn"

@onready var epilogue_label: Label = %Epilogue
@onready var moral_summary_label: Label = %MoralSummary
@onready var auto_return_label: Label = %AutoReturn
@onready var auto_timer: Timer = %AutoTimer

func _ready() -> void:
    %ReturnTitle.pressed.connect(return_to_title)
    %ReturnHub.pressed.connect(return_to_hub)
    auto_timer.timeout.connect(_on_auto_return_timeout)
    epilogue_label.text = _epilogue_text()
    moral_summary_label.text = build_moral_summary()
    if auto_return_seconds > 0.0:
        auto_timer.start(auto_return_seconds)
        set_process(true)
    else:
        auto_return_label.visible = false
        set_process(false)

func _process(_delta: float) -> void:
    auto_return_label.text = "Tự động tiếp tục sau %.1f giây" % auto_timer.time_left

func build_moral_summary() -> String:
    var state: Node = _singleton(&"GameState")
    var choices: Dictionary = _collect_moral_choices(state)
    var compassion: int = 0
    var truth: int = 0
    var sacrifice: int = 0
    var other: int = 0
    for raw_key: Variant in choices:
        var value: Variant = choices[raw_key]
        if not _choice_was_made(value):
            continue
        var searchable: String = (str(raw_key) + " " + str(value)).to_lower()
        if _contains_any(searchable, ["mercy", "spare", "forgive", "compassion", "tha_thu", "cuu", "long_tot"]):
            compassion += 1
        elif _contains_any(searchable, ["truth", "reveal", "honesty", "su_that", "phoi_bay"]):
            truth += 1
        elif _contains_any(searchable, ["sacrifice", "hy_sinh", "save_world", "world_root", "giu_re"]):
            sacrifice += 1
        else:
            other += 1
    var total: int = compassion + truth + sacrifice + other
    var level: int = 1
    var class_name_text: String = "Kẻ Giữ Rễ"
    if state != null:
        level = int(_read_property(state, [&"level", &"player_level"], 1))
        class_name_text = str(_read_property(state, [&"current_class", &"active_class"], class_name_text))
    if total == 0:
        return "HÀNH TRÌNH CỦA KAEL
Cấp %d · %s
Không có dữ liệu lựa chọn đạo đức trong GameState." % [level, class_name_text]
    return "HÀNH TRÌNH CỦA KAEL
Cấp %d · %s
Lựa chọn đã ghi nhận: %d
• Lòng trắc ẩn: %d
• Bảo vệ sự thật: %d
• Chấp nhận hy sinh: %d
• Lựa chọn khác: %d" % [level, class_name_text, total, compassion, truth, sacrifice, other]

func return_to_title() -> void:
    var router: Node = _singleton(&"SceneRouter")
    for method_name: StringName in [&"return_to_title", &"go_to_title"]:
        if router != null and router.has_method(method_name):
            router.call(method_name)
            return
    if ResourceLoader.exists(title_scene_path):
        get_tree().change_scene_to_file(title_scene_path)
    elif ResourceLoader.exists(MAIN_SCENE_PATH):
        get_tree().change_scene_to_file(MAIN_SCENE_PATH)

func return_to_hub() -> void:
    var state: Node = _singleton(&"GameState")
    _write_property(state, [&"current_map"], HUB_MAP_ID)
    _write_property(state, [&"current_spawn"], DEFAULT_SPAWN_ID)
    var router: Node = _singleton(&"SceneRouter")
    var player: Variant = null if router == null or not router.has_method(&"get_player") else router.call(&"get_player")
    var events: Node = _singleton(&"GameEvents")
    if player != null and events != null and events.has_signal(&"map_change_requested"):
        events.emit_signal(&"map_change_requested", HUB_MAP_ID, DEFAULT_SPAWN_ID)
        return
    if ResourceLoader.exists(MAIN_SCENE_PATH):
        get_tree().change_scene_to_file(MAIN_SCENE_PATH)

func _on_auto_return_timeout() -> void:
    if auto_return_mode == ReturnMode.TITLE:
        return_to_title()
    else:
        return_to_hub()

func _epilogue_text() -> String:
    return "Kael Asterion đặt bàn tay lên Căn Rễ và gọi lại cái tên mà thế giới đã cố xóa.

Không có khúc khải hoàn. Không có Giáo Hội nào thú nhận lời dối trá. Chỉ có những chiếc đinh Ánh Sáng lần lượt rời khỏi thân cây, và Hư Vô thôi gào khóc như một vết thương cuối cùng được nhìn nhận.

Aria ở lại dựng lại những ngôi nhà mình từng không thể bảo vệ. Elysia mở kho lưu trữ cấm để mọi người tự đọc sự thật. Cecilia từ chối ngai Thánh Nữ và đi giữa những người sống sót bằng chính đôi chân mình.

Cây Thế Giới hồi phục chậm. Mùa màng đầu tiên vẫn nghèo nàn. Nhiều người vẫn gọi Kael là Ma Vương.

Nhưng dưới những rễ cây đang nảy mầm, bóng tối cuối cùng đã nhớ đúng tên anh: Kẻ Giữ Rễ."

func _collect_moral_choices(state: Node) -> Dictionary:
    if state == null:
        return {}
    for method_name: StringName in [&"get_moral_choices", &"get_moral_summary"]:
        if state.has_method(method_name):
            var result: Variant = state.call(method_name)
            if result is Dictionary:
                return (result as Dictionary).duplicate(true)
    var merged: Dictionary = {}
    for property_name: StringName in [&"moral_choices", &"choices", &"flags"]:
        var value: Variant = _read_property(state, [property_name], null)
        if value is Dictionary:
            merged.merge(value as Dictionary, true)
    return merged

func _choice_was_made(value: Variant) -> bool:
    if value is bool:
        return bool(value)
    if value is int or value is float:
        return not is_zero_approx(float(value))
    if value is String or value is StringName:
        var text: String = str(value).strip_edges().to_lower()
        return not text.is_empty() and text not in ["false", "none", "neutral", "unmade"]
    return value != null

func _contains_any(text: String, needles: Array[String]) -> bool:
    for needle: String in needles:
        if needle in text:
            return true
    return false

func _singleton(singleton_name: StringName) -> Node:
    return get_tree().root.get_node_or_null(NodePath(String(singleton_name)))

func _read_property(target: Object, property_names: Array[StringName], fallback: Variant) -> Variant:
    if target == null:
        return fallback
    var properties: Dictionary = {}
    for property: Dictionary in target.get_property_list():
        properties[StringName(property.get("name", &""))] = true
    for property_name: StringName in property_names:
        if properties.has(property_name):
            return target.get(property_name)
    return fallback

func _write_property(target: Object, property_names: Array[StringName], value: Variant) -> bool:
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
