class_name AriaDialogueData
extends Resource

@export var dialogue_id: StringName
@export var speaker_name: String = "Aria"
@export var lines: Array[String] = []
@export var completion_flag: StringName
@export_file("*.tscn") var next_scene: String = ""
@export var next_spawn_id: StringName
