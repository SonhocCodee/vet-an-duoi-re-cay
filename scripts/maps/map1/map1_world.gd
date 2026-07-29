extends Node2D

const MAP_SIZE := Vector2(1600.0, 900.0)
const TREE_POSITIONS: Array[Vector2] = [
	Vector2(115.0, 120.0), Vector2(255.0, 105.0), Vector2(410.0, 125.0),
	Vector2(585.0, 90.0), Vector2(765.0, 115.0), Vector2(955.0, 95.0),
	Vector2(1150.0, 125.0), Vector2(1340.0, 100.0), Vector2(1510.0, 145.0),
	Vector2(90.0, 315.0), Vector2(155.0, 500.0), Vector2(95.0, 735.0),
	Vector2(285.0, 805.0), Vector2(485.0, 780.0), Vector2(690.0, 825.0),
	Vector2(900.0, 790.0), Vector2(1110.0, 825.0), Vector2(1305.0, 785.0),
	Vector2(1510.0, 735.0), Vector2(1515.0, 280.0),
	Vector2(530.0, 315.0), Vector2(1090.0, 305.0), Vector2(1200.0, 590.0)
]
const GLOW_MOSS_POSITIONS: Array[Vector2] = [
	Vector2(335.0, 645.0), Vector2(610.0, 570.0), Vector2(730.0, 410.0),
	Vector2(930.0, 410.0), Vector2(1050.0, 555.0), Vector2(1290.0, 520.0)
]


func _ready() -> void:
	_build_boundary_collisions()
	_build_tree_collisions()
	queue_redraw()


func _draw() -> void:
	draw_rect(Rect2(Vector2.ZERO, MAP_SIZE), Color("172820"))
	draw_colored_polygon(PackedVector2Array([
		Vector2(165.0, 720.0), Vector2(300.0, 600.0), Vector2(520.0, 570.0),
		Vector2(700.0, 455.0), Vector2(850.0, 390.0), Vector2(1030.0, 460.0),
		Vector2(1220.0, 535.0), Vector2(1440.0, 500.0), Vector2(1510.0, 570.0),
		Vector2(1470.0, 655.0), Vector2(1240.0, 625.0), Vector2(1020.0, 555.0),
		Vector2(850.0, 500.0), Vector2(670.0, 555.0), Vector2(510.0, 650.0),
		Vector2(310.0, 690.0), Vector2(215.0, 790.0)
	]), Color("314336"))

	for moss_position: Vector2 in GLOW_MOSS_POSITIONS:
		draw_circle(moss_position, 30.0, Color(0.24, 0.78, 0.69, 0.08))
		draw_circle(moss_position, 12.0, Color(0.43, 0.91, 0.77, 0.24))

	for tree_position: Vector2 in TREE_POSITIONS:
		_draw_tree(tree_position)

	for index: int in range(7):
		var fog_center := Vector2(160.0 + index * 235.0, 240.0 + float(index % 2) * 300.0)
		draw_circle(fog_center, 135.0, Color(0.68, 0.82, 0.77, 0.035))


func _draw_tree(tree_position: Vector2) -> void:
	draw_rect(Rect2(tree_position + Vector2(-10.0, 2.0), Vector2(20.0, 47.0)), Color("463c2c"))
	draw_circle(tree_position + Vector2(0.0, -18.0), 49.0, Color("213e2c"))
	draw_circle(tree_position + Vector2(-27.0, -5.0), 31.0, Color("294c33"))
	draw_circle(tree_position + Vector2(27.0, -8.0), 34.0, Color("1d3728"))
	draw_circle(tree_position + Vector2(-10.0, -28.0), 7.0, Color(0.39, 0.76, 0.55, 0.28))


func _build_boundary_collisions() -> void:
	var boundaries := StaticBody2D.new()
	boundaries.name = "MapBoundaries"
	add_child(boundaries)
	_add_rectangle_collision(boundaries, Vector2(800.0, -16.0), Vector2(1632.0, 32.0))
	_add_rectangle_collision(boundaries, Vector2(800.0, 916.0), Vector2(1632.0, 32.0))
	_add_rectangle_collision(boundaries, Vector2(-16.0, 450.0), Vector2(32.0, 932.0))
	_add_rectangle_collision(boundaries, Vector2(1616.0, 450.0), Vector2(32.0, 932.0))


func _build_tree_collisions() -> void:
	var trees := Node2D.new()
	trees.name = "TreeCollisions"
	add_child(trees)
	for index: int in range(TREE_POSITIONS.size()):
		var tree_body := StaticBody2D.new()
		tree_body.name = "TreeCollision_%02d" % index
		tree_body.position = TREE_POSITIONS[index] + Vector2(0.0, 25.0)
		var shape := CollisionShape2D.new()
		var circle := CircleShape2D.new()
		circle.radius = 24.0
		shape.shape = circle
		tree_body.add_child(shape)
		trees.add_child(tree_body)


func _add_rectangle_collision(parent: StaticBody2D, center: Vector2, size: Vector2) -> void:
	var shape := CollisionShape2D.new()
	shape.position = center
	var rectangle := RectangleShape2D.new()
	rectangle.size = size
	shape.shape = rectangle
	parent.add_child(shape)

