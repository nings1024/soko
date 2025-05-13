extends CanvasLayer

func _ready() -> void:
	process_mode=Node.PROCESS_MODE_WHEN_PAUSED

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_replay_pressed() -> void:
	get_tree().paused=false
	EventBus.reset_level.emit()
	hide()


func _on_next_level_pressed() -> void:
	get_tree().paused=false
	EventBus.next_level.emit()
	hide()
