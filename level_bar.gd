extends HBoxContainer


func _on_next_pressed() -> void:
	EventBus.next_level.emit()


func _on_prev_pressed() -> void:
	EventBus.prev_level.emit()


func _on_edit_pressed() -> void:
	get_tree().change_scene_to_file("res://gameedit.tscn")
