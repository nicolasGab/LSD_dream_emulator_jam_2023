extends MeshInstance3D

var interact_enabled : bool = false

func _ready():
	var tween : Tween = create_tween().set_parallel(false).set_loops()
	tween.tween_property(self, "rotation:y", 6.28319, 2)
	GameState.eventbus.interact_requested.connect(_on_interact_requested)

func _on_area_3d_body_entered(body):
	if body is CharacterBody3D:
		Hud.show_interact_label()
		interact_enabled = true


func _on_area_3d_body_exited(body):
	if body is CharacterBody3D:
		Hud.hide_interact_label()
		interact_enabled = false

func _on_interact_requested():
	if not interact_enabled:
		return
	visible = false
	get_node("Area3D").monitoring = false
	GameState.object_enabled = true
	await get_tree().create_timer(0.5).timeout
	Hud.show_object_label()
	await get_tree().create_timer(1.5).timeout
	Hud.hide_object_label()
	
