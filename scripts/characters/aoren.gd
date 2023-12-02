extends CharacterBody3D

@export var light: OmniLight3D
@export var mesh: MeshInstance3D

const MAX_LIGHT_ENERGY = 1
const MIN_LIGHT_ENERGY = 0.2
const MAX_AOREN_RANGE = 45
const MIN_AOREN_RANGE = 3
const SYNC_STEPPER = 60

var frequencies = [
	55.00,
	58.27,
	61.74,
	65.41,
	69.30,
	73.42,
	77.78,
	82.41,
	87.31,
	92.50,
	98.00,
	103.83,
	110.00,
	116.54,
	123.47,
	130.81,
	138.59,
	146.83,
	155.56,
	164.81,
	174.61,
	185.00,
	196.00,
	207.65,
	220.00,
	233.08,
	246.94,
	261.63,
	277.18,
	293.66,
	311.13,
	329.63,
	349.23,
	369.99,
	392.00,
	415.30,
	440.00,
	466.16,
	493.88,
	523.25,
	554.37,
	587.33,
	622.25,
	659.25,
	698.46,
	739.99,
	783.99,
	830.61,
	880.00,
	932.33,
	987.77,
	1046.50,
	1108.73,
	1174.66,
	1244.51,
	1318.51,
	1396.91,
	1479.98,
	1567.98,
	1661.22
]
var rng = RandomNumberGenerator.new()
var light_energy_target = MIN_LIGHT_ENERGY
var stepper = -160
var speed_modifier = 1
var AOREN_RANGE = 0

func _ready():
	Wwise.register_game_obj(self, name)
	Wwise.set_3d_position(self, transform)
	Wwise.set_rtpc_value_id(AK.GAME_PARAMETERS.AOREN_FREQUENCY, frequencies[rng.randi_range(0, frequencies.size()-1)], self)
	Wwise.post_event_id(AK.EVENTS.TRIGGER_AOREN, self)
	
	AOREN_RANGE = rng.randi_range(MIN_AOREN_RANGE, MAX_AOREN_RANGE)
	
	#modulate_light()
	modulate_position("x")
	modulate_position("y")
	modulate_position("z")
	
	
func modulate_position(axis: String = "y"):
	var tween = create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE).set_parallel(false)
	var delta = rng.randi_range(0.2, 1)
	tween.tween_property(self, "position:"+axis, delta, speed_modifier*rng.randf_range(2, 4)).as_relative()
	tween.tween_property(self, "position:"+axis, -delta, speed_modifier*rng.randf_range(2, 4)).as_relative()
	tween.tween_callback(modulate_position.bind(axis))
	
func modulate_light():
	if light_energy_target == MIN_LIGHT_ENERGY:
		light_energy_target = MAX_LIGHT_ENERGY
	else :
		light_energy_target = MIN_LIGHT_ENERGY
	var tween = create_tween()
	tween.tween_property(light, "light_energy", light_energy_target, 2)
	tween.tween_callback(modulate_light)

func _physics_process(delta):
	stepper += 1
	if stepper < 0 :
		return
	if stepper%10 == 0:
		register_aoren()
	if stepper%SYNC_STEPPER == 0:
		stepper = 0
		sync_to_aorens_in_range()

func register_aoren():
	GameState.dream_information.objects[name] = {
		"position": position,
		"frequency": Wwise.get_rtpc_value_id(AK.GAME_PARAMETERS.AOREN_FREQUENCY, self)
	}

func get_aorens_in_range():
	return GameState.dream_information.objects.values().filter(func(aoren): 
		return position.distance_to(aoren.position) < AOREN_RANGE
	)
	
func sync_to_aorens_in_range():
	var mean_frequency = 0.0
	var aorens_in_range = get_aorens_in_range()
	for aoren in aorens_in_range:
		mean_frequency += aoren.frequency
	mean_frequency /= aorens_in_range.size()
	if rng.randf_range(0, 100) < 0.4:
		#mean_frequency += rng.randi_range(-200, 200)
		#mean_frequency = clamp(mean_frequency, 20, 1500)
		mean_frequency = frequencies[rng.randi_range(0, frequencies.size()-1)]

	Wwise.set_rtpc_value_id(AK.GAME_PARAMETERS.AOREN_FREQUENCY, int(mean_frequency/2)*2, self)
	set_color(min(mean_frequency/100, 1))
	
func set_color(R):
	mesh.mesh.material.albedo_color = Color(R, 0.631, max(0.5, 1-R/10))
