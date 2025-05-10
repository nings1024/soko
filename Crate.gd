class_name Crate
extends "res://game_object.gd"
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D

var is_reached:bool=false:
	set(v):
		if is_reached==v:
			return 
		is_reached=v
		animated_sprite_2d.play('reached' if is_reached  else 'default')

func move_to(cell: Vector2i):
	super(cell)
	if is_dest(cell):
		is_reached=true
		EventBus.crate_reached.emit()
	else:
		is_reached=false
func _ready() -> void:
	call_deferred("move_to",cell_position)
