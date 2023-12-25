extends CharacterBody3D

@export var light: OmniLight3D
@export var mesh: MeshInstance3D
@export var registry_delay : float = 0.5
@export var vote_delay : float = 20.0
@export var aoren_frequency : float = 0.0

const MAX_LIGHT_ENERGY = 1
const MIN_LIGHT_ENERGY = 0.2
const MAX_AOREN_RANGE = 45
const MIN_AOREN_RANGE = 25
const SYNC_STEPPER = 60
const RELEASE_TIME = 5.0

var frequencies = [
	65.41,
	73.42,
	82.41,
	87.31,
	98.00,
	110.00,
	123.47,
	]
var triade = [
	1,
	1.2599,
	1.4983,
]
var octaves = [
	0,0625,
	0.125,
	0.25,
	0.5,
	1,
	2,
	4,
]
var decompte_votes = {}
var rng = RandomNumberGenerator.new()
var light_energy_target = MIN_LIGHT_ENERGY
var stepper = -160
var speed_modifier = 1
var AOREN_RANGE = 0

func _ready():
	Wwise.register_game_obj(self, name)
	Wwise.set_3d_position(self, transform)
	
	vote_delay = rng.randi_range(5, 30)
	
	initialize_parameters()
	choose_pitch()
	vote()
	
	#modulate_light()
	#modulate_position("x")
	#modulate_position("y")
	#modulate_position("z")
	
func initialize_parameters():
	# init pitch
	aoren_frequency = frequencies[rng.randi_range(0, frequencies.size()-1)]
	Wwise.set_rtpc_value_id(AK.GAME_PARAMETERS.AOREN_FREQUENCY, aoren_frequency, self)
	
	# init range
	AOREN_RANGE = rng.randi_range(MIN_AOREN_RANGE, MAX_AOREN_RANGE)

func choose_pitch():
	# release envelop
	Wwise.post_event_id(AK.EVENTS.RELEASE_AOREN, self)
	await get_tree().create_timer(RELEASE_TIME).timeout
	
	aoren_frequency = aoren_frequency * octaves[rng.randi_range(0, octaves.size()-1)] * triade[rng.randi_range(0, triade.size()-1)]
	aoren_frequency = aoren_frequency if aoren_frequency > 16 else frequencies[0]
	aoren_frequency = aoren_frequency if aoren_frequency < 2100 else frequencies[-1]
	Wwise.set_rtpc_value_id(AK.GAME_PARAMETERS.AOREN_FREQUENCY, aoren_frequency, self)
	
	# trigger envelop
	Wwise.post_event_id(AK.EVENTS.TRIGGER_AOREN, self)

func vote():
	sync_to_aorens_in_range() # vote
	choose_pitch()
	await get_tree().create_timer(vote_delay).timeout
	vote()

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


func register_aoren():
	GameState.dream_information.objects[name] = {
		"position": position,
		"frequency": Wwise.get_rtpc_value_id(AK.GAME_PARAMETERS.AOREN_FREQUENCY, self)
	}
	await get_tree().create_timer(registry_delay).timeout
	register_aoren()

func get_aorens_in_range():
	return GameState.dream_information.objects.values().filter(func(aoren): 
		return position.distance_to(aoren.position) < AOREN_RANGE
	)
	
func sync_to_aorens_in_range():
	#var mean_frequency = 0.0
	var aorens_in_range = get_aorens_in_range()
	for aoren in aorens_in_range:
		decompte_votes[aoren.frequency] = 1 if not decompte_votes[aoren.frequency] else decompte_votes[aoren.frequency] + 1
	aoren_frequency = _get_vote_result()
	
func set_color(R):
	mesh.mesh.material.albedo_color = Color(R, 0.631, max(0.5, 1-R/10))

func _get_vote_result() -> float:
	var temp_max : int = 0
	var max_key : float = frequencies[0]
	for key in decompte_votes:
		if decompte_votes[key] > temp_max:
			temp_max = decompte_votes[key]
			max_key = key
	return max_key
