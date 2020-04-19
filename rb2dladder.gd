extends RigidBody2D

var held = false
var grabbed_vector = null

onready var beltmap = $"../BeltTiles"

var dir_vectors = [Vector2(1,0), Vector2(0,-1), Vector2(-1,0), Vector2(0,1)]

export var rungs := 12
export var cx := 2.5  # offset for edge feet
export var cy := 5.0  # offset for edge feet
#onready var foot_vectors = [Vector2(0,0), Vector2(cx,cy), Vector2(cx,-cy), Vector2(-cx,-cy), Vector2(-cx,cy)]
var foot_vectors
#var foot_weights = [3, 1, 1, 1, 1]
var total_weight = 7


func _ready():
	friction = 1
	linear_damp = 2
	angular_damp = 100

	total_weight = 1 + rungs*4
	foot_vectors = [Vector2(0, 0)]
	for i in rungs:
		foot_vectors.append(Vector2(cx*(i+1), cy))
		foot_vectors.append(Vector2(-cx*(i+1), cy))
		foot_vectors.append(Vector2(cx*(i+1), -cy))
		foot_vectors.append(Vector2(-cx*(i+1), -cy))


func get_belt_direction(tx, ty):
	var xflip = beltmap.is_cell_x_flipped(tx, ty)
	var tp = beltmap.is_cell_transposed(tx, ty)
	return int(tp) + int(xflip)*2

func get_belt_rect(vec):
	var origin = beltmap.map_to_world(vec)
	return Rect2(to_local(origin), Vector2(8, 8))

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	var belt_speed = delta * 8
func _physics_process(delta):
	var belt_speed = 8 * 24
	var direction = Vector2(0, 0)
	set_applied_force(Vector2(0,0))
	set_applied_torque(0)
	for i in len(foot_vectors):
		var vec = beltmap.world_to_map(position + foot_vectors[i].rotated(rotation))
		if beltmap.get_cell(vec.x, vec.y) >= 0:
			add_force(vec - position, belt_speed*dir_vectors[get_belt_direction(vec.x, vec.y)]/total_weight)
			#direction += dir_vectors[get_belt_direction(vec.x, vec.y)] * foot_weights[i]
#	position += direction/total_weight * belt_speed
	if held:
		var ggv = to_global(grabbed_vector)
		var dv = get_global_mouse_position() - ggv
		add_force(grabbed_vector, dv * dv.abs() *friction*linear_damp)


#func _input_event(_viewport, event, _shape_idx):
#	if event is InputEventMouseButton:
#		held = event.pressed
#		if held:
#			grabbed_vector = to_local(event.position)

func _input(event):
	if held:
		if event is InputEventMouseButton:
			if not event.pressed:
				held = false
#		elif event is InputEventMouseMotion:
##			position += event.relative
#			apply_impulse(grabbed_vector, event.relative * friction)
	elif event is InputEventMouseButton and event.pressed:
		if $SprLadder6.get_rect().has_point(to_local(event.position)):
			held = true
			grabbed_vector = to_local(event.position)
