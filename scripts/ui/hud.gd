class_name HubHUD
extends Control

@onready var hp_bar: ProgressBar = %HPBar
@onready var stamina_bar: ProgressBar = %StaminaBar
@onready var exp_bar: ProgressBar = %EXPBar
@onready var hp_label: Label = %HPLabel
@onready var stamina_label: Label = %StaminaLabel
@onready var exp_label: Label = %EXPLabel
@onready var level_label: Label = %LevelLabel
@onready var class_label: Label = %ClassLabel

var _player: PlayerController

func _ready() -> void:
	GameEvents.player_registered.connect(_bind_player)
	GameState.level_changed.connect(_on_level_changed)
	GameState.class_changed.connect(_on_class_changed)
	call_deferred(&"_bind_existing_player")
	_on_level_changed(GameState.level, GameState.experience, GameState.experience_required())
	_on_class_changed(GameState.current_class)

func _bind_existing_player() -> void:
	var candidate: Node = get_tree().get_first_node_in_group(&"player")
	if candidate is PlayerController:
		_bind_player(candidate)

func _bind_player(candidate: Node) -> void:
	if candidate is not PlayerController:
		return
	_player = candidate as PlayerController
	if not _player.health_changed.is_connected(_on_health_changed):
		_player.health_changed.connect(_on_health_changed)
	if not _player.stamina_changed.is_connected(_on_stamina_changed):
		_player.stamina_changed.connect(_on_stamina_changed)
	_on_health_changed(_player.get_health(), _player.get_max_health())
	_on_stamina_changed(_player.get_stamina(), _player.get_max_stamina())

func _on_health_changed(current: float, maximum: float) -> void:
	hp_bar.max_value = maximum
	hp_bar.value = current
	hp_label.text = "HP %d / %d" % [roundi(current), roundi(maximum)]

func _on_stamina_changed(current: float, maximum: float) -> void:
	stamina_bar.max_value = maximum
	stamina_bar.value = current
	stamina_label.text = "STA %d / %d" % [roundi(current), roundi(maximum)]

func _on_level_changed(current_level: int, current_experience: int, required_experience: int) -> void:
	level_label.text = "Lv. %d" % current_level
	exp_bar.max_value = maxf(float(required_experience), 1.0)
	exp_bar.value = current_experience
	exp_label.text = "EXP %d / %d" % [current_experience, required_experience]

func _on_class_changed(class_id: StringName) -> void:
	var names: Dictionary = {
		GameIds.CLASS_BLADEMASTER: "Kiếm Vệ",
		GameIds.CLASS_GUARDIAN: "Hộ Vệ Rễ Cây",
		GameIds.CLASS_SPELLBLADE: "Pháp Kiếm Hư Vô",
		GameIds.CLASS_PRIEST: "Tu Sĩ Tro Tàn",
	}
	class_label.text = String(names.get(class_id, class_id))
	if _player != null:
		var class_index: int = GameIds.PLAYABLE_CLASSES.find(class_id)
		if class_index >= 0:
			_player.call(&"set_player_class", class_index)
