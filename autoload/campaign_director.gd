extends Node

const CHAPTER_MAPS: Dictionary = {
	2: GameIds.MAP_CHAPTER_2,
	3: GameIds.MAP_CHAPTER_3,
	4: GameIds.MAP_CHAPTER_4,
	5: GameIds.MAP_CHAPTER_5,
	6: GameIds.MAP_CHAPTER_6,
	7: GameIds.MAP_CHAPTER_7,
	8: GameIds.MAP_CHAPTER_8,
	9: GameIds.MAP_CHAPTER_9,
	10: GameIds.MAP_CHAPTER_10,
}

func start_from_hub() -> void:
	go_to_chapter(maxi(GameState.current_chapter, 2))

func go_to_chapter(chapter_number: int) -> bool:
	var map_id: StringName = StringName(CHAPTER_MAPS.get(chapter_number, &""))
	if map_id.is_empty():
		return false
	GameEvents.map_change_requested.emit(map_id, GameIds.SPAWN_DEFAULT)
	return true

func complete_chapter(chapter_number: int, map_id: StringName, next_map_id: StringName = &"") -> void:
	if GameState.complete_chapter(chapter_number, map_id):
		GameEvents.chapter_completed.emit(chapter_number, map_id)
	if chapter_number >= 10:
		GameEvents.campaign_completed.emit()
		GameEvents.map_change_requested.emit(GameIds.MAP_TRUE_ENDING, GameIds.SPAWN_DEFAULT)
		return
	var destination: StringName = next_map_id
	if destination.is_empty():
		destination = StringName(CHAPTER_MAPS.get(chapter_number + 1, &""))
	if not destination.is_empty():
		GameEvents.map_change_requested.emit(destination, GameIds.SPAWN_DEFAULT)

func get_chapter_map(chapter_number: int) -> StringName:
	return StringName(CHAPTER_MAPS.get(chapter_number, &""))
