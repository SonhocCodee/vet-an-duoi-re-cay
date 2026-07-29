class_name ForgeStation
extends HubStation

const MAX_ENHANCEMENT: int = 10
const SOCKET_COUNT: int = 3
const SUCCESS_RATES: Dictionary = {
    1: 1.0, 2: 1.0, 3: 1.0,
    4: 0.75, 5: 0.65, 6: 0.55,
    7: 0.45, 8: 0.35, 9: 0.25, 10: 0.15,
}

@export var target_item_id: StringName = &"equipped_weapon"
@export_range(0, MAX_ENHANCEMENT, 1) var enhancement_level: int = 0
@export var sockets: Array[StringName] = [&"", &"", &""]
@export var force_success_for_tests: bool = false

var _rng: RandomNumberGenerator = RandomNumberGenerator.new()

func _ready() -> void:
    station_id = &"forge"
    prompt_text = "Dùng Lò Rèn Rễ Cây"
    _rng.randomize()
    _load_from_game_state()
    _normalize_sockets()
    super._ready()

func get_runes() -> Array[HubRuneData]:
    return HubRuneCatalog.all()

func enhance() -> Dictionary:
    if enhancement_level >= MAX_ENHANCEMENT:
        return {"ok": false, "message": "Trang bị đã đạt +10.", "level": enhancement_level}
    var target_level: int = enhancement_level + 1
    var success_rate: float = float(SUCCESS_RATES[target_level])
    HubServices.call_game_state([&"get_calculated_stats"], [])
    var succeeded: bool = force_success_for_tests or _rng.randf() <= success_rate
    if succeeded:
        enhancement_level = target_level
    elif target_level >= 7:
        enhancement_level = 6
    elif enhancement_level >= 3:
        enhancement_level -= 1
    _save_to_game_state()
    var payload: Dictionary = {
        "item_id": target_item_id,
        "success": succeeded,
        "level": enhancement_level,
        "target_level": target_level,
        "success_rate": success_rate,
    }
    HubServices.emit_event(HubConstants.EVENT_ITEM_ENHANCED, payload)
    var message: String = "Cường hóa thành công: +%d" % enhancement_level if succeeded else "Cường hóa thất bại, còn +%d" % enhancement_level
    HubServices.toast(message)
    return {"ok": true, "success": succeeded, "message": message, "level": enhancement_level}

func socket_rune(slot_index: int, rune_id: StringName) -> Dictionary:
    _normalize_sockets()
    if slot_index < 0 or slot_index >= SOCKET_COUNT:
        return {"ok": false, "message": "Ô khảm không hợp lệ."}
    var rune: HubRuneData = HubRuneCatalog.find_by_id(rune_id)
    if rune == null:
        return {"ok": false, "message": "Không tìm thấy Cổ Ấn."}
    sockets[slot_index] = rune_id
    _save_to_game_state()
    HubServices.emit_event(HubConstants.EVENT_RUNE_SOCKETED, {"item_id": target_item_id, "slot_index": slot_index, "rune_id": rune_id})
    HubServices.toast("Đã khảm %s." % rune.display_name)
    return {"ok": true, "message": "Đã khảm %s vào ô %d." % [rune.display_name, slot_index + 1]}

func remove_rune(slot_index: int) -> Dictionary:
    _normalize_sockets()
    if slot_index < 0 or slot_index >= SOCKET_COUNT:
        return {"ok": false, "message": "Ô khảm không hợp lệ."}
    sockets[slot_index] = &""
    _save_to_game_state()
    return {"ok": true, "message": "Đã tháo Cổ Ấn."}

func _load_from_game_state() -> void:
    var state: Node = HubServices.singleton(HubServices.GAME_STATE_NAME)
    var equipment_value: Variant = HubServices.read_first_property(state, [&"equipment"])
    if equipment_value is not Dictionary:
        return
    var equipment: Dictionary = equipment_value as Dictionary
    enhancement_level = clampi(int(equipment.get(&"weapon_level", enhancement_level)), 0, MAX_ENHANCEMENT)
    var saved_sockets: Variant = equipment.get(&"sockets", [])
    if saved_sockets is Array:
        sockets.clear()
        for rune_id: Variant in saved_sockets:
            sockets.append(StringName(rune_id))

func _save_to_game_state() -> void:
    var state: Node = HubServices.singleton(HubServices.GAME_STATE_NAME)
    if state == null:
        return
    var equipment_value: Variant = HubServices.read_first_property(state, [&"equipment"])
    var equipment: Dictionary = (equipment_value as Dictionary).duplicate(true) if equipment_value is Dictionary else {}
    equipment[&"weapon_level"] = enhancement_level
    equipment[&"sockets"] = sockets.duplicate()
    HubServices.write_first_property(state, [&"equipment"], equipment)
    if state.has_signal(&"stats_changed") and state.has_method(&"get_calculated_stats"):
        state.emit_signal(&"stats_changed", state.call(&"get_calculated_stats"))

func _normalize_sockets() -> void:
    while sockets.size() < SOCKET_COUNT:
        sockets.append(&"")
    if sockets.size() > SOCKET_COUNT:
        sockets.resize(SOCKET_COUNT)
