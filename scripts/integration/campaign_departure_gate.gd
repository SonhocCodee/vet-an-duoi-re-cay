class_name CampaignDepartureGate
extends Interactable

func _ready() -> void:
	prompt_text = "Tiếp tục hành trình Chapter %d" % maxi(GameState.current_chapter, 2)
	collision_layer = 32
	collision_mask = 1
	monitoring = true
	var shape_node := CollisionShape2D.new()
	var shape := RectangleShape2D.new()
	shape.size = Vector2(82.0, 140.0)
	shape_node.shape = shape
	add_child(shape_node)
	var portal := Polygon2D.new()
	portal.polygon = PackedVector2Array([Vector2(-38, 65), Vector2(-38, -65), Vector2(38, -65), Vector2(38, 65)])
	portal.color = Color(0.25, 0.62, 0.72, 0.55)
	add_child(portal)
	var label := Label.new()
	label.position = Vector2(-92, -102)
	label.size = Vector2(184, 34)
	label.text = "CỔNG HÀNH TRÌNH"
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	add_child(label)

func interact(actor: Node) -> void:
	if not enabled:
		return
	super.interact(actor)
	CampaignDirector.start_from_hub()
