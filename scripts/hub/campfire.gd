class_name CampfireStation
extends HubStation

func _ready() -> void:
    station_id = &"campfire"
    prompt_text = "Nghỉ tại Bàn Lửa Trại"
    super._ready()

func rest(actor: Node = null) -> Dictionary:
    var resting_actor: Node = actor if actor != null else HubServices.player()
    if resting_actor != null and resting_actor.has_method(&"restore_full"):
        resting_actor.call(&"restore_full")
    HubServices.call_game_state([&"set_checkpoint"], [HubConstants.MAP_ID, HubConstants.SPAWN_DEFAULT])
    HubServices.emit_event(HubConstants.EVENT_RESTED, {"station_id": station_id, "actor": resting_actor})
    HubServices.toast("Đã nghỉ tại Bàn Lửa Trại.")
    return {"ok": true, "message": "Sinh lực và thể lực đã hồi phục."}

func save_game() -> Dictionary:
    var result: Variant = HubServices.call_save_service([&"save_game"], [0])
    var succeeded: bool = result == null or (result is int and int(result) == OK)
    HubServices.emit_event(HubConstants.EVENT_SAVE_REQUESTED, {"station_id": station_id, "slot": 0})
    return {"ok": succeeded, "message": "Đã lưu game." if succeeded else "Lưu game thất bại."}

func change_class(class_id: StringName) -> Dictionary:
    if not HubConstants.CLASSES.has(class_id):
        return {"ok": false, "message": "Class không hợp lệ."}
    var result: Variant = HubServices.call_game_state([&"set_class", &"change_class"], [class_id])
    if result == false:
        return {"ok": false, "message": "Chưa thể đổi class."}
    var actor: Node = HubServices.player()
    if actor != null and actor.has_method(&"set_player_class"):
        actor.call(&"set_player_class", HubConstants.CLASSES.find(class_id))
    HubServices.emit_event(HubConstants.EVENT_CLASS_CHANGED, {"class_id": class_id})
    HubServices.toast("Đã đổi sang %s." % HubConstants.CLASS_NAMES[class_id])
    return {"ok": true, "message": "Đã đổi sang %s." % HubConstants.CLASS_NAMES[class_id]}

func allocate_stat(stat_id: StringName) -> Dictionary:
    if not HubConstants.STATS.has(stat_id):
        return {"ok": false, "message": "Chỉ số không hợp lệ."}
    var result: Variant = HubServices.call_game_state([&"allocate_stat"], [stat_id, 1])
    if result != true:
        return {"ok": false, "message": "Không đủ điểm tiềm năng."}
    HubServices.emit_event(HubConstants.EVENT_STAT_ALLOCATED, {"stat_id": stat_id, "amount": 1})
    return {"ok": true, "message": "+1 %s" % String(stat_id).to_upper()}
