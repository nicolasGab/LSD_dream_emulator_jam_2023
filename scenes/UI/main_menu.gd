extends Panel

@export var lavomatic_scene : PackedScene

func _on_launch_game_pressed():
	print("Game Started")
	get_tree().change_scene_to_packed(lavomatic_scene)
