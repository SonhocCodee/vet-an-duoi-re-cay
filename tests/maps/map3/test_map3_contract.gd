extends SceneTree

const MAP_SCENE: String = "res://scenes/maps/map3_ashen_town_hub.tscn"
const REQUIRED_FILES: PackedStringArray = [
    MAP_SCENE,
    "res://scripts/hub/map3_ashen_town_hub.gd",
    "res://scenes/hub/campfire.tscn",
    "res://scenes/hub/forge.tscn",
    "res://scenes/hub/shop.tscn",
    "res://scenes/hub/quest_board.tscn",
    "res://scenes/ui/game_hud.tscn",
    "res://resources/hub/rune_catalog.gd",
]

var _failures: Array[String] = []

func _init() -> void:
    _check_required_files()
    _check_map_contract()
    _check_station_contracts()
    _check_content_counts()
    _finish()

func _check_required_files() -> void:
    for path: String in REQUIRED_FILES:
        _expect(FileAccess.file_exists(path), "Missing Map 3 file: %s" % path)

func _check_map_contract() -> void:
    var scene_text: String = FileAccess.get_file_as_string(MAP_SCENE)
    _expect('[node name="default" type="Marker2D" parent="SpawnPoints"' in scene_text, "Missing default spawn point.")
    _expect('[node name="from_map2" type="Marker2D" parent="SpawnPoints"' in scene_text, "Missing from_map2 spawn point.")
    _expect('[node name="from_east_gate" type="Marker2D" parent="SpawnPoints"' in scene_text, "Missing east gate spawn point.")
    _expect("player.tscn" not in scene_text.to_lower(), "Map 3 must not instance Player.")
    for station_scene: String in ["campfire.tscn", "forge.tscn", "shop.tscn", "quest_board.tscn"]:
        _expect(station_scene in scene_text, "Map 3 does not instance %s." % station_scene)

func _check_station_contracts() -> void:
    var base_text: String = FileAccess.get_file_as_string("res://scripts/hub/hub_station.gd")
    _expect("extends Interactable" in base_text, "Hub stations must use shared Interactable.")
    _expect("func interact(actor: Node)" in base_text, "Hub stations need public interact(actor).")
    for station_scene: String in [
        "res://scenes/hub/campfire.tscn",
        "res://scenes/hub/forge.tscn",
        "res://scenes/hub/shop.tscn",
        "res://scenes/hub/quest_board.tscn",
    ]:
        var scene_text: String = FileAccess.get_file_as_string(station_scene)
        _expect('type="Area2D"' in scene_text, "%s root must be Area2D." % station_scene)
        _expect("collision_layer = 32" in scene_text, "%s must use Interactables layer." % station_scene)
    var campfire_text: String = FileAccess.get_file_as_string("res://scripts/hub/campfire.gd")
    var forge_text: String = FileAccess.get_file_as_string("res://scripts/hub/forge.gd")
    var shop_text: String = FileAccess.get_file_as_string("res://scripts/hub/shop.gd")
    var quest_text: String = FileAccess.get_file_as_string("res://scripts/hub/quest_board.gd")
    _expect("set_checkpoint" in campfire_text and "save_game" in campfire_text and "set_class" in campfire_text, "Campfire core calls are incomplete.")
    _expect("MAX_ENHANCEMENT: int = 10" in forge_text and "SOCKET_COUNT: int = 3" in forge_text, "Forge +10/3-socket contract is missing.")
    _expect("spend_currency" in shop_text and "add_item" in shop_text, "Shop must spend gold and grant items through GameState.")
    _expect("is_quest_accepted" in quest_text and "set_quest_state" in quest_text, "Quest board duplicate guard is missing.")

func _check_content_counts() -> void:
    var rune_count: int = _count_files("res://resources/hub/runes", ".tres")
    var shop_count: int = _count_files("res://resources/items/hub", ".tres")
    var quest_count: int = _count_files("res://resources/hub/quests", ".tres")
    _expect(rune_count == 10, "Expected 10 rune resources, found %d." % rune_count)
    _expect(shop_count == 4, "Expected 4 shop items, found %d." % shop_count)
    _expect(quest_count == 2, "Expected 2 quests, found %d." % quest_count)

func _count_files(directory_path: String, suffix: String) -> int:
    var directory: DirAccess = DirAccess.open(directory_path)
    if directory == null:
        return 0
    var count: int = 0
    directory.list_dir_begin()
    var file_name: String = directory.get_next()
    while not file_name.is_empty():
        if not directory.current_is_dir() and file_name.ends_with(suffix):
            count += 1
        file_name = directory.get_next()
    directory.list_dir_end()
    return count

func _finish() -> void:
    if _failures.is_empty():
        print("Map 3 contract checks passed.")
        quit(0)
        return
    for failure: String in _failures:
        push_error(failure)
    quit(1)

func _expect(condition: bool, message: String) -> void:
    if not condition:
        _failures.append(message)
