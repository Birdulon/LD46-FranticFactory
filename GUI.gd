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
	var p1_s_rect = $Hotbar.get_child(p1_s).get_global_rect()
	var pos1 = p1_s_rect.position + Vector2(p1_s_rect.size.x/2-4, -7 + sin(OS.get_ticks_msec()*TAU*0.001))
	draw_texture(cursor, pos1, Color.yellow)

	if p1_s > 0:
		var mouse_pos = get_viewport().get_mouse_position()
		if $Hotbar.get_rect().has_point(mouse_pos):
			return
		mouse_pos = Vector2(floor(mouse_pos.x/8)*8, floor(mouse_pos.y/8)*8)
		draw_texture(cursor_sprites[p1_s], mouse_pos, Color(0.75, 0.75, 0.75, 0.75))


func _input(event):
	if event is InputEventMouseButton and event.pressed:
		if event.button_mask & BUTTON_MASK_LEFT:
			if $Hotbar.get_rect().has_point(event.position):
				for i in 8:
					if $Hotbar.get_child(i).get_global_rect().has_point(event.position):
						$"/root/Main".p1_selection = i
						break
	elif event is InputEventMouseMotion:
		pass
