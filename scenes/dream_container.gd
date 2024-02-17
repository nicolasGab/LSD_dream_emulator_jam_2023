extends Node3D

@export var world_env: WorldEnvironment

var tween: Tween
var background_energy_multiplier

func _ready():
	background_energy_multiplier = world_env.environment.background_energy_multiplier
	animate_sky()

func animate_sky():
	tween = create_tween().set_parallel(false).set_loops()
	tween.tween_property(world_env.environment, "background_energy_multiplier", -0.5, 25).as_relative()
	tween.tween_property(world_env.environment, "background_energy_multiplier", 0.2, 10).as_relative()
	tween.tween_property(world_env.environment, "background_energy_multiplier", background_energy_multiplier, 25)
