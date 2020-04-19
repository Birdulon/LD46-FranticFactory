extends Sprite

var held = false
onready var beltmap = $"../BeltTiles"

var dir_vectors = [Vector2(1,0), Vector2(0,-1), Vector2(-1,0), Vector2(0,1)]

export var cx := 5  # offset for edge feet
export var cy := 5  # offset for edge feet
onready var foot_vectors = [Vector2(0,0), Vector2(cx,cy), Vector2(cx,-cy), Vector2(-cx,-cy), Vector2(-cx,cy)]
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
		var vec = beltmap.world_to_map(position + foot_vectors[i].rotated(rotation))
		if beltmap.get_cell(vec.x, vec.y) >= 0:
			direction += dir_vectors[get_belt_direction(vec.x, vec.y)] * foot_weights[i]
	position += direction/total_weight * belt_speed


func _input(event):
	if event is InputEventMouseButton:
		if not event.pressed:
			held = false
		elif get_rect().has_point(to_local(event.position)):
			held = true
	elif event is InputEventMouseMotion:
		if held:
			position += event.relative
