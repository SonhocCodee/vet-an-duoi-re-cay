extends Node
class_name Map1StoryDirector

signal dialogue_requested(payload: Dictionary)
signal tutorial_requested(payload: Dictionary)
signal opening_finished
signal movement_tutorial_finished
signal weapon_sequence_finished

@export var story: Map1StoryResource
@export var movement_distance_required := 56.0
@export var opening_line_seconds := 2.4

var _player: PlayerController
var _movement_origin := Vector2.ZERO
var _watching_movement := false
var _opening_started := false


func _ready() -> void:
	set_process(false)
	call_deferred("_begin_when_player_is_ready")


func _process(_delta: float) -> void:
	if not _watching_movement or _player == null:
		return
	if _player.global_position.distance_to(_movement_origin) < movement_distance_required:
		return
	_watching_movement = false
	set_process(false)
	movement_tutorial_finished.emit()
	_request_tutorial(&"map1_interact_rune_pillar", story.pillar_prompt)


func bind_pillar(pillar: Map1RunePillar) -> void:
	pillar.weapon_granted.connect(_on_weapon_granted)


func _begin_when_player_is_ready() -> void:
	for _attempt: int in range(180):
		var candidate := get_tree().get_first_node_in_group(&"player")
		if candidate is PlayerController:
			_player = candidate as PlayerController
			break
		await get_tree().physics_frame

	if _player == null:
		push_warning("Map1StoryDirector could not find PlayerController in group 'player'.")
		return
	if GameState.has_flag(GameIds.FLAG_WEAPON_UNLOCKED):
		opening_finished.emit()
		return
	await _play_opening_cutscene()


func _play_opening_cutscene() -> void:
	if _opening_started:
		return
	_opening_started = true
	_player.set_control_enabled(false)
	if _player.has_method("play_state_animation"):
		_player.play_state_animation(&"wake_up")

	var lines := story.get_lines(&"opening")
	for index: int in range(lines.size()):
		_request_dialogue(&"opening", index, lines[index])
		await get_tree().create_timer(opening_line_seconds).timeout

	_player.set_control_enabled(true)
	opening_finished.emit()
	_movement_origin = _player.global_position
	_watching_movement = true
	set_process(true)
	_request_tutorial(&"map1_movement", story.movement_prompt)


func _on_weapon_granted(weapon_id: StringName) -> void:
	var lines := story.get_lines(&"weapon")
	for index: int in range(lines.size()):
		_request_dialogue(&"weapon", index, lines[index], {"weapon_id": weapon_id})
		await get_tree().create_timer(opening_line_seconds).timeout
	weapon_sequence_finished.emit()
	_request_tutorial(&"map1_exit", story.exit_prompt)


func _request_dialogue(
	sequence_id: StringName,
	line_index: int,
	text: String,
	extra: Dictionary = {}
) -> void:
	var dialogue_id := StringName("map1_%s_%02d" % [String(sequence_id), line_index])
	var payload := {
		"map_id": GameIds.MAP_1,
		"dialogue_id": dialogue_id,
		"sequence_id": sequence_id,
		"line_index": line_index,
		"speaker": "Kael",
		"text": text,
		"extra": extra,
	}
	dialogue_requested.emit(payload)
	GameEvents.dialogue_requested.emit(dialogue_id)


func _request_tutorial(tutorial_id: StringName, text: String) -> void:
	var payload := {
		"map_id": GameIds.MAP_1,
		"tutorial_id": tutorial_id,
		"text": text,
	}
	tutorial_requested.emit(payload)
	GameEvents.tutorial_requested.emit(tutorial_id, text)

