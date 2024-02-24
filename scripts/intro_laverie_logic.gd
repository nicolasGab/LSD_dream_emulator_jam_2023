extends Node

func _ready():
	await get_tree().create_timer(2.0).timeout
	Hud.show_run_label()
	await get_tree().create_timer(5.0).timeout
	Hud.hide_run_label()
