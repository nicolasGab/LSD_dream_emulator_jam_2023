extends OmniLight3D

func _ready():
	var tween : Tween = create_tween().set_parallel(false).set_loops().set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "light_energy", -0.7, 0.1).as_relative().set_delay(4.0)
	tween.tween_property(self, "light_energy", 0.7, 0.05).as_relative()
	tween.tween_property(self, "light_energy", -0.7, 0.06).as_relative().set_delay(4.0)
	tween.tween_property(self, "light_energy", 0.7, 0.05).as_relative()
	tween.tween_property(self, "light_energy", -0.7, 0.07).as_relative().set_delay(0.05)
	tween.tween_property(self, "light_energy", 0.7, 0.05).as_relative()
