extends Node2D

var SAVE_FILE='user://levels'
#@onready var map: TileMapLayer = $objects
@onready var select_item: TileMapLayer = $SelectItem
@onready var place: TileMapLayer = $Place
@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var text_edit: TextEdit = $CanvasLayer/TextEdit

var select_flag=false
var select_Coor=Vector2i.ZERO
var current_level=1
var level_array:Array=[]
var current_mouse_arrow

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_init_save_file()
	var levels_file=FileAccess.open('user://levels',FileAccess.READ)
	level_array=levels_file.get_var()
	print(level_array)
	levels_file.close()
	current_level=level_array.size()
	text_edit.text=str(current_level)
	sprite_2d.hide()

func _init_save_file():
	if FileAccess.file_exists(SAVE_FILE):
		return 
	else:
		var save_file_write=FileAccess.open(SAVE_FILE,FileAccess.WRITE)
		save_file_write.store_var([])
		save_file_write.close()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	Input.set_custom_mouse_cursor(null)
	var cell_pos=select_item.local_to_map(select_item.to_local(get_global_mouse_position()))
	if select_flag:
		if cell_pos.x<12 and cell_pos.y<12 and cell_pos.x>0 and cell_pos.y>0:
			Input.set_custom_mouse_cursor(
				current_mouse_arrow,
				Input.CURSOR_ARROW,
				Vector2i.ONE*32
			)
			sprite_2d.position=select_item.map_to_local(cell_pos)
			if not sprite_2d.visible:
				sprite_2d.show()
			if Input.is_action_pressed("nav"):
				place.set_cell(cell_pos,1,select_Coor)
	else:
		if Input.is_action_pressed("disselect"):
			place.set_cell(cell_pos,-1)
	
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("nav"):
		var dest=select_item.local_to_map(select_item.to_local(get_global_mouse_position()))
		set_select(dest)
	if event.is_action_pressed("disselect"):
		select_flag=false
		Input.set_custom_mouse_cursor(null)
		sprite_2d.hide()
	if event.is_action_pressed("1"):
		set_select(Vector2i(1,12))
	if event.is_action_pressed("2"):
		set_select(Vector2i(3,12))
	if event.is_action_pressed("3"):
		set_select(Vector2i(5,12))
	if event.is_action_pressed("4"):
		set_select(Vector2i(7,12))
func set_select(cell_pos:Vector2i):
	var  dest=cell_pos
	var t=select_item.get_cell_source_id(dest)
	var t1=select_item.get_cell_atlas_coords(dest)
	if t==1:
		select_Coor=t1
		var so:TileSetAtlasSource=select_item.tile_set.get_source(t)
		var atlas_texture = AtlasTexture.new()
		atlas_texture.atlas = so.texture
		atlas_texture.region = Rect2(so.texture_region_size*t1,so.texture_region_size)
		var tile_data:TileData=select_item.get_cell_tile_data(dest)
		current_mouse_arrow=atlas_texture
		sprite_2d.texture=atlas_texture
		sprite_2d.modulate.a=0.8
		select_flag=true


func _on_button_pressed() -> void:
	var dict={}
	for cell in place.get_used_cells():
		if place.get_cell_atlas_coords(cell) in dict:
			dict[place.get_cell_atlas_coords(cell)].append(cell)
		else:
			var array=[]
			array.append(cell)
			dict.set(place.get_cell_atlas_coords(cell),array)
	var level_file_name="user://level"+text_edit.text
	var level_file=FileAccess.open(level_file_name,FileAccess.WRITE)
	level_file.store_var(dict)
	level_file.close()
	if level_file_name not in level_array:
		level_array.append(level_file_name)
	var save_file_write=FileAccess.open(SAVE_FILE,FileAccess.WRITE)
	save_file_write.store_var(level_array)
	save_file_write.close()
	current_level=level_array.size()
	text_edit.text=str(current_level)
		


func _on_load_pressed() -> void:
	if FileAccess.file_exists("user://level"+text_edit.text):
		place.clear()
		var level_file=FileAccess.open("user://level"+text_edit.text,FileAccess.READ)
		var dict=level_file.get_var()
		level_file.close()
		# Godot 4.0及以上版本可以直接获取键值对
		for key in dict:
			var value = dict[key]
			for cell in value:
				place.set_cell(cell,1,key)
