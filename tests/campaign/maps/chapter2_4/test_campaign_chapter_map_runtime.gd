extends Node

const SCENES: Array[String] = [
	"res://scenes/maps/campaign/chapter_2_drowned_bells.tscn",
	"res://scenes/maps/campaign/chapter_3_blind_procession.tscn",
	"res://scenes/maps/campaign/chapter_4_erased_archive.tscn",
]

var _failures: Array[String] = []


func _ready() -> void:
	for scene_path: String in SCENES:
		var packed_scene := load(scene_path) as PackedScene
		_expect(packed_scene != null, "Could not load %s" % scene_path)
		if packed_scene == null:
			continue
		var map := packed_scene.instantiate() as CampaignChapterMap
		_expect(map != null, "Root is not CampaignChapterMap: %s" % scene_path)
		if map == null:
			continue
		map.play_intro_on_ready = false
		add_child(map)
		await get_tree().process_frame
		_expect(map.get_node_or_null("SpawnPoints/default") is Marker2D, "Missing default spawn: %s" % scene_path)
		_expect(map.get_node_or_null("EncounterZone1") is Area2D, "Missing encounter zone 1: %s" % scene_path)
		_expect(map.get_node_or_null("EncounterZone2") is Area2D, "Missing encounter zone 2: %s" % scene_path)
		_expect(map.get_node_or_null("EncounterZone3") is Area2D, "Missing encounter zone 3: %s" % scene_path)
		_expect(map.get_node_or_null("MoralShrine") is CampaignMoralShrine, "Missing moral shrine: %s" % scene_path)
		_expect(map.get_node_or_null("BossArena") is Area2D, "Missing boss arena: %s" % scene_path)
		_expect(map.find_child("Player", true, false) == null, "Map contains Player: %s" % scene_path)
		_expect(map.find_child("HUD", true, false) == null, "Map contains HUD: %s" % scene_path)
		map.queue_free()
		await get_tree().process_frame

	await get_tree().process_frame
	if _failures.is_empty():
		print("Campaign chapter 2-4 runtime smoke test passed.")
		get_tree().quit(0)
		return
	for failure: String in _failures:
		push_error(failure)
	get_tree().quit(1)


func _expect(condition: bool, message: String) -> void:
	if not condition:
		_failures.append(message)


