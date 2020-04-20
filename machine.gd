extends StaticBody2D

export(Constants.MACHINE_TYPE) var machine_type = Constants.MACHINE_TYPE.SMELTER
export var max_idle_time := 8.0
export var max_input_buffer := 3
var num_inputs = 0
var working := false setget set_working
var idle_time := 0.0
var work_time := 0.0
var anim_speed = 1.0
onready var rect = $sprite.get_rect()
onready var width = rect.size.x
onready var height = rect.size.y
onready var w_cells = width/8
onready var h_cells = height/8
onready var beltmap = $"../../BeltTiles"
var surrounding_tilename_indices
var surrounding_tilename_indices_internal
var surrounding_tilename_indices_dir
var was_started = false

var dir_vectors = [Vector2(1,0), Vector2(0,-1), Vector2(-1,0), Vector2(0,1)]
var dir_angles = [0, 90, 0, 90]  # Angles to rotate output by
func get_belt_direction(tx, ty):
	var xflip = beltmap.is_cell_x_flipped(tx, ty)
	var tp = beltmap.is_cell_transposed(tx, ty)
	return int(tp) + int(xflip)*2

onready var recipe = Constants.RECIPES[machine_type]
func _ready():
	var top_left_corner_tile = position - Vector2(width/2-4, height/2-4)
	var tlct = beltmap.world_to_map(top_left_corner_tile)
	surrounding_tilename_indices = []
	surrounding_tilename_indices_internal = []
	surrounding_tilename_indices_dir = []
	# Add all orthogonal cells in clockwise order
	for i in w_cells:
		surrounding_tilename_indices.append(tlct+Vector2(i,-1))
		surrounding_tilename_indices_internal.append(tlct+Vector2(i,0))
		surrounding_tilename_indices_dir.append(1)
	for i in h_cells:
		surrounding_tilename_indices.append(tlct+Vector2(w_cells,i))
		surrounding_tilename_indices_internal.append(tlct+Vector2(w_cells-1,i))
		surrounding_tilename_indices_dir.append(0)
	for i in w_cells:
		surrounding_tilename_indices.append(tlct+Vector2(w_cells-1-i,h_cells))
		surrounding_tilename_indices_internal.append(tlct+Vector2(w_cells-1-i,h_cells-1))
		surrounding_tilename_indices_dir.append(3)
	for i in h_cells:
		surrounding_tilename_indices.append(tlct+Vector2(-1,h_cells-1-i))
		surrounding_tilename_indices_internal.append(tlct+Vector2(0,h_cells-1-i))
		surrounding_tilename_indices_dir.append(2)

func _process(delta):
	if num_inputs < max_input_buffer and recipe.input != Constants.MATERIAL_TYPE.iMOLTEN:
		suck_materials()

	if working:
		if work_time >= recipe.time:
			output()
		else:
			work_time += delta
			return

	if num_inputs <= 0:
		self.working = false
		if not was_started:
			return
		idle_time += delta
		if idle_time >= max_idle_time:
			$"/root/Main".game_over()
		var overspeed = clamp(floor(idle_time/2)*2, 1, 8)
		$sprite.material.set_shader_param('rps', overspeed*anim_speed)
	else:
		self.working = true
		was_started = true
		num_inputs -= 1
		work_time = 0
		idle_time = 0

func output():
	if recipe.output == Constants.MATERIAL_TYPE.iMOLTEN:
		for i in len(surrounding_tilename_indices):
			var ind = surrounding_tilename_indices[i]
			if beltmap.get_cell(ind.x, ind.y) == 4:  # Channel
				var dir = get_belt_direction(ind.x, ind.y)
				if dir != surrounding_tilename_indices_dir[i]:
					continue
				else:
					var xy = ind
					while(true):
						xy += dir_vectors[dir]
						if beltmap.get_cell(xy.x, xy.y) == 4:
							if get_belt_direction(xy.x, xy.y) == dir:
								continue
						else:
							for child in get_parent().get_children():  # Check if a suitable machine is on this tile
								if child.rect.has_point(child.to_local(beltmap.map_to_world(xy) + Vector2(4,4))):
									child.feed(null)
									return
						break
	else:
		for i in len(surrounding_tilename_indices):
			var ind = surrounding_tilename_indices[i]
			var celltype = beltmap.get_cell(ind.x, ind.y)
			if celltype >= 0 and celltype != 4:  # Belt
				# For correct logic on 2wide outputs, we'd have to check for 2 adjacent belts
				# Since we have no time, we'll just throw it out as if there was a second belt
				# If people think they're exploiting the game, they're only playing themselves
				var dir = get_belt_direction(ind.x, ind.y)
				if dir != surrounding_tilename_indices_dir[i]:
					continue
				var product = Constants.MATERIAL_SCENES[recipe.output].instance()
				var outpos = beltmap.map_to_world(surrounding_tilename_indices_internal[i]) + Vector2(4, 4)
				if recipe.output > 2:  # Make a proper check later
					outpos += dir_vectors[surrounding_tilename_indices_dir[i]-1]*4  # the list progresses CCW, we want CW
				product.position = outpos
				product.rotation_degrees = dir_angles[surrounding_tilename_indices_dir[i]]
				outpos -= dir_vectors[surrounding_tilename_indices_dir[i]]  # Hack to make feed exit work
				product.leave_machine(self, outpos)
				$"../../Objects".add_child(product)
				return

func set_working(state):
	working = state
	$sprite.material.set_shader_param('rps', int(state)*anim_speed)

func suck_materials():
	for candidate in $SuckArea.get_overlapping_bodies():
		if candidate.has_method('enter_machine'):
			if candidate.material_type == recipe.input and not candidate.entering_machine:
				var displacement = candidate.position - position
				var nearest_col = clamp(round((displacement.x + width/2 - 4)/8), 0, w_cells-1)
				var nearest_row = clamp(round((displacement.y + height/2 - 4)/8), 0, h_cells-1)
				var port = position + Vector2(nearest_col*8-width/2+4, nearest_row*8-height/2+4)
				candidate.enter_machine(self, port)

func feed(object):
	if object:
		object.get_parent().remove_child(object)
		object.queue_free()
	num_inputs += 1
