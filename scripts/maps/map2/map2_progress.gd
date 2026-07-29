class_name Map2Progress
extends RefCounted

const COMBO_FINISHER: StringName = &"combo_finisher"
const DODGE: StringName = &"dodge"
const SKILL_1: StringName = &"skill_1"
const ENCOUNTER_COUNT: int = 4

var active_encounter: int = -1
var enemies_remaining: int = 0
var requirement_met: bool = false
var _completed: Dictionary = {}


func can_activate(encounter_index: int) -> bool:
	if encounter_index < 0 or encounter_index >= ENCOUNTER_COUNT:
		return false
	if is_completed(encounter_index):
		return false
	for previous_index: int in range(encounter_index):
		if not is_completed(previous_index):
			return false
	return active_encounter == -1


func start(encounter_index: int, enemy_count: int) -> bool:
	if not can_activate(encounter_index):
		return false
	active_encounter = encounter_index
	enemies_remaining = maxi(enemy_count, 0)
	requirement_met = encounter_index == 3
	return true


func note_action(action: StringName, during_enemy_telegraph: bool = false) -> bool:
	match active_encounter:
		0:
			requirement_met = requirement_met or action == COMBO_FINISHER
		1:
			requirement_met = requirement_met or (action == DODGE and during_enemy_telegraph)
		2:
			requirement_met = requirement_met or action == SKILL_1
		_:
			pass
	return requirement_met


func note_enemy_died() -> bool:
	enemies_remaining = maxi(enemies_remaining - 1, 0)
	return is_ready_to_complete()


func is_ready_to_complete() -> bool:
	return active_encounter >= 0 and enemies_remaining == 0 and requirement_met


func complete_active() -> int:
	if not is_ready_to_complete():
		return -1
	var completed_index: int = active_encounter
	_completed[completed_index] = true
	active_encounter = -1
	enemies_remaining = 0
	requirement_met = false
	return completed_index


func restore_completed(encounter_index: int) -> void:
	if encounter_index >= 0 and encounter_index < ENCOUNTER_COUNT:
		_completed[encounter_index] = true


func is_completed(encounter_index: int) -> bool:
	return bool(_completed.get(encounter_index, false))
