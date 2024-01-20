extends SubViewport

@export_group("Internal Nodes")
@export var camera : Camera3D
@export var light : SpotLight3D

var rand = RandomNumberGenerator.new()

func _ready():
	animate_stuff()

func animate_stuff():
	var tween = create_tween().set_parallel(false).set_trans(Tween.TRANS_BOUNCE)
	tween.tween_property(light, "light_energy", 3, 0.1).set_delay(rand.randf_range(0.1, 5.0))
	tween.tween_property(light, "light_energy", 1, 0.02)
	tween.tween_callback(animate_stuff)
