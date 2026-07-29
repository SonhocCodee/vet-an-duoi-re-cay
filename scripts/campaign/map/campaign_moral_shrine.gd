class_name CampaignMoralShrine
extends Area2D

signal choice_requested(choice_id: StringName, options: Array[Dictionary])
signal choice_selected(choice_id: StringName, option_id: StringName)

@export var choice_id: StringName = &"campaign_choice"
@export var prompt_text: String = "Đối diện với lựa chọn"
@export var use_external_choice_ui := true

var options: Array[Dictionary] = []
var _available := false
var _awaiting_choice := false
var _nearby_player: Node2D


func _ready() -> void:
	collision_layer = 32
	collision_mask = 3
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	queue_redraw()


func configure(new_choice_id: StringName, new_options: Array[Dictionary], new_prompt: String) -> void:
	choice_id = new_choice_id
	options = new_options
	prompt_text = new_prompt
	queue_redraw()


func set_available(value: bool) -> void:
	_available = value
	visible = value
	monitoring = value
	if not value:
		_awaiting_choice = false
		_nearby_player = null
	queue_redraw()


func resolve(option_id: StringName) -> void:
	if not _available:
		return
	_available = false
	_awaiting_choice = false
	monitoring = false
	GameEvents.interaction_prompt_changed.emit("", false)
	choice_selected.emit(choice_id, option_id)
	queue_redraw()


func _unhandled_input(event: InputEvent) -> void:
	if not _available or _nearby_player == null:
		return
	if not _awaiting_choice and event.is_action_pressed(&"interact"):
		_awaiting_choice = true
		choice_requested.emit(choice_id, options)
		get_viewport().set_input_as_handled()
		return
	if use_external_choice_ui:
		return
	if not _awaiting_choice or event is not InputEventKey or not event.pressed:
		return
	var key_event := event as InputEventKey
	var selected_index := -1
	if key_event.physical_keycode == KEY_1:
		selected_index = 0
	elif key_event.physical_keycode == KEY_2:
		selected_index = 1
	if selected_index < 0 or selected_index >= options.size():
		return
	resolve(StringName(options[selected_index].get("id", "choice_%d" % selected_index)))
	get_viewport().set_input_as_handled()


func _draw() -> void:
	var glow := Color(0.31, 0.88, 0.76, 0.16 if _available else 0.05)
	draw_circle(Vector2.ZERO, 68.0, glow)
	draw_circle(Vector2(0.0, 12.0), 34.0, Color("253d38"))
	draw_colored_polygon(PackedVector2Array([
		Vector2(-28.0, 18.0), Vector2(-18.0, -42.0), Vector2(0.0, -64.0),
		Vector2(18.0, -42.0), Vector2(28.0, 18.0)
	]), Color("52645b"))
	draw_polyline(PackedVector2Array([
		Vector2(-12.0, -30.0), Vector2(0.0, -45.0), Vector2(12.0, -30.0),
		Vector2(0.0, -14.0), Vector2(-12.0, -30.0)
	]), Color("7fe5d0"), 4.0)


func _on_body_entered(body: Node2D) -> void:
	if not _available or not _is_player(body):
		return
	_nearby_player = body
	GameEvents.interaction_prompt_changed.emit("%s · E" % prompt_text, true)


func _on_body_exited(body: Node2D) -> void:
	if body != _nearby_player:
		return
	_nearby_player = null
	_awaiting_choice = false
	GameEvents.interaction_prompt_changed.emit("", false)


func _is_player(body: Node) -> bool:
	return body is PlayerController or body.is_in_group(&"player") or body.name == &"Player"

