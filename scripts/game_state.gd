extends Node

@export var dream_information: Node
@export var gravity : float = 0.6
@export var eventbus: Node
@export var dreams: Array[PackedScene]

var object_enabled : bool = false

func _ready():
	pass

func next_scene():
	if dreams.size() > 0:
		get_tree().change_scene_to_packed(dreams.pick_random())
