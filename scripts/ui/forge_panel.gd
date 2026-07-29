class_name ForgePanel
extends HubModalBase

var _runes: Array[HubRuneData] = []

func _ready() -> void:
    %Enhance.pressed.connect(_enhance)
    %Socket1.pressed.connect(_socket.bind(0))
    %Socket2.pressed.connect(_socket.bind(1))
    %Socket3.pressed.connect(_socket.bind(2))
    %Close.pressed.connect(close)

func refresh() -> void:
    if station == null:
        return
    _runes = station.call(&"get_runes") as Array[HubRuneData]
    %RuneOptions.clear()
    for rune: HubRuneData in _runes:
        %RuneOptions.add_item(rune.display_name)
        %RuneOptions.set_item_metadata(%RuneOptions.item_count - 1, rune.id)
    _refresh_equipment()

func _enhance() -> void:
    var result: Dictionary = station.call(&"enhance") as Dictionary
    %Status.text = str(result.get("message", ""))
    _refresh_equipment()

func _socket(slot_index: int) -> void:
    if %RuneOptions.item_count == 0:
        return
    var rune_id: StringName = StringName(%RuneOptions.get_selected_metadata())
    var result: Dictionary = station.call(&"socket_rune", slot_index, rune_id) as Dictionary
    %Status.text = str(result.get("message", ""))
    _refresh_equipment()

func _refresh_equipment() -> void:
    %Item.text = "Trang bị: %s" % str(station.get("target_item_id"))
    %Level.text = "Cường hóa: +%d / +10" % int(station.get("enhancement_level"))
    var socket_values: Array = station.get("sockets") as Array
    %Socket1.text = _socket_text(0, socket_values)
    %Socket2.text = _socket_text(1, socket_values)
    %Socket3.text = _socket_text(2, socket_values)

func _socket_text(index: int, values: Array) -> String:
    var value: String = "Trống" if index >= values.size() or String(values[index]).is_empty() else String(values[index])
    return "Ô %d: %s" % [index + 1, value]
