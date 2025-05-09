extends Node2D
var tween: Tween
@onready var map: TileMapLayer = get_parent()
@onready var cell_position: Vector2i = map.local_to_map(position)

func _ready() -> void:
	tween = get_tree().create_tween()
	tween.kill()

func move_to(cell: Vector2i):
	if !map.get_used_rect().has_point(cell):  # 检查是否在地图范围内
		bump(cell_position)  # 碰到边界时反弹
		return
	cell_position = cell
	tween =get_tree(). create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
	tween.tween_property(self, 'position', map.map_to_local(cell), 0.05)

func is_wall(cell: Vector2i) -> bool:
	if !map.get_used_rect().has_point(cell):  # 地图外的也算墙
		return true
	var data = map.get_cell_tile_data(cell)
	return data and data.get_custom_data('is_wall')

func is_player(cell: Vector2i) -> bool:
	for p in get_tree().get_nodes_in_group('player'):
		if p != self and p.cell_position == cell:  # 排除自己
			return true
	return false

func bump(cell: Vector2i):
	return 
	if tween:
		tween.kill()
	tween = get_tree().create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
	var bump_pos = (map.map_to_local(cell) + position) / 2
	tween.tween_property(self, 'position', bump_pos, 0.1)
	tween.tween_property(self, 'position', position, 0.1)

func get_crate(cell: Vector2i) -> Crate:  # 假设你有一个Crate类
	for c in get_tree().get_nodes_in_group('crates'):
		if c.cell_position == cell:
			return c
	return null

func is_dest(cell: Vector2i) -> bool:
	var data = map.get_cell_tile_data(cell)
	return data and data.get_custom_data('is_dest')
