class_name PixelCityLayout
extends Resource

@export var environment_asset_root: String = "res://assets/art/pixel/environment/"
@export var world_size: Vector2i = Vector2i(1920, 1280)
@export_range(16, 64, 8) var navigation_cell_size: int = 32
@export var road_rects: Array[Rect2] = []
@export var building_bases: PackedVector2Array = PackedVector2Array()
@export var building_sizes: PackedVector2Array = PackedVector2Array()
@export var building_styles: PackedInt32Array = PackedInt32Array()
@export var tree_positions: PackedVector2Array = PackedVector2Array()
@export var market_positions: PackedVector2Array = PackedVector2Array()
@export var npc_spawn_positions: PackedVector2Array = PackedVector2Array()
@export var patrol_positions: PackedVector2Array = PackedVector2Array()


func is_valid() -> bool:
	return world_size.x > 0 \
		and world_size.y > 0 \
		and building_bases.size() == building_sizes.size() \
		and building_bases.size() == building_styles.size() \
		and npc_spawn_positions.size() >= 20
