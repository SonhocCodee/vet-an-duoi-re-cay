class_name HubRuneData
extends Resource

enum Alignment { LIGHT, VOID, ELEMENTAL, TACTICAL }

@export var id: StringName
@export var display_name: String = "Cổ Ấn"
@export_multiline var description: String = ""
@export var alignment: Alignment = Alignment.TACTICAL
