extends Node2D
var p1_selection = 0

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

