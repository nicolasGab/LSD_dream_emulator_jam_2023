extends Node

@export var tide_pods : Array[TidePod]

var unused_tide_pods : Array[TidePod]
var used_tide_pods : Array[TidePod]

func get_tide_pod() -> TidePod :
	if tide_pods.is_empty():
		printerr("NO TIDE PODS")
		return null
	if unused_tide_pods.is_empty():
		unused_tide_pods = tide_pods.duplicate() as Array[TidePod]
		used_tide_pods.clear()
	var rand_index : int = randi()%unused_tide_pods.size()
	var returned_tide_pod : TidePod= unused_tide_pods[rand_index]
	unused_tide_pods.erase(returned_tide_pod)
	used_tide_pods.append(returned_tide_pod)
	return returned_tide_pod
