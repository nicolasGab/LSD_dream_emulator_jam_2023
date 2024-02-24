extends Node
@export var camera : Camera3D

# Called when the node enters the scene tree for the first time.
func _ready():
	camera.rotation.z = -0.04
	var tween : Tween = create_tween().set_parallel(false).set_loops().set_trans(Tween.TRANS_SINE)
	tween.tween_property(camera, "rotation:z", 0.04, 2)
	tween.tween_property(camera, "rotation:z", -0.04, 2)
