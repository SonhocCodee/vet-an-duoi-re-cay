class_name DialoguePanel
extends PanelContainer

signal choice_selected(index: int)
signal dialogue_closed

@onready var choices: VBoxContainer = %Choices

func show_dialogue(speaker: String, line: String, options: Array[String] = []) -> void:
    %Speaker.text = speaker
    %Line.text = line
    for child: Node in choices.get_children():
        child.queue_free()
    for index: int in range(options.size()):
        var button: Button = Button.new()
        button.text = options[index]
        button.pressed.connect(_select_choice.bind(index))
        choices.add_child(button)
    visible = true

func close_dialogue() -> void:
    visible = false
    dialogue_closed.emit()

func _select_choice(index: int) -> void:
    choice_selected.emit(index)
