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
