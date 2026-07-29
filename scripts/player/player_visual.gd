class_name PlayerVisual
extends Node2D

const BODY_COLORS: Array[Color] = [
	Color("70b7d7"),
	Color("8b6b3f"),
	Color("8b5bd1"),
	Color("e7d98b"),
]

var controller: PlayerController


func _ready() -> void:
	controller = get_parent() as PlayerController
	set_process(true)


func _process(_delta: float) -> void:
	queue_redraw()


func _draw() -> void:
	if controller == null:
		return
	var class_index: int = clampi(controller.player_class, 0, BODY_COLORS.size() - 1)
	var facing: Vector2 = controller.get_facing_direction()
	var body_color: Color = BODY_COLORS[class_index]
	if controller.is_dodging():
		draw_circle(Vector2.ZERO, 20.0, Color(0.55, 0.9, 1.0, 0.25))
	draw_circle(Vector2(0.0, 7.0), 12.0, body_color.darkened(0.2))
	draw_circle(Vector2(0.0, -8.0), 9.0, Color("dcc7a1"))
	draw_line(Vector2.ZERO, facing * 16.0, Color.WHITE, 3.0, true)
	draw_circle(facing * 17.0, 3.0, Color("d8f4ff"))
	if controller.is_weapon_unlocked():
		var side: Vector2 = facing.orthogonal()
		var hilt: Vector2 = facing * 5.0 + side * 8.0
		draw_line(hilt, hilt + facing * 22.0, Color("dce8ef"), 4.0, true)
		draw_line(hilt - side * 5.0, hilt + side * 5.0, Color("765331"), 3.0, true)
