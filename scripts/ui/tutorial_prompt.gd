class_name TutorialPrompt
extends PanelContainer

func show_step(title: String, description: String) -> void:
    %Title.text = title
    %Description.text = description
    visible = true

func dismiss() -> void:
    visible = false
