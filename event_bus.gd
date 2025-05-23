extends Node
signal crate_reached
signal game_sucess
signal next_level
signal prev_level
signal reset_level
signal undo_move


var current_level=0

func _ready() -> void:
	crate_reached.connect(_on_crate_reached)
	
	
func _on_crate_reached():
	for c in get_tree().get_nodes_in_group('crates'):
		if not c.is_reached:
			return
	game_sucess.emit()
