extends Node3D

@export var listener: Node

func _ready():
	Wwise.register_game_obj(listener, "player")
	Wwise.set_switch_id(AK.SWITCHES.MATERIAL.GROUP, AK.SWITCHES.MATERIAL.SWITCH.SOFT, listener)

func walk():
	Wwise.post_event_id(AK.EVENTS.CHARACTER_FOOTSTEPS, listener)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
