class_name LootPickupVisual
extends Node2D

var rarity: LootEntry.Rarity = LootEntry.Rarity.COMMON
var pulse_time: float = 0.0


func _process(delta: float) -> void:
	pulse_time += delta
	queue_redraw()


func set_rarity(value: LootEntry.Rarity) -> void:
	rarity = value
	queue_redraw()


func _draw() -> void:
	var color: Color = _rarity_color()
	var pulse: float = 1.0 + sin(pulse_time * 4.0) * 0.12
	draw_circle(Vector2.ZERO, 11.0 * pulse, Color(color, 0.12))
	draw_circle(Vector2.ZERO, 6.0, color)
	draw_rect(Rect2(-3.0, -3.0, 6.0, 6.0), Color.WHITE, true)


func _rarity_color() -> Color:
	match rarity:
		LootEntry.Rarity.UNCOMMON:
			return Color("66e37f")
		LootEntry.Rarity.RARE:
			return Color("f4c95d")
		_:
			return Color("edf2f4")
