extends Control

var cursor = load('res://assets/sprites/downarrow.png')

func _ready():
	pass

func _process(delta):
	update()


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
func _draw():
	var p1_s = $"/root/Main".p1_selection
	var x_offsets = [0, 16, 28, 44, 68, 96, 128, 164]
	var pos1 = Vector2(x_offsets[p1_s]+4, 336)
	draw_texture(cursor, pos1, Color.yellow)

	if p1_s > 0:
		var mouse_pos = get_viewport().get_mouse_position()
		mouse_pos = Vector2(floor(mouse_pos.x/8)*8, floor(mouse_pos.y/8)*8)
		draw_texture(cursor_sprites[p1_s], mouse_pos, Color(0.75, 0.75, 0.75, 0.75))


func _input(event):
	if event is InputEventMouseButton and event.pressed:
		if event.button_mask & BUTTON_MASK_LEFT:
			if $HBoxContainer.get_rect().has_point(event.position):
				for i in 8:
					if $HBoxContainer.get_child(i).get_global_rect().has_point(event.position):
						$"/root/Main".p1_selection = i
						break
	elif event is InputEventMouseMotion:
		pass
