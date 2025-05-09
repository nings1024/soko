class_name Player
extends "res://game_object.gd"
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D

var astar2D=AStarGrid2D.new()
var nav_path=[]

func _ready() -> void:
	animated_sprite_2d.play("move_down")
	astar2D.region=map.get_used_rect()
	astar2D.diagonal_mode=AStarGrid2D.DIAGONAL_MODE_NEVER
	astar2D.update()
	for cell in map.get_used_cells():
		if is_wall(cell):
			astar2D.set_point_solid(cell)
	

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("nav"):
		var dest=map.local_to_map(map.to_local(get_global_mouse_position()))
		if not is_wall(dest):
			astar2D.fill_weight_scale_region(astar2D.region,1)
			for crate:Crate in get_tree().get_nodes_in_group('crates'):
				astar2D.set_point_weight_scale(crate.cell_position,8)
			nav_path=astar2D.get_id_path(cell_position,dest)
			if nav_path:
				nav_path.remove_at(0)
			print(nav_path)
	if tween and tween.is_running():
		return 
	if nav_path and len(nav_path)>0:
		if not try_move(nav_path.pop_front()-cell_position):
			nav_path.clear()
	
	var input = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	if input != Vector2.ZERO:
		try_move(input.round())

# 移动处理函数
func try_move(dir: Vector2i)->bool:
	# 如果水平（x）输入不为0，清除垂直（y）输入
	if dir.x != 0:
		dir.y = 0
	# 如果垂直（y）输入不为0且水平（x）方向没有墙，保持垂直方向
	elif dir.y != 0:
		dir.x = 0
	
	var dest = cell_position + dir
	
	# 检查目标位置是否是墙或玩家
	if is_wall(dest) or is_player(dest):
		bump(dest)
		return false
	
	# 如果目标位置有箱子
	var crate = get_crate(dest)
	if crate:
		var crate_dest = dest + dir
		# 如果箱子的目标位置没有墙、没有玩家并且没有其他箱子
		if !is_wall(crate_dest) and !is_player(crate_dest) and !get_crate(crate_dest):
			crate.move_to(crate_dest)
			move_to(dest)
			return true
	else:
		# 如果没有箱子，直接移动
		move_to(dest)
		return true
	return false

func get_show():
	return animated_sprite_2d.sprite_frames.get_frame_texture('default',1)
