class_name InteractionPrompt
extends PanelContainer

var source_station: Node

func show_prompt(station: Node, message: String) -> void:
    source_station = station
    %PromptLabel.text = "[E] %s" % message
    visible = true

func hide_prompt(station: Node = null) -> void:
    if station == null or station == source_station:
        source_station = null
        visible = false
