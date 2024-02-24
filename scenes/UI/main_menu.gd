extends Control

@export var lavomatic_scene : PackedScene

func _ready():
	Hud.hide_hud()
	Wwise.post_event_id(AK.EVENTS.HOME_SCENE, AudioManager)

func _on_launch_game_pressed():
	Hud.show_hud()
	Wwise.post_event_id(AK.EVENTS.HOME_SCENE_STOP, AudioManager)
	print("Game Started")
	get_tree().change_scene_to_packed(lavomatic_scene)
