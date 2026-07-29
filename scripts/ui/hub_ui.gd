class_name HubUI
extends CanvasLayer

@onready var interaction_prompt: InteractionPrompt = $InteractionPrompt
@onready var campfire_panel: CampfirePanel = $CampfirePanel
@onready var forge_panel: ForgePanel = $ForgePanel
@onready var shop_panel: ShopPanel = $ShopPanel
@onready var quest_panel: QuestBoardPanel = $QuestBoardPanel
@onready var toast: ToastMessage = $Toast

func open_station(station: Node) -> void:
    close_all_modals()
    var station_type: StringName = station.call(&"get_station_type") as StringName
    match station_type:
        &"campfire": campfire_panel.open_for(station)
        &"forge": forge_panel.open_for(station)
        &"shop": shop_panel.open_for(station)
        &"quest_board": quest_panel.open_for(station)
        _: toast.push("Station chưa có giao diện.")

func show_interaction(station: Node, message: String) -> void:
    interaction_prompt.show_prompt(station, message)

func hide_interaction(station: Node) -> void:
    interaction_prompt.hide_prompt(station)

func show_tutorial(title: String, description: String) -> void:
    $TutorialPrompt.show_step(title, description)

func show_dialogue(speaker: String, line: String, options: Array[String] = []) -> void:
    $DialoguePanel.show_dialogue(speaker, line, options)

func show_toast(message: String) -> void:
    toast.push(message)

func close_all_modals() -> void:
    campfire_panel.close()
    forge_panel.close()
    shop_panel.close()
    quest_panel.close()
