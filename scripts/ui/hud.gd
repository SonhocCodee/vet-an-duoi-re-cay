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

var _refresh_elapsed: float = 0.0

func _process(delta: float) -> void:
    _refresh_elapsed += delta
    if _refresh_elapsed < 0.1:
        return
    _refresh_elapsed = 0.0
    refresh()

func refresh() -> void:
    var hp: float = HubServices.read_number([&"hp", &"current_hp"], 100.0)
    var max_hp: float = maxf(HubServices.read_number([&"max_hp", &"hp_max"], 100.0), 1.0)
    var stamina: float = HubServices.read_number([&"stamina", &"sta", &"current_stamina"], 100.0)
    var max_stamina: float = maxf(HubServices.read_number([&"max_stamina", &"max_sta", &"stamina_max"], 100.0), 1.0)
    var experience: float = HubServices.read_number([&"experience", &"exp", &"current_exp"], 0.0)
    var next_experience: float = maxf(HubServices.read_number([&"experience_to_next", &"exp_to_next", &"next_level_exp"], 100.0), 1.0)
    var level: int = HubServices.read_int([&"level", &"player_level"], 1)
    var class_id: StringName = StringName(HubServices.read_text([&"active_class", &"class_id", &"current_class"], String(HubConstants.CLASS_SWORD_WARDEN)))
    hp_bar.max_value = max_hp
    hp_bar.value = hp
    stamina_bar.max_value = max_stamina
    stamina_bar.value = stamina
    exp_bar.max_value = next_experience
    exp_bar.value = experience
    hp_label.text = "HP %d / %d" % [roundi(hp), roundi(max_hp)]
    stamina_label.text = "STA %d / %d" % [roundi(stamina), roundi(max_stamina)]
    exp_label.text = "EXP %d / %d" % [roundi(experience), roundi(next_experience)]
    level_label.text = "Lv. %d" % level
    class_label.text = str(HubConstants.CLASS_NAMES.get(class_id, String(class_id)))
