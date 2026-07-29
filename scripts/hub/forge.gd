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
    _normalize_sockets()
    super._ready()

func get_runes() -> Array[HubRuneData]:
    return HubRuneCatalog.all()

func enhance() -> Dictionary:
    if enhancement_level >= MAX_ENHANCEMENT:
        return {"ok": false, "message": "Trang bị đã đạt +10.", "level": enhancement_level}
    var target_level: int = enhancement_level + 1
    var success_rate: float = float(SUCCESS_RATES[target_level])
    var state_result: Variant = HubServices.call_game_state(
        [&"request_forge_enhancement", &"enhance_item"],
        [target_item_id, enhancement_level, target_level, success_rate]
    )
    if state_result is Dictionary and not bool((state_result as Dictionary).get("allowed", true)):
        return state_result as Dictionary
    var succeeded: bool = force_success_for_tests or _rng.randf() <= success_rate
    if state_result is Dictionary and (state_result as Dictionary).has("success"):
        succeeded = bool((state_result as Dictionary)["success"])
    if succeeded:
        enhancement_level = target_level
    elif target_level >= 7:
        enhancement_level = 6
    elif enhancement_level >= 3:
        enhancement_level -= 1
    HubServices.call_game_state([&"set_item_enhancement", &"sync_item_enhancement"], [target_item_id, enhancement_level])
    var payload: Dictionary = {
        "item_id": target_item_id,
        "success": succeeded,
        "level": enhancement_level,
        "target_level": target_level,
        "success_rate": success_rate,
    }
    HubServices.emit_event(HubConstants.EVENT_ITEM_ENHANCED, payload)
    var message: String = "Cường hóa thành công: +%d" % enhancement_level if succeeded else "Cường hóa thất bại, còn +%d" % enhancement_level
    return {"ok": true, "success": succeeded, "message": message, "level": enhancement_level}

func socket_rune(slot_index: int, rune_id: StringName) -> Dictionary:
    _normalize_sockets()
    if slot_index < 0 or slot_index >= SOCKET_COUNT:
        return {"ok": false, "message": "Ô khảm không hợp lệ."}
    var rune: HubRuneData = HubRuneCatalog.find_by_id(rune_id)
    if rune == null:
        return {"ok": false, "message": "Không tìm thấy Cổ Ấn."}
    var state_result: Variant = HubServices.call_game_state(
        [&"socket_rune", &"set_item_socket"],
        [target_item_id, slot_index, rune_id]
    )
    if state_result == false:
        return {"ok": false, "message": "Không thể khảm Cổ Ấn."}
    sockets[slot_index] = rune_id
    HubServices.emit_event(HubConstants.EVENT_RUNE_SOCKETED, {
        "item_id": target_item_id,
        "slot_index": slot_index,
        "rune_id": rune_id,
    })
    return {"ok": true, "message": "Đã khảm %s vào ô %d." % [rune.display_name, slot_index + 1]}

func remove_rune(slot_index: int) -> Dictionary:
    _normalize_sockets()
    if slot_index < 0 or slot_index >= SOCKET_COUNT:
        return {"ok": false, "message": "Ô khảm không hợp lệ."}
    HubServices.call_game_state([&"remove_rune", &"clear_item_socket"], [target_item_id, slot_index])
    sockets[slot_index] = &""
    return {"ok": true, "message": "Đã tháo Cổ Ấn."}

func _normalize_sockets() -> void:
    while sockets.size() < SOCKET_COUNT:
        sockets.append(&"")
    if sockets.size() > SOCKET_COUNT:
        sockets.resize(SOCKET_COUNT)
