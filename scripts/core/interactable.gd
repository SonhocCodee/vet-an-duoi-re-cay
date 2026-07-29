class_name Interactable
extends Area2D

signal interacted(actor: Node)

@export var prompt_text: String = "Tương tác"
@export var enabled: bool = true

func interact(actor: Node) -> void:
	if enabled:
		interacted.emit(actor)

func get_prompt_text() -> String:
	return prompt_text if enabled else ""
