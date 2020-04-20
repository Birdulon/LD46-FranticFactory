extends Node2D

func _ready():
	pass

func spawn_ore():
	if len($DumpZone.get_overlapping_bodies()) <= 0:
		var product = Constants.MATERIAL_SCENES[Constants.MATERIAL_TYPE.iORE].instance()
		var outpos = position
		product.position = outpos
		$"/root/Main/TileMap/Objects".add_child(product)


func _on_Timer_timeout():
	spawn_ore()
