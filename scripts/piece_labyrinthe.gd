extends Node3D

signal reach_north
signal reach_south
signal reach_east
signal reach_west

@export var area_north : Area3D
@export var area_south : Area3D
@export var area_east : Area3D
@export var area_west : Area3D

const NORTH_OFFSET : Vector3 = Vector3(10, 0, 0)
const SOUTH_OFFSET : Vector3 = Vector3(-10, 0, 0)
const EAST_OFFSET : Vector3 = Vector3(0, 0, 10)
const WEST_OFFSET : Vector3 = Vector3(0, 0, -10)

var piece_north : bool = false
var piece_south : bool = false
var piece_east : bool = false
var piece_west : bool = false

var pieces_labyrinthe : Array = [
	"res://scenes/pieces_labyrinthe/piece_labyrinthe_1.tscn",
	"res://scenes/pieces_labyrinthe/piece_labyrinthe_2.tscn",
	"res://scenes/pieces_labyrinthe/piece_labyrinthe_3.tscn",
]
var rand = RandomNumberGenerator.new()

func _ready():
	if area_north:
		area_north.body_entered.connect(_on_area_north_area_entered)
	if area_south:
		area_south.body_entered.connect(_on_area_south_area_entered)
	if area_east:
		area_east.body_entered.connect(_on_area_east_area_entered)
	if area_west:
		area_west.body_entered.connect(_on_area_west_area_entered)

func _on_area_north_area_entered(body: Node3D):
	reach_north.emit()
	if not piece_north:
		pop_new_piece(NORTH_OFFSET)
		piece_north = true
	if area_north:
		area_north.body_entered.disconnect(_on_area_north_area_entered)

func _on_area_south_area_entered(body: Node3D):
	reach_south.emit()
	if not piece_south:
		pop_new_piece(SOUTH_OFFSET)
		piece_south = true
	if area_south:
		area_south.body_entered.disconnect(_on_area_south_area_entered)

func _on_area_east_area_entered(body: Node3D):
	reach_east.emit()
	if not piece_east:
		pop_new_piece(EAST_OFFSET)
		piece_east = true
	if area_east:
		area_east.body_entered.disconnect(_on_area_east_area_entered)

func _on_area_west_area_entered(body: Node3D):
	reach_west.emit()
	if not piece_west:
		pop_new_piece(WEST_OFFSET)
		piece_west = true
	if area_west:
		area_west.body_entered.disconnect(_on_area_west_area_entered)

func pop_new_piece(offset: Vector3):
	if prospect(offset):
		return
	var new_pos = global_position + offset
	var scene : PackedScene = load(pieces_labyrinthe[rand.randi_range(0, pieces_labyrinthe.size()-1)])
	var node = scene.instantiate()
	node.position = new_pos
	match offset:
		NORTH_OFFSET:
			node.area_south = null
		SOUTH_OFFSET:
			node.area_north = null
		EAST_OFFSET:
			node.area_west = null
		WEST_OFFSET:
			node.area_east = null
	get_parent().add_child(node)

func prospect(offset: Vector3):
	var prospect_pos = global_position + offset
	for node in get_parent().get_children():
		if node.position == prospect_pos:
			return true
	return false
