class_name QuestBoardStation
extends HubStation

const QUEST_PATHS: Array[String] = [
    "res://resources/hub/quests/chapter_2_ashen_wind.tres",
    "res://resources/hub/quests/rescue_missing_villagers.tres",
]

var _accepted_quests: Dictionary = {}

func _ready() -> void:
    station_id = &"quest_board"
    prompt_text = "Xem Bảng Cáo Thị"
    super._ready()

func get_quests() -> Array[HubQuestData]:
    var quests: Array[HubQuestData] = []
    for path: String in QUEST_PATHS:
        var quest: HubQuestData = load(path) as HubQuestData
        if quest != null:
            quests.append(quest)
    return quests

func is_quest_accepted(quest_id: StringName) -> bool:
    if _accepted_quests.has(quest_id):
        return true
    var result: Variant = HubServices.call_game_state([&"has_quest", &"is_quest_active", &"is_quest_accepted"], [quest_id])
    return result == true

func accept_quest(quest_id: StringName) -> Dictionary:
    var quest: HubQuestData = _find_quest(quest_id)
    if quest == null:
        return {"ok": false, "message": "Nhiệm vụ không tồn tại."}
    if is_quest_accepted(quest_id):
        return {"ok": false, "duplicate": true, "message": "Nhiệm vụ đã được nhận."}
    var result: Variant = HubServices.call_game_state([&"accept_quest", &"add_quest"], [quest_id])
    if result == false or (result is Dictionary and not bool((result as Dictionary).get("ok", true))):
        return {"ok": false, "message": "Chưa thể nhận nhiệm vụ."}
    _accepted_quests[quest_id] = true
    HubServices.emit_event(HubConstants.EVENT_QUEST_ACCEPTED, {"quest_id": quest_id})
    return {"ok": true, "message": "Đã nhận: %s" % quest.title}

func _find_quest(quest_id: StringName) -> HubQuestData:
    for quest: HubQuestData in get_quests():
        if quest.id == quest_id:
            return quest
    return null
