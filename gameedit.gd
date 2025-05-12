extends Node2D

var SAVE_FILE='user://levels'
var PLAY_PLACE=16
#@onready var map: TileMapLayer = $objects
@onready var select_item: TileMapLayer = $SelectItem
@onready var place: TileMapLayer = $Place
@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var text_edit: TextEdit = $CanvasLayer/TextEdit


var select_flag=false

var select={
	source_id=0,
	coords=Vector2i.ZERO,
	scene_id=0
}
var current_level=1
var level_array:Array=[]
var current_mouse_arrow

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_init_save_file()
	var levels_file=FileAccess.open('user://levels',FileAccess.READ)
	level_array=levels_file.get_var()
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
		var level_dir=DirAccess.open("user://")
		level_dir.make_dir("level")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	Input.set_custom_mouse_cursor(null)
	var cell_pos=select_item.local_to_map(select_item.to_local(get_global_mouse_position()))
	if select_flag:
		if cell_pos.x<(PLAY_PLACE+1) and cell_pos.y<(PLAY_PLACE+1) and cell_pos.x>0 and cell_pos.y>0:
			Input.set_custom_mouse_cursor(
				current_mouse_arrow,
				Input.CURSOR_ARROW,
				Vector2i.ONE*32
			)
			sprite_2d.position=select_item.map_to_local(cell_pos)
			if not sprite_2d.visible:
				sprite_2d.show()
			if Input.is_action_pressed("nav"):
				if place.tile_set.get_source(select.source_id) is  TileSetScenesCollectionSource:
					var added=false
					for child in place.get_children():
						if place.local_to_map(child.position)==cell_pos and child.get_script().get_global_name()==place.tile_set.get_source(select.source_id).get_scene_tile_scene(select.scene_id).instantiate().get_script().get_global_name():
							added=true							
							break							
					if not added:
						var p=place.tile_set.get_source(select.source_id).get_scene_tile_scene(select.scene_id).instantiate()
						p.position=place.map_to_local(cell_pos)
						place.add_child(p)
						p.set_meta('tile_position',select)
				elif select.source_id==0:
					for child in place.get_children():
						if place.local_to_map(child.position)==cell_pos:
							place.remove_child(child)
					place.set_cell(cell_pos,-1)	
				else:	
					place.set_cell(cell_pos,select.source_id,select.coords,select.scene_id)
			if Input.is_action_pressed("disselect"):
				for child in place.get_children():
					if place.local_to_map(child.position)==cell_pos:
						place.remove_child(child)
				place.set_cell(cell_pos,-1)
				
	
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("nav"):
		var dest=select_item.local_to_map(select_item.to_local(get_global_mouse_position()))
		set_select(dest)
	if event.is_action_pressed("1"):
		set_select(Vector2i(1,(PLAY_PLACE+1)))
	if event.is_action_pressed("2"):
		set_select(Vector2i(3,(PLAY_PLACE+1)))
	if event.is_action_pressed("3"):
		set_select(Vector2i(5,(PLAY_PLACE+1)))
	if event.is_action_pressed("4"):
		set_select(Vector2i(7,(PLAY_PLACE+1)))
func set_select(cell_pos:Vector2i):
	var  dest=cell_pos
	var source_id=select_item.get_cell_source_id(dest)
	if source_id==-1:
		return
	var coords=select_item.get_cell_atlas_coords(dest)
	var scene_id=select_item.get_cell_alternative_tile(dest)
	select={}
	select={
	source_id=source_id,
	coords=coords,
	scene_id=scene_id
	}	
	select_flag=true
	var source=select_item.tile_set.get_source(source_id)
	var atlas_texture = AtlasTexture.new()
	if source is TileSetAtlasSource:
		atlas_texture.atlas = source.texture
		atlas_texture.region = Rect2(source.texture_region_size*coords,source.texture_region_size)
	if source is TileSetScenesCollectionSource:
		var a=source.get_scene_tile_scene(scene_id)
		for child_scene in a.instantiate().get_children():
			if child_scene is AnimatedSprite2D:
				atlas_texture=child_scene.sprite_frames.get_frame_texture('default',0)
				break
	current_mouse_arrow=atlas_texture
	sprite_2d.texture=atlas_texture
	sprite_2d.modulate.a=0.8
		

	
	
	


func _on_button_pressed() -> void:
	var dict={}
	for cell in place.get_used_cells():
		var key=str(place.get_cell_source_id(cell))
		key+=str(place.get_cell_atlas_coords(cell))
		key+=str(place.get_cell_alternative_tile(cell))
		if key in dict:
			dict[key].cells.append(cell)
		else:
			var value={
				source_id=place.get_cell_source_id(cell),
				coords=place.get_cell_atlas_coords(cell),
				scene_id=place.get_cell_alternative_tile(cell),
				cells=[]
			}
			value.cells.append(cell)
			dict.set(key,value)
	for child in place.get_children():
		var cell=place.local_to_map(child.position)
		var tile_position= child.get_meta('tile_position')
		var key=str(tile_position.source_id)
		key+=str(tile_position.coords)
		key+=str(tile_position.scene_id)	
		if key in dict:
			dict[key].cells.append(cell)
		else:
			var value={
				source_id=tile_position.source_id,
				coords=tile_position.coords,
				scene_id=tile_position.scene_id,
				cells=[]
			}
			value.cells.append(cell)
			dict.set(key,value)
	var level_file_name="user://level/"+text_edit.text
	var level_file=FileAccess.open(level_file_name,FileAccess.WRITE)
	level_file.store_var(dict.values())
	level_file.close()
	if level_file_name not in level_array:
		level_array.append(level_file_name)
	var save_file_write=FileAccess.open(SAVE_FILE,FileAccess.WRITE)
	save_file_write.store_var(level_array)
	save_file_write.close()
	current_level=level_array.size()
	text_edit.text=str(current_level)
	_on_clear_pressed()
		
func _on_load_pressed() -> void:
	if FileAccess.file_exists("user://level/"+text_edit.text):
		_on_clear_pressed()
		var level_file=FileAccess.open("user://level/"+text_edit.text,FileAccess.READ)
		var dict=level_file.get_var()
		level_file.close()
		# Godot 4.0及以上版本可以直接获取键值对
		for tile_data in dict:
			for cell in tile_data.cells:
				if place.tile_set.get_source(tile_data.source_id) is  TileSetScenesCollectionSource:
					var p=place.tile_set.get_source(tile_data.source_id).get_scene_tile_scene(tile_data.scene_id).instantiate()
					p.position=place.map_to_local(cell)
					place.add_child(p)
					var tile_data_tmp=tile_data.duplicate()
					tile_data_tmp.erase('cells')
					p.set_meta('tile_position',tile_data_tmp)
				else:
					place.set_cell(cell,tile_data.source_id,tile_data.coords,tile_data.scene_id)
func _on_clear_pressed() -> void:
	for cell in place.get_used_cells():
		place.set_cell(cell,-1)
	for child in place.get_children():
		child.queue_free()


func _on_edit_pressed() -> void:
	get_tree().change_scene_to_file("res://gameedit.tscn") # Replace with function body.


func _on_play_pressed() -> void:
	get_tree().change_scene_to_file("res://game.tscn")
