extends HSlider

func _ready():
	connect("value_changed", $"/root/Main/bgm", "set_volume")
	$"/root/Main/bgm".set_volume(0.5)
