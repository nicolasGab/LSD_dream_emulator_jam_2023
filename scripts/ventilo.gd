extends MeshInstance3D


func _ready():
	var tween : Tween = create_tween().set_parallel(false).set_loops()
	tween.tween_property(self, "rotation:y", 6.28319, 2)