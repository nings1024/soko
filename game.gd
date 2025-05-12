extends Node2D
var SAVE_FILE='user://levels'
@onready var map: TileMapLayer = $game_objects
@onready var color_rect: ColorRect = $CanvasLayer/ColorRect


var CRATE =preload("res://Crate.tscn")
var levels=[]

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _ready() -> void:
	if FileAccess.file_exists(SAVE_FILE):
		var read_file=FileAccess.open(SAVE_FILE,FileAccess.READ)
		levels=read_file.get_var()
		read_file.close()
	change_level(0)
	EventBus.next_level.connect(level_bar_change.bind(1))
	EventBus.prev_level.connect(level_bar_change.bind(-1))

	
func level_bar_change(level_change:int):	
	var level=level_change+EventBus.current_level
	if level<=-1 or level>=levels.size():
		return 
	EventBus.current_level=level
	change_level(level)

func change_level(level:int):
	var tween=create_tween()
	tween.tween_callback(color_rect.show)
	tween.tween_property(color_rect,'color',Color(Color.BLACK,1.0),0.2)
	tween.tween_callback(_load_level.bind(level))
	tween.tween_property(color_rect,'color',Color(Color.BLACK,0.0),0.2)
	tween.tween_callback(color_rect.hide)

func _load_level(level:int):
	map.clear()
	for child in map.get_children():
		child.queue_free()
	if levels.size()<=0:
		get_tree().change_scene_to_file("res://gameedit.tscn")
	else:
		var current_level=level
		var level_file=FileAccess.open(levels[current_level],FileAccess.READ)
		var cell_dict=level_file.get_var()
		level_file.close()
		for tile_data in cell_dict:
			for cell in tile_data.cells:
				if map.tile_set.get_source(tile_data.source_id) is  TileSetScenesCollectionSource:
					var p=map.tile_set.get_source(tile_data.source_id).get_scene_tile_scene(tile_data.scene_id).instantiate()
					p.position=map.map_to_local(cell)
					map.add_child(p)
					p.move_to(cell)
				else:
					map.set_cell(cell,tile_data.source_id,tile_data.coords,tile_data.scene_id)
				
				
		var tweeen=create_tween()
		tweeen.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_SINE)
		tweeen.tween_property(self,'scale',Vector2.ONE,0.2).from(Vector2.ONE*1.05)
		map.scale=Vector2i.ONE
		map.position=Vector2i.ZERO
		var used_rect= map.get_used_rect()
		var max_width=max(used_rect.size.x,used_rect.size.y)
		map.scale=Vector2.ONE*16.0/max_width
		map.position=map.position-((used_rect.position)*64.0*16.0/max_width)+$"Grid Display".position
		$"Grid Display".scale=map.scale
		$"Grid Display".grid_size=Vector2.ONE*max_width
