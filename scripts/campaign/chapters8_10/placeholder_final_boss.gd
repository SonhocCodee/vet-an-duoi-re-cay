class_name PlaceholderFinalBoss
extends Area2D

signal defeated(boss_id: StringName)

@export var boss_id: StringName = &"corrupted_asterion_echo"
@export var display_name: String = "Bóng Asterion Sai Lệch"

var _defeated: bool = false

func _ready() -> void:
    add_to_group(&"boss")
    set_meta(&"boss_id", boss_id)
    collision_layer = 4
    collision_mask = 0
    monitoring = false
    monitorable = true
    _build_placeholder_visual()

func defeat() -> void:
    if _defeated:
        return
    _defeated = true
    defeated.emit(boss_id)
    queue_free()

func _build_placeholder_visual() -> void:
    var aura: Polygon2D = Polygon2D.new()
    aura.name = "CorruptedAura"
    aura.polygon = PackedVector2Array([
        Vector2(-54, 0), Vector2(-34, -42), Vector2(0, -58),
        Vector2(34, -42), Vector2(54, 0), Vector2(34, 42),
        Vector2(0, 58), Vector2(-34, 42),
    ])
    aura.color = Color(0.34, 0.08, 0.48, 0.82)
    add_child(aura)
    var core: Polygon2D = Polygon2D.new()
    core.name = "AsterionEcho"
    core.polygon = PackedVector2Array([Vector2(-20, 32), Vector2(0, -42), Vector2(20, 32)])
    core.color = Color(0.85, 0.72, 0.94, 1.0)
    add_child(core)
    var shape: CollisionShape2D = CollisionShape2D.new()
    var circle: CircleShape2D = CircleShape2D.new()
    circle.radius = 48.0
    shape.shape = circle
    add_child(shape)
    var label: Label = Label.new()
    label.name = "BossLabel"
    label.text = display_name
    label.position = Vector2(-120, 70)
    label.size = Vector2(240, 30)
    label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    add_child(label)
