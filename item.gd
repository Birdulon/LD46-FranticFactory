extends Sprite

var held = false
onready var beltmap = $"../BeltTiles"

var dir_vectors = [Vector2(1,0), Vector2(0,-1), Vector2(-1,0), Vector2(0,1)]

var cx := 5  # offset for edge feet
var cy := 5  # offset for edge feet
var foot_vectors = [Vector2(0,0), Vector2(cx,cy), Vector2(cx,-cy), Vector2(-cx,-cy), Vector2(-cx,cy)]
var foot_weights = [3, 1, 1, 1, 1]
var total_weight = 7
#var stuck_vec = null
#var stuck_dir = -1  # For going off the end of belts


func get_belt_direction(tx, ty):
	var xflip = beltmap.is_cell_x_flipped(tx, ty)
	var tp = beltmap.is_cell_transposed(tx, ty)
	return int(tp) + int(xflip)*2

func get_belt_rect(vec):
	var origin = beltmap.map_to_world(vec)
	return Rect2(to_local(origin), Vector2(8, 8))

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var belt_speed = delta * 8

	var direction = Vector2(0, 0)
	for i in len(foot_vectors):
		var vec = beltmap.world_to_map(position + foot_vectors[i])
		if beltmap.get_cell(vec.x, vec.y) >= 0:
			direction += dir_vectors[get_belt_direction(vec.x, vec.y)] * foot_weights[i]
	position += direction/total_weight * belt_speed

#	var vec = beltmap.world_to_map(position)
#	if stuck_vec:
#		if get_rect().intersects(get_belt_rect(stuck_vec)):
#			position += dir_vectors[stuck_dir] * belt_speed
#			return
#		else:
#			stuck_vec = null
#			stuck_dir = -1

#	var tx = vec[0]
#	var ty = vec[1]
#	if beltmap.get_cell(tx, ty) >= 0:
#		stuck_dir = get_belt_direction(tx, ty)
#		stuck_vec = vec
#		position += dir_vectors[stuck_dir] * belt_speed


func _input(event):
	if event is InputEventMouseButton:
		if not event.pressed:
			held = false
		elif get_rect().has_point(to_local(event.position)):
			held = true
	elif event is InputEventMouseMotion:
		if held:
			position += event.relative
