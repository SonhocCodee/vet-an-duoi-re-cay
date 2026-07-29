class_name HubUI
extends Control

@onready var interaction_prompt: InteractionPrompt = $InteractionPrompt
@onready var campfire_panel: CampfirePanel = $CampfirePanel
@onready var forge_panel: ForgePanel = $ForgePanel
@onready var shop_panel: ShopPanel = $ShopPanel
@onready var quest_panel: QuestBoardPanel = $QuestBoardPanel
@onready var toast: ToastMessage = $Toast

func _ready() -> void:
    var events: Node = HubServices.singleton(HubServices.GAME_EVENTS_NAME)
    if events == null:
        return
    _connect_event(events, &"interaction_prompt_changed", _on_interaction_prompt_changed)
    _connect_event(events, &"hub_panel_requested", _on_panel_requested)
    _connect_event(events, &"toast_requested", show_toast)
    _connect_event(events, &"tutorial_requested", _on_tutorial_requested)

func open_station(target_station: Node) -> void:
    close_all_modals()
    var station_type: StringName = StringName(target_station.call(&"get_station_type"))
    match station_type:
        &"campfire": campfire_panel.open_for(target_station)
        &"forge": forge_panel.open_for(target_station)
        &"shop": shop_panel.open_for(target_station)
        &"quest_board": quest_panel.open_for(target_station)
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

func _on_interaction_prompt_changed(message: String, visible: bool) -> void:
    if visible:
        interaction_prompt.show_prompt(null, message)
    else:
        interaction_prompt.hide_prompt()

func _on_panel_requested(panel_id: StringName) -> void:
    for candidate: Node in get_tree().get_nodes_in_group(HubConstants.GROUP_HUB_STATION):
        if candidate.has_method(&"get_station_type") and StringName(candidate.call(&"get_station_type")) == panel_id:
            open_station(candidate)
            return

func _on_tutorial_requested(step_id: StringName, message: String) -> void:
    show_tutorial("Hướng dẫn: %s" % String(step_id), message)

func _connect_event(events: Node, signal_name: StringName, callback: Callable) -> void:
    if events.has_signal(signal_name) and not events.is_connected(signal_name, callback):
        events.connect(signal_name, callback)
