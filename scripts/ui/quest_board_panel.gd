class_name QuestBoardPanel
extends HubModalBase

func _ready() -> void:
    %Close.pressed.connect(close)

func refresh() -> void:
    for child: Node in %Quests.get_children():
        child.queue_free()
    if station == null:
        return
    var quests: Array[HubQuestData] = station.call(&"get_quests") as Array[HubQuestData]
    for quest: HubQuestData in quests:
        var button: Button = Button.new()
        var accepted: bool = bool(station.call(&"is_quest_accepted", quest.id))
        button.text = "%s%s" % [quest.title, " (Đã nhận)" if accepted else ""]
        button.tooltip_text = "%s
Thưởng: %d vàng" % [quest.description, quest.reward_gold]
        button.disabled = accepted
        button.pressed.connect(_accept.bind(quest.id))
        %Quests.add_child(button)

func _accept(quest_id: StringName) -> void:
    var result: Dictionary = station.call(&"accept_quest", quest_id) as Dictionary
    %Status.text = str(result.get("message", ""))
    refresh()
