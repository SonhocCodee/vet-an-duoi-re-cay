class_name PixelWorldProp
extends Node2D

enum Kind { TREE, FENCE, MARKET_STALL, WELL, CRATE, LAMP, SIGN, FLOWER }

@export var kind: Kind = Kind.TREE
@export var variant: int = 0
@export var horizontal := true


func _ready() -> void:
	add_to_group(&"pixel_prop")
	set_meta(&"depth_anchor", position)
	if is_solid():
		_build_collision()
	queue_redraw()


func configure(kind_value: int, variant_value: int = 0, horizontal_value: bool = true) -> void:
	kind = kind_value
	variant = variant_value
	horizontal = horizontal_value
	queue_redraw()


func is_solid() -> bool:
	return kind in [Kind.TREE, Kind.FENCE, Kind.MARKET_STALL, Kind.WELL, Kind.CRATE]


func navigation_blocker() -> Rect2:
	match kind:
		Kind.TREE:
			return Rect2(position - Vector2(18, 20), Vector2(36, 32))
		Kind.FENCE:
			return Rect2(position - (Vector2(30, 8) if horizontal else Vector2(8, 30)), Vector2(60, 16) if horizontal else Vector2(16, 60))
		Kind.MARKET_STALL:
			return Rect2(position - Vector2(50, 26), Vector2(100, 34))
		Kind.WELL:
			return Rect2(position - Vector2(34, 24), Vector2(68, 42))
		Kind.CRATE:
			return Rect2(position - Vector2(16, 20), Vector2(32, 28))
	return Rect2()


func _build_collision() -> void:
	var blocker := navigation_blocker()
	var body := StaticBody2D.new()
	body.name = "PropCollision"
	body.collision_layer = 1
	body.collision_mask = 0
	var shape_node := CollisionShape2D.new()
	var shape := RectangleShape2D.new()
	shape.size = blocker.size
	shape_node.shape = shape
	shape_node.position = blocker.get_center() - position
	body.add_child(shape_node)
	add_child(body)


func _draw() -> void:
	match kind:
		Kind.TREE:
			_draw_tree()
		Kind.FENCE:
			_draw_fence()
		Kind.MARKET_STALL:
			_draw_market_stall()
		Kind.WELL:
			_draw_well()
		Kind.CRATE:
			_draw_crate()
		Kind.LAMP:
			_draw_lamp()
		Kind.SIGN:
			_draw_sign()
		Kind.FLOWER:
			_draw_flower()


func _draw_tree() -> void:
	var leaf: Color = [Color("#2f5539"), Color("#365f3b"), Color("#285144")][posmod(variant, 3)]
	draw_rect(Rect2(-15, -56, 30, 62), Color("#5e412e"))
	draw_rect(Rect2(-9, -54, 10, 58), Color("#805b39"))
	draw_rect(Rect2(-45, -112, 90, 64), Color("#1f3b2e"))
	draw_rect(Rect2(-54, -94, 108, 42), leaf)
	draw_rect(Rect2(-34, -124, 68, 86), leaf.lightened(0.08))
	draw_rect(Rect2(-20, -112, 22, 12), leaf.lightened(0.22))


func _draw_fence() -> void:
	if horizontal:
		for x in [-28, 24]:
			draw_rect(Rect2(x, -34, 8, 38), Color("#60452f"))
		draw_rect(Rect2(-32, -27, 64, 8), Color("#88633e"))
		draw_rect(Rect2(-32, -9, 64, 8), Color("#765536"))
	else:
		for y in [-28, 24]:
			draw_rect(Rect2(-4, y - 6, 8, 38), Color("#60452f"))
		draw_colored_polygon(PackedVector2Array([Vector2(-18, -32), Vector2(-8, -36), Vector2(18, 30), Vector2(8, 34)]), Color("#88633e"))


func _draw_market_stall() -> void:
	var awning: Color = [Color("#a85445"), Color("#4c6f78"), Color("#9a7b3f")][posmod(variant, 3)]
	draw_rect(Rect2(-43, -62, 8, 64), Color("#5b402f"))
	draw_rect(Rect2(35, -62, 8, 64), Color("#5b402f"))
	draw_rect(Rect2(-49, -62, 98, 18), Color("#ded0a5"))
	for x in range(-49, 49, 24):
		draw_rect(Rect2(x, -62, 12, 18), awning)
	draw_rect(Rect2(-48, -26, 96, 22), Color("#765137"))
	for x in range(-34, 35, 22):
		draw_rect(Rect2(x, -36, 13, 10), Color("#c99a4d").lightened(variant * 0.04))


func _draw_well() -> void:
	draw_rect(Rect2(-31, -25, 62, 26), Color("#5b5b55"))
	draw_rect(Rect2(-36, -34, 72, 15), Color("#8b8173"))
	draw_rect(Rect2(-27, -30, 54, 11), Color("#273f48"))
	draw_rect(Rect2(-32, -80, 7, 52), Color("#5b402f"))
	draw_rect(Rect2(25, -80, 7, 52), Color("#5b402f"))
	draw_colored_polygon(PackedVector2Array([Vector2(-43, -79), Vector2(0, -103), Vector2(43, -79)]), Color("#70423b"))


func _draw_crate() -> void:
	draw_rect(Rect2(-16, -29, 32, 29), Color("#563d2b"))
	draw_rect(Rect2(-12, -25, 24, 21), Color("#987047"))
	draw_line(Vector2(-10, -23), Vector2(10, -6), Color("#60452f"), 4)
	draw_line(Vector2(10, -23), Vector2(-10, -6), Color("#60452f"), 4)


func _draw_lamp() -> void:
	draw_rect(Rect2(-3, -69, 6, 69), Color("#403a38"))
	draw_rect(Rect2(-10, -72, 20, 7), Color("#403a38"))
	draw_rect(Rect2(-9, -94, 18, 24), Color("#5e4e3f"))
	draw_rect(Rect2(-5, -90, 10, 16), Color("#e5bd62"))


func _draw_sign() -> void:
	draw_rect(Rect2(-4, -45, 8, 45), Color("#5b402f"))
	draw_rect(Rect2(-25, -56, 50, 24), Color("#4b3529"))
	draw_rect(Rect2(-21, -52, 42, 16), Color("#a47a4d"))
	draw_colored_polygon(PackedVector2Array([Vector2(25, -56), Vector2(36, -44), Vector2(25, -32)]), Color("#a47a4d"))


func _draw_flower() -> void:
	draw_rect(Rect2(-2, -10, 4, 10), Color("#52713f"))
	var bloom: Color = [Color("#d9aaad"), Color("#d9cc74"), Color("#9eb7d9")][posmod(variant, 3)]
	draw_rect(Rect2(-7, -15, 14, 8), bloom)
	draw_rect(Rect2(-3, -19, 6, 16), bloom.lightened(0.12))
