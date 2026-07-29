class_name CampaignEnemyVisual
extends EnemyVisual

const ROOT_DIRECTIONS: Array[Vector2] = [Vector2.UP, Vector2.RIGHT, Vector2.DOWN, Vector2.LEFT]
const ART_DIRECTORY := "res://assets/art/enemies"

@export_range(0, 4, 1) var campaign_style: int = 0
@export var directional_animation_enabled := true

var artwork: Sprite2D
var _has_artwork := false


func _ready() -> void:
	super._ready()
	artwork = get_node_or_null(^"Artwork") as Sprite2D
	if artwork == null:
		artwork = Sprite2D.new()
		artwork.name = "Artwork"
		artwork.show_behind_parent = true
		add_child(artwork)
	if directional_animation_enabled:
		artwork.visible = false
		_has_artwork = false
		queue_redraw()
	else:
		call_deferred(&"_load_artwork")


func _process(delta: float) -> void:
	super._process(delta)
	if directional_animation_enabled or not _has_artwork or artwork == null:
		return
	var enemy := get_parent() as CharacterBody2D
	if enemy != null and absf(enemy.velocity.x) > 0.05:
		artwork.flip_h = enemy.velocity.x < 0.0


func _load_artwork() -> void:
	if directional_animation_enabled:
		_has_artwork = false
		if artwork != null:
			artwork.visible = false
		return
	var enemy_id := _get_enemy_id()
	if enemy_id.is_empty():
		return
	var shared_art_name := "campaign_boss_silhouette" if enemy_id.begins_with("boss_") else "campaign_enemy_silhouette"
	var preferred_paths: PackedStringArray = [
		ART_DIRECTORY.path_join(enemy_id + ".svg"), ART_DIRECTORY.path_join(enemy_id + ".png"),
		ART_DIRECTORY.path_join(enemy_id + ".webp"), ART_DIRECTORY.path_join(shared_art_name + ".svg"),
		ART_DIRECTORY.path_join(shared_art_name + ".png"), ART_DIRECTORY.path_join(shared_art_name + ".webp"),
	]
	var texture := ArtTextureResolver.load_texture(preferred_paths, ART_DIRECTORY, [enemy_id, enemy_id.replace("_", "")])
	_has_artwork = texture != null
	artwork.visible = _has_artwork
	if not _has_artwork:
		queue_redraw()
		return
	artwork.texture = texture
	artwork.position = Vector2(0.0, -size * 0.12)
	var longest_side := maxf(texture.get_size().x, texture.get_size().y)
	if longest_side > 0.0:
		var art_scale := size * 2.15 / longest_side
		artwork.scale = Vector2(art_scale, art_scale)


func _get_enemy_id() -> String:
	var enemy := get_parent() as EnemyBase
	return String(enemy.data.enemy_id) if enemy != null and enemy.data != null else ""


func _draw() -> void:
	if elite_aura_enabled:
		draw_circle(Vector2.ZERO, size * 1.05, Color(1.0, 0.72, 0.18, 0.14))
		draw_arc(Vector2.ZERO, size, 0.0, TAU, 40, Color(1.0, 0.75, 0.25, 0.82), 2.0)
	if not _has_artwork:
		_apply_animation_draw_transform()
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
		_draw_direction_detail()
		_reset_animation_draw_transform()
	if telegraph_amount > 0.0:
		var warning := Color(1.0, 0.12, 0.06, 0.3 + telegraph_amount * 0.55)
		draw_arc(Vector2.ZERO, size + 9.0, -PI * 0.5, -PI * 0.5 + TAU * telegraph_amount, 40, warning, 4.0)


func _draw_humanoid() -> void:
	var side := _view_mode() == &"side"
	draw_circle(Vector2(size * 0.08 if side else 0.0, -size * 0.48), size * 0.28, accent_color)
	draw_rect(Rect2(-size * (0.3 if side else 0.38), -size * 0.2, size * (0.65 if side else 0.76), size), body_color, true)
	draw_line(Vector2(-size * 0.3, size * 0.05), Vector2(-size * 0.6, size * 0.55), accent_color, 4.0)
	draw_line(Vector2(size * 0.3, size * 0.05), Vector2(size * 0.62, size * 0.55), accent_color, 4.0)


func _draw_beast() -> void:
	var points := PackedVector2Array([
		Vector2(-size * 0.8, size * 0.35), Vector2(-size * 0.5, -size * 0.35),
		Vector2(0.0, -size * 0.58), Vector2(size * 0.72, -size * 0.12),
		Vector2(size * 0.82, size * 0.42), Vector2(0.0, size * 0.55),
	])
	draw_colored_polygon(points, body_color)
	if _view_mode() != &"up":
		draw_circle(Vector2(size * 0.4, -size * 0.17), 3.0, accent_color)


func _draw_caster() -> void:
	draw_colored_polygon(PackedVector2Array([
		Vector2.ZERO, Vector2(-size * 0.65, size), Vector2(size * 0.65, size),
	]), body_color)
	draw_circle(Vector2.ZERO, size * 0.42, accent_color)
	draw_arc(Vector2.ZERO, size * 0.68, PI, TAU, 20, body_color, 5.0)


func _draw_winged() -> void:
	draw_circle(Vector2.ZERO, size * 0.38, body_color)
	draw_colored_polygon(PackedVector2Array([
		Vector2(-size * 0.25, 0.0), Vector2(-size, -size * 0.55), Vector2(-size * 0.72, size * 0.5),
	]), accent_color)
	draw_colored_polygon(PackedVector2Array([
		Vector2(size * 0.25, 0.0), Vector2(size, -size * 0.55), Vector2(size * 0.72, size * 0.5),
	]), accent_color)
	if _view_mode() != &"up":
		draw_circle(Vector2(size * 0.12, -size * 0.1), 2.5, Color.WHITE)


func _draw_rooted() -> void:
	draw_circle(Vector2.ZERO, size * 0.52, body_color)
	for direction: Vector2 in ROOT_DIRECTIONS:
		draw_line(direction * size * 0.35, direction * size, accent_color, 5.0)
	draw_circle(Vector2.ZERO, size * 0.2, accent_color)


func _draw_direction_detail() -> void:
	match _view_mode():
		&"down":
			draw_circle(Vector2(-size * 0.11, -size * 0.2), maxf(2.0, size * 0.045), Color.WHITE)
			draw_circle(Vector2(size * 0.11, -size * 0.2), maxf(2.0, size * 0.045), Color.WHITE)
		&"up":
			draw_line(Vector2(-size * 0.24, -size * 0.12), Vector2(size * 0.24, -size * 0.12), accent_color.darkened(0.28), maxf(3.0, size * 0.08))
		&"side":
			draw_circle(Vector2(size * 0.2, -size * 0.2), maxf(2.0, size * 0.05), Color.WHITE)
