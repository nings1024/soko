extends CanvasLayer



func _on_next_pressed() -> void:
	EventBus.next_level.emit()


func _on_prev_pressed() -> void:
	EventBus.prev_level.emit()


func _on_reset_pressed() -> void:
	EventBus.reset_level.emit()


func _on_undo_pressed() -> void:
	EventBus.undo_move.emit()
