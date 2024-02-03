class_name Player
extends CharacterBody3D

const step_divider_walk = 20
const step_divider_run = 10

var move_amount
var walk_amount: float = 0.15
var run_amount: float = 0.4
var movement = Vector3.ZERO
var step_counter = 0
var step_divider = step_divider_walk

@export_group("Internal Nodes")
@export var camera_node: Camera3D
@export var audio: Node3D
@export var main : MeshInstance3D


# Called when the node enters the scene tree for the first time.
func _ready():
	move_amount = walk_amount


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	velocity = move_amount*movement.rotated(Vector3(0,1,0),rotation.y)/delta
	if velocity != Vector3.ZERO:
		step_counter += 1
		if step_counter%step_divider == 0:
			step_counter = 0
			audio.walk()
	move_and_slide()

func _input(event):
	if event.is_action_pressed("move_right"):
		movement.x = 1
	if event.is_action_released("move_right"):
		movement.x = 0
	if event.is_action_pressed("move_left"):
		movement.x = -1
	if event.is_action_released("move_left"):
		movement.x = 0
		
	if event.is_action_pressed("move_forward"):
		movement.z = -1
	if event.is_action_released("move_forward"):
		movement.z = 0
	if event.is_action_pressed("move_backward"):
		movement.z = 1
	if event.is_action_released("move_backward"):
		movement.z = 0
		
	if event.is_action_pressed("run"):
		move_amount = run_amount
		step_divider = step_divider_run
	if event.is_action_released("run"):
		move_amount = walk_amount
		step_divider = step_divider_walk
	if event is InputEventKey and event.keycode == KEY_A and event.is_pressed():
		main.get_node("AnimationPlayer").play("activation_main")
