extends Area2D

var font = preload("res://assets/UI_module_names.tres")

func _process(delta):
	update()

func _draw():
	if not $"..".was_started:
		return
	if $"..".working:
		if $"..".num_inputs > 0:
			draw_string(font, Vector2(5.25, -2.75), str($"..".num_inputs))
		draw_rect(Rect2(6.5, -1, 1, 6), Color.black, true)
		var progress = $"..".work_time/$"..".recipe.time
		draw_rect(Rect2(6.5, 6*(1-progress)-1, 1, 6*progress), Color.green, true)
	else:
		var death_eta = max($"..".max_idle_time - $"..".idle_time, 0)
		draw_string(font, Vector2(5.25, -2.75), '%.0f'%death_eta, Color.red)

