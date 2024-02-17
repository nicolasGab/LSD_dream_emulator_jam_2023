extends Node

@export var animation_player : AnimationPlayer
@export var jambes_container : Node3D

const WALK_DURATION : float = 0.75

var tween : Tween
var rng: RandomNumberGenerator = RandomNumberGenerator.new()
var move_lock: bool = false
var rotation_rad: float = -1 :
	set(value):
		rotation_rad = value
		get_parent().rotate(Vector3(0,1,0), rotation_rad)

func _ready():
	_init_movement()

func _init_movement():
	animation_player.play("RESET")
	animation_player.play("walk", -1, 1.1)
	rotation_rad = rng.randf_range(0, 0.5)
	_init_tween()

func _init_tween():
	#tween = create_tween().set_parallel(false).set_loops()
	#tween.tween_property(self, "rotation_rad", rng.randf_range(-0.25, 0.25), 0.1).set_delay(rng.randf_range(1, 2))
	while true:
		if move_lock:
			await get_tree().process_frame
			continue

		get_parent().move_amount = 0.0
		animation_player.play("RESET")
		rotation_rad += rng.randf_range(0, 0.5)
		await get_tree().create_timer(rng.randf_range(1, 2)).timeout

		get_parent().move_amount = 0.01
		animation_player.play("walk", -1, 1.1)
		await get_tree().create_timer(rng.randf_range(1, 2)).timeout

func _on_collision(delta: float = 0.25):
	if tween:
		tween.kill()
	rotation_rad += delta
	run_away()
	
func run_away():
	move_lock = true
	animation_player.play("RESET")
	animation_player.play("run")
	get_parent().move_amount = 0.05
	await get_tree().create_timer(2).timeout
	move_lock = false
	
#func move():
	#if move_lock:
		#return
	#var collision = get_parent().move_and_collide(Vector3(0,0,0.01).rotated(Vector3(0,1,0), rotation_rad))
	#if collision:
		#_on_collision(rotation_rad + 0.25)
		##rotation_rad += 0.25
