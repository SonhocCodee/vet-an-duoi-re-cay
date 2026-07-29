extends Node

const CHARACTER_ART: Dictionary = {
	&"player": preload("res://assets/art/characters/kael.svg"),
	&"aria": preload("res://assets/art/characters/aria.svg"),
	&"cecilia": preload("res://assets/art/characters/cecilia.svg"),
	&"elysia": preload("res://assets/art/characters/elysia.svg"),
}
const TARGET_HEIGHTS: Dictionary = {
	&"player": 54.0,
	&"aria": 72.0,
	&"cecilia": 72.0,
	&"elysia": 72.0,
}


func _ready() -> void:
	if not get_tree().node_added.is_connected(_on_node_added):
		get_tree().node_added.connect(_on_node_added)
	call_deferred("_refresh_character_art")


func _exit_tree() -> void:
	if get_tree() != null and get_tree().node_added.is_connected(_on_node_added):
		get_tree().node_added.disconnect(_on_node_added)


func _on_node_added(node: Node) -> void:
	for group_id: StringName in CHARACTER_ART:
		if node.is_in_group(group_id):
			call_deferred("_apply_character_art", node, group_id)
			return


func _refresh_character_art() -> void:
	for group_id: StringName in CHARACTER_ART:
		for character: Node in get_tree().get_nodes_in_group(group_id):
			_apply_character_art(character, group_id)


func _apply_character_art(character: Node, group_id: StringName) -> void:
	if not is_instance_valid(character):
		return
	var sprite_name := "Artwork" if group_id == &"player" else "Sprite"
	var sprite := character.find_child(sprite_name, true, false) as Sprite2D
	if sprite == null:
		return
	var texture := CHARACTER_ART[group_id] as Texture2D
	if texture == null:
		return
	sprite.texture = texture
	sprite.visible = true
	var texture_size := texture.get_size()
	if texture_size.y <= 0.0:
		return
	var facing_sign := signf(sprite.scale.x)
	if is_zero_approx(facing_sign):
		facing_sign = 1.0
	var art_scale: float = float(TARGET_HEIGHTS[group_id]) / texture_size.y
	sprite.scale = Vector2(art_scale * facing_sign, art_scale)
