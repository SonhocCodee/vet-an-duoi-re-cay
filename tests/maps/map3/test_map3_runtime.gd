extends SceneTree

class RestActor:
    extends Node
    var restored: bool = false
    func restore_full() -> void:
        restored = true

var _failures: Array[String] = []

func _init() -> void:
    call_deferred(&"_run")

func _run() -> void:
    var state: Node = root.get_node("GameState")
    state.call(&"reset_new_game")
    var hud_scene: PackedScene = load("res://scenes/ui/game_hud.tscn") as PackedScene
    var hud: Control = hud_scene.instantiate() as Control
    root.add_child(hud)
    var map_scene: PackedScene = load("res://scenes/maps/map3_ashen_town_hub.tscn") as PackedScene
    var map: Node2D = map_scene.instantiate() as Node2D
    root.add_child(map)
    await process_frame

    _expect(map.get_node("SpawnPoints/default") is Marker2D, "Default spawn is unavailable at runtime.")
    _expect(map.get_node("Stations").get_child_count() == 4, "Expected four runtime stations.")

    var campfire: CampfireStation = map.get_node("Stations/Campfire") as CampfireStation
    var actor: RestActor = RestActor.new()
    actor.add_to_group(&"player")
    root.add_child(actor)
    var rest_result: Dictionary = campfire.rest(actor)
    _expect(bool(rest_result.get("ok", false)) and actor.restored, "Campfire rest did not restore actor.")
    _expect(bool(campfire.change_class(HubConstants.CLASS_SPELLBLADE).get("ok", false)), "Campfire class change failed.")
    _expect(StringName(state.get("current_class")) == HubConstants.CLASS_SPELLBLADE, "Class was not stored in GameState.")
    state.set("potential_points", 1)
    _expect(bool(campfire.allocate_stat(HubConstants.STAT_VIT).get("ok", false)), "Campfire stat allocation failed.")

    var shop: ShopStation = map.get_node("Stations/Shop") as ShopStation
    state.call(&"add_currency", HubConstants.CURRENCY_GOLD, 100)
    var buy_result: Dictionary = shop.buy_item(&"hp_potion")
    _expect(bool(buy_result.get("ok", false)), "Shop purchase failed.")
    _expect(int(state.call(&"get_item_quantity", &"hp_potion")) == 1, "Purchased item was not added.")

    var board: QuestBoardStation = map.get_node("Stations/QuestBoard") as QuestBoardStation
    var first_quest: Dictionary = board.accept_quest(&"chapter_2_ashen_wind")
    var duplicate_quest: Dictionary = board.accept_quest(&"chapter_2_ashen_wind")
    _expect(bool(first_quest.get("ok", false)), "Quest was not accepted.")
    _expect(bool(duplicate_quest.get("duplicate", false)), "Duplicate quest was not rejected.")

    var forge: ForgeStation = map.get_node("Stations/Forge") as ForgeStation
    forge.force_success_for_tests = true
    for step: int in range(10):
        forge.enhance()
    _expect(forge.enhancement_level == 10, "Forge did not reach +10.")
    _expect(bool(forge.socket_rune(0, &"holy_radiance").get("ok", false)), "Socket 1 failed.")
    _expect(bool(forge.socket_rune(1, &"soul_drainer").get("ok", false)), "Socket 2 failed.")
    _expect(bool(forge.socket_rune(2, &"fortitude").get("ok", false)), "Socket 3 failed.")
    _expect(forge.sockets.size() == 3, "Forge socket count changed.")

    campfire.interact(actor)
    await process_frame
    _expect(hud.get_node("CampfirePanel").visible, "Campfire interaction did not open its panel.")

    hud.queue_free()
    map.queue_free()
    actor.queue_free()
    await process_frame
    _finish()

func _finish() -> void:
    if _failures.is_empty():
        print("Map 3 runtime checks passed.")
        quit(0)
        return
    for failure: String in _failures:
        push_error(failure)
    quit(1)

func _expect(condition: bool, message: String) -> void:
    if not condition:
        _failures.append(message)
