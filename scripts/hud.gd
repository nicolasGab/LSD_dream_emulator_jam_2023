extends Control

@export var object_label: Label
@export var interact_label: Label
@export var run_label: Label

func _ready():
	visible = true

func show_hud():
	visible = true
	
func hide_hud():
	visible = false

func show_object_label():
	object_label.visible = true

func hide_object_label():
	object_label.visible = false

func show_interact_label():
	interact_label.visible = true

func hide_interact_label():
	interact_label.visible = false

func show_run_label():
	run_label.visible = true

func hide_run_label():
	run_label.visible = false
