extends MeshInstance3D

@export var area: Area3D
@export var video_player : VideoStreamPlayer
@export var audio_player : Node

func _ready():
	area.body_entered.connect(_on_body_entered)
	area.body_exited.connect(_on_body_exited)

func _on_body_entered(body: Node3D):
	if not body is CharacterBody3D:
		return
	if not video_player:
		return
	video_player.play()
	audio_player.play()

func _on_body_exited(body: Node3D):
	if not body is CharacterBody3D:
		return
	if not video_player:
		return
	video_player.stop()
	audio_player.stop()
