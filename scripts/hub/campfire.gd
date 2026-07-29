class_name CampfireStation
extends HubStation

func _ready() -> void:
    station_id = &"campfire"
    prompt_text = "Nghỉ tại Bàn Lửa Trại"
    super._ready()

func rest(actor: Node = null) -> Dictionary:
    var result: Variant = HubServices.call_game_state([&"rest_at_campfire", &"rest"], [station_id])
    if result == null:
        var state: Node = HubServices.singleton(HubServices.GAME_STATE_NAME)
        var max_hp: float = HubServices.read_number([&"max_hp", &"hp_max"], 100.0)
        var max_stamina: float = HubServices.read_number([&"max_stamina", &"max_sta", &"stamina_max"], 100.0)
        HubServices.write_first_property(state, [&"hp", &"current_hp"], max_hp)
        HubServices.write_first_property(state, [&"stamina", &"sta", &"current_stamina"], max_stamina)
    var payload: Dictionary = {"station_id": station_id, "actor": actor}
    HubServices.emit_event(HubConstants.EVENT_RESTED, payload)
    return {"ok": true, "message": "Sinh lực và thể lực đã hồi phục."}

func save_game() -> Dictionary:
    var result: Variant = HubServices.call_save_service([&"save_game", &"save", &"save_current_game"], [])
    HubServices.emit_event(HubConstants.EVENT_SAVE_REQUESTED, {"station_id": station_id})
    return {"ok": result != false, "message": "Đã gửi yêu cầu lưu game."}

func change_class(class_id: StringName) -> Dictionary:
    if not HubConstants.CLASSES.has(class_id):
        return {"ok": false, "message": "Class không hợp lệ."}
    var result: Variant = HubServices.call_game_state([&"change_class", &"set_active_class"], [class_id])
    if result == false:
        return {"ok": false, "message": "Chưa thể đổi class."}
    HubServices.emit_event(HubConstants.EVENT_CLASS_CHANGED, {"class_id": class_id})
    return {"ok": true, "message": "Đã đổi sang %s." % HubConstants.CLASS_NAMES[class_id]}

func allocate_stat(stat_id: StringName) -> Dictionary:
    if not HubConstants.STATS.has(stat_id):
        return {"ok": false, "message": "Chỉ số không hợp lệ."}
    var result: Variant = HubServices.call_game_state([&"allocate_stat", &"spend_stat_point"], [stat_id, 1])
    if result == false:
        return {"ok": false, "message": "Không đủ điểm tiềm năng."}
    HubServices.emit_event(HubConstants.EVENT_STAT_ALLOCATED, {"stat_id": stat_id, "amount": 1})
    return {"ok": true, "message": "+1 %s" % String(stat_id).to_upper()}
