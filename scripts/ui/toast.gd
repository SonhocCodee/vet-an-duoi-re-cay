class_name ToastMessage
extends PanelContainer

var _queue: Array[String] = []

func _ready() -> void:
    %Timer.timeout.connect(_on_timeout)

func push(message: String) -> void:
    if message.is_empty():
        return
    _queue.append(message)
    if not visible:
        _show_next()

func _show_next() -> void:
    if _queue.is_empty():
        visible = false
        return
    %Message.text = _queue.pop_front()
    visible = true
    %Timer.start()

func _on_timeout() -> void:
    _show_next()
