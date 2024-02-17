extends Control

func _ready():
	if not visible:
		return
	update_menu_visibility()

func _input(event):
	if not event.is_action_pressed("toggle_menu"):
		return
	update_menu_visibility()

func update_menu_visibility():
	visible = not visible
	if visible:
		Input.warp_mouse(DisplayServer.window_get_size()/2.0)
	Input.mouse_mode = Input.MOUSE_MODE_HIDDEN if not visible else Input.MOUSE_MODE_VISIBLE

func _on_quit_pressed():
	get_tree().quit()


func _on_visibility_changed():
	get_tree().paused = self.visible
