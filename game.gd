extends Node2D
@onready var map: TileMapLayer = $objects
@onready var color_rect: ColorRect = $CanvasLayer/ColorRect

var levels:Array=[
'''
000011100000
000012100000
000010111100
001113032100
001203911100
001111310000
000001210000
000001110000
000000000000
000000000000
000000000000
000000000000
''',
'''
001111100000
001900100000
001033101110
001030101210
001110111210
000110000210
000100010010
000100011110
000111110000
000000000000
000000000000
000000000000
''',
]
var CRATE =preload("res://Crate.tscn")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _ready() -> void:
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
	var current_level=level
	var level_string:String=levels[current_level].strip_edges()
	var level_lines=level_string.split('\n')	
	for y in range(level_lines.size()):
		for x in range(len(level_lines[y])):
			if level_lines[y][x]=='0':
				continue
			if level_lines[y][x]=='1':
				map.set_cell(Vector2i(x,y),1,Vector2i.ONE*6)		
			if level_lines[y][x]=='2':
				map.set_cell(Vector2i(x,y),1,Vector2i(1,3))			
			if level_lines[y][x]=='3':
				map.set_cell(Vector2i(x,y),2,Vector2i.ZERO,2)
			if level_lines[y][x]=='9':
				map.set_cell(Vector2i(x,y),2,Vector2i.ZERO,1)
	var tweeen=create_tween()
	tweeen.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_SINE)
	tweeen.tween_property(self,'scale',Vector2.ONE,0.2).from(Vector2.ONE*1.05)
	
