extends Node

var event_id: int = 0

func _ready():
	await get_tree().create_timer(2.0).timeout
	event_id = Wwise.post_event_id(AK.EVENTS.MUSIQUE_LAVERIE, AudioManager)
	Hud.show_run_label()
	await get_tree().create_timer(5.0).timeout
	Hud.hide_run_label()

	
func _exit_tree():
	Wwise.stop_event(event_id, 500, AkUtils.AK_CURVE_CONSTANT)
