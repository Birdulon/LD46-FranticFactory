extends AudioStreamPlayer

const START_DELAY = 1.0
const BAR_LENGTH = 2.0
#const SEGMENT_TIMES = [0.0, 8.0, 16.0, 32.0, 40.0, 56.0, 76.0, 82.0]+1
const SEGMENT_TIMES = [1.0, 9.0, 17.0, 33.0, 41.0, 57.0, 77.0, 83.0]
enum SEGMENT_NAMES {Intro, Bass, Piano, KeyChange, Return, Outro, Ending, Fanfare}

var queue = [SEGMENT_NAMES.Intro, SEGMENT_NAMES.Bass, SEGMENT_NAMES.Bass, SEGMENT_NAMES.Bass]
func _ready():
	pass

func get_bartime(realtime):
	return (realtime - START_DELAY) / BAR_LENGTH

func queue_fanfare():
	var current_bartime = get_bartime(get_playback_position())

func set_volume(value):
	set_volume_db(linear2db(value))
