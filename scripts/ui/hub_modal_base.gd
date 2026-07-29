class_name HubModalBase
extends PanelContainer

signal closed

var station: Node

func open_for(target_station: Node) -> void:
    station = target_station
    visible = true
    refresh()

func close() -> void:
    station = null
    visible = false
    closed.emit()

func refresh() -> void:
    pass
