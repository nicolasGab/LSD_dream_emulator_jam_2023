extends Camera3D

const ROTATION_VALUE = .03

var parent: CharacterBody3D
var desired_rotation : Vector3 

# Called when the node enters the scene tree for the first time.
func _ready():
	parent = get_parent()
	desired_rotation = parent.rotation
	set_fov(80.0)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	parent.rotation = parent.rotation.lerp(desired_rotation, 1)

func _input(event):
	if event.is_action("look_left"):
		rotate_camera(Vector2(1,0))
	if event.is_action("look_right"):
		rotate_camera(Vector2(-1,0))
	if event is InputEventMouseMotion:
		rotate_camera(event.relative, event.velocity)

func rotate_camera(relative_mouvement: Vector2, velocity: Vector2 = Vector2.ONE):
	velocity*=.001
	velocity = abs(velocity)
	var normalized_mouvement = relative_mouvement.normalized()
	desired_rotation.y -= normalized_mouvement.x*ROTATION_VALUE * velocity.x
	desired_rotation.x -= normalized_mouvement.y*ROTATION_VALUE * velocity.y
	desired_rotation.x = min(max(-1.0, desired_rotation.x), 1.25)
	
	
