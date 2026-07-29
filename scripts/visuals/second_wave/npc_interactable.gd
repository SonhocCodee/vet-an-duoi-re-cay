class_name SecondWaveNpcInteractable
extends Interactable

@export_range(48.0, 320.0, 1.0) var nameplate_distance: float = 150.0

var _nameplate: Label


func _ready() -> void:
	_nameplate = get_parent().get_node_or_null(^"Nameplate") as Label
	if _nameplate != null:
		_nameplate.visible = false
	set_process(true)


func _process(_delta: float) -> void:
	if _nameplate == null:
		return
	var player := SceneRouter.get_player()
	_nameplate.visible = player != null and get_parent().global_position.distance_to(player.global_position) <= nameplate_distance


func interact(actor: Node) -> void:
	if not enabled:
		return
	super.interact(actor)
	var npc := get_parent()
	if npc != null and npc.has_method(&"request_interaction"):
		npc.call(&"request_interaction", actor)
