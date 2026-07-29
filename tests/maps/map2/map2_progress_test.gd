extends SceneTree

const Map2ProgressType = preload("res://scripts/maps/map2/map2_progress.gd")


func _init() -> void:
	_test_encounters_require_strict_order()
	_test_combo_requires_finisher_and_all_kills()
	_test_dodge_only_counts_during_telegraph()
	_test_skill_1_requirement()
	quit(0)


func _test_encounters_require_strict_order() -> void:
	var progress: Map2ProgressType = Map2ProgressType.new()
	assert(not progress.can_activate(1))
	assert(progress.start(0, 2))


func _test_combo_requires_finisher_and_all_kills() -> void:
	var progress: Map2ProgressType = Map2ProgressType.new()
	assert(progress.start(0, 2))
	assert(not progress.note_action(&"attack_light"))
	assert(progress.note_action(&"combo_finisher"))
	assert(not progress.note_enemy_died())
	assert(progress.note_enemy_died())
	assert(progress.complete_active() == 0)


func _test_dodge_only_counts_during_telegraph() -> void:
	var progress: Map2ProgressType = Map2ProgressType.new()
	progress.restore_completed(0)
	assert(progress.start(1, 2))
	assert(not progress.note_action(&"dodge", false))
	assert(progress.note_action(&"dodge", true))


func _test_skill_1_requirement() -> void:
	var progress: Map2ProgressType = Map2ProgressType.new()
	progress.restore_completed(0)
	progress.restore_completed(1)
	assert(progress.start(2, 1))
	assert(not progress.note_action(&"skill_2"))
	assert(progress.note_action(&"skill_1"))
