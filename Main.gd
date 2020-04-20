extends Node2D
var p1_selection = 0

var map1 = preload("res://maps/Map1.tscn")

var crosshair_16 = preload("res://assets/sprites/cursor_16.tres")
var crosshair_32 = preload("res://assets/sprites/cursor_32.tres")
var crosshair_48 = preload("res://assets/sprites/cursor_48.tres")
var crosshair_64 = preload("res://assets/sprites/cursor_64.tres")
func _ready():
	update_cursor(1)


func update_cursor(size):
	match size:
		0:
			Input.set_custom_mouse_cursor(crosshair_16, Input.CURSOR_ARROW, Vector2(8, 8))
		1:
			Input.set_custom_mouse_cursor(crosshair_32, Input.CURSOR_ARROW, Vector2(16, 16))
		2:
			Input.set_custom_mouse_cursor(crosshair_48, Input.CURSOR_ARROW, Vector2(24, 24))
		3:
			Input.set_custom_mouse_cursor(crosshair_64, Input.CURSOR_ARROW, Vector2(32, 32))


var game_starting_tween = null
func _on_MainSplash_start_pressed():
	if (not game_starting_tween) and splash:
		start_game()

onready var splash = $"GUI/MainSplash"
var map = null
const splash_scroll_time = 0.67
func start_game():
	game_starting_tween = Tween.new()
	add_child(game_starting_tween)
	game_starting_tween.interpolate_property(splash, "anchor_top", 0, 1, splash_scroll_time)
	game_starting_tween.interpolate_property(splash, "anchor_bottom", 1, 2, splash_scroll_time)
	game_starting_tween.interpolate_property($"GUI/Hotbar", "anchor_top", 2, 1, splash_scroll_time)
	game_starting_tween.interpolate_property($"GUI/Hotbar", "anchor_bottom", 2, 1, splash_scroll_time)
	game_starting_tween.start()
	var timer = get_tree().create_timer(splash_scroll_time)
	timer.connect("timeout", self, "remove_splash")
	map = map1.instance()
	add_child_below_node($bgm, map)

func remove_splash():
	remove_child(game_starting_tween)
	game_starting_tween.queue_free()
	game_starting_tween = null
	$GUI.remove_child(splash)
	splash.queue_free()
	splash = null


func get_cursor_snapped_position():
	var mouse_pos = get_viewport().get_mouse_position()
	if $"GUI/Hotbar".get_rect().has_point(mouse_pos):
		return Vector2(-1, -1)
	return Vector2(floor(mouse_pos.x/8)*8, floor(mouse_pos.y/8)*8)

var gameover_splash = preload("res://GameoverSplash.tscn")
func game_over():
	splash = gameover_splash.instance()
	$GUI.add_child(splash)
	splash.connect("start_pressed", self, "_on_MainSplash_start_pressed")
	remove_child(map)
	map.queue_free()
	map = null

const FLOOR = 1
var belt_dirs = [  # v2 is widebelt second tile offset
	{v=Vector2(1, 0), v2=Vector2(0,1), fx=false, fy=false, t=false},
	{v=Vector2(0, 1), v2=Vector2(1,0), fx=true, fy=false, t=true},
	{v=Vector2(-1,0), v2=Vector2(0,1), fx=true, fy=true, t=false},
	{v=Vector2(0,-1), v2=Vector2(1,0), fx=false, fy=true, t=true}
]
var cursor_sprites = [
	null,
	load('res://assets/sprites/belt.tres'),
	load('res://assets/sprites/channel.tres'),
	load('res://assets/sprites/2x2belt.tres'),
	load('res://assets/sprites/smelter.tres'),
	load('res://assets/sprites/forge.tres'),
	load('res://assets/sprites/lathe.tres'),
	load('res://assets/sprites/welder.tres'),
]
var machines = {
	4: load('res://machines/Smelter.tscn'),
	5: load('res://machines/Forge.tscn'),
	6: load('res://machines/Lathe.tscn'),
	7: load('res://machines/Welder.tscn')
}
func _input(event):
	if not map:
		return
	var Tiles: TileMap = map.get_node("TileMap")
	var BeltTiles: TileMap = map.get_node("BeltTiles")
	var belt_types = {1: 0, 2: 4, 3: 1} # 2 for secondary wide (3)
	if event is InputEventMouse:
		if p1_selection <= 0:
			return
		var pos = get_cursor_snapped_position()
		if pos.x < 0:
			return
		var grid_index = BeltTiles.world_to_map(pos + Vector2(4,4))

		if p1_selection <= 3:
			if event.button_mask & BUTTON_MASK_LEFT:
				if event is InputEventMouseMotion:
					var dir = int(fposmod(round((event.relative.angle()/TAU)*4), 4))
					var d = belt_dirs[dir]
					if Tiles.get_cellv(grid_index) == FLOOR:
						if p1_selection == 3:
							if Tiles.get_cellv(grid_index+d.v2) == FLOOR:
								if dir == 0 or dir == 3:
									BeltTiles.set_cellv(grid_index, 1, d.fx, d.fy, d.t)
									BeltTiles.set_cellv(grid_index+d.v2, 2, d.fx, d.fy, d.t)
								else:
									BeltTiles.set_cellv(grid_index, 2, d.fx, d.fy, d.t)
									BeltTiles.set_cellv(grid_index+d.v2, 1, d.fx, d.fy, d.t)
						else:
							BeltTiles.set_cellv(grid_index, belt_types[p1_selection], d.fx, d.fy, d.t)
			elif event.button_mask & BUTTON_MASK_RIGHT:
				if Tiles.get_cellv(grid_index) == FLOOR:
					BeltTiles.set_cellv(grid_index, -1)
				if p1_selection == 3:
					for offset in [Vector2(1,0), Vector2(0,1), Vector2(1,1)]:
						if Tiles.get_cellv(grid_index + offset) == FLOOR:
							BeltTiles.set_cellv(grid_index + offset, -1)
		else:
			if event is InputEventMouseButton:
				if event.button_mask & BUTTON_MASK_LEFT:
					var px_size = cursor_sprites[p1_selection].get_size()
					var cell_size = px_size / 8
					for i in cell_size.x:
						for j in cell_size.y:
							if not check_tile_buildable(grid_index + Vector2(i, j)):
								return
					var target_rect = Rect2(pos, px_size)
					for machine in map.get_node("Machines").get_children():
						if target_rect.intersects(machine.get_global_rect()):
							return false  # Check if any overlap
					var machine = machines[p1_selection].instance()
					machine.position = pos + px_size/2
					map.get_node("Machines").add_child(machine)
				elif event.button_mask & BUTTON_MASK_RIGHT:
					# Delete a machine underneath, but only if it has never worked
					for machine in map.get_node("Machines").get_children():
						if machine.get_global_rect().has_point(event.position):
							if not machine.was_started:
								map.get_node("Machines").remove_child(machine)
								machine.queue_free()
							return false


func check_tile_buildable(grid_index):
	if not map:
		return
	var Tiles: TileMap = map.get_node("TileMap")
	if Tiles.get_cellv(grid_index) != FLOOR:
		return false
	return true
