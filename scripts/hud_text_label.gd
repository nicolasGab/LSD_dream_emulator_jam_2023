@tool
extends Label
var action: String = "lala"

func _get_property_list():
	var properties = []
	properties.append_array([{
			"name" = "action",
			"type" = TYPE_STRING,
			"hint" = PROPERTY_HINT_ENUM,
			"hint_string" = "use_object,interact,jump,run",
			"usage" = PROPERTY_USAGE_DEFAULT 
		}])
	return properties

@export var hud_text: String = "Press {0} to use object"

func _ready():
	text = hud_text.format([OS.get_keycode_string(DisplayServer.keyboard_get_keycode_from_physical(
		ProjectSettings.get_setting("input/"+action).events[0].physical_keycode)
		)
	])
