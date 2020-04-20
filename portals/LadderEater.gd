extends Node2D

func _ready():
	pass

func _process(delta):
	# For now, just delete everything. EVERYTHING.
	for object in $EatZone.get_overlapping_bodies():
		object.get_parent().remove_child(object)
		object.queue_free()
