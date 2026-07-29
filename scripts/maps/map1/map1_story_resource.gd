class_name Map1StoryResource
extends Resource

@export var opening_lines: PackedStringArray = []
@export var movement_prompt: String = ""
@export var pillar_prompt: String = ""
@export var weapon_lines: PackedStringArray = []
@export var exit_prompt: String = ""


func get_lines(section: StringName) -> PackedStringArray:
	match section:
		&"opening":
			return opening_lines
		&"weapon":
			return weapon_lines
		_:
			return PackedStringArray()
