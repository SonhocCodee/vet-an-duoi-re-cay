class_name FinalSequenceDecorator
extends Node

enum Phase { WAITING_FIRST_BOSS, SECOND_BOSS_ACTIVE, COMPLETED }

signal second_boss_spawned(boss: Node)
signal sequence_completed

@export var first_boss_id: StringName = &"boss_papal_root_avatar"
@export var second_boss_id: StringName = &"boss_corrupted_asterion"
@export var second_boss_name: String = "Bóng Asterion Sai Lệch"

var phase: Phase = Phase.WAITING_FIRST_BOSS
var _campaign_map: Node
var _spawn_marker: Marker2D
var _second_boss: Node

func configure(campaign_map: Node, spawn_marker: Marker2D) -> void:
    _campaign_map = campaign_map
    _spawn_marker = spawn_marker
    _connect_generic_boss_signal()

func notify_boss_defeated(defeated_boss_id: StringName = &"") -> void:
    if phase == Phase.WAITING_FIRST_BOSS:
        if not defeated_boss_id.is_empty() and defeated_boss_id != first_boss_id:
            return
        phase = Phase.SECOND_BOSS_ACTIVE
        _spawn_second_boss()
        return
    if phase == Phase.SECOND_BOSS_ACTIVE:
        if not defeated_boss_id.is_empty() and defeated_boss_id != second_boss_id:
            return
        phase = Phase.COMPLETED
        sequence_completed.emit()

func get_second_boss() -> Node:
    return _second_boss

func _connect_generic_boss_signal() -> void:
    if _campaign_map == null:
        return
    for signal_name: StringName in [&"boss_defeated", &"chapter_boss_defeated", &"encounter_completed"]:
        if _campaign_map.has_signal(signal_name):
            var callback: Callable = _on_generic_boss_defeated
            if not _campaign_map.is_connected(signal_name, callback):
                _campaign_map.connect(signal_name, callback)
            return

func _on_generic_boss_defeated(boss_value: Variant = null, _extra: Variant = null) -> void:
    var defeated_id: StringName = &""
    if boss_value is String or boss_value is StringName:
        defeated_id = StringName(boss_value)
    elif boss_value is Node:
        defeated_id = StringName((boss_value as Node).get_meta(&"boss_id", &""))
    notify_boss_defeated(defeated_id)

func _spawn_second_boss() -> void:
    var hook_result: Dictionary = _try_generic_spawn_hook()
    if bool(hook_result.get("handled", false)):
        var spawned: Variant = hook_result.get("result")
        if spawned is Node:
            _second_boss = spawned as Node
            _connect_second_boss_signal(_second_boss)
            second_boss_spawned.emit(_second_boss)
        return
    _second_boss = _spawn_placeholder_boss()
    second_boss_spawned.emit(_second_boss)

func _try_generic_spawn_hook() -> Dictionary:
    if _campaign_map == null:
        return {"handled": false}
    var spawn_position: Vector2 = Vector2.ZERO if _spawn_marker == null else _spawn_marker.global_position
    for method: Dictionary in _campaign_map.get_method_list():
        var method_name: StringName = StringName(method.get("name", &""))
        if not [&"spawn_boss", &"spawn_chapter_boss", &"begin_boss_encounter", &"start_boss_encounter"].has(method_name):
            continue
        var arguments: Array = method.get("args", []) as Array
        var result: Variant
        if arguments.size() == 2:
            result = _campaign_map.call(method_name, second_boss_id, spawn_position)
        elif arguments.size() == 1:
            result = _campaign_map.call(method_name, second_boss_id)
        elif arguments.is_empty():
            result = _campaign_map.call(method_name)
        else:
            continue
        return {"handled": true, "result": result}
    return {"handled": false}

func _spawn_placeholder_boss() -> Node:
    var boss_script: Script = load("res://scripts/campaign/chapters8_10/placeholder_final_boss.gd") as Script
    var boss: PlaceholderFinalBoss = boss_script.new() as PlaceholderFinalBoss
    boss.boss_id = second_boss_id
    boss.display_name = second_boss_name
    get_parent().add_child(boss)
    boss.global_position = Vector2.ZERO if _spawn_marker == null else _spawn_marker.global_position
    _connect_second_boss_signal(boss)
    return boss

func _connect_second_boss_signal(boss: Node) -> void:
    if boss == null:
        return
    for signal_name: StringName in [&"defeated", &"died", &"boss_defeated"]:
        if boss.has_signal(signal_name):
            var callback: Callable = _on_second_boss_defeated
            if not boss.is_connected(signal_name, callback):
                boss.connect(signal_name, callback)
            return

func _on_second_boss_defeated(_payload: Variant = null) -> void:
    notify_boss_defeated(second_boss_id)
