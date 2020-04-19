extends StaticBody2D

export(Constants.MACHINE_TYPE) var machine_type = Constants.MACHINE_TYPE.SMELTER
export var max_idle_time := 8.0
export var max_input_buffer := 3
var num_inputs = 0
var working := false setget set_working
var idle_time := 0.0
var anim_speed = 1.0



onready var recipe = Constants.RECIPES[machine_type]
func _ready():
	pass

func _process(delta):
	if num_inputs < max_input_buffer:
		suck_materials()
	if num_inputs <= 0:
		self.working = false
		idle_time += delta
	else:
		self.working = true

func set_working(state):
	working = state
	$sprite.material.set_shader_param('rps', int(state)*anim_speed)

func suck_materials():
	for candidate in $SuckArea.get_overlapping_bodies():
		if candidate.has_method('enter_machine'):
			if candidate.material_type == recipe.input:
				pass
