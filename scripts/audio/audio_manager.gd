extends Node3D


# Called when the node enters the scene tree for the first time.
func _ready():
	Wwise.load_bank_id(AK.BANKS.INIT)
	Wwise.load_bank_id(AK.BANKS.MAIN)
	Wwise.register_game_obj(self, "audio manager")
	
	set_switches_to_default()



func set_switches_to_default():
	Wwise.set_switch_id(AK.SWITCHES.MATERIAL.GROUP, AK.SWITCHES.MATERIAL.SWITCH.SOFT, self)
