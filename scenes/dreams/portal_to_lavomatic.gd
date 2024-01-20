extends Area3D

@export var lavomatic_scene : PackedScene

func _on_body_entered(body):
	if not body is Player :
		return
	print("Plqyer entered portal")
	get_tree().change_scene_to_packed(lavomatic_scene)
