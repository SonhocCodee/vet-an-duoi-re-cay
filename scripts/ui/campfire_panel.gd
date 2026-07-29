class_name CampfirePanel
extends HubModalBase

func _ready() -> void:
    %Rest.pressed.connect(_rest)
    %Save.pressed.connect(_save)
    %Close.pressed.connect(close)
    for class_id: StringName in HubConstants.CLASSES:
        var button: Button = Button.new()
        button.text = str(HubConstants.CLASS_NAMES[class_id])
        button.pressed.connect(_change_class.bind(class_id))
        %ClassButtons.add_child(button)
    for stat_id: StringName in HubConstants.STATS:
        var button: Button = Button.new()
        button.text = "+1 %s" % String(stat_id).to_upper()
        button.pressed.connect(_allocate_stat.bind(stat_id))
        %StatButtons.add_child(button)

func _rest() -> void:
    _show_result(station.call(&"rest") as Dictionary)

func _save() -> void:
    _show_result(station.call(&"save_game") as Dictionary)

func _change_class(class_id: StringName) -> void:
    _show_result(station.call(&"change_class", class_id) as Dictionary)

func _allocate_stat(stat_id: StringName) -> void:
    _show_result(station.call(&"allocate_stat", stat_id) as Dictionary)

func _show_result(result: Dictionary) -> void:
    %Status.text = str(result.get("message", ""))
