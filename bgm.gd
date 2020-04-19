extends AudioStreamPlayer

const BAR_LENGTH = 0.5
const SEGMENT_TIMES = [1.0, 9.0, 15.0, 33.0, 41.0, 57.0, 83.0]
enum SEGMENT_NAMES {Intro, Bass, Piano, KeyChange, Return, Outro, Fanfare}

func _ready():
	pass

func set_volume(value):
	set_volume_db(linear2db(value))
