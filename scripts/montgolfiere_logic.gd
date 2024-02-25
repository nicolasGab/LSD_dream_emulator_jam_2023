extends Node

@export var mesh: MeshInstance3D
@export var mesh_valley: MeshInstance3D
@export var player: CharacterBody3D

var material_road: StandardMaterial3D
var material_valley: StandardMaterial3D
var tween : Tween
var event_id: int = 0

func _ready():
	material_road = mesh.mesh.material
	GameState.eventbus.player_velocity_x.connect(scroll_uvs)
	
	event_id = Wwise.post_event_id(AK.EVENTS.LIGHT_WIND, AudioManager)

func scroll_uvs(speed: float = 0.1):
	material_road.uv1_offset.y += speed*0.6
	mesh_valley.mesh.material.uv1_offset.y += speed*0.005

func _physics_process(delta):
	player.move_amount = 0.001
	
func _exit_tree():
	Wwise.stop_event(event_id, 500, AkUtils.AK_CURVE_CONSTANT)
