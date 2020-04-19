extends KinematicBody2D


var held = false
var grabbed_vector = null
onready var beltmap = $"../BeltTiles"

var dir_vectors = [Vector2(1,0), Vector2(0,-1), Vector2(-1,0), Vector2(0,1)]

const max_speed := 200
export var rungs := 13
export var cx := 2.0  # offset for edge feet
export var cy := 5.0  # offset for edge feet
var foot_vectors
var foot_weights
var total_weight
#var stuck_vec = null
#var stuck_dir = -1  # For going off the end of belts

func _ready():
	total_weight = 1 + rungs*4
	foot_vectors = [Vector2(0, 0)]
	foot_weights = [3]
	for i in rungs:
		foot_vectors.append(Vector2(cx*(i+1), cy))
		foot_vectors.append(Vector2(-cx*(i+1), cy))
		foot_vectors.append(Vector2(cx*(i+1), -cy))
		foot_vectors.append(Vector2(-cx*(i+1), -cy))
		foot_weights.append(1)
		foot_weights.append(1)
		foot_weights.append(1)
		foot_weights.append(1)

func get_belt_direction(tx, ty):
	var xflip = beltmap.is_cell_x_flipped(tx, ty)
	var tp = beltmap.is_cell_transposed(tx, ty)
	return int(tp) + int(xflip)*2

func get_belt_rect(vec):
	var origin = beltmap.map_to_world(vec)
	return Rect2(to_local(origin), Vector2(8, 8))

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	var belt_speed = 8

	var direction = Vector2(0, 0)
	for i in len(foot_vectors):
		var vec = beltmap.world_to_map(position + foot_vectors[i].rotated(rotation))
		if beltmap.get_cell(vec.x, vec.y) >= 0:
			direction += dir_vectors[get_belt_direction(vec.x, vec.y)] * foot_weights[i]
	direction /= total_weight*0.5
	direction.x = clamp(direction.x, -1, 1)
	direction.y = clamp(direction.y, -1, 1)
	move_and_slide(direction * belt_speed)

	if held:  # Cursor drag code
		var ggv = to_global(grabbed_vector)
		var dv = get_global_mouse_position() - ggv
		var dvn = dv.normalized()
		var dvm = dv.length()
		var velo = dvn * min(dvm*dvm, max_speed)
#		move_and_slide(dvn * min(dvm*dvm, max_speed))  # Simple movement
		var collision = move_and_collide(velo*delta)
		if collision and collision.remainder.length_squared()>0:
			if collision.collider is KinematicBody2D:
				var col2 = collision.collider.move_and_collide(collision.remainder)
				if col2 and col2.remainder.length_squared()>0:
					if col2.collider is KinematicBody2D:
						col2.collider.move_and_collide(col2.remainder)
						collision.collider.move_and_collide(col2.remainder)
						move_and_collide(col2.remainder)
				move_and_collide(collision.remainder)
			else:
				move_and_collide(collision.remainder.slide(collision.normal))


func _input(event):
	if event is InputEventMouseButton:
		if not event.pressed:
			held = false
		elif $sprite.get_rect().has_point(to_local(event.position)):
			held = true
			grabbed_vector = to_local(event.position)
