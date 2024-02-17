extends Node

@export var mesh: MeshInstance3D
@export var mesh_valley: MeshInstance3D
@export var player: CharacterBody3D

var material_road: StandardMaterial3D
var material_valley: StandardMaterial3D
var tween : Tween

func _ready():
	material_road = mesh.mesh.material
	GameState.eventbus.player_velocity_x.connect(scroll_uvs)

func scroll_uvs(speed: float = 0.1):
	material_road.uv1_offset.y += speed*0.6
	mesh_valley.mesh.material.uv1_offset.y += speed*0.005

func _physics_process(delta):
	player.move_amount = 0.001
