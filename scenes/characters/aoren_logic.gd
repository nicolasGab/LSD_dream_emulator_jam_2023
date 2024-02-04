extends Node

@export var animation_player : AnimationPlayer
@export var jambes_container : Node3D

const WALK_DURATION : float = 0.75

var tween : Tween
var rotation_rad: float = -1 :
	set(value):
		rotation_rad = value
		if rotation_rad > 0:
			jambes_container.rotate(Vector3(0,1,0), rotation_rad)

func _ready():
	_on_collision()
	
func _physics_process(delta):
	if rotation_rad >= 0:
		move()

func walk(rotation_rad = 0):
	animation_player.play("walk")
	tween = create_tween().set_parallel(false)
	tween.tween_property(get_parent(), "position", Vector3(1,0,1).rotated(Vector3(0,1,0), rotation_rad), WALK_DURATION*2).as_relative()
	
	tween.tween_callback(animation_player.play.bind("RESET"))

func _on_collision(delta: float = 0.0):
	if tween:
		tween.kill()
	rotation_rad = -1
	animation_player.play("RESET")
	#await get_tree().create_timer(2.0).timeout
	animation_player.play("walk", -1, 1.1)
	rotation_rad = delta

func move():
	var collision = get_parent().move_and_collide(Vector3(0.01,0,0.01).rotated(Vector3(0,1,0), rotation_rad))
	if collision:
		_on_collision(rotation_rad + 0.25)
		#rotation_rad += 0.25
