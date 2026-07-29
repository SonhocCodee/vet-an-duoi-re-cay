class_name CampaignEnemyVisual
extends EnemyVisual

const ROOT_DIRECTIONS: Array[Vector2] = [Vector2.UP, Vector2.RIGHT, Vector2.DOWN, Vector2.LEFT]
const ART_DIRECTORY: String = "res://assets/art/enemies"

@export_range(0, 4, 1) var campaign_style: int = 0

var artwork: Sprite2D
var _has_artwork: bool = false


func _ready() -> void:
	artwork = get_node_or_null(^"Artwork") as Sprite2D
	if artwork == null:
		artwork = Sprite2D.new()
		artwork.name = "Artwork"
		artwork.show_behind_parent = true
		add_child(artwork)
	call_deferred(&"_load_artwork")
	set_process(true)


func _process(_delta: float) -> void:
	if not _has_artwork or artwork == null:
		return
	var enemy: CharacterBody2D = get_parent() as CharacterBody2D
	if enemy != null and absf(enemy.velocity.x) > 0.05:
		artwork.flip_h = enemy.velocity.x < 0.0


func _load_artwork() -> void:
	var enemy_id: String = _get_enemy_id()
	if enemy_id.is_empty():
		return
	var shared_art_name: String = "campaign_boss_silhouette" if enemy_id.begins_with("boss_") else "campaign_enemy_silhouette"
	var preferred_paths: PackedStringArray = [
		ART_DIRECTORY.path_join(enemy_id + ".svg"),
		ART_DIRECTORY.path_join(enemy_id + ".png"),
		ART_DIRECTORY.path_join(enemy_id + ".webp"),
		ART_DIRECTORY.path_join(shared_art_name + ".svg"),
		ART_DIRECTORY.path_join(shared_art_name + ".png"),
		ART_DIRECTORY.path_join(shared_art_name + ".webp"),
	]
	var name_tokens: PackedStringArray = [enemy_id, enemy_id.replace("_", "")]
	var texture: Texture2D = ArtTextureResolver.load_texture(preferred_paths, ART_DIRECTORY, name_tokens)
	_has_artwork = texture != null
	if not _has_artwork:
		artwork.visible = false
		queue_redraw()
		return
	artwork.texture = texture
	artwork.visible = true
	artwork.position = Vector2(0.0, -size * 0.12)
	var texture_size: Vector2 = texture.get_size()
	var longest_side: float = maxf(texture_size.x, texture_size.y)
	if longest_side > 0.0:
		var art_scale: float = size * 2.15 / longest_side
		artwork.scale = Vector2(art_scale, art_scale)
	queue_redraw()


func _get_enemy_id() -> String:
	var enemy: EnemyBase = get_parent() as EnemyBase
	if enemy == null or enemy.data == null:
		return ""
	return String(enemy.data.enemy_id)


func _draw() -> void:
	if elite_aura_enabled:
		draw_circle(Vector2.ZERO, size * 1.05, Color(1.0, 0.72, 0.18, 0.14))
		draw_arc(Vector2.ZERO, size, 0.0, TAU, 40, Color(1.0, 0.75, 0.25, 0.82), 2.0)
	if not _has_artwork:
		match campaign_style:
			0:
				_draw_humanoid()
			1:
				_draw_beast()
			2:
				_draw_caster()
			3:
				_draw_winged()
			_:
				_draw_rooted()
	if telegraph_amount > 0.0:
		var warning: Color = Color(1.0, 0.12, 0.06, 0.3 + telegraph_amount * 0.55)
		draw_arc(Vector2.ZERO, size + 9.0, -PI * 0.5, -PI * 0.5 + TAU * telegraph_amount, 40, warning, 4.0)


func _draw_humanoid() -> void:
	draw_circle(Vector2(0.0, -size * 0.48), size * 0.28, accent_color)
	draw_rect(Rect2(-size * 0.38, -size * 0.2, size * 0.76, size), body_color, true)
	draw_line(Vector2(-size * 0.38, size * 0.05), Vector2(-size * 0.72, size * 0.55), accent_color, 4.0)
	draw_line(Vector2(size * 0.38, size * 0.05), Vector2(size * 0.72, size * 0.55), accent_color, 4.0)


func _draw_beast() -> void:
	var points: PackedVector2Array = PackedVector2Array([
		Vector2(-size * 0.8, size * 0.35), Vector2(-size * 0.5, -size * 0.35),
		Vector2(0.0, -size * 0.58), Vector2(size * 0.72, -size * 0.12),
		Vector2(size * 0.82, size * 0.42), Vector2.ZERO,])
	draw_colored_polygon(points, body_color)
	draw_circle(Vector2(size * 0.4, -size * 0.17), 3.0, accent_color)


func _draw_caster() -> void:
	draw_colored_polygon(PackedVector2Array([
		Vector2.ZERO, Vector2(-size * 0.65, size), Vector2(size * 0.65, size),]), body_color)
	draw_circle(Vector2.ZERO, size * 0.42, accent_color)
	draw_arc(Vector2.ZERO, size * 0.68, PI, TAU, 20, body_color, 5.0)


func _draw_winged() -> void:
	draw_circle(Vector2.ZERO, size * 0.38, body_color)
	draw_colored_polygon(PackedVector2Array([
		Vector2(-size * 0.25, 0.0), Vector2(-size, -size * 0.55), Vector2(-size * 0.72, size * 0.5),]), accent_color)
	draw_colored_polygon(PackedVector2Array([
		Vector2(size * 0.25, 0.0), Vector2(size, -size * 0.55), Vector2(size * 0.72, size * 0.5),]), accent_color)
	draw_circle(Vector2(size * 0.12, -size * 0.1), 2.5, Color.WHITE)


func _draw_rooted() -> void:
	draw_circle(Vector2.ZERO, size * 0.52, body_color)
	for direction: Vector2 in ROOT_DIRECTIONS:
		draw_line(direction * size * 0.35, direction * size, accent_color, 5.0)
	draw_circle(Vector2.ZERO, size * 0.2, accent_color)
