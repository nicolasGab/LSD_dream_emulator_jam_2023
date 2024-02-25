extends Node3D

@export var listener: Node

func _ready():
	Wwise.register_game_obj(listener, "player")
	Wwise.set_switch_id(AK.SWITCHES.MATERIAL.GROUP, AK.SWITCHES.MATERIAL.SWITCH.HARD, listener)

func walk():
	Wwise.post_event_id(AK.EVENTS.CHARACTER_FOOTSTEPS, listener)
