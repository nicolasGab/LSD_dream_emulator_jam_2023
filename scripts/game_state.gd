extends Node

@export var dream_information: Node
@export var gravity : float = 0.6
@export var eventbus: Node
@export var dreams: Array[PackedScene]
@export var final_scene: PackedScene

var object_enabled : bool = false

func _ready():
	pass

func next_scene():
	if dreams.size() > 0:
		var scene = dreams.pick_random()
		get_tree().change_scene_to_packed(scene)
		dreams.erase(scene)
	else :
		get_tree().change_scene_to_packed(final_scene)
