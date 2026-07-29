class_name PlayerVisual
extends Node2D

const BODY_COLORS: Array[Color] = [
	Color("70b7d7"),
	Color("8b6b3f"),
	Color("8b5bd1"),
	Color("e7d98b"),
]
const KAEL_ART_PATHS: PackedStringArray = [
	"res://assets/art/characters/kael.svg",
	"res://assets/art/characters/kael.png",
	"res://assets/art/characters/kael.webp",
]
const KAEL_ART_DIRECTORY: String = "res://assets/art/characters"
const KAEL_ART_TOKENS: PackedStringArray = ["kael"]
const ARTWORK_HEIGHT: float = 54.0

var controller: PlayerController
var artwork: Sprite2D
var _has_artwork: bool = false


func _ready() -> void:
	controller = get_parent() as PlayerController
	artwork = get_node_or_null(^"Artwork") as Sprite2D
	if artwork == null:
		artwork = Sprite2D.new()
		artwork.name = "Artwork"
		artwork.show_behind_parent = true
		add_child(artwork)
	_load_artwork()
	set_process(true)


func _process(_delta: float) -> void:
	if controller != null and artwork != null and _has_artwork:
		var facing: Vector2 = controller.get_facing_direction()
		if absf(facing.x) > 0.05:
			artwork.flip_h = facing.x < 0.0
	queue_redraw()


func _load_artwork() -> void:
	var texture: Texture2D = ArtTextureResolver.load_texture(
		KAEL_ART_PATHS,
		KAEL_ART_DIRECTORY,
		KAEL_ART_TOKENS
	)
	_has_artwork = texture != null
	if not _has_artwork:
		artwork.visible = false
		return
	artwork.texture = texture
	artwork.visible = true
	artwork.position = Vector2(0.0, -4.0)
	var texture_size: Vector2 = texture.get_size()
	if texture_size.y > 0.0:
		var art_scale: float = ARTWORK_HEIGHT / texture_size.y
		artwork.scale = Vector2(art_scale, art_scale)


func _draw() -> void:
	if controller == null:
		return
	var class_index: int = clampi(controller.player_class, 0, BODY_COLORS.size() - 1)
	var facing: Vector2 = controller.get_facing_direction()
	var body_color: Color = BODY_COLORS[class_index]
	if controller.is_dodging():
		draw_circle(Vector2.ZERO, 20.0, Color(0.55, 0.9, 1.0, 0.25))
	if not _has_artwork:
		draw_circle(Vector2(0.0, 7.0), 12.0, body_color.darkened(0.2))
		draw_circle(Vector2(0.0, -8.0), 9.0, Color("dcc7a1"))
		draw_line(Vector2.ZERO, facing * 16.0, Color.WHITE, 3.0, true)
		draw_circle(facing * 17.0, 3.0, Color("d8f4ff"))
	if controller.is_weapon_unlocked():
		var side: Vector2 = facing.orthogonal()
		var hilt: Vector2 = facing * 5.0 + side * 8.0
		draw_line(hilt, hilt + facing * 22.0, Color("dce8ef"), 4.0, true)
		draw_line(hilt - side * 5.0, hilt + side * 5.0, Color("765331"), 3.0, true)
