extends Node

var event_id: int = 0

func _ready():
	event_id = Wwise.post_event_id(AK.EVENTS.LIGHT_WIND, AudioManager)
	
func _exit_tree():
	Wwise.stop_event(event_id, 500, AkUtils.AK_CURVE_CONSTANT)
